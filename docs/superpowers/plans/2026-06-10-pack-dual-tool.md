# Pack Dual-Tool (Amazon Q + Copilot) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fazer o pack `arquitetura` funcionar por completo no Amazon Q e no GitHub Copilot, com camada `.github/` gerada por script, trilha nova de engenharia, e todos os bugs da auditoria dos installers corrigidos.

**Architecture:** `.amazonq/rules/` permanece canônico (editado à mão); `tools/sync-copilot.sh` gera `.github/` (instructions com frontmatter + path-rewrite, wrappers `.prompt.md` e `SKILL.md` a partir de `tools/manifest.tsv`); `prompts/` vira árvore única tool-neutral; analisadores gravam contexto em destino duplo.

**Tech Stack:** Bash (sync + install.sh), PowerShell 5+ (install.ps1, ASCII-only), Markdown. Sem dependências externas.

**Spec:** `docs/superpowers/specs/2026-06-10-pack-dual-tool-design.md`

**Regras gerais de execução:**
- Working dir: raiz do repo (`/Users/matheus/PESSOAL/arquitetura`).
- NUNCA edite nada dentro de `.github/` à mão — é gerado pela Task 2 e regenerado na Task 9.
- Commit ao final de cada task com a mensagem indicada.
- Testes de installer SEMPRE em `mktemp -d`, nunca dentro do repo do pack.

---

### Task 1: `tools/manifest.tsv`

**Files:**
- Create: `tools/manifest.tsv`

- [ ] **Step 1: Criar o arquivo**

Colunas separadas por TAB real (`\t`), sem header. ATENÇÃO: ao colar, garanta que o separador é TAB e não espaços (o sync script lê com `IFS=$'\t'`).

```tsv
analisador-de-projeto	arquitetura	Analisa o repositorio e gera o contexto tecnico do projeto (roda primeiro em todo repo novo)
arquiteto-de-sistema	arquitetura	Persona de arquiteto senior para visao geral e diagramas de arquitetura do servico
gerador-adr	arquitetura	Gera ADRs em formato MADR com trade-offs explicitos e metrica de validacao
gerador-runbook	arquitetura	Gera runbooks operacionais com failure modes, sintomas e acoes
documentador-fluxo	arquitetura	Documenta fluxos transacionais com sequence diagrams e payloads
grill-doc	arquitetura	Revisor cetico de documentacao: procura furos, inconsistencias e garantias nao implementadas
brainstorm-arquitetural	arquitetura	Parceiro de pensamento pre-ADR: reformula o problema, gera opcoes e converge com trade-offs
designer-ux-controlado	frontend	Decisoes visuais propostas antes de aplicadas, uma por vez
designer-ui-pro-max	frontend	Catalogo de estilos, paletas e padroes visuais para escolher direcao
design-system-arquitetura	frontend	Extensao e auditoria do design system do pack
polidor-ui	frontend	Polimento de UI: microinteracoes, easing e acabamento (estilo Emil Kowalski)
analisador-de-dominio	negocio	Analisa o dominio e gera o contexto de negocio (regras, atores, eventos)
mapeador-de-fluxo-de-negocio	negocio	Mapeia fluxo de negocio com caminho feliz e caminhos tristes em diagrama
catalogo-de-regras	negocio	Cataloga regras de negocio com origem, dono e consequencia
glossario-de-negocio	negocio	Gera o glossario do dominio (linguagem ubiqua)
grill-negocio	negocio	Interrogatorio por fases com ledger para extrair regras nao escritas do dominio
depurador-sistematico	engenharia	Depuracao sistematica em 4 fases: causa raiz com evidencia antes de qualquer correcao
planejador-de-implementacao	engenharia	Transforma spec/decisao em plano de etapas pequenas e independentemente verificaveis
```

(Descrições em ASCII puro de propósito — vão para frontmatter YAML de `.prompt.md`/`SKILL.md` e evitam problemas de encoding em qualquer superfície.)

- [ ] **Step 2: Verificar formato**

Run: `awk -F'\t' 'NF!=3 {print "LINHA RUIM " NR": "$0}' tools/manifest.tsv | head; awk -F'\t' '{print $2}' tools/manifest.tsv | sort | uniq -c`
Expected: nenhuma "LINHA RUIM"; contagem `7 arquitetura, 2 engenharia, 4 frontend, 5 negocio` (total 18).

- [ ] **Step 3: Commit**

```bash
git add tools/manifest.tsv
git commit -m "feat: manifest dos 18 prompts para geracao da camada Copilot"
```

---

### Task 2: `tools/sync-copilot.sh`

**Files:**
- Create: `tools/sync-copilot.sh`

Nota de ordem: o script referencia `engenharia-style.md` e `prompts/engenharia/*`, criados nas Tasks 4-6. Ele só RODA de verdade na Task 9 — aqui criamos e validamos a sintaxe.

- [ ] **Step 1: Criar o script (conteúdo completo)**

````bash
#!/usr/bin/env bash
#
# tools/sync-copilot.sh — gera a camada GitHub Copilot (.github/) a partir do canonico.
#
# Fonte canonica:  .amazonq/rules/*.md  +  tools/manifest.tsv  +  prompts/**
# Gerado (commitado, NUNCA editado a mao):
#   .github/copilot-instructions.md
#   .github/instructions/<rule>.instructions.md     (4 rules)
#   .github/prompts/<slug>.prompt.md                (18 wrappers)
#   .github/skills/<slug>/SKILL.md                  (18 wrappers)
#
# Uso:
#   bash tools/sync-copilot.sh           # (re)gera .github/
#   bash tools/sync-copilot.sh --check   # exit 1 se .github/ commitado divergir do gerado
#
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$PACK_DIR/tools/manifest.tsv"
RULES=(architecture-style frontend-style negocio-style engenharia-style)

MODE="generate"
if [ "${1:-}" = "--check" ]; then MODE="check"; fi

if [ "$MODE" = "check" ]; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  OUT="$TMP/.github"
else
  OUT="$PACK_DIR/.github"
  rm -rf "$OUT/instructions" "$OUT/prompts" "$OUT/skills"
fi
mkdir -p "$OUT/instructions" "$OUT/prompts" "$OUT/skills"

# ── 1) Rules canonicas → instructions ───────────────────────────────────────
# Reescreve apenas os paths das 4 rules de estilo. Paths de contexto
# (project/business-context) NAO sao reescritos: o texto canonico cita os dois.
rewrite_for_copilot() {
  sed \
    -e 's|\.amazonq/rules/architecture-style\.md|.github/instructions/architecture-style.instructions.md|g' \
    -e 's|\.amazonq/rules/frontend-style\.md|.github/instructions/frontend-style.instructions.md|g' \
    -e 's|\.amazonq/rules/negocio-style\.md|.github/instructions/negocio-style.instructions.md|g' \
    -e 's|\.amazonq/rules/engenharia-style\.md|.github/instructions/engenharia-style.instructions.md|g' \
    -e 's|Lido automaticamente pelo Amazon Q em todo workspace que contenha esta pasta\.|Aplicado automaticamente pelo GitHub Copilot em todo repositorio que contenha esta pasta (frontmatter `applyTo`).|g'
}

for r in "${RULES[@]}"; do
  src="$PACK_DIR/.amazonq/rules/$r.md"
  [ -f "$src" ] || { echo "ERRO: rule canonica ausente: $src" >&2; exit 1; }
  {
    printf -- '---\napplyTo: "**"\nexcludeAgent: "code-review"\n---\n'
    rewrite_for_copilot < "$src"
  } > "$OUT/instructions/$r.instructions.md"
done

# ── 2) Entry point ──────────────────────────────────────────────────────────
cat > "$OUT/copilot-instructions.md" <<'EOF'
# Pack de documentacao arquitetural — instrucoes para o GitHub Copilot

> GERADO por `tools/sync-copilot.sh` a partir de `.amazonq/rules/` — NAO edite a mao.
> Este repositorio usa o pack `arquitetura` com Amazon Q **e** GitHub Copilot.

## Como este repo esta organizado para o Copilot

- As regras completas estao em `.github/instructions/*.instructions.md` (aplicadas
  automaticamente): `architecture-style` (trilha tecnica), `negocio-style` (negocio),
  `frontend-style` (HTML/CSS), `engenharia-style` (disciplinas de engenharia).
- A metodologia de cada tarefa mora em `prompts/<trilha>/<nome>.md`. As tabelas de
  gatilhos nas instructions mapeiam a intencao do usuario para o prompt certo. Quando
  um gatilho casar, LEIA o arquivo do prompt e siga TODO o processo descrito, fase por
  fase — nunca achate fases interativas em checklist ou despejo de perguntas.
- Atalhos: cada prompt existe como slash command (`.github/prompts/`, use `/<slug>` no
  chat das IDEs) e como Agent Skill (`.github/skills/`, Copilot CLI).

## Gate de contexto (resumo)

Antes de gerar documentacao, o contexto do projeto precisa existir em DOIS arquivos de
mesmo conteudo: `.github/instructions/project-context.instructions.md` (Copilot) e
`.amazonq/rules/project-context.md` (Amazon Q). Se nenhum existir, rode primeiro
`prompts/arquitetura/analisador-de-projeto.md` (`/analisador-de-projeto`). Se so um
existir, espelhe no outro. Doc de NEGOCIO exige tambem o par `business-context`
(criado por `prompts/negocio/analisador-de-dominio.md`).

## Regra inegociavel

Todo diagrama segue a convencao Mermaid da instruction `architecture-style` secao 1
(diagram-viewer + classDefs com cores fixas). E a unica regra rigida de visual.
EOF

# ── 3) Wrappers a partir do manifest ───────────────────────────────────────
count=0
while IFS=$'\t' read -r slug trilha desc; do
  [ -z "$slug" ] && continue
  case "$slug" in \#*) continue ;; esac
  canonical="prompts/$trilha/$slug.md"
  if [ ! -f "$PACK_DIR/$canonical" ]; then
    echo "ERRO: manifest aponta para $canonical, que nao existe." >&2
    exit 1
  fi

  cat > "$OUT/prompts/$slug.prompt.md" <<EOF
---
description: "$desc"
---

Siga TODO o processo descrito em \`$canonical\` (na raiz deste repositorio), fase por
fase, na ordem em que esta escrito.

Regras de execucao:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o
  prompt pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- As instructions deste repositorio (\`.github/instructions/\`) continuam valendo.
EOF

  mkdir -p "$OUT/skills/$slug"
  cat > "$OUT/skills/$slug/SKILL.md" <<EOF
---
name: $slug
description: $desc
---

Siga TODO o processo descrito em \`$canonical\` (na raiz deste repositorio), fase por
fase, na ordem em que esta escrito.

Regras de execucao:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o
  prompt pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- As instructions deste repositorio (\`.github/instructions/\`) continuam valendo.
EOF
  count=$((count + 1))
done < "$MANIFEST"

# ── 4) Resultado ────────────────────────────────────────────────────────────
if [ "$MODE" = "check" ]; then
  if diff -r "$PACK_DIR/.github" "$OUT" > /dev/null 2>&1; then
    echo "OK: .github/ em sincronia com o canonico."
  else
    echo "DRIFT: .github/ difere do que seria gerado. Rode: bash tools/sync-copilot.sh" >&2
    diff -r "$PACK_DIR/.github" "$OUT" 2>&1 | head -40 >&2 || true
    exit 1
  fi
else
  echo "Gerado: ${#RULES[@]} instructions + copilot-instructions.md + $count prompt files + $count skills em $OUT"
fi
````

- [ ] **Step 2: Tornar executável e validar sintaxe**

Run: `chmod +x tools/sync-copilot.sh && bash -n tools/sync-copilot.sh && echo SINTAXE-OK`
Expected: `SINTAXE-OK`

- [ ] **Step 3: Rodar AGORA deve falhar com erro claro (engenharia-style ainda não existe)**

Run: `bash tools/sync-copilot.sh; echo "exit=$?"`
Expected: `ERRO: rule canonica ausente: .../engenharia-style.md` e `exit=1`. Isso confirma a validação de pré-condições. (Se passar, algo está errado.)

- [ ] **Step 4: Commit**

```bash
git add tools/sync-copilot.sh
git commit -m "feat: gerador da camada Copilot (.github/) a partir do canonico"
```

---

### Task 3: Fixes + gate duplo nas rules canônicas existentes

**Files:**
- Modify: `.amazonq/rules/architecture-style.md` (linhas 3, 9-31, 43, 151)
- Modify: `.amazonq/rules/negocio-style.md` (linhas 3 [conferir], 10-36, 45-46, 49)
- Modify: `.amazonq/rules/frontend-style.md` (header — conferir frase de auto-load)

- [ ] **Step 1: architecture-style.md — padronizar frase de auto-load (linha 3)**

Old:
```
> Este arquivo é lido automaticamente pelo Amazon Q em todo workspace que contenha esta pasta.
```
New:
```
> Lido automaticamente pelo Amazon Q em todo workspace que contenha esta pasta.
```
(A frase padronizada é o alvo exato do sed do sync. As outras rules devem usar a MESMA frase.)

- [ ] **Step 2: architecture-style.md — gate duplo (substituir as linhas 9-31 inteiras, do `## GATE` até a linha `isso **sobrescreve** qualquer exemplo...`)**

New (substitui o bloco todo):

````markdown
## GATE OBRIGATÓRIO — contexto do projeto

**Antes de qualquer geração de documentação**, verifique se o contexto do projeto existe.
Ele mora em DOIS arquivos com o mesmo conteúdo (um por ferramenta de assistente):

- `.amazonq/rules/project-context.md` (lido pelo Amazon Q)
- `.github/instructions/project-context.instructions.md` (lido pelo GitHub Copilot; começa com frontmatter `applyTo: "**"`)

```
Pedido de geração chega
        ↓
os dois arquivos de contexto existem?
        │
        ├── NENHUM existe → carregue `prompts/arquitetura/analisador-de-projeto.md` PRIMEIRO.
        │        Pare a geração original. Conclua a análise. Peça confirmação.
        │        Depois disso o usuário pode reinvocar o pedido original.
        │
        ├── SÓ UM existe (repo instalado antes da era dual-tool) → espelhe o conteúdo no
        │        destino que falta (com/sem o frontmatter conforme o lado) e prossiga.
        │
        └── AMBOS existem → leia COMPLETO o do seu lado. Use-o como fonte de verdade para:
                 • Nome do serviço (não use "Liquidação Transacional")
                 • Stack real (não copie a do exemplo)
                 • Padrões que NÃO se aplicam (não documente o que está listado como "não usado")
                 • SLO, criticidade, glossário do domínio
                 Depois prossiga normalmente com o prompt indicado pelo gatilho.
```

O contexto do projeto tem **peso de regra**, igual a este arquivo. Quando ele afirma "não usamos Outbox",
isso **sobrescreve** qualquer exemplo em `templates/` que mencione Outbox.
````

- [ ] **Step 3: architecture-style.md — linha 43, célula da tabela §0**

Old (célula da primeira coluna):
```
| `.amazonq/rules/project-context.md` | **REGRA por projeto** (gerada pelo analisador) |
```
New:
```
| Contexto do projeto: `.amazonq/rules/project-context.md` + `.github/instructions/project-context.instructions.md` | **REGRA por projeto** (gerada pelo analisador, nos dois destinos) |
```
(Resto da linha — coluna "Como usar" — fica como está.)

- [ ] **Step 4: architecture-style.md — linha 151, âncora condicional**

Old:
```
Todo HTML novo segue este esqueleto (confirma o padrão demonstrado em `templates/01-visao-geral.html` em diante). Detalhamento em `frontend-style.md`.
```
New:
```
Todo HTML novo segue este esqueleto (demonstrado em `templates/01-visao-geral.html` quando o pack foi instalado com `--with-examples`; sem os exemplos, o esqueleto abaixo é a referência completa). Detalhamento em `frontend-style.md`.
```

- [ ] **Step 5: negocio-style.md — gate duplo (substituir linhas 10-36, do `## GATE` até `...sobrescreve qualquer exemplo em templates/.`)**

New (mesma estrutura do Step 2, trocando os nomes — bloco completo):

````markdown
## GATE OBRIGATÓRIO — contexto de negócio

Antes de gerar **qualquer doc de negócio** (exceto os dois prompts que o criam — ver abaixo),
verifique se o contexto de negócio existe. Ele mora em DOIS arquivos com o mesmo conteúdo:

- `.amazonq/rules/business-context.md` (lido pelo Amazon Q)
- `.github/instructions/business-context.instructions.md` (lido pelo GitHub Copilot; começa com frontmatter `applyTo: "**"`)

```
Pedido de doc de negócio chega
        ↓
os dois arquivos de contexto de negócio existem?
        │
        ├── NENHUM existe → carregue prompts/negocio/analisador-de-dominio.md PRIMEIRO.
        │        Pare a geração. Conclua a análise de domínio. Peça confirmação.
        │        Depois o usuário reinvoca o pedido original.
        │
        ├── SÓ UM existe (repo da era Q-only) → espelhe o conteúdo no destino que falta
        │        (com/sem o frontmatter conforme o lado) e prossiga.
        │
        └── AMBOS existem → leia COMPLETO o do seu lado. É a fonte de verdade de NEGÓCIO:
                 • glossário do domínio (linguagem ubíqua)
                 • regras de negócio confirmadas + dono + consequência
                 • atores/papéis e desfechos de negócio
                 Prossiga com o prompt indicado pelo gatilho (§2).
```

**Exceções ao gate** (rodam JUSTAMENTE pra popular o contexto de negócio):
- `analisador-de-dominio.md` — cria/atualiza os dois arquivos.
- `grill-negocio.md` — refina os arquivos inline durante a sessão (mantenha os dois em sincronia).

**Pré-requisito recomendado:** o contexto do projeto (trilha técnica) deve existir — o analisador
de domínio o consome. Se faltar, sugira rodar `analisador-de-projeto.md` antes; mas é possível
seguir a partir do código.

O contexto de negócio tem **peso de regra**, igual a esta. Quando define um termo ou regra,
**sobrescreve** qualquer exemplo em `templates/`.
````

- [ ] **Step 6: negocio-style.md — tabela §0: dual paths + remover linha pendurada**

Linha 45, old → new (só a primeira célula muda):
```
| `.amazonq/rules/business-context.md` | ...
```
→
```
| Contexto de negócio: `.amazonq/rules/business-context.md` + `.github/instructions/business-context.instructions.md` | ...
```
Linha 46, mesma transformação para `project-context.md` (+ `.github/instructions/project-context.instructions.md`).
Linha 49 — **DELETAR a linha inteira** (referência a `templates/negocio/*`, diretório que nunca existiu):
```
| `templates/negocio/*` (exemplos de negócio) | **EXEMPLO** | Forma, não substância. Adapte ao domínio real. |
```

- [ ] **Step 7: frontend-style.md — padronizar frase de auto-load**

Run: `grep -n "Amazon Q" .amazonq/rules/frontend-style.md | head -5`
Se o header tiver variação da frase de auto-load, padronize para EXATAMENTE:
`> Lido automaticamente pelo Amazon Q em todo workspace que contenha esta pasta.`
Se não houver frase de auto-load, adicione-a como segunda linha do arquivo (após o H1).

- [ ] **Step 8: Verificar**

Run: `grep -c "instructions.md" .amazonq/rules/architecture-style.md .amazonq/rules/negocio-style.md && grep -rn "templates/negocio" .amazonq/ ; echo "grep-exit=$?"`
Expected: contagens ≥ 1 em ambos; nenhuma ocorrência de `templates/negocio` (grep-exit=1).

- [ ] **Step 9: Commit**

```bash
git add .amazonq/rules/
git commit -m "feat: gate duplo de contexto + fixes de referencias penduradas nas rules"
```

---

### Task 4: Rule canônica `engenharia-style.md`

**Files:**
- Create: `.amazonq/rules/engenharia-style.md`

- [ ] **Step 1: Criar o arquivo (conteúdo completo)**

```markdown
# Engineering Discipline Style Guide — trilha `engenharia`

> Lido automaticamente pelo Amazon Q em todo workspace que contenha esta pasta.
> Governa a **trilha de engenharia** do pack: disciplinas de processo portadas do superpowers
> (debugging sistemático, planejamento de implementação, verificação antes de concluir).
> **Complementa** as demais rules — vale para QUALQUER tarefa de código, não só documentação.

---

## 0. STATUS DESTA TRILHA

| Pasta / arquivo | Status | Como usar |
|---|---|---|
| `.amazonq/rules/engenharia-style.md` (esta) | **REGRA** | Disciplina de conclusão sempre ativa + hooks da trilha. |
| `prompts/engenharia/*.md` | **REGRA** (metodologia) | Carregue conforme a tabela de hooks § 1. |

**Sem gate de contexto:** as disciplinas desta trilha funcionam em qualquer repositório,
com ou sem contexto de projeto. Quando o contexto existir, use-o.

---

## 1. Hooks — gatilho → prompt (engenharia)

| Quando o usuário pedir / mencionar | Carregue |
|---|---|
| "debugga", "investiga esse bug", "não funciona", "causa raiz", "por que está quebrando", "teste falhando" | `prompts/engenharia/depurador-sistematico.md` |
| "planeja a implementação", "plano de implementação", "quebra em etapas", "como implementar isso passo a passo" | `prompts/engenharia/planejador-de-implementacao.md` |

Pedido ambíguo entre investigar e implementar ("conserta o X") → primeiro o depurador
(causa raiz demonstrada), depois proponha o planejador se a correção for maior que um fix pontual.

---

## 2. Disciplina de conclusão (sempre ativa)

Porte destilado de `superpowers:verification-before-completion`. Vale para TODA resposta
que afirme progresso ou conclusão, em qualquer trilha deste pack:

- **Nunca afirme "pronto", "corrigido", "funcionando" ou "passando" sem ter rodado o comando
  de verificação na MESMA resposta e mostrado o output real.**
- Teste falhando é reportado como **falhando**, com o output. Não minimize, não prometa.
- Passo pulado é **declarado** ("não rodei X porque Y") — nunca omitido.
- Build/teste que você não pode executar → diga explicitamente que a verificação está
  pendente e qual comando o usuário deve rodar.
- Evidência ANTES de afirmação. Sem exceção.

---

## 3. O que esta trilha NÃO cobre

- Convenções de documentação (trilhas `arquitetura`/`negocio`) e visual (`frontend`).
- Orquestração de subagentes/worktrees — específica de outros harnesses; não tente emular.
```

- [ ] **Step 2: Commit**

```bash
git add .amazonq/rules/engenharia-style.md
git commit -m "feat: rule da trilha engenharia (hooks + disciplina de conclusao)"
```

---

### Task 5: `prompts/engenharia/depurador-sistematico.md`

**Files:**
- Create: `prompts/engenharia/depurador-sistematico.md`

- [ ] **Step 1: Criar o arquivo (conteúdo completo)**

```markdown
# Prompt — Depurador Sistemático

> ## STATUS
>
> Este prompt é referenciado pela rule `.amazonq/rules/engenharia-style.md` § 1.
>
> Debugging é metodologia de investigação — não produz HTML. O output é a causa raiz
> demonstrada com evidência + o fix mínimo verificado.

Clona o comportamento da skill `superpowers:systematic-debugging`.

## Quando usar
- "debugga", "investiga esse bug", "não funciona", "causa raiz", "teste falhando"
- SEMPRE que houver comportamento inesperado, antes de propor qualquer correção.
- Especialmente quando a tentação é "deve ser X, deixa eu trocar e ver se resolve".

## Persona

Você é um **investigador de causa raiz** — não um chutador de correções. Você assume que:

- O sintoma raramente aponta direto para a causa.
- Correção sem causa raiz demonstrada é aposta — e aposta em produção custa caro.
- A mensagem de erro contém mais informação do que a primeira leitura extraiu.
- "Funcionou depois que mexi" sem explicação = bug ainda vivo, só escondido.

## REGRA DE OURO

**É PROIBIDO propor correção antes de ter evidência da causa raiz.**
Se o usuário pedir "só conserta logo", responda: "Proposta sem causa raiz é aposta.
A Fase 1 leva poucos minutos: [primeira ação/pergunta]". Sem exceção.

## Metodologia — 4 fases com gate

### Fase 1 — Reproduzir e ler
1. Reproduza o problema OU obtenha o output/stack trace real (não a paráfrase do usuário).
2. Leia a mensagem de erro INTEIRA, incluindo inner exceptions e o primeiro frame do código do projeto.
3. Anote: o que era esperado vs o que aconteceu, e desde quando (último commit/deploy que funcionava, se souber).

**Gate de saída:** você consegue apontar o output real do erro. Sem ele, peça o comando/log
exato — não prossiga por descrição.

### Fase 2 — Investigar a causa raiz
1. Liste no máximo 3 suspeitos, ordenados por probabilidade, cada um com o porquê.
2. Para o suspeito nº 1, busque evidência no código/log/config que CONFIRME ou ELIMINE.
3. Eliminou? Próximo suspeito. NÃO acumule mudanças "pra ver se resolve".

**Gate de saída:** uma frase no formato "A causa é X, demonstrada por Y", onde Y é código,
log ou config concreto (`arquivo:linha`).

### Fase 3 — Corrigir o mínimo
1. Proponha o fix MÍNIMO que ataca a causa demonstrada — não refatore junto.
2. Declare o que o fix NÃO cobre (casos relacionados ficam listados para depois).
3. Aplique UMA mudança por vez. Duas hipóteses ≠ uma mudança dupla.

### Fase 4 — Verificar
1. Rode a reprodução da Fase 1 — o sintoma sumiu?
2. Rode os testes relacionados — nada regrediu?
3. Aplique a Disciplina de conclusão (`engenharia-style.md` § 2): output real na resposta;
   falhou = reportar como falhando.

**Gate de saída:** evidência de verificação na resposta. "Deve funcionar agora" é proibido.

## Regras de comportamento

- Uma hipótese por vez; mudanças em paralelo embaralham a evidência.
- Eliminou 3 suspeitos? PARE e releia a Fase 1 — o sintoma foi mal caracterizado.
- Causa em dependência externa/ambiente → diga isso com a evidência; não "contorne" em silêncio.
- Descobertas colaterais (outro bug, código morto) viram notas ao final — não conserte junto.

## Anti-padrões a recusar

- "Troca a lib/versão e vê se resolve" sem evidência.
- Fix + refactor + melhoria de estilo no mesmo diff.
- Declarar resolvido sem rodar a reprodução.
- `try/catch` engolindo a exceção como "correção".

## Saída esperada

Resposta estruturada (texto, não HTML):

1. **Sintoma** — output real.
2. **Causa raiz** — "X, demonstrada por Y" (`arquivo:linha`).
3. **Fix aplicado** — diff mínimo.
4. **Verificação** — comando + output.
5. **Notas** — o que não foi coberto; descobertas colaterais.

## Exemplo de invocação

> O endpoint de estorno está retornando 500 intermitente desde ontem. Siga todo o processo
> descrito em `prompts/engenharia/depurador-sistematico.md` — quero a causa raiz demonstrada
> antes de qualquer mudança.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/depurador-sistematico` |
| Copilot CLI | Gatilho natural ("investiga esse bug") — a instruction roteia |

## Referências
- Disciplina de conclusão: `engenharia-style.md` § 2 — obrigatória na Fase 4.
- Fix cresceu além do pontual? `prompts/engenharia/planejador-de-implementacao.md`.
```

- [ ] **Step 2: Commit**

```bash
git add prompts/engenharia/depurador-sistematico.md
git commit -m "feat: prompt depurador-sistematico (porte de superpowers:systematic-debugging)"
```

---

### Task 6: `prompts/engenharia/planejador-de-implementacao.md`

**Files:**
- Create: `prompts/engenharia/planejador-de-implementacao.md`

- [ ] **Step 1: Criar o arquivo (conteúdo completo)**

````markdown
# Prompt — Planejador de Implementação

> ## STATUS
>
> Este prompt é referenciado pela rule `.amazonq/rules/engenharia-style.md` § 1.
>
> O output é um plano em Markdown — não HTML.

Clona o comportamento da skill `superpowers:writing-plans`.

## Quando usar
- "planeja a implementação", "plano de implementação", "quebra em etapas"
- Depois que a decisão/abordagem existe (ADR ou brainstorm concluído) e antes de codar.
- Quando a mudança toca 3+ arquivos ou exige 2+ sessões de trabalho.

## Pré-requisito (gate de entrada)

O plano pressupõe que O QUE fazer já está decidido. Se a abordagem ainda está em aberto,
pare e sugira `prompts/arquitetura/brainstorm-arquitetural.md` primeiro. Não planeje em
cima de decisão que não existe.

## Persona

Você escreve planos para um dev competente que NÃO conhece este código nem o domínio.
Tudo que ele precisa está no plano: arquivos exatos, mudança concreta, como verificar.
Você não confia em "ele vai saber" — você escreve.

## Metodologia — 4 passos

### Passo 1 — Mapear arquivos
Antes das etapas, liste os arquivos que serão criados/modificados e a responsabilidade de
cada um. Use o contexto do projeto (quando existir) para respeitar os padrões da casa.

### Passo 2 — Quebrar em etapas pequenas
Cada etapa deve ser concluível em uma sessão curta e verificável SOZINHA:

```
### Etapa N — <título>
**Arquivos:** <criar/modificar, paths exatos>
**Mudança:** <o que muda, concreto — com código quando for código>
**Verificação:** <comando exato OU passos de inspeção>
**Pronto quando:** <critério observável>
```

Proibido: "TBD", "adicionar tratamento de erro apropriado", "similar à etapa N" (repita o
conteúdo). Etapa que não dá pra verificar sozinha está mal cortada — recorte.

### Passo 3 — Ordenar por dependência
Dependências explícitas ("a Etapa 4 exige a 2"). O caminho que entrega valor verificável
mais cedo vem primeiro. Inclua etapa final de validação de ponta a ponta.

### Passo 4 — Salvar e resumir
Salve em `docs/planos/<AAAA-MM-DD>-<slug-da-feature>.md`. Termine com: quantas etapas,
qual a primeira, qual o maior risco.

## Auto-revisão antes de entregar

- [ ] Toda etapa tem os 4 campos (arquivos, mudança, verificação, pronto quando)?
- [ ] Algum requisito do spec/decisão ficou sem etapa?
- [ ] Nomes e assinaturas consistentes entre as etapas?
- [ ] Nenhum placeholder?

## Exemplo de invocação

> A decisão da ADR-012 (mover idempotência para Redis) foi aprovada. Siga todo o processo
> descrito em `prompts/engenharia/planejador-de-implementacao.md` e gere o plano de
> implementação em etapas verificáveis.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/planejador-de-implementacao` |
| Copilot CLI | Gatilho natural ("planeja a implementação") |

## Referências
- Decisão em aberto? Antes: `prompts/arquitetura/brainstorm-arquitetural.md` → `gerador-adr.md`.
- Durante a execução: disciplina de conclusão (`engenharia-style.md` § 2) em toda etapa.
- Algo quebrou no meio? `prompts/engenharia/depurador-sistematico.md`.
````

- [ ] **Step 2: Commit**

```bash
git add prompts/engenharia/planejador-de-implementacao.md
git commit -m "feat: prompt planejador-de-implementacao (porte de superpowers:writing-plans)"
```

---

### Task 7: Enriquecer `brainstorm-arquitetural.md`

**Files:**
- Modify: `prompts/arquitetura/brainstorm-arquitetural.md`

- [ ] **Step 1: Disciplina "uma pergunta por vez" na Fase 1**

Old:
```
### Fase 1 — Reformular o problema (5–10 perguntas)
Não aceite o framing inicial do usuário. Pergunte:
```
New:
```
### Fase 1 — Reformular o problema (5–10 perguntas)
Não aceite o framing inicial do usuário. **Uma pergunta por vez** — faça a pergunta, espere
a resposta, só então faça a próxima. Quando couber, ofereça múltipla escolha (A/B/C + "outra")
em vez de pergunta aberta: é mais fácil de responder e revela o que o usuário NÃO considerou.
Pergunte:
```

- [ ] **Step 2: Título da metodologia 3 → 4 fases**

Old: `## Metodologia — 3 fases`
New: `## Metodologia — 4 fases`

- [ ] **Step 3: Substituir o fecho da Fase 3 pela Fase 4 nova**

Old (linhas 72-75):
```
Sugira que o usuário **decida**. Você **não decide por ele**. Apresente trade-offs e pergunte "qual incômodo você está mais disposto a aceitar?".

Quando o usuário escolhe, sugira:
> "Pronto para virar ADR? Eu posso iniciar usando `prompts/arquitetura/gerador-adr.md`."
```
New:
```
Sugira que o usuário **decida**. Você **não decide por ele**. Apresente trade-offs e pergunte "qual incômodo você está mais disposto a aceitar?".

### Fase 4 — Fechar com aprovação por seções
Antes de encerrar, apresente o resultado em seções e valide CADA uma com o usuário:

1. **Problema reformulado** — "isso captura o problema?"
2. **Opções consideradas** (incluindo as descartadas e por quê) — "faltou alguma?"
3. **Avaliação e escolha** — "os trade-offs refletem a conversa?"

Só depois das três aprovações, ofereça os próximos passos:
> "Pronto para virar ADR? Posso iniciar usando `prompts/arquitetura/gerador-adr.md`.
> Se a decisão gera trabalho de implementação, o passo seguinte é
> `prompts/engenharia/planejador-de-implementacao.md`."
```

- [ ] **Step 4: Acrescentar referência ao planejador**

Old (bloco Referências, linhas 114-116):
```
## Referências
- Próximo passo natural: `gerador-adr.md` quando a decisão estiver pronta.
- Complemento: `arquiteto-de-sistema.md` se o brainstorm revelar que a doc base está incompleta.
```
New:
```
## Referências
- Próximo passo natural: `gerador-adr.md` quando a decisão estiver pronta.
- Decisão aprovada que vira código: `prompts/engenharia/planejador-de-implementacao.md`.
- Complemento: `arquiteto-de-sistema.md` se o brainstorm revelar que a doc base está incompleta.
```

- [ ] **Step 5: Commit**

```bash
git add prompts/arquitetura/brainstorm-arquitetural.md
git commit -m "feat: brainstorm-arquitetural com uma-pergunta-por-vez e aprovacao por secoes"
```

---

### Task 8: Neutralizar `prompts/` (16 arquivos) + destino duplo nos analisadores

**Files:**
- Modify: todos os `.md` em `prompts/arquitetura/`, `prompts/frontend/`, `prompts/negocio/` (16 arquivos; os 2 de `prompts/engenharia/` já nasceram neutros)

Parte A — analisadores (mais delicada, fazer à mão):

- [ ] **Step 1: `prompts/arquitetura/analisador-de-projeto.md` — destino duplo**

Localize todas as menções ao output: `grep -n "project-context" prompts/arquitetura/analisador-de-projeto.md`.
Em cada menção de destino único (`.amazonq/rules/project-context.md`), reescreva citando o par. Na seção que especifica a geração do arquivo (Fase 3), insira o bloco verbatim:

````markdown
### Destino duplo do arquivo gerado

Gere o MESMO conteúdo em dois arquivos (um por ferramenta de assistente):

1. `.amazonq/rules/project-context.md` — sem frontmatter (lido pelo Amazon Q).
2. `.github/instructions/project-context.instructions.md` — começando com o frontmatter literal:

   ```
   ---
   applyTo: "**"
   ---
   ```

   seguido do MESMO conteúdo do arquivo 1.
````

E adicione ao checklist de aceitação do prompt (se existir; senão crie seção "Checklist de aceitação"):
```
- [ ] Os dois arquivos de contexto existem com o mesmo conteúdo (fora o frontmatter)?
- [ ] O arquivo `.instructions.md` começa com `applyTo: "**"`?
```

- [ ] **Step 2: `prompts/negocio/analisador-de-dominio.md` — destino duplo**

Mesma operação do Step 1, trocando `project-context` por `business-context`:
`grep -n "business-context" prompts/negocio/analisador-de-dominio.md`, reescrever menções de destino único, inserir o mesmo bloco verbatim (com `business-context` nos dois paths) e os 2 itens de checklist.

- [ ] **Step 3: `prompts/negocio/grill-negocio.md` — atualização inline dupla**

`grep -n "business-context" prompts/negocio/grill-negocio.md` — em cada instrução de "atualize o business-context.md", acrescente: "(nos DOIS destinos: `.amazonq/rules/business-context.md` e `.github/instructions/business-context.instructions.md` — mantenha-os idênticos fora o frontmatter)". A primeira menção ganha a forma completa; as seguintes podem dizer "nos dois destinos do contexto de negócio".

Parte B — neutralização mecânica (todos os 16):

- [ ] **Step 4: Aplicar a tabela de substituições, arquivo por arquivo**

Para CADA arquivo (use o grep para localizar, edite com julgamento — substituição cega de `sed` em prosa NÃO é permitida aqui):

Run para localizar: `grep -rn -iE 'amazon q|@workspace|modo write' prompts/arquitetura prompts/frontend prompts/negocio`

| Padrão encontrado | Substituição |
|---|---|
| `O Amazon Q tende a achatar...` | `Assistentes tendem a achatar...` (manter TODO o andaime que segue) |
| `o Amazon Q` / `Amazon Q` (sujeito de frase) | `o assistente` |
| `Clona o comportamento da skill X para Amazon Q` | `Clona o comportamento da skill X.` |
| `use @workspace` / `usar @workspace` / `com @workspace` (instrução de exploração) | `explore o código do workspace` |
| `@workspace está aberto...` (em exemplos de invocação) | remover a menção (a frase segue sem ela) |
| `em modo write` / `no modo write` | `gerando o arquivo no repositório` |
| `Revisor: Amazon Q + Persona Grill` (template de output do grill-doc) | `Revisor: assistente + Persona Grill` |
| `## Exemplo de invocação no Amazon Q` | `## Exemplo de invocação` |

- [ ] **Step 5: Tabela de invocação por ferramenta em cada prompt**

Em cada um dos 16 arquivos, logo após o bloco de exemplo da seção `## Exemplo de invocação` (renomeada no Step 4), adicione a tabela (trocando `<slug>` pelo nome do arquivo sem `.md`):

```markdown
| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/<slug>` |
| Copilot CLI | Gatilho natural — a instruction roteia |
```

- [ ] **Step 6: Gate de verificação (zero sobras)**

Run: `grep -rn -iE '@workspace|modo write|amazon q tende' prompts/ ; echo "exit=$?"`
Expected: `exit=1` (zero matches).

Run: `grep -rni 'amazon q' prompts/ | grep -vE '\| *Amazon Q \(IDE ou' ; echo "exit=$?"`
Expected: `exit=1` — a ÚNICA forma permitida de "Amazon Q" em `prompts/` é a célula da tabela de invocação.

- [ ] **Step 7: Commit**

```bash
git add prompts/
git commit -m "feat: prompts tool-neutral + destino duplo de contexto nos analisadores"
```

---

### Task 9: Gerar a camada `.github/` e commitar

**Files:**
- Create (gerados): `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md` (4), `.github/prompts/*.prompt.md` (18), `.github/skills/*/SKILL.md` (18)

- [ ] **Step 1: Gerar**

Run: `bash tools/sync-copilot.sh`
Expected: `Gerado: 4 instructions + copilot-instructions.md + 18 prompt files + 18 skills em .../.github`

- [ ] **Step 2: Inspecionar transformações**

Run: `head -8 .github/instructions/architecture-style.instructions.md`
Expected: frontmatter `applyTo: "**"` + `excludeAgent: "code-review"`, seguido do H1 e da frase "Aplicado automaticamente pelo GitHub Copilot...".

Run: `grep -c "\.github/instructions/" .github/instructions/architecture-style.instructions.md && grep -n "\.amazonq/rules/architecture-style\.md" .github/instructions/*.md ; echo "exit=$?"`
Expected: contagem ≥ 3 (paths reescritos); `exit=1` na segunda (nenhum path de rule de estilo sobrou sem reescrever).

Run: `grep -n "\.amazonq/rules/project-context\.md" .github/instructions/architecture-style.instructions.md | head -2`
Expected: ≥ 1 match — o path de contexto do Q PERMANECE (citação dual intencional do gate).

- [ ] **Step 3: Idempotência e --check**

Run: `bash tools/sync-copilot.sh && git status --porcelain .github | head; bash tools/sync-copilot.sh --check`
Expected: segunda geração não muda nada novo após o primeiro `git add`; `--check` imprime `OK: .github/ em sincronia com o canonico.`

- [ ] **Step 4: Teste negativo do --check**

Run: `echo "drift-test" >> .github/copilot-instructions.md && bash tools/sync-copilot.sh --check; echo "exit=$?"; git checkout -- .github/copilot-instructions.md`
Expected: `DRIFT: ...` e `exit=1`; depois do checkout, `--check` volta a passar.

- [ ] **Step 5: Commit**

```bash
git add .github/
git commit -m "feat: camada Copilot gerada (instructions, prompt files, skills)"
```

---

### Task 10: Reescrever `install.sh`

**Files:**
- Modify: `install.sh` (substituição completa)

- [ ] **Step 1: Substituir o arquivo inteiro pelo conteúdo abaixo**

```bash
#!/usr/bin/env bash
# install.sh — instala o pack arquitetura (Amazon Q + GitHub Copilot) num repositorio de servico.
#
# Uso:
#   bash install.sh                         # instala no diretorio atual
#   bash install.sh /caminho/do/servico     # instala no repo indicado
#   bash install.sh --with-examples .       # inclui as paginas HTML de exemplo
#   bash install.sh --help                  # mostra esta ajuda
#
# Copia: .amazonq/rules/ (4 rules) + .github/ (camada Copilot: instructions,
#        prompts, skills) + prompts/ (4 trilhas) + design-system/*.css +
#        templates/{diagram-viewer,sidebar}.js + COMO-USAR.md
# NAO copia: arquivos de contexto por-servico (project/business-context nos
#        dois lados) — sao gerados pelos analisadores e preservados em re-runs.
set -euo pipefail

usage() { sed -n '2,14p' "$0" | sed 's/^#$//; s/^# //'; }

WITH_EXAMPLES=0
TARGET=""
for arg in "$@"; do
  case "$arg" in
    --with-examples) WITH_EXAMPLES=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "❌ Opcao desconhecida: $arg"; echo ""; usage; exit 1 ;;
    *)
      if [ -n "$TARGET" ]; then
        echo "❌ Mais de um alvo informado: \"$TARGET\" e \"$arg\". Passe so um."
        exit 1
      fi
      TARGET="$arg"
      ;;
  esac
done

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-$(pwd)}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "❌ Alvo nao existe: ${TARGET}"; exit 1; }

if [ "$TARGET" = "$PACK_DIR" ]; then
  echo "❌ O alvo e o proprio pack. Rode apontando pro repo do SERVICO:"
  echo "   bash \"$PACK_DIR/install.sh\" /caminho/do/seu/servico"
  exit 1
fi

echo "📦 arquitetura (Amazon Q + Copilot)  →  $TARGET"
echo ""

# 1) Rules Amazon Q (nunca tocamos *-context.md, que sao por-servico)
mkdir -p "$TARGET/.amazonq/rules"
[ -e "$TARGET/.amazonq/rules/architecture-style.md" ] && \
  echo "ℹ️  Instalacao existente — atualizo as rules do pack (arquivos de contexto ficam intactos)."
for f in architecture-style.md frontend-style.md negocio-style.md engenharia-style.md; do
  cp "$PACK_DIR/.amazonq/rules/$f" "$TARGET/.amazonq/rules/$f"
  echo "  ✓ .amazonq/rules/$f"
done

# 2) Camada Copilot (instructions nomeadas — nunca tocamos *-context.instructions.md)
mkdir -p "$TARGET/.github/instructions" "$TARGET/.github/prompts" "$TARGET/.github/skills"
cp "$PACK_DIR/.github/copilot-instructions.md" "$TARGET/.github/copilot-instructions.md"
echo "  ✓ .github/copilot-instructions.md"
for f in architecture-style frontend-style negocio-style engenharia-style; do
  cp "$PACK_DIR/.github/instructions/$f.instructions.md" "$TARGET/.github/instructions/$f.instructions.md"
done
echo "  ✓ .github/instructions/ (4 instructions)"
cp -R "$PACK_DIR/.github/prompts/." "$TARGET/.github/prompts/"
cp -R "$PACK_DIR/.github/skills/."  "$TARGET/.github/skills/"
echo "  ✓ .github/prompts/ + .github/skills/ (18 wrappers cada)"

# 3) Prompts (4 trilhas)
mkdir -p "$TARGET/prompts"
for t in arquitetura frontend negocio engenharia; do
  cp -R "$PACK_DIR/prompts/$t" "$TARGET/prompts/"
done
echo "  ✓ prompts/{arquitetura,frontend,negocio,engenharia}"

# 4) Design system (CSS reutilizavel)
mkdir -p "$TARGET/design-system"
cp "$PACK_DIR/design-system/"*.css "$TARGET/design-system/"
echo "  ✓ design-system/*.css"

# 5) Runtime dos templates (viewer + sidebar)
mkdir -p "$TARGET/templates"
cp "$PACK_DIR/templates/diagram-viewer.js" "$TARGET/templates/"
cp "$PACK_DIR/templates/sidebar.js"        "$TARGET/templates/"
echo "  ✓ templates/diagram-viewer.js + sidebar.js"

# 5b) Paginas de exemplo (opcional — so com --with-examples)
if [ "$WITH_EXAMPLES" = "1" ]; then
  if cp "$PACK_DIR/templates/"*.html "$TARGET/templates/" 2>/dev/null; then
    echo "  ✓ templates/*.html (exemplos)"
  else
    echo "  ⚠ templates/*.html nao copiados (nenhum .html no pack?)"
  fi
fi

# 6) Guia de uso
if cp "$PACK_DIR/COMO-USAR.md" "$TARGET/COMO-USAR.md" 2>/dev/null && [ -f "$TARGET/COMO-USAR.md" ]; then
  echo "  ✓ COMO-USAR.md"
else
  echo "  ⚠ COMO-USAR.md nao copiado (destino bloqueado?)"
fi

# 7) Limpeza de lixo do Finder
find "$TARGET/prompts" "$TARGET/.github" "$TARGET/templates" "$TARGET/design-system" \
  -name '.DS_Store' -delete 2>/dev/null || true

echo ""
echo "✅ Instalado. O Amazon Q le .amazonq/rules/ e o Copilot le .github/ automaticamente."
echo ""
echo "Comece:"
echo "   Tecnica:    \"documenta esse servico\"   (Copilot IDE: /analisador-de-projeto na 1a vez)"
echo "   Negocio:    \"analisa o dominio\" → \"grilla o negocio\""
echo "   Frontend:   \"polir essa pagina\""
echo "   Engenharia: \"investiga esse bug\" · \"planeja a implementacao\""
echo ""
echo "📖 Todos os gatilhos, por ferramenta: COMO-USAR.md"
```

- [ ] **Step 2: Smoke test imediato**

Run:
```bash
bash -n install.sh && T="$(mktemp -d)" && bash install.sh "$T" && find "$T" -type f | wc -l && bash install.sh --help | head -3 && bash install.sh --typo "$T"; echo "typo-exit=$?"; rm -rf "$T"
```
Expected: instalação ok; contagem de arquivos ≈ 65 (4 rules + 1 copilot-instructions + 4 instructions + 18 prompt files + 18 SKILL.md + 18 prompts canônicos + 2 css + 2 js + COMO-USAR — confira o número exato e anote); `--help` mostra só o cabeçalho (SEM `!/usr/bin/env`); `--typo` → `Opcao desconhecida` e `typo-exit=1`.

- [ ] **Step 3: Commit**

```bash
git add install.sh
git commit -m "fix: install.sh copia 4 trilhas + camada Copilot; corrige help/flags/mascaramento"
```

---

### Task 11: Reescrever `install.ps1` (ASCII puro)

**Files:**
- Modify: `install.ps1` (substituição completa)

- [ ] **Step 1: Substituir o arquivo inteiro pelo conteúdo abaixo**

REGRA DURA: o arquivo final deve ser 100% ASCII (sem em-dash, sem acento, sem emoji) — é isso que elimina o mojibake no PowerShell 5.1 sem depender de BOM.

```powershell
#requires -Version 5
<#
  install.ps1 - instala o pack arquitetura (Amazon Q + GitHub Copilot) num repositorio de servico.

  Uso (PowerShell / pwsh - Windows, macOS ou Linux):
    pwsh install.ps1                          # instala no diretorio atual
    pwsh install.ps1 -Target C:\repos\servico
    pwsh install.ps1 -WithExamples            # inclui as paginas HTML de exemplo

  Copia: .amazonq/rules/ (4 rules) + .github/ (camada Copilot) + prompts/ (4 trilhas)
         + design-system/*.css + templates/{diagram-viewer,sidebar}.js + COMO-USAR.md
  NAO copia: arquivos de contexto por-servico (project/business-context nos dois lados).
#>
param(
  [string]$Target = (Get-Location).Path,
  [switch]$WithExamples
)
$ErrorActionPreference = 'Stop'

$PackDir = $PSScriptRoot
try {
  $Target = (Resolve-Path -LiteralPath $Target -ErrorAction Stop).Path
} catch {
  Write-Host "[erro] Alvo nao existe: $Target"
  exit 1
}
$seps = [char[]]@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$Target  = $Target.TrimEnd($seps)
$PackDir = $PackDir.TrimEnd($seps)

if ($Target -eq $PackDir) {
  Write-Host "[erro] O alvo e o proprio pack. Aponte pro repo do SERVICO:"
  Write-Host ("       pwsh `"" + (Join-Path $PackDir 'install.ps1') + "`" -Target <repo>")
  exit 1
}

Write-Host "[pack] arquitetura (Amazon Q + Copilot) -> $Target`n"

# 1) Rules Amazon Q (nunca tocamos *-context.md)
$rulesDst = Join-Path $Target '.amazonq/rules'
New-Item -ItemType Directory -Force -Path $rulesDst | Out-Null
if (Test-Path (Join-Path $rulesDst 'architecture-style.md')) {
  Write-Host "  i  Instalacao existente - atualizo as rules (arquivos de contexto ficam intactos)."
}
foreach ($f in 'architecture-style.md','frontend-style.md','negocio-style.md','engenharia-style.md') {
  Copy-Item (Join-Path $PackDir ".amazonq/rules/$f") (Join-Path $rulesDst $f) -Force
  Write-Host "  + .amazonq/rules/$f"
}

# 2) Camada Copilot (nunca tocamos *-context.instructions.md)
$ghDst = Join-Path $Target '.github'
foreach ($d in 'instructions','prompts','skills') {
  New-Item -ItemType Directory -Force -Path (Join-Path $ghDst $d) | Out-Null
}
Copy-Item (Join-Path $PackDir '.github/copilot-instructions.md') (Join-Path $ghDst 'copilot-instructions.md') -Force
Write-Host "  + .github/copilot-instructions.md"
foreach ($f in 'architecture-style','frontend-style','negocio-style','engenharia-style') {
  Copy-Item (Join-Path $PackDir ".github/instructions/$f.instructions.md") (Join-Path $ghDst "instructions/$f.instructions.md") -Force
}
Write-Host "  + .github/instructions/ (4 instructions)"
Copy-Item (Join-Path $PackDir '.github/prompts/*') (Join-Path $ghDst 'prompts') -Recurse -Force
Copy-Item (Join-Path $PackDir '.github/skills/*')  (Join-Path $ghDst 'skills')  -Recurse -Force
Write-Host "  + .github/prompts/ + .github/skills/ (18 wrappers cada)"

# 3) Prompts (4 trilhas)
$promptsDst = Join-Path $Target 'prompts'
New-Item -ItemType Directory -Force -Path $promptsDst | Out-Null
foreach ($t in 'arquitetura','frontend','negocio','engenharia') {
  Copy-Item (Join-Path $PackDir "prompts/$t") $promptsDst -Recurse -Force
}
Write-Host "  + prompts/{arquitetura,frontend,negocio,engenharia}"

# 4) Design system
$dsDst = Join-Path $Target 'design-system'
New-Item -ItemType Directory -Force -Path $dsDst | Out-Null
Copy-Item (Join-Path $PackDir 'design-system/*.css') $dsDst -Force
Write-Host "  + design-system/*.css"

# 5) Runtime dos templates
$tplDst = Join-Path $Target 'templates'
New-Item -ItemType Directory -Force -Path $tplDst | Out-Null
Copy-Item (Join-Path $PackDir 'templates/diagram-viewer.js') $tplDst -Force
Copy-Item (Join-Path $PackDir 'templates/sidebar.js')        $tplDst -Force
Write-Host "  + templates/diagram-viewer.js + sidebar.js"

# 5b) Paginas de exemplo (opcional)
if ($WithExamples) {
  $html = Get-ChildItem (Join-Path $PackDir 'templates') -Filter '*.html' -ErrorAction SilentlyContinue
  if ($html) {
    $html | Copy-Item -Destination $tplDst -Force
    Write-Host "  + templates/*.html (exemplos)"
  } else {
    Write-Host "  ! templates/*.html nao copiados (nenhum .html no pack?)"
  }
}

# 6) Guia de uso
Copy-Item (Join-Path $PackDir 'COMO-USAR.md') (Join-Path $Target 'COMO-USAR.md') -Force -ErrorAction SilentlyContinue
if (Test-Path -PathType Leaf (Join-Path $Target 'COMO-USAR.md')) {
  Write-Host "  + COMO-USAR.md"
} else {
  Write-Host "  ! COMO-USAR.md nao copiado (destino bloqueado?)"
}

# 7) Limpeza de lixo do Finder
Get-ChildItem -Path $promptsDst, $ghDst, $tplDst, $dsDst -Recurse -Force -Filter '.DS_Store' -ErrorAction SilentlyContinue |
  Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "`n[ok] Instalado. O Amazon Q le .amazonq/rules/ e o Copilot le .github/ automaticamente.`n"
Write-Host 'Comece:'
Write-Host '   Tecnica:    "documenta esse servico"   (Copilot IDE: /analisador-de-projeto na 1a vez)'
Write-Host '   Negocio:    "analisa o dominio" -> "grilla o negocio"'
Write-Host '   Frontend:   "polir essa pagina"'
Write-Host '   Engenharia: "investiga esse bug" / "planeja a implementacao"'
Write-Host "`nTodos os gatilhos, por ferramenta: COMO-USAR.md"
```

- [ ] **Step 2: Verificar ASCII puro e paridade**

Run: `LC_ALL=C grep -nP '[^\x00-\x7F]' install.ps1 ; echo "ascii-exit=$?"`
Expected: `ascii-exit=1` (zero bytes não-ASCII).

Conferir paridade de itens copiados com install.sh: mesmas 4 rules, mesmos 4 instructions nomeados, prompts/skills wholesale, 4 trilhas, css, 2 js, COMO-USAR. (pwsh não está disponível nesta máquina — validação estática aqui; teste real no Windows fica para o usuário, ver Task 14.)

- [ ] **Step 3: Commit**

```bash
git add install.ps1
git commit -m "fix: install.ps1 ASCII puro, guard com TrimEnd, erros amigaveis, camada Copilot"
```

---

### Task 12: README dual-tool

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Título e abertura (linhas 1-6)**

Old:
```
# arquitetura-amazonq-btg

Starter pack de documentação arquitetural para serviços **.NET transacionais** usando **Amazon Q Developer** como assistente.
```
New:
```
# arquitetura — pack de documentação para Amazon Q e GitHub Copilot

Starter pack de documentação arquitetural para serviços **.NET transacionais**, usando
**Amazon Q Developer** ou **GitHub Copilot** (VS Code, Visual Studio, JetBrains, CLI) como assistente.
```

- [ ] **Step 2: Bullets de "O que esse repositório é" — acrescentar após o bullet das Rules**

```
- **Camada Copilot gerada** (`.github/`): instructions auto-aplicadas, slash commands (`/gerador-adr`, ...) e Agent Skills — gerada de `.amazonq/rules/` por `tools/sync-copilot.sh`, nunca editada à mão
- **Trilha de engenharia**: debugging sistemático, planejamento de implementação e disciplina de verificação (portes do superpowers)
```

- [ ] **Step 3: Seção "Instalação rápida" — atualizar lista manual**

Old (lista do "Manual"):
```
- `.amazonq/rules/` → `architecture-style.md`, `frontend-style.md`, `negocio-style.md`
- `prompts/arquitetura/` e `prompts/negocio/` (as duas pastas inteiras)
- `design-system/*.css`
- `templates/diagram-viewer.js` e `templates/sidebar.js`
```
New:
```
- `.amazonq/rules/` → as 4 rules (`architecture-style`, `frontend-style`, `negocio-style`, `engenharia-style`)
- `.github/` → `copilot-instructions.md`, `instructions/` (as 4), `prompts/` e `skills/` inteiras
- `prompts/` → as 4 trilhas inteiras (`arquitetura`, `frontend`, `negocio`, `engenharia`)
- `design-system/*.css`
- `templates/diagram-viewer.js` e `templates/sidebar.js`
- `COMO-USAR.md`
```
E na frase seguinte ("Não copie..."), atualizar para citar os 4 arquivos de contexto (2 em `.amazonq/rules/`, 2 em `.github/instructions/`).

- [ ] **Step 4: "Como funciona" — acrescentar nota dual-tool antes do diagrama ASCII**

```
> O fluxo abaixo descreve o Amazon Q. No Copilot é o mesmo desenho com outros nomes:
> `.github/instructions/` no lugar de `.amazonq/rules/` (auto-aplicadas), `/analisador-de-projeto`
> como atalho, e o contexto gerado nos DOIS lados (`project-context.md` + `project-context.instructions.md`).
```

- [ ] **Step 5: Árvore "Estrutura" — substituir pela atual**

Substituir o bloco da árvore inteiro pelo refletindo o repo real pós-mudança (gerar com `find`/`tree` e conferir): inclui `negocio-style.md`, `engenharia-style.md`, `prompts/negocio/`, `prompts/engenharia/`, `.github/` (com nota "← gerado, não editar"), `tools/`, `COMO-USAR.md`, `install.sh`, `install.ps1`, `docs/`.

- [ ] **Step 6: Nova seção "Para mantenedores do pack" (antes de "Contribuindo")**

```markdown
## Para mantenedores do pack

`.amazonq/rules/` é a fonte canônica. A camada `.github/` é GERADA — não edite à mão.
Depois de editar qualquer rule ou o `tools/manifest.tsv`:

    bash tools/sync-copilot.sh        # regenera .github/
    bash tools/sync-copilot.sh --check   # confirma que está em sincronia (use antes de commitar)

Commite o `.github/` regenerado junto com a mudança canônica.
```

- [ ] **Step 7: Commit**

```bash
git add README.md
git commit -m "docs: README dual-tool (Copilot + trilha engenharia + secao de mantenedores)"
```

---

### Task 13: COMO-USAR dual-tool

**Files:**
- Modify: `COMO-USAR.md`

- [ ] **Step 1: Substituir título e introdução (linhas 1-5)**

New:
```markdown
# Como usar o pack — Amazon Q e GitHub Copilot

O pack funciona com os dois assistentes, sem configuração manual:

- **Amazon Q** lê `.amazonq/rules/` sozinho (IDE ou `q chat`). Fale em linguagem natural
  com o repo aberto e ele identifica a intenção e carrega o prompt certo.
- **GitHub Copilot** aplica `.github/instructions/` sozinho (VS Code, Visual Studio,
  JetBrains e Copilot CLI). Os mesmos gatilhos funcionam; nas IDEs você também tem
  slash commands (`/analisador-de-projeto`, `/gerador-adr`, ...) e no CLI os prompts
  existem como Agent Skills.

## Como invocar, por ferramenta

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE / `q chat`) | Gatilho natural ("documenta esse serviço") ou mensagem nomeando o prompt |
| Copilot IDE (VS Code / VS / JetBrains) | Gatilho natural OU `/<slug>` (ex.: `/grill-negocio`) |
| Copilot CLI | Gatilho natural; prompts também disponíveis como skills |
```

- [ ] **Step 2: Neutralizar menções a `@workspace` no corpo**

Run: `grep -n "@workspace" COMO-USAR.md`
Em cada uma: "com `@workspace` aberto no repo" → "com o repo aberto no assistente". A dica do bloco `> 💡` permanece (vale para os dois assistentes).

- [ ] **Step 3: Acrescentar as trilhas que faltavam (depois da tabela "Trilha TÉCNICA")**

```markdown
## Trilha FRONTEND

| Pra... | Diga algo como |
|---|---|
| Decisões visuais (uma por vez) | `como deixar essa página bonita` · `melhora o visual` |
| Catálogo de estilos/paletas | `que estilo combina com isso` · `paleta` |
| Design system (estender/auditar) | `padroniza os componentes` · `tokens` |
| Polimento final | `polir` · `micro-interações` · `acabamento` |

## Trilha ENGENHARIA

| Pra... | Diga algo como |
|---|---|
| Investigar bug (causa raiz primeiro) | `investiga esse bug` · `debugga` · `por que está quebrando` |
| Plano de implementação | `planeja a implementação` · `quebra em etapas` |
```

- [ ] **Step 4: Atualizar a frase "No fim, dois arquivos em `.amazonq/rules/`"**

Old: `No fim, dois arquivos em `.amazonq/rules/`.`
New: `No fim, os arquivos de contexto nos dois lados: `.amazonq/rules/` (Q) e `.github/instructions/` (Copilot).`

- [ ] **Step 5: Commit**

```bash
git add COMO-USAR.md
git commit -m "docs: COMO-USAR dual-tool com as 4 trilhas e invocacao por ferramenta"
```

---

### Task 14: Validação de ponta a ponta

**Files:** nenhum (só execução); Modify: `.gitignore` (se faltar `.DS_Store`)

- [ ] **Step 1: `.gitignore` cobre `.DS_Store`**

Run: `grep -qx '.DS_Store' .gitignore || (echo '.DS_Store' >> .gitignore && git add .gitignore && git commit -m "chore: ignora .DS_Store")`

- [ ] **Step 2: Instalação limpa — zero paths pendurados**

```bash
T="$(mktemp -d)"
bash install.sh "$T"
grep -rohE '(prompts|templates|design-system)/[A-Za-z0-9._/-]+\.(md|css|js|html)' \
  "$T/.amazonq/rules" "$T/.github" 2>/dev/null | sort -u | while read -r p; do
  [ -e "$T/$p" ] || echo "PENDURADO: $p"
done
```
Expected: instalação ok; NENHUMA linha `PENDURADO:` (exceção aceitável: `templates/01-visao-geral.html`, que o texto condiciona explicitamente a `--with-examples` — confirme que a frase condicional está lá: `grep -n "with-examples" "$T/.amazonq/rules/architecture-style.md"`).

- [ ] **Step 3: Re-run preserva contextos dos dois lados**

```bash
echo "CONTEXTO-Q"  > "$T/.amazonq/rules/project-context.md"
printf -- '---\napplyTo: "**"\n---\nCONTEXTO-COPILOT\n' > "$T/.github/instructions/project-context.instructions.md"
bash install.sh "$T"
cat "$T/.amazonq/rules/project-context.md"
head -4 "$T/.github/instructions/project-context.instructions.md"
find "$T/prompts" -type d -name arquitetura | wc -l
```
Expected: `CONTEXTO-Q` e o frontmatter+`CONTEXTO-COPILOT` intactos; exatamente `1` diretório `arquitetura` (sem aninhamento).

- [ ] **Step 4: Guard, help, flags e exemplos**

```bash
bash install.sh "$PWD/" ; echo "guard-exit=$?"        # trailing slash → bloqueado
bash install.sh --help | grep -c 'usr/bin/env'        # 0 (sem vazamento do shebang)
bash install.sh --with-examples "$T" && ls "$T/templates/"*.html | wc -l
rm -rf "$T"
```
Expected: `guard-exit=1` com a mensagem do pack; `0`; ≥ 12 html copiados.

- [ ] **Step 5: Sync em sincronia + greps finais do repo**

```bash
bash tools/sync-copilot.sh --check
grep -rn -iE '@workspace|modo write' prompts/ COMO-USAR.md ; echo "neutro-exit=$?"
grep -rn 'templates/negocio' . --include='*.md' ; echo "pendurado-exit=$?"
git status --porcelain
```
Expected: `OK: .github/ em sincronia...`; `neutro-exit=1`; `pendurado-exit=1`; working tree limpo.

- [ ] **Step 6: Passos manuais do usuário (fora desta máquina) — registrar como pendência na entrega**

1. Windows do trabalho: `powershell -ExecutionPolicy Bypass -File install.ps1 -Target <repo-teste>` (confere mojibake zero e instalação completa).
2. VS Code + Copilot: abrir repo instalado, rodar `/analisador-de-projeto`, conferir que os DOIS arquivos de contexto são gerados.
3. Amazon Q: fluxo atual de regressão ("documenta esse serviço").
4. Copilot CLI: gatilho natural "investiga esse bug" → deve carregar o depurador.

---

## Self-review (do plano contra o spec)

- **Spec §3 estrutura** → Tasks 1-6, 9 ✓ · **§4 camada gerada** → Tasks 2, 9 ✓ · **§5 gate duplo** → Tasks 3, 8 ✓ · **§6 neutralização** → Task 8 ✓ · **§7 trilha engenharia** → Tasks 4-7 ✓ · **§8 fixes auditoria** → Tasks 3, 10, 11, 14 ✓ · **§9 README/COMO-USAR** → Tasks 12, 13 ✓ · **§10 validação** → Task 14 ✓.
- Placeholders: nenhum — todo arquivo novo tem conteúdo integral; edições têm old/new exatos ou regra de transformação + gate de grep.
- Consistência: slugs do manifest = nomes dos arquivos em `prompts/` (18/18); frase de auto-load padronizada (Task 3) = alvo do sed (Task 2); paths citados nos prompts novos existem após Task 9.
