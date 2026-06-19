# Design — Pipeline de arquitetura rígido (v2): 7 etapas + validadores + QA-ledger + atualizador

- **Data:** 2026-06-19 (revisão 1.1 — pós-revisão adversarial, ver §13)
- **Status:** APROVADO para planejamento (revisão 1.1 aprovada pelo usuário; Decisão #10 confirmada via QA.md)
- **Autor:** Matheus + Claude (brainstorming + human-architect-mindset)
- **Task de controle:** doc/controle/2026-06-19-pipeline-arquitetura-v2/
- **Q&A do brainstorming:** doc/controle/2026-06-19-pipeline-arquitetura-v2/QA.md

## 1. Objetivo

No último uso, a doc gerada **não seguiu o padrão visual do template**. A causa-raiz (mapeada por 6 leitores
paralelos) NÃO é falta de prompt: é **falta de enforcement** + **ambiguidade**. Especificamente:

- O template (`ia/templates/`) é tratado só como "referência de FORMA", nunca como obrigação; o
  enforcement é 100% mental ("verifique mentalmente", `architecture-style.md:280`, `frontend-style.md:301`).
- O Mermaid só falha em runtime no browser (`diagram-viewer.js`); nada valida antes de entregar o HTML.
- Há **3 destinos de gravação contraditórios** nas regras: `ia/templates/` (`architecture-style.md:172,247`),
  `doc/arquitetura/` (`doc/arquitetura/README.md`) e `docs/<servico>/` (`gerador-adr.md:91`,
  `sincronizar-doc-codigo.md:42,59,68`).
- O input do usuário (respostas às perguntas-âncora + grilling) não fica registrado de forma estruturada.

Este redesign torna o padrão **obrigatório, verificável e granular**: quebra o fluxo em **7 etapas
conceituais sequenciais (que correspondem a 8 sessões — Etapa 1 tem 2 sessões)**, cada prompt em sessão
própria; adiciona 2 validadores executáveis (front/template e sintaxe/Mermaid); acopla "iniciar
documentação → abrir task de controle + QA-ledger"; unifica o destino em `doc/arquitetura/`; e cria um
prompt complementar `atualizador-arquitetura` (fora da trilha numerada) para conformar doc já existente.
Modelo-alvo continua Claude Sonnet 4.6 / Opus em Amazon Q, Copilot e Kiro — portabilidade é restrição de
1ª classe.

## 2. Decisões e justificativas (aprovadas no brainstorming)

| # | Decisão | Escolha | Procedência | Por quê |
|---|---|---|---|---|
| 1 | Split | **7 etapas** = 5 geração + 2 validadores (denominador /7) | usuário (QA.md:13-19) | Granularidade pedida; cada etapa fica enforce-ável isolada. |
| 1b | **Sessão** | **Cada PROMPT em sessão própria.** Etapa 1 = 2 sessões (1a + 1b); total = **8 sessões para 7 etapas conceituais** | usuário (QA.md:15 verbatim) | Invariante master que veio em CAPS do input. Não tem como Etapa 1 reusar 2 prompts maduros em 1 sessão sem violar isso. |
| 2 | Etapa 1 | Reúne `analisador-de-projeto` (contexto) + `analisador-de-dominio` (domínio) como **2 sessões consecutivas** | proposta minha (aceita: QA.md:46 "recomendado") | Reusa prompts maduros; menos superfície a manter que um prompt novo combinado. **Nota:** `analisador-de-dominio` vive em `ia/prompts/negocio/` — é reusado pela trilha arquitetura, NÃO movido nem duplicado. |
| 3 | Orquestradores | **`completar-documentacao` aposentada (deletada — sem stub)**; **`documentar-servico` repropósito** como índice da trilha (preserva o gatilho "documenta esse serviço" → aponta as 7 etapas) | proposta minha (aceita: QA.md:46 "recomendado") | Mantém o gatilho de entrada sem violar a regra de sessão-própria. |
| 4 | Rigidez | **Híbrido**: checklist obrigatório com evidência (portável) + `ia/tools/validar-doc.sh` opcional (determinístico quando o ambiente permite) | usuário (QA.md:21) | Garante em todo harness; determinístico quando dá rodar binário. |
| 5 | Sessão (texto) | Texto explícito no índice da trilha + topo de cada prompt + COMO-USAR: *"A documentação de arquitetura são 7 etapas, em 8 sessões (Etapa 1 = 2 sessões). Rode TODAS na ordem 1→7, **cada prompt em sessão própria**."* | usuário (QA.md:15 verbatim) | Rigidez de processo; evita contaminação de contexto entre etapas. |
| 6 | Ledger de input | **`QA.md` próprio por task**, status vivo (apendar no **mesmo turno** da resposta), captura TODAS as perguntas (7 âncora + grilling), regra binária: **verbatim sempre que houver decisão** (escolha entre opções, nome de tecnologia, restrição numérica/temporal); caso contrário **normalizada** (1 linha) | usuário (QA.md:24) | Documenta o input; não estoura o cap de 60 linhas do `LEDGER.md` nem polui suas 3 seções. |
| 7 | Acoplamento | **Iniciar documentação abre task de controle ANTES de gerar** | usuário (seed, QA.md:8-11) | Hoje doc e task nem se falam; é o que garante o QA-ledger nascer. |
| 8 | Destino | **`doc/arquitetura/` (páginas) + `doc/adr/` (ADRs)**; `ia/templates/` vira só referência | usuário (QA.md:34) | Pré-requisito dos validadores (onde varrer); espelha o layout do pack pós-reorg; elimina o maior drift. |
| 9 | Fronteira do template | Quantidade de seções/páginas é **livre** (quebrar é incentivado). MUST = 3 invariantes co-iguais: **(a) navegável** (entry no NAV + link funcional) + **(b) estilo visual** (esqueleto + vocabulário fechado + cores via `var(--color-*)`) + **(c) regras de UI/UX** (enumeradas em §5.1.3) | usuário (QA.md:28-32 verbatim, 3 DEVE em CAPS) | Cada arquitetura é única; o imutável é a forma e a navegabilidade. |
| 10 | Atualizador | Diagnostica e **ramifica**: drift de front → plano de ajuste + conforma; drift lógico → grill gravando no QA.md. **1 task de controle por execução**, cobrindo toda a pasta `doc/arquitetura/` analisada | usuário (QA.md:37-41 verbatim para a ramificação; QA.md "deva ser somente uma task" verbatim para a granularidade) | Re-validação de doc existente sob as novas regras. |
| 11 | NAV editor | **A etapa de geração que cria o `.html` é responsável por apendar a entry `{label,href}` no `NAV` em `sidebar.js`**, na seção correta. Validador #6 só confere. Sem helper automático | proposta minha (resolve risco) | Sem isso, `sidebar.js` vira lacuna de implementação e #6 cai em loop. |
| 12 | Aplicação de correções | **#5 grill aplica inline** após confirmação no grill (já é hoje). **#6 e #7 SÓ REPORTAM** (pass/fail + violações `arquivo:linha`). Aplicação volta para o prompt gerador correspondente OU para o `atualizador-arquitetura` | proposta minha (resolve ambiguidade) | Evita validador editar à revelia; mantém autoria da geração no gerador. |

## 3. A trilha de arquitetura — 7 etapas / 8 sessões

Ordem de execução **1→7**, cada prompt em **sessão própria** (Etapa 1 = 2 sessões consecutivas).
Geração primeiro, lógica (5), depois forma (6,7).

| Etapa | Sessão | Prompt | Tipo | Saída |
|---|---|---|---|---|
| 1 | 1a | `analisador-de-projeto` (em `ia/prompts/arquitetura/`) | geração — contexto | `project-context.md` em 3 destinos de **rules** (`.amazonq/rules/`, `.github/instructions/`, `.kiro/steering/`) |
| 1 | 1b | `analisador-de-dominio` (em `ia/prompts/negocio/`, reusado) | geração — domínio | `business-context.md` em 3 destinos de **rules** |
| 2 | 2 | `arquiteto-de-sistema` | geração | páginas-núcleo em `doc/arquitetura/` + entries no NAV |
| 3 | 3 | `documentador-fluxo` | geração | página(s) de fluxo crítico em `doc/arquitetura/` + entries no NAV |
| 4 | 4 | `gerador-runbook` | geração | `doc/arquitetura/runbook.html` + entry no NAV |
| 5 | 5 | `grill-arquitetura` | validação **lógica** | correções inline (aplica após grill confirmar) + tabela de certezas |
| 6 | 6 | `validador-visual` (NOVO) | validação **visual — só reporta** | relatório pass/fail + lista de violações `arquivo:linha` |
| 7 | 7 | `validador-sintaxe-mermaid` (NOVO) | validação **forma — só reporta** | relatório pass/fail + lista de violações `arquivo:linha` |

### 3.1 Handoffs (prosa, sequência fechada)

```
1a analisador-de-projeto  →  1b analisador-de-dominio  →  2 arquiteto-de-sistema
   →  3 documentador-fluxo  →  4 gerador-runbook  →  5 grill-arquitetura
   →  6 validador-visual  →  7 validador-sintaxe-mermaid  →  FIM
```

Cada prompt termina com snippet "próximo passo" apontando o próximo nome. `documentar-servico` deixa de
orquestrar e vira o **índice** (apresenta a trilha e os 8 snippets); não é etapa numerada.

### 3.2 Notas estruturais

- Etapas 2-5 já existem como prompts atômicos no `manifest.tsv` — viram as etapas direto, com os rótulos
  e handoffs em prosa reescritos para a sequência 1→7.
- **NAV é responsabilidade do gerador** (Decisão #11): cada etapa de geração (2, 3, 4) tem bullet
  obrigatório de saída "apendar entry `{label, href}` na seção correta do `NAV` em `sidebar.js`".
- Não há maquinaria de orquestração programática — handoffs continuam em prosa.

## 4. Destino único e correções de drift (pré-requisito)

- Páginas geradas → **`doc/arquitetura/`**; ADRs → **`doc/adr/`** (irmãos sob `doc/`, espelhando o pack).
- Corrigir: `architecture-style.md:172,247` (`ia/templates/` → "referência/exemplo de forma apenas"),
  `gerador-adr.md:91` e `sincronizar-doc-codigo.md:42,59,68` (`docs/<servico>/` → `doc/`).
- `ia/templates/` permanece como o **gabarito canônico de forma** (referência), nunca destino de gravação.

## 5. Validadores #6 e #7 — enforcement híbrido

Cada validador é um prompt que:

1. **Sempre** preenche o **checklist canônico** (§5.4) com evidência (`arquivo:linha` ou trecho do HTML) —
   camada portável ativa em todo harness.
2. **Tenta uma vez** invocar `ia/tools/validar-doc.sh` com a flag apropriada (Decisão #4). Heurística de
   fallback (§5.5): qualquer falha de ambiente cai pro checklist sem perguntar ao usuário.

Saída padronizada: **lista de violações `arquivo:linha` + veredito pass/fail**. Os validadores **só
reportam** (Decisão #12) — não editam arquivos. Molde do único acceptance-test executável que já existe
(`analisador-de-projeto.md:226-238`).

### 5.1 Validador #6 — front/template (`validador-visual`)

REJEITA quando qualquer regra abaixo falha. As 3 dimensões refletem os 3 MUSTs em CAPS do usuário (QA.md:28-32).

#### 5.1.1 Navegabilidade (DEVE ficar na sidebar e ser navegável)
- Cada `.html` em `doc/arquitetura/` tem entry `{label, href}` na seção certa do `NAV` em `sidebar.js`.
- O `href` resolve para o arquivo existente (sem entries quebradas).
- Não há entry no `NAV` apontando para arquivo inexistente (NAV órfão inverso).

#### 5.1.2 Estilo visual (DEVE seguir o estilo)
- `<head>` na ordem fixa: `meta charset` → `meta viewport` → `title` → `meta description` → `script src="../templates/prefs.js"` → `link tokens.css` → `link components.css` (CSS sempre em `../design-system/`).
- Body em `div.shell > aside#sidebar.sidebar + main#main.main`.
- Toda classe usada está na **lista canônica** em `ia/tools/lib/design-system-classes.txt` (fonte única — Decisão SoT em §5.6).
- Toda cor de UI via `var(--color-*)`; **zero hex hardcoded** fora dos `classDef` do Mermaid.
- Scripts finais: `sidebar.js` sempre; `diagram-viewer.js` apenas se houver diagrama; classic script (nunca `type=module`).

#### 5.1.3 Regras de UI/UX (DEVE obedecer)
Gate enumerado (não "regras de UI/UX em geral"):
- Cabeçalho de seção SEMPRE `h2.section-eyebrow`; subseção `h3` simples; texto `p.prose`.
- Página de conteúdo abre com `nav.breadcrumb + header.hero` (com `hero__eyebrow` + `hero__title` contendo um `span.accent-word` + `hero__subtitle`).
- Diagrama segue padrão de 2 partes obrigatório (figure + script `text/mermaid` com `data-id` ↔ `data-diagram` pareados 1:1).
- Sem resíduo do exemplo fictício (lista lida de `ia/tools/lib/forbidden-terms.txt` — inicialmente "Liquidação Transacional", "FICO Falcon"; case-insensitive substring match).

**NÃO é violação:** quantidade de seções ou de páginas — quebrar para evitar HTML extenso é incentivado.

### 5.2 Validador #7 — sintaxe + Mermaid (`validador-sintaxe-mermaid`)

REJEITA quando:
- `data-diagram` (no `div.diagram-viewer`) sem `script[type=text/mermaid][data-id]` pareado 1:1.
- 1ª linha do bloco Mermaid não é tipo válido (`flowchart`, `sequenceDiagram`, `classDiagram`, `stateDiagram-v2`, `erDiagram`).
- Bloco sem os **4 `classDef`** com os hex EXATOS lidos de `ia/tools/lib/mermaid-classdefs.txt`.
- Label com `<`/`>` crus, `\n` dentro de label, ou texto com espaço/pontuação sem aspas.
- **Sequence diagram sem `autonumber`** (regra binária: TODO `sequenceDiagram` em `doc/arquitetura/**/*.html` DEVE ter `autonumber`. Sem exceção).
- Comparadores não escapados em labels (`>`/`<` → `&gt;`/`&lt;`).
- Tipografia Butterick (`frontend-style.md` §7, linhas 205-241) ausente onde aplicável: aspas tipográficas (" "), em/en dash (— –), reticências (…), sinal de multiplicação ×, ≥/≤, número PT-BR `1.234,56`.

### 5.3 `ia/tools/validar-doc.sh` (novo, opcional — Decisão #4)

CLI canônica:

```
ia/tools/validar-doc.sh <pasta> [--front | --mermaid | --all]
```

- **`<pasta>`** é tipicamente `doc/arquitetura/`.
- **`--front`** invocado pelo validador #6: rules de 5.1 (vocabulário, esqueleto, cores, NAV, regras UI/UX, forbidden-terms).
- **`--mermaid`** invocado pelo validador #7: rules de 5.2 (pareamento, classDef, labels, autonumber).
- **`--all`** atalho para uso manual: roda os dois conjuntos.
- **Exit codes:** `0` = clean, `1` = violations (lista no stdout, formato `arquivo:linha: regra: descrição`), `2` = ambiente sem `mermaid-cli` ou outras deps opcionais (relata fallback gracioso — validador cai no checklist).
- O script lê as listas canônicas de `ia/tools/lib/` (Decisão SoT §5.6); sem hardcode de regras dependentes.
- Upgrade opcional: parse headless de Mermaid via `mermaid-cli` quando disponível (não obrigatório).
- Não é a única linha de defesa — o checklist é (Decisão #4).

### 5.4 Formato canônico do checklist (gate de resposta)

Cada validador #6/#7 DEVE iniciar a resposta com este bloco (extraído para `ia/templates/checklist-validador.md`):

```markdown
## Checklist do validador

| Regra | Status | Evidência |
|---|---|---|
| <id da regra (ex.: 5.1.2 ordem do head)> | PASS / FAIL / N-A | `arquivo:linha` ou trecho HTML |
| ... | ... | ... |

**Veredito:** PASS (zero FAIL) | FAIL (lista N violações abaixo)
```

Sem esse bloco no início, a etapa **não conta como concluída** — o handoff para a próxima etapa pede que o
usuário re-invoque na sessão correta.

### 5.5 Heurística de fallback (qual ambiente "permite")

O prompt do validador instrui: tente `ia/tools/validar-doc.sh <pasta> --<flag>` **uma vez**.
- Sucesso (exit 0 ou 1) → integre o output ao checklist.
- Exit 2 ou ferramenta de Bash indisponível ou comando inexistente → o checklist é a defesa; relate
  "modo fallback" no veredito; não pergunte ao usuário.

Para Amazon Q / Kiro sem shell, o checklist roda sozinho com leitura dos arquivos via tool de Read.

### 5.6 Source of Truth das listas (resolve duplicação)

Três arquivos em `ia/tools/lib/`, lidos pelo prompt do validador E pelo `validar-doc.sh`:

| Arquivo | Conteúdo | Lido por |
|---|---|---|
| `design-system-classes.txt` | Lista de classes permitidas, uma por linha | #6 + `validar-doc.sh --front` |
| `mermaid-classdefs.txt` | Os 4 `classDef` com hex EXATOS | #7 + `validar-doc.sh --mermaid` |
| `forbidden-terms.txt` | Termos proibidos (resíduo de exemplo), um por linha (case-insensitive) | #6 + `validar-doc.sh --front` |

Adicionar/remover classe = editar **um** arquivo. Nada é hardcoded em prompt.

## 6. Rigidez transversal (rules)

- **Regra master: cada PROMPT da trilha roda em sessão própria** (verbatim do usuário) — adicionada em
  `architecture-style.md` (e propagada aos mirrors via sync). Cada prompt da trilha cita a regra no STATUS de topo.
- **Texto de sequência** (no índice `documentar-servico` + `architecture-style.md` + COMO-USAR):
  *"A documentação de arquitetura são 7 etapas em 8 sessões (Etapa 1 = 2 sessões). Rode TODAS na ordem
  1→7, cada prompt em sessão própria."*
- Os checklists hoje mentais (`architecture-style.md:280`, `frontend-style.md:301`) viram **checklist
  obrigatório preenchido na resposta com evidência** (§5.4) — gate de resposta, não "verifique mentalmente".

## 7. Controle + QA.md (documentar o input)

- **Acoplamento:** a Etapa 1 (sessões 1a e 1b) e o `atualizador-arquitetura` passam a **citar o protocolo
  de controle** e abrir a task ANTES de gerar (hoje só `sincronizar-doc-codigo.md:79` faz). Não depende só
  do hook de início de interação.
- **Novo arquivo `doc/controle/<task>/QA.md`** (formato canônico):
  ```markdown
  # QA — <task-id>

  ## Perguntas & Respostas
  - [AAAA-MM-DD] P: <pergunta feita ao usuário>
    R: <normalizada em 1 linha>          # se NÃO houver decisão
    R: verbatim: "<trecho do usuário>"   # se houver decisão (escolha/nome/restrição)
  ```
- **Status vivo (Decisão #6, parte 1):** apendar pergunta+resposta ao QA.md **no mesmo turno** em que a
  resposta chega, antes de continuar o grilling. Edição lazy ao final é proibida.
- **Regra binária verbatim/normalizada (Decisão #6, parte 2):**
  - **Verbatim** sempre que a resposta contenha **decisão** — escolha entre opções, nome de tecnologia,
    restrição numérica/temporal, valor de configuração.
  - **Normalizada** (1 linha) no resto.
- `controle-de-tarefa.md` ganha o template do `QA.md`; `controle-style.md` ganha a regra (criar QA.md
  quando a task é de doc; status vivo; regra binária). O cap de 60 linhas do `LEDGER.md` permanece
  (QA.md é arquivo à parte).
- Propagar a regra "apendar Q&A ao QA.md no mesmo turno" aos prompts de grilling: `analisador-de-projeto`,
  `analisador-de-dominio`, `arquiteto-de-sistema`, `grill-arquitetura`.

## 8. `atualizador-arquitetura` (prompt complementar — doc já existente)

Fora da trilha numerada. Diagnostica a doc existente em `doc/arquitetura/` e **ramifica** por tipo de drift
(QA.md:37-41 verbatim):

- **Front (UI/UX / template / classes / Mermaid / NAV / resíduo fictício):** gera um **plano de ajuste**
  como seção no TASK.md da task de controle, e **conforma in-place** (aplica #6/#7 sobre o existente —
  como o atualizador É quem está autorizado a editar, não viola a regra "validadores só reportam").
- **Arquitetural / lógico (incertezas, garantias não resolvidas, lacuna de conteúdo):** abre um **grill**
  como `grill-arquitetura`, registrando cada par P→R no **`QA.md`** da task.

**1 task de controle por execução** (Decisão #10), cobrindo toda a pasta `doc/arquitetura/` analisada.
O QA.md acumula o grill lógico; o plano de ajuste de front vai como seção no TASK.md. Para tratar
páginas isoladas em tasks separadas, o usuário invoca o atualizador uma vez por página.

Ordem de checagem proposta (não verbatim do QA — proposta coerente com o input): validação geral →
compara com template → valida front+sintaxe (#6 + #7) → valida resultado final (lógica via grill).

## 9. `ia/COMO-USAR.html` (entregável)

- Reescrever a **trilha de arquitetura** no topo: **7 cards "Etapa N/7"** na sequência, com **bloco de
  cabeçalho explícito**: *"A trilha tem 7 etapas (8 sessões — Etapa 1 = 2 sessões). Rode TODAS na ordem
  1→7, cada prompt em sessão própria."*
- **Card Etapa 1/7 explicita as 2 sessões**: "esta etapa tem 2 sessões — rode `analisador-de-projeto`
  primeiro e `analisador-de-dominio` em seguida, ambas em sessão própria, antes de ir para Etapa 2/7".
- Atualizar o **card COMBO** (identificá-lo por âncora estável `id="combo-arquitetura"` em vez de número
  de linha) para a sequência de 7 etapas + a nota das 2 sessões da Etapa 1.
- Adicionar card do **`atualizador-arquitetura`** (subseção "doc já existente").
- Cards apontam `ia/prompts/...`; mensagens prontas por etapa.
- COMO-USAR.html é **canônico**; rodar `bash ia/tools/sync-como-usar.sh` após editar (senão `--check` = DRIFT, exit 1).

## 10. Ripple / máquina (sem editar mirror à mão)

**Aritmética travada (verificada):**
- Hoje: arquitetura **11**, frontend 4, negocio 5, engenharia 10 = **30** prompts.
  *(O `ia/INSTALAR.md:99` afirma "arquitetura 10" — erro próprio do INSTALAR.md a corrigir.)*
- Após v2: arquitetura **13** (11 − 1 aposentada + 3 novas), trilhas outras inalteradas = **32** prompts.
- Skills/wrappers: 62 → **64** (cada um dos 3 novos prompts gera 1 wrapper Copilot + 1 Kiro; sem exceção).

**Passos:**

1. **`ia/tools/manifest.tsv`** — 3 operações distintas:
   - **Deletar** a linha `completar-documentacao` (aposentada — sem stub).
   - **Reescrever** a descrição de `documentar-servico` como *"Índice da trilha de 7 etapas: aponta as
     etapas 1→7, em sessão própria; cada prompt em sessão própria."*
   - **Renumerar** as descrições: `arquiteto-de-sistema` (Etapa 2/7), `documentador-fluxo` (3/7),
     `gerador-runbook` (4/7), `grill-arquitetura` (5/7).
   - **Adicionar** 3 linhas novas: `validador-visual` (Etapa 6/7), `validador-sintaxe-mermaid` (Etapa 7/7),
     `atualizador-arquitetura` (complementar — fora da trilha).

2. **Criar os `.md` novos** em `ia/prompts/arquitetura/` ANTES do sync (`sync-*.sh` aborta se o manifest
   apontar para arquivo inexistente): `validador-visual.md`, `validador-sintaxe-mermaid.md`,
   `atualizador-arquitetura.md`. **Deletar** `ia/prompts/arquitetura/completar-documentacao.md`.

3. **Criar `ia/tools/lib/`** com `design-system-classes.txt`, `mermaid-classdefs.txt`, `forbidden-terms.txt`
   (SoT — §5.6); **criar `ia/templates/checklist-validador.md`** (formato §5.4); **criar `ia/tools/validar-doc.sh`** (§5.3).

4. **`bash ia/tools/sync-copilot.sh` + `bash ia/tools/sync-kiro.sh`** (regeneram `.github/` e `.kiro/`,
   incluindo `--prune` para remover wrappers órfãos do `completar-documentacao`). Cada prompt novo gera
   `.github/prompts/<slug>.prompt.md` + `.github/skills/<slug>/SKILL.md` + `.kiro/skills/<slug>/SKILL.md`.

5. **`architecture-style.md`**: bloco "Fluxo canônico" (`:157-162`, 3→7 etapas), tabela de gatilhos
   (`:139-155`, rótulos `Etapa N/3` → `N/7` + 1 linha de gatilho por prompt novo), destino único,
   regra master de sessão.

6. **Handoffs em prosa**: reescrever em cada prompt da cadeia + STATUS de topo que dizem "3 etapas".
   Grafo em §3.1.

7. **`ia/COMO-USAR.html`** + `sync-como-usar.sh` (§9).

8. **`controle-de-tarefa.md`** + **`controle-style.md`** (§7).

9. **3× `--check` pós-mudanças** (todos devem sair 0):
   ```
   bash ia/tools/sync-copilot.sh   --check
   bash ia/tools/sync-kiro.sh      --check
   bash ia/tools/sync-como-usar.sh --check
   ```

10. **Inventário stale (contagens hardcoded)** — varrer com comando concreto antes de fechar a
    implementação:
    ```
    grep -rEn '(de 3|30 wrappers|29 prompts|31 skills|60 wrappers|87 |arquitetura 10|arquitetura 11)' .
    ```
    Esperado: corrigir 100% dos matches. Arquivos previamente identificados:
    - `README.md:20,172-176,178,185` (29/31/60/87) → atualizar.
    - `ia/INSTALAR.md:99` ("arquitetura 10" → "arquitetura 13"); breakdown total e contagens correlatas.
    - `install.sh:12,76,87,99` e `install.ps1:12,76,90,104` (echos "30 wrappers" / "62: 30+32").
    - Cabeçalhos `sync-copilot.sh:9-10` / `sync-kiro.sh:8` (contagens em comentário).
    - `ia/skills/README.md`.

## 11. Não-objetivos (YAGNI)

- NÃO criar maquinaria de orquestração programática entre etapas (handoffs continuam em prosa).
- NÃO tornar `validar-doc.sh` a única defesa nem obrigatório (portabilidade > determinismo).
- NÃO renomear o repo nem mexer nas trilhas negócio/frontend/engenharia.
- NÃO reescrever conteúdo do template (`ia/templates/*.html`) — só promovê-lo a gabarito obrigatório.
- NÃO criar stub deprecated para `completar-documentacao` — delete completo.

## 12. Riscos / pontos de atenção

- **Volume de mudança nas contagens**: muitos arquivos com números hardcoded; risco de deixar um stale.
  Mitigação: comando de varredura concreto (§10.10).
- **`sidebar.js` mantido à mão**: resolvido por Decisão #11 (gerador edita; #6 confere).
- **`validar-doc.sh` portátil**: regex pega os padrões conhecidos que mais quebram; parse real só onde
  houver `mermaid-cli`. Documentar a limitação no próprio script + exit code 2 (fallback documentado).
- **Tamanho do esforço**: implementação é grande (prompts novos + rules + mirrors + COMO-USAR + controle).
  Decompor em fases no plano de implementação (writing-plans) — pelo menos: (Fase A) SoT + validar-doc.sh;
  (Fase B) prompts novos + manifest + sync; (Fase C) handoffs + rules + COMO-USAR; (Fase D) QA.md + controle;
  (Fase E) inventário stale + verificação final.

## 13. Mudanças desta revisão (auto-revisão adversarial, 2026-06-19)

Esta revisão 1.1 incorpora 28 findings de um painel de 4 críticos (completude, fidelidade, consistência
interna, ambiguidade/acionabilidade). Resumo das resoluções:

- **(alta) Contradição sessão/etapa/prompt** → Decisão #1b cravada: 7 etapas conceituais, 8 sessões,
  invariante master "cada PROMPT em sessão própria". COMO-USAR e card 1/7 explicitam.
- **(alta) Aritmética por trilha** → conferida via `find` (arquitetura = 11 hoje, não 10); pós-v2 = 13;
  total 30→32. Erro próprio do `INSTALAR.md:99` virou item de fix em §10.10.
- **(alta) NAV editor em aberto** → Decisão #11: gerador edita; #6 confere.
- **(alta) Atualizador — quantas tasks** → Decisão #10: 1 task por execução, QA.md acumula grill, plano
  de front em seção do TASK.md.
- **(alta) `validar-doc.sh` CLI** → cravada em §5.3: `<pasta> [--front|--mermaid|--all]`; exit 0/1/2;
  #6 chama `--front`, #7 chama `--mermaid`.
- **(alta) Source of Truth das listas** → §5.6: `ia/tools/lib/{design-system-classes,mermaid-classdefs,forbidden-terms}.txt`.
- **(alta) Validadores aplicam ou só reportam?** → Decisão #12: #5 aplica após grill; #6/#7 só reportam;
  aplicação volta para gerador ou atualizador.
- **(média) "TODOS no começo da trilha"** → interpretação cravada: apresentados no topo do índice
  COMO-USAR; executados como 5/6/7 (validador não pode rodar antes do que valida existir).
- **(média) Ordem de 4 passos do atualizador "dada pelo usuário"** → reclassificada em §8 como "proposta
  coerente com o input" (verbatim do QA só descreve ramificação).
- **(média) 3 MUSTs do template verificáveis** → §5.1.1/5.1.2/5.1.3 enumeram por dimensão.
- **(média) Etapa 1 cruza trilhas** → §3 tabela explicita que `analisador-de-dominio` vive em
  `ia/prompts/negocio/` e é reusado pela trilha arquitetura (sem mover/duplicar).
- **(média) manifest.tsv:27-29 — 3 operações distintas** → §10.1 detalha delete/reescrita/renumber/+3.
- **(média) `autonumber` "quando convenção exige"** → §5.2 cravado binário: sempre.
- **(média) "Apendar Q&A quando"** → §7 cravado: mesmo turno.
- **(média) Verbatim "quando importa"** → §7 regra binária: verbatim sempre que houver decisão.
- **(média) Wrappers para #6/#7/#8** → §10.0 cravado: sim, sem exceção.
- **(média) Heurística de fallback "ambiente permite"** → §5.5 cravada.
- **(média) Formato do checklist** → §5.4 (tabela md canônica) + `ia/templates/checklist-validador.md`.
- **(média) "3 destinos cada"** → §3 tabela: explicito que são 3 destinos de **rules** (não 3 de página HTML).
- **(baixa) `frontend-style.md:208-241`** → corrigido para `:205-241`.
- **(baixa) `README.md:172-185`** → expandido em §10.10 para incluir linha 20.
- **(baixa) `business-context`** → `business-context.md` na §3 tabela.
- **(baixa) "8º prompt"** → "prompt complementar (fora da trilha numerada)".
- **(baixa) Aposentar = delete** → §10.1 + §11 cravado: sem stub.
- **(baixa) Linha 927-939 stale** → §9 troca para âncora estável `id="combo-arquitetura"`.
- **(baixa) "3× --check"** → §10.9 comando completo.
- **(baixa) Grafo de handoffs** → §3.1 desenhado.
- **(baixa) Card 1/7 explicita 2 sessões** → §9 bullet adicionado.

**Confirmação pós-revisão (2026-06-19):** Decisão #10 (atualizador = 1 task por execução) foi confirmada
pelo usuário — *"deva ser somente uma task"* (QA.md, entrada de 2026-06-19). Spec totalmente aprovado.
