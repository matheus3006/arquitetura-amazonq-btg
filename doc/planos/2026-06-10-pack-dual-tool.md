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
| Referências a `.amazonq/rules/<rule>.md § N` (em STATUS e corpo) | `a rule da trilha <X> § N (\`.amazonq/rules/<rule>.md\` ou \`.github/instructions/<rule>.instructions.md\`, conforme a ferramenta)` — mesmo padrão já usado nos prompts de engenharia |

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
#        templates/{diagram-viewer,sidebar}.js + COMO-USAR.html
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

# 6) Guia de uso (mensagens prontas — abra no navegador)
if cp "$PACK_DIR/COMO-USAR.html" "$TARGET/COMO-USAR.html" 2>/dev/null && [ -f "$TARGET/COMO-USAR.html" ]; then
  echo "  ✓ COMO-USAR.html"
else
  echo "  ⚠ COMO-USAR.html nao copiado (destino bloqueado?)"
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
echo "📖 Mensagens prontas por trilha: abra COMO-USAR.html no navegador"
```

- [ ] **Step 2: Smoke test imediato**

Run:
```bash
bash -n install.sh && T="$(mktemp -d)" && bash install.sh "$T" && find "$T" -type f | wc -l && bash install.sh --help | head -3 && bash install.sh --typo "$T"; echo "typo-exit=$?"; rm -rf "$T"
```
Expected: instalação ok; contagem de arquivos ≈ 68 (4 rules + 1 copilot-instructions + 4 instructions + 18 prompt files + 18 SKILL.md + 18 prompts canônicos + 2 css + 2 js + COMO-USAR.html — confira o número exato e anote); `--help` mostra só o cabeçalho (SEM `!/usr/bin/env`); `--typo` → `Opcao desconhecida` e `typo-exit=1`.

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
         + design-system/*.css + templates/{diagram-viewer,sidebar}.js + COMO-USAR.html
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

# 6) Guia de uso (mensagens prontas - abra no navegador)
Copy-Item (Join-Path $PackDir 'COMO-USAR.html') (Join-Path $Target 'COMO-USAR.html') -Force -ErrorAction SilentlyContinue
if (Test-Path -PathType Leaf (Join-Path $Target 'COMO-USAR.html')) {
  Write-Host "  + COMO-USAR.html"
} else {
  Write-Host "  ! COMO-USAR.html nao copiado (destino bloqueado?)"
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
Write-Host "`nMensagens prontas por trilha: abra COMO-USAR.html no navegador"
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
- `COMO-USAR.html`
```
E na frase seguinte ("Não copie..."), atualizar para citar os 4 arquivos de contexto (2 em `.amazonq/rules/`, 2 em `.github/instructions/`).

- [ ] **Step 3b: Opção de instalação via IA (logo acima das vias bash/PowerShell)**

```markdown
**Via assistente de IA (qualquer plataforma):** aponte o seu assistente (Amazon Q, Copilot,
Claude...) para o arquivo [`INSTALAR.md`](INSTALAR.md) do pack e diga:
> Siga o INSTALAR.md deste pack e instale no repositório `<caminho-do-meu-servico>`.
```

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

### Task 13: `COMO-USAR.html` — mensagens prontas (substitui COMO-USAR.md)

**Files:**
- Create: `COMO-USAR.html`
- Delete: `COMO-USAR.md` (via `git rm`)

Página no design system do pack (dark, `file://`-compatível, scripts clássicos). Um card por prompt (18), agrupados por trilha, cada um com a mensagem pronta + botão Copiar + atalho `/slug` do Copilot.

- [ ] **Step 1: Validar nomes das variáveis de token**

Run: `grep -oE -- '--[a-z0-9-]+' design-system/tokens.css | sort -u`
O HTML do Step 2 usa `var(--nome, fallback)` em todo lugar. Compare cada `var(--*)` usado com a lista real e corrija os NOMES divergentes (os fallbacks garantem que a página não quebra, mas o nome certo deve ser usado — regra da casa: nunca hardcode sem var).

- [ ] **Step 2: Criar `COMO-USAR.html` (conteúdo completo)**

As 18 mensagens abaixo são o conteúdo de fato — não as altere ao montar a página. Estrutura de card é idêntica para todos; estão todos listados.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Como usar · Pack arquitetura (Amazon Q + Copilot)</title>
  <meta name="description" content="Mensagens prontas para extrair o máximo dos prompts do pack.">
  <link rel="stylesheet" href="design-system/tokens.css">
  <link rel="stylesheet" href="design-system/components.css">
  <style>
    .guide { max-width: 1040px; margin: 0 auto; padding: var(--space-8, 48px) var(--space-4, 24px); }
    .guide-hero h1 { margin: 0 0 8px; }
    .guide-hero p { color: var(--color-text-muted, #9aa3b2); max-width: 70ch; }
    .trilha { margin-top: var(--space-8, 48px); }
    .cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(420px, 1fr)); gap: var(--space-4, 20px); margin-top: var(--space-4, 20px); }
    .msg-card { border: 1px solid var(--color-border, #232a36); border-radius: var(--radius-md, 10px); padding: var(--space-4, 20px); background: var(--color-surface, #11151d); display: flex; flex-direction: column; gap: 10px; }
    .msg-card h3 { margin: 0; font-size: 1rem; }
    .msg-card .quando { color: var(--color-text-muted, #9aa3b2); font-size: .85rem; margin: 0; }
    .msg { white-space: pre-wrap; font-family: var(--font-mono, ui-monospace, monospace); font-size: .82rem; line-height: 1.5; background: var(--color-bg, #0a0c12); border: 1px solid var(--color-border, #232a36); border-radius: var(--radius-sm, 6px); padding: 12px; margin: 0; }
    .msg b { color: var(--color-accent, #4a8fe7); }
    .card-foot { display: flex; align-items: center; justify-content: space-between; gap: 8px; margin-top: auto; }
    .slug { font-family: var(--font-mono, ui-monospace, monospace); font-size: .78rem; color: var(--color-text-muted, #9aa3b2); }
    .copy-btn { cursor: pointer; border: 1px solid var(--color-border, #232a36); background: var(--color-surface-2, #1a2030); color: var(--color-text, #e8ecf3); border-radius: var(--radius-sm, 6px); padding: 6px 12px; font-size: .8rem; transition: background-color 150ms var(--ease-out-strong, ease-out), transform 100ms var(--ease-out-strong, ease-out); }
    .copy-btn:hover { background: var(--color-surface-3, #232c42); }
    .copy-btn:active { transform: scale(0.97); }
    @media print { .copy-btn { display: none; } }
  </style>
</head>
<body>
  <main class="guide">
    <header class="guide-hero">
      <h1>Como usar o pack</h1>
      <p>Mensagens prontas para copiar e mandar pro assistente (Amazon Q ou GitHub Copilot).
         Troque os <b>[CAMPOS]</b> e envie. Nomear o prompt e mandar "seguir todo o processo"
         é o que faz o assistente executar o fluxo inteiro em vez de responder por cima.</p>
    </header>

    <section class="trilha">
      <h2 class="section-eyebrow">Como invocar, por ferramenta</h2>
      <table>
        <thead><tr><th>Ferramenta</th><th>Como invocar</th></tr></thead>
        <tbody>
          <tr><td>Amazon Q (IDE / <code>q chat</code>)</td><td>Cole a mensagem do card</td></tr>
          <tr><td>Copilot IDE (VS Code / Visual Studio / JetBrains)</td><td>Cole a mensagem OU use o atalho <code>/slug</code> indicado no card</td></tr>
          <tr><td>Copilot CLI</td><td>Cole a mensagem (os prompts também existem como skills)</td></tr>
        </tbody>
      </table>
      <p><strong>Primeira vez no repositório?</strong> Rode o card nº 1 antes de qualquer outro —
         todo o resto depende do contexto que ele gera. Para docs de negócio, rode também o nº 8.</p>
    </section>

    <section class="trilha">
      <h2 class="section-eyebrow">Trilha técnica</h2>
      <div class="cards">

        <article class="msg-card">
          <h3>1 · Preparar o repositório</h3>
          <p class="quando">Primeira invocação em repo novo, ou quando o código mudou muito.</p>
          <pre class="msg">Quero preparar este repositório para gerar documentação. Analise a aplicação <b>[NOME_DA_APLICACAO]</b>. Siga todo o processo descrito em prompts/arquitetura/analisador-de-projeto.md: detecte a stack e os padrões, me mostre o que encontrou, pergunte o que o código não revela (uma pergunta por vez) e gere o contexto do projeto nos dois destinos.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /analisador-de-projeto</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>2 · Visão geral de arquitetura</h3>
          <p class="quando">Documentar o serviço do zero ou atualizar a visão geral.</p>
          <pre class="msg">Quero a visão geral de arquitetura da aplicação <b>[NOME_DA_APLICACAO]</b>. Siga todo o processo descrito em prompts/arquitetura/arquiteto-de-sistema.md: faça as 5 perguntas-âncora antes de gerar qualquer conteúdo, e produza o HTML no padrão da casa com os diagramas na convenção rígida.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /arquiteto-de-sistema</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>3 · Registrar uma decisão (ADR)</h3>
          <p class="quando">Decisão tomada (ou madura o suficiente) que precisa virar registro.</p>
          <pre class="msg">Quero registrar a decisão <b>[DECISAO]</b> como ADR. Siga todo o processo descrito em prompts/arquitetura/gerador-adr.md: formato MADR, mínimo 3 decision drivers e 2 opções consideradas, trade-offs explícitos e métrica de validação ("como saberemos que deu certo?").</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /gerador-adr</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>4 · Runbook operacional</h3>
          <p class="quando">Documentação de operação: failure modes, on-call, SLO.</p>
          <pre class="msg">Quero o runbook operacional de <b>[SERVICO_OU_FLUXO]</b>. Siga todo o processo descrito em prompts/arquitetura/gerador-runbook.md: cada failure mode com sintoma observável, query de log/métrica para confirmar, ação imediata e mitigação permanente. Não invente SLO — me pergunte.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /gerador-runbook</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>5 · Fluxo transacional (técnico)</h3>
          <p class="quando">Sequência de chamadas, payloads, estados — visão de runtime.</p>
          <pre class="msg">Quero documentar o fluxo técnico de <b>[FLUXO]</b> na aplicação <b>[NOME_DA_APLICACAO]</b>. Siga todo o processo descrito em prompts/arquitetura/documentador-fluxo.md: sequence diagram com autonumber, payloads relevantes e os estados de erro/retry.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /documentador-fluxo</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>6 · Revisar documentação (grill técnico)</h3>
          <p class="quando">Auditar uma página/ADR existente procurando furos.</p>
          <pre class="msg">Revise a documentação <b>[PAGINA_OU_ADR]</b> procurando furos. Siga todo o processo descrito em prompts/arquitetura/grill-doc.md: aplique as 7 lentes na ordem (terminologia, decisões disfarçadas de premissa, garantias vs implementação, janelas sem número...) e gere o relatório estruturado.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /grill-doc</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>7 · Brainstorm (antes de decidir)</h3>
          <p class="quando">Ainda não decidiu? Sempre antes de uma ADR.</p>
          <pre class="msg">Estou pensando em <b>[IDEIA_OU_PROBLEMA]</b> e ainda não decidi. Siga todo o processo descrito em prompts/arquitetura/brainstorm-arquitetural.md: reformule o problema antes de discutir solução, uma pergunta por vez, mínimo 4 opções de naturezas diferentes, e feche com aprovação por seções.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /brainstorm-arquitetural</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

      </div>
    </section>

    <section class="trilha">
      <h2 class="section-eyebrow">Trilha de negócio</h2>
      <div class="cards">

        <article class="msg-card">
          <h3>8 · Mapear o domínio</h3>
          <p class="quando">Primeira doc de negócio do repo, ou refresh após mudanças grandes.</p>
          <pre class="msg">Quero o mapeamento da arquitetura de negócio (fluxo de negócio). Analise a aplicação <b>[NOME_DA_APLICACAO]</b>. Siga todo o processo descrito em prompts/negocio/analisador-de-dominio.md: detecte as regras candidatas no código (validações, enums, autorização), os atores e os eventos, me grile por fases pra confirmar o que o código não revela, e gere o contexto de negócio nos dois destinos.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /analisador-de-dominio</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>9 · Grill do negócio (interrogatório)</h3>
          <p class="quando">Tirar do código o que ele não conta: regra não-escrita, dono, exceções.</p>
          <pre class="msg">Quero aprofundar as regras de negócio de <b>[PROCESSO_OU_AREA]</b> na aplicação <b>[NOME_DA_APLICACAO]</b>. Siga todo o processo descrito em prompts/negocio/grill-negocio.md: me interrogue por fases, uma pergunta por vez, propondo sua resposta recomendada, mostrando o ledger ✓/▸/○ a cada rodada, e atualize o contexto de negócio (nos dois destinos) conforme fechamos.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /grill-negocio</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>10 · Fluxo de negócio (feliz/triste)</h3>
          <p class="quando">Desenho visual do processo com desfechos positivos e de exceção.</p>
          <pre class="msg">Quero o desenho do fluxo de negócio de <b>[PROCESSO]</b> na aplicação <b>[NOME_DA_APLICACAO]</b>. Siga todo o processo descrito em prompts/negocio/mapeador-de-fluxo-de-negocio.md: caminho feliz e pelo menos um caminho triste, com o diagrama no padrão da casa (classes papel/atividade/decisao/desfecho).</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /mapeador-de-fluxo-de-negocio</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>11 · Catálogo de regras</h3>
          <p class="quando">Inventário das regras de negócio com origem, dono e consequência.</p>
          <pre class="msg">Quero o catálogo de regras de negócio da aplicação <b>[NOME_DA_APLICACAO]</b>, agrupado por capacidade. Siga todo o processo descrito em prompts/negocio/catalogo-de-regras.md: toda regra com origem no código (arquivo:símbolo) ou marcada como regra de processo, dono e consequência de negócio.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /catalogo-de-regras</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>12 · Glossário do domínio</h3>
          <p class="quando">Linguagem ubíqua: os termos do negócio, sem detalhe de implementação.</p>
          <pre class="msg">Quero a página de glossário do domínio da aplicação <b>[NOME_DA_APLICACAO]</b>. Siga todo o processo descrito em prompts/negocio/glossario-de-negocio.md: termos do contexto de negócio, definição operacional curta, sem virar spec técnica.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /glossario-de-negocio</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

      </div>
    </section>

    <section class="trilha">
      <h2 class="section-eyebrow">Trilha frontend</h2>
      <div class="cards">

        <article class="msg-card">
          <h3>13 · Melhorar o visual (controlado)</h3>
          <p class="quando">Decisões visuais propostas uma a uma, com seu OK antes de aplicar.</p>
          <pre class="msg">Quero melhorar o visual de <b>[PAGINA]</b>. Siga todo o processo descrito em prompts/frontend/designer-ux-controlado.md: proponha cada decisão visual antes de aplicar, uma por vez, e espere minha aprovação em cada uma.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /designer-ux-controlado</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>14 · Escolher direção visual</h3>
          <p class="quando">Antes de criar algo novo: estilo, paleta, referências.</p>
          <pre class="msg">Quero escolher uma direção visual para <b>[PROJETO_OU_PAGINA]</b>. Siga todo o processo descrito em prompts/frontend/designer-ui-pro-max.md: apresente opções do catálogo de estilos e paletas adequadas ao contexto, com prós e contras, e me deixe escolher.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /designer-ui-pro-max</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>15 · Design system (estender/auditar)</h3>
          <p class="quando">Padronizar componentes, auditar tokens, evitar drift visual.</p>
          <pre class="msg">Quero <b>[ESTENDER_OU_AUDITAR]</b> o design system deste repositório. Siga todo o processo descrito em prompts/frontend/design-system-arquitetura.md: audite tokens e componentes existentes, aponte inconsistências e proponha a mudança sem quebrar o que já existe.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /design-system-arquitetura</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>16 · Polir (acabamento)</h3>
          <p class="quando">A página funciona mas falta o acabamento fino.</p>
          <pre class="msg">Quero polir <b>[PAGINA]</b>. Siga todo o processo descrito em prompts/frontend/polidor-ui.md: aplique o checklist de polimento na ordem (microespaçamento, easing, estados, press feedback), sempre usando os tokens do design system — nada hardcoded.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /polidor-ui</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

      </div>
    </section>

    <section class="trilha">
      <h2 class="section-eyebrow">Trilha engenharia</h2>
      <div class="cards">

        <article class="msg-card">
          <h3>17 · Investigar bug (causa raiz)</h3>
          <p class="quando">Comportamento inesperado — antes de qualquer tentativa de correção.</p>
          <pre class="msg"><b>[SINTOMA — cole o erro/stack trace real]</b>

Siga todo o processo descrito em prompts/engenharia/depurador-sistematico.md: quero a causa raiz demonstrada com evidência (arquivo:linha) ANTES de qualquer proposta de correção, e o fix mínimo verificado ao final.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /depurador-sistematico</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

        <article class="msg-card">
          <h3>18 · Plano de implementação</h3>
          <p class="quando">Decisão aprovada que vira código — antes de codar.</p>
          <pre class="msg">A decisão <b>[DECISAO_OU_ADR]</b> foi aprovada. Siga todo o processo descrito em prompts/engenharia/planejador-de-implementacao.md: gere o plano em etapas pequenas e independentemente verificáveis — cada etapa com arquivos exatos, mudança concreta, comando de verificação e critério de pronto.</pre>
          <div class="card-foot"><span class="slug">Copilot IDE: /planejador-de-implementacao</span><button class="copy-btn" type="button">Copiar</button></div>
        </article>

      </div>
    </section>
  </main>

  <script>
    // script clássico (não module) — funciona em file://
    document.addEventListener('click', function (ev) {
      var btn = ev.target.closest('.copy-btn');
      if (!btn) return;
      var pre = btn.closest('.msg-card').querySelector('.msg');
      var text = pre.innerText;
      function done() {
        btn.textContent = 'Copiado!';
        setTimeout(function () { btn.textContent = 'Copiar'; }, 1600);
      }
      function fallback() {
        var ta = document.createElement('textarea');
        ta.value = text;
        document.body.appendChild(ta);
        ta.select();
        try { document.execCommand('copy'); done(); } catch (e) {}
        document.body.removeChild(ta);
      }
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(done, fallback);
      } else {
        fallback();
      }
    });
  </script>
</body>
</html>
```

- [ ] **Step 3: Remover o COMO-USAR.md**

Run: `git rm COMO-USAR.md`

- [ ] **Step 4: Verificar**

Run: `grep -c 'prompts/' COMO-USAR.html && grep -c 'msg-card' COMO-USAR.html && grep -n 'type="module"' COMO-USAR.html ; echo "module-exit=$?"`
Expected: 18 referências a `prompts/`; 18+ `msg-card` (1 por card no mínimo); `module-exit=1` (nenhum ES module — regra da casa para `file://`). Abra `file:///.../COMO-USAR.html` no navegador e teste o botão Copiar de 1 card por trilha.

- [ ] **Step 5: Commit**

```bash
git add COMO-USAR.html
git commit -m "feat: COMO-USAR.html com mensagens prontas por trilha (substitui o .md)"
```

---

### Task 13b: `INSTALAR.md` — guia de instalação para o assistente de IA

**Files:**
- Create: `INSTALAR.md`

- [ ] **Step 1: Criar o arquivo (conteúdo completo)**

````markdown
# INSTALAR.md — guia de instalação (para o seu assistente de IA executar)

> **Você, assistente** (Amazon Q, GitHub Copilot, Claude ou outro agente com acesso a
> arquivos): este arquivo é um runbook para VOCÊ executar, não um texto para resumir ao
> usuário. Siga os passos na ordem. O objetivo é instalar o pack `arquitetura` no
> repositório do serviço do usuário.

## Passo 0 — Confirme o alvo

Identifique a RAIZ do repositório do serviço onde o pack será instalado. Se não estiver
claro pelo contexto, pergunte ao usuário. Duas regras:

- NUNCA instale dentro do próprio pack (o diretório que contém este INSTALAR.md).
- O alvo deve ser a raiz do repo (onde fica o `.git/`), não uma subpasta.

## Passo 1 — Caminho preferido: rode o script

Se você pode executar comandos de shell:

- **macOS / Linux:** `bash <caminho-do-pack>/install.sh <raiz-do-repo-alvo>`
- **Windows:** `powershell -ExecutionPolicy Bypass -File <caminho-do-pack>\install.ps1 -Target <raiz-do-repo-alvo>`
- Opcional: acrescente `--with-examples` (sh) ou `-WithExamples` (ps1) para incluir as
  páginas HTML de exemplo.

O script é idempotente e termina com a lista do que copiou. Se der erro, a mensagem é
autoexplicativa (alvo inexistente, opção desconhecida, alvo = próprio pack) — corrija e
rode de novo. Se o script funcionou, pule para o Passo 3.

## Passo 2 — Fallback: cópia manual (se você não pode rodar shell)

Copie do pack para a raiz do repo alvo, preservando a estrutura de pastas:

| Origem (pack) | Destino (repo alvo) |
|---|---|
| `.amazonq/rules/architecture-style.md`, `frontend-style.md`, `negocio-style.md`, `engenharia-style.md` | `.amazonq/rules/` |
| `.github/copilot-instructions.md` | `.github/` |
| `.github/instructions/*.instructions.md` (as 4 de estilo) | `.github/instructions/` |
| `.github/prompts/` (inteira) | `.github/prompts/` |
| `.github/skills/` (inteira) | `.github/skills/` |
| `prompts/arquitetura/`, `prompts/frontend/`, `prompts/negocio/`, `prompts/engenharia/` (inteiras) | `prompts/` |
| `design-system/*.css` | `design-system/` |
| `templates/diagram-viewer.js`, `templates/sidebar.js` | `templates/` |
| `COMO-USAR.html` | raiz do repo |

**NUNCA copie (nem sobrescreva se existirem no alvo):**

- `.amazonq/rules/project-context.md` e `.amazonq/rules/business-context.md`
- `.github/instructions/project-context.instructions.md` e `business-context.instructions.md`

Esses 4 são por-serviço, gerados pelos analisadores DEPOIS da instalação. Se já existem
no alvo, é uma instalação anterior — preserve-os intactos.

Também não copie: `templates/*.html` (exemplos, só se o usuário pedir), `tools/`,
`INSTALAR.md`, `README.md`, `LICENSE`, `docs/` — são do pack, não do serviço.

## Passo 3 — Verifique a instalação

Confira que TODOS estes paths existem no repo alvo (via shell ou listagem de arquivos):

- `.amazonq/rules/` com as 4 rules de estilo
- `.github/copilot-instructions.md` + `.github/instructions/` com 4 arquivos `.instructions.md`
- `.github/prompts/` com 18 arquivos `.prompt.md` e `.github/skills/` com 18 subpastas
- `prompts/` com as 4 trilhas (7 + 4 + 5 + 2 = 18 arquivos `.md`)
- `design-system/` com 2 `.css`; `templates/` com os 2 `.js`; `COMO-USAR.html` na raiz

Se algo faltar, volte ao passo que o copia. Não declare a instalação concluída sem
esta verificação (evidência antes de afirmação).

## Passo 4 — Re-instalação / atualização

Rodar de novo é seguro: os scripts (e a regra do Passo 2) preservam os 4 arquivos de
contexto por-serviço. O resto é sobrescrito com a versão nova do pack — é o esperado.

## Passo 5 — Oriente o usuário (primeiro uso)

Ao terminar, diga ao usuário, nas suas palavras:

1. A instalação está completa e verificada (mostre a lista do Passo 3).
2. O primeiro passo de uso é gerar o contexto do projeto: mensagem "analisa o projeto"
   (Amazon Q) ou `/analisador-de-projeto` (Copilot IDE). Sem isso, o pack bloqueia
   gerações de documentação de propósito.
3. As mensagens prontas para todos os fluxos estão em `COMO-USAR.html` — abrir no navegador.

## Regras para você, assistente

- Não modifique nenhum arquivo do pack ao copiar — cópia fiel.
- Não rode `tools/sync-copilot.sh` no repo alvo: é ferramenta de manutenção do pack.
- Não commite nada sem o usuário pedir.
````

- [ ] **Step 2: Verificar consistência com os installers**

Run: `diff <(grep -oE '(architecture|frontend|negocio|engenharia)-style' INSTALAR.md | sort -u) <(grep -oE '(architecture|frontend|negocio|engenharia)-style' install.sh | sort -u)`
Expected: diff vazio (as mesmas 4 rules citadas). Confira manualmente que a tabela do Passo 2 cobre exatamente o que o `install.sh` copia (itens 1-6) e que a lista de "nunca copie" tem os 4 arquivos de contexto.

- [ ] **Step 3: Commit**

```bash
git add INSTALAR.md
git commit -m "feat: INSTALAR.md — runbook de instalacao para o assistente de IA executar"
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
grep -rn -iE '@workspace|modo write' prompts/ COMO-USAR.html ; echo "neutro-exit=$?"
grep -rn 'templates/negocio' . --include='*.md' ; echo "pendurado-exit=$?"
[ -f COMO-USAR.html ] && [ ! -e COMO-USAR.md ] && [ -f INSTALAR.md ] && echo "guias-ok"
grep -rn 'COMO-USAR\.md' README.md install.sh install.ps1 INSTALAR.md ; echo "ref-velha-exit=$?"
git status --porcelain
```
Expected: `OK: .github/ em sincronia...`; `neutro-exit=1`; `pendurado-exit=1`; `guias-ok`; `ref-velha-exit=1` (nenhuma referência ao .md antigo); working tree limpo.

- [ ] **Step 6: Passos manuais do usuário (fora desta máquina) — registrar como pendência na entrega**

1. Windows do trabalho: `powershell -ExecutionPolicy Bypass -File install.ps1 -Target <repo-teste>` (confere mojibake zero e instalação completa).
2. VS Code + Copilot: abrir repo instalado, rodar `/analisador-de-projeto`, conferir que os DOIS arquivos de contexto são gerados.
3. Amazon Q: fluxo atual de regressão ("documenta esse serviço").
4. Copilot CLI: gatilho natural "investiga esse bug" → deve carregar o depurador.

---

## Self-review (do plano contra o spec)

- **Spec §3 estrutura** → Tasks 1-6, 9 ✓ · **§4 camada gerada** → Tasks 2, 9 ✓ · **§5 gate duplo** → Tasks 3, 8 ✓ · **§6 neutralização** → Task 8 ✓ · **§7 trilha engenharia** → Tasks 4-7 ✓ · **§8 fixes auditoria** → Tasks 3, 10, 11, 14 ✓ · **§9 README/COMO-USAR.html/INSTALAR.md** → Tasks 12, 13, 13b ✓ · **§10 validação** → Task 14 ✓.
- Mudança de escopo pós-aprovação (registrada no spec): COMO-USAR vira `.html` de mensagens prontas (Task 13) e nasce `INSTALAR.md` como runbook para o assistente de IA (Task 13b). Installers e validação atualizados em conformidade.
- Placeholders: nenhum — todo arquivo novo tem conteúdo integral; edições têm old/new exatos ou regra de transformação + gate de grep.
- Consistência: slugs do manifest = nomes dos arquivos em `prompts/` (18/18); frase de auto-load padronizada (Task 3) = alvo do sed (Task 2); paths citados nos prompts novos existem após Task 9.
