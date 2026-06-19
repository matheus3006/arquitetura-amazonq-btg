---
applyTo: "**"
excludeAgent: "code-review"
---
# Architecture Documentation Style Guide

> Aplicado automaticamente pelo GitHub Copilot em todo repositorio que contenha esta pasta (frontmatter `applyTo`).
> Define **o que é exemplo e o que é regra**, mapeia gatilhos de usuário para prompts especializados,
> e estabelece a única convenção rígida deste workspace: a criação de diagramas.

---

## GATE OBRIGATÓRIO — contexto do projeto

**Antes de qualquer geração de documentação**, verifique se o contexto do projeto existe.
Ele mora em TRÊS arquivos com o mesmo conteúdo (um por ferramenta de assistente):

- `.amazonq/rules/project-context.md` (lido pelo Amazon Q)
- `.github/instructions/project-context.instructions.md` (lido pelo GitHub Copilot; começa com frontmatter `applyTo: "**"`)
- `.kiro/steering/project-context.md` (lido pelo Kiro; começa com frontmatter `inclusion: always`)

```
Pedido de geração chega
        ↓
os três arquivos de contexto existem?
        │
        ├── NENHUM existe → carregue `ia/prompts/arquitetura/analisador-de-projeto.md` PRIMEIRO.
        │        Pare a geração original. Conclua a análise. Peça confirmação.
        │        Depois disso o usuário pode reinvocar o pedido original.
        │
        ├── ALGUM falta (repo instalado antes da era multi-tool) → espelhe o conteúdo nos
        │        destinos que faltam (com/sem o frontmatter conforme o lado) e prossiga.
        │
        └── TODOS existem → leia COMPLETO o do seu lado. Use-o como fonte de verdade para:
                 • Nome do serviço (não use "Liquidação Transacional")
                 • Stack real (não copie a do exemplo)
                 • Padrões que NÃO se aplicam (não documente o que está listado como "não usado")
                 • SLO, criticidade, glossário do domínio
                 Depois prossiga normalmente com o prompt indicado pelo gatilho.
```

O contexto do projeto tem **peso de regra**, igual a este arquivo. Quando ele afirma "não usamos Outbox",
isso **sobrescreve** qualquer exemplo em `ia/templates/` que mencione Outbox.

---

## 0. STATUS DESTE WORKSPACE

Antes de qualquer coisa, entenda como tratar o que existe aqui:

| Pasta / arquivo | Status | Como usar |
|---|---|---|
| `.github/instructions/architecture-style.instructions.md` (este arquivo) | **REGRA** | Aplique sempre. Convenções de geração e hooks de prompt. |
| `.github/instructions/frontend-style.instructions.md` | **REGRA** | Aplique sempre. Estrutura HTML e padrão de diagramas. |
| Contexto do projeto: `.amazonq/rules/project-context.md` + `.github/instructions/project-context.instructions.md` + `.kiro/steering/project-context.md` | **REGRA por projeto** (gerada pelo analisador, nos três destinos) | Define este projeto específico. Sobrescreve exemplos. Se não existirem (ou faltar algum), agir conforme o gate acima (analisador ou espelhamento). |
| `ia/prompts/arquitetura/*.md` | **REGRA** (metodologia) | Carregue conforme tabela de hooks. Siga a metodologia descrita. |
| `ia/prompts/frontend/*.md` | **REGRA** (metodologia) | Carregue para tarefas visuais. |
| `ia/design-system/tokens.css` e `components.css` | **REGRA** (CSS) | Use `var(--*)` sempre. Nunca hardcode cor/espaço/raio. |
| `ia/templates/*.html` | **EXEMPLO** | Páginas de um serviço **fictício** chamado "Liquidação Transacional". Demonstram aplicação dos prompts. **Substitua toda substância (nomes, decisões, latências, stack, glossário) pelo serviço REAL** ao gerar nova documentação. Mantenha apenas o esqueleto estrutural. |
| `ia/templates/sidebar.js` e `ia/templates/diagram-viewer.js` | **REGRA** (runtime) | Inclua em toda página gerada. Não substitua por alternativa. |

**Resumo:** estilo de redação, convenção de diagrama, estrutura HTML básica, fluxo dos prompts → **regra**.
Conteúdo concreto, nomes de serviços, decisões específicas, valores de latência, terminologia de domínio → **exemplo, adaptar à realidade**.

---

## 1. A ÚNICA REGRA RÍGIDA DE VISUAL: Convenção de Diagrama

Esta é **a única regra prescritiva sobre visual** neste workspace. Aplicação obrigatória em todo diagrama gerado.

### 1.1 Tecnologia: Mermaid via `diagram-viewer.js`

- Use **Mermaid** (não outras ferramentas de diagrama, não imagens PNG, não SVG estático).
- Renderização via o leitor estático em `ia/templates/diagram-viewer.js`. Esse leitor:
  - Carrega Mermaid e Panzoom como `<script>` clássicos (não ES Modules — quebram em `file://`).
  - Lê a fonte do diagrama de `<script type="text/mermaid" data-id="...">` no fim do `<body>`.
  - Renderiza com tema `neutral` (fundo claro, traços escuros — boa legibilidade).
  - Aplica pan/zoom estilo Figma com controles `+/−/⟲`.

### 1.2 Padrão obrigatório no HTML

```html
<!-- onde o diagrama aparece -->
<figure class="diagram-figure">
  <div class="diagram-viewer" data-diagram="meu-id"></div>
  <figcaption>Figura N — descrição curta.</figcaption>
</figure>

<!-- ao final do <body>, antes dos <script>s -->
<script type="text/mermaid" data-id="meu-id">
flowchart LR
  ...
</script>
```

Nunca use `<div class="mermaid">` inline com a fonte dentro. Nunca importe Mermaid via `<script type="module">`.

### 1.3 Sintaxe: `flowchart` (não `C4Context`)

Use **`flowchart LR`** ou **`flowchart TB`** para diagramas de relação (sistema, container, componente).
Não use `C4Context` — renderização do C4 é instável entre versões do Mermaid.

Para fluxos temporais: **`sequenceDiagram`** com `autonumber`.

### 1.4 As 4 classes visuais obrigatórias

Todo diagrama de relação inclui esta `classDef` no início:

```mermaid
classDef person   fill:#1c4e93,stroke:#0a0c12,color:#ffffff,stroke-width:2px
classDef sys      fill:#4a8fe7,stroke:#0a0c12,color:#ffffff,stroke-width:2.5px
classDef ext      fill:#ffffff,stroke:#1f2937,color:#0a0c12,stroke-width:1.5px
classDef extAsync fill:#f9fafb,stroke:#6b7280,color:#0a0c12,stroke-width:1.5px,stroke-dasharray:5 3
```

Significado:

| Classe | Cor | Quando usar |
|---|---|---|
| `person` | azul escuro institucional (texto branco) | Quem inicia o fluxo: usuário, canal, sistema upstream |
| `sys` | azul accent (texto branco, borda mais grossa) | **O serviço documentado** — sempre o protagonista visual |
| `ext` | branco com borda escura | Dependência externa **síncrona** (gera latência no caminho crítico) |
| `extAsync` | cinza claro com borda **tracejada** | Dependência externa **assíncrona** (não bloqueia o caminho crítico) |

Aplicar via `class NomeDoNo classeVisual` ao final do bloco. Cores **não** são adaptáveis — são a convenção da casa.

### 1.5 Labels com quebra de linha

Use `<br/>` para quebra. Não use `\n`. Mermaid renderiza HTML básico em labels desde que `securityLevel: "loose"` (já configurado no `diagram-viewer.js`).

Evite `<b>`, `<span style=...>` em labels — instáveis. Primeira linha vira título por posicionamento; segunda linha vira descrição.

### 1.6 Wrapper `<figure>` + `<figcaption>`

Toda figura tem legenda numerada: `<figcaption>Figura 1 — descrição.</figcaption>`. Numeração sequencial dentro da página.

---

## 2. Prompt hooks — mapa gatilho → prompt

Antes de responder, identifique se a intenção do usuário casa com algum gatilho abaixo. Se sim, **leia o prompt referenciado** e siga sua metodologia. Combine dois prompts quando a tarefa exigir (ex: brainstorm + adr).

| Quando o usuário pedir / mencionar | Carregue este prompt |
|---|---|
| **Primeira invocação em um repositório** OU "analisa o projeto", "refresh project context", "atualiza contexto" OU par de contexto do projeto ausente/incompleto (ver gate) | `ia/prompts/arquitetura/analisador-de-projeto.md` (**Etapa 1/7 sessão 1a** — sempre antes de qualquer outro prompt) |
| "documentar o serviço do zero", "documentação técnica completa", "começar a documentação do repo" | `ia/prompts/arquitetura/documentar-servico.md` (**ÍNDICE da trilha** — aponta as 7 etapas; cada prompt em sessão própria; NÃO orquestra) |
| "analisar o domínio", "mapear o negócio", "preparar o business-context" (Etapa 1 sessão 1b) | `ia/prompts/negocio/analisador-de-dominio.md` (**Etapa 1/7 sessão 1b** — reusado pela trilha arquitetura) |
| "arquitetura/espinha", "visão geral do serviço", "system/container/sequence diagram" (geração) | `ia/prompts/arquitetura/arquiteto-de-sistema.md` (**Etapa 2/7** — geração; NAV editor obrigatório) |
| "documentar fluxo", "sequência transacional", "fluxograma de processo", "saga", "fluxo de autorização" | `ia/prompts/arquitetura/documentador-fluxo.md` (**Etapa 3/7** — geração; NAV editor obrigatório) |
| "runbook", "documentação operacional", "failure mode", "on-call", "SLO" | `ia/prompts/arquitetura/gerador-runbook.md` (**Etapa 4/7** — geração; NAV editor obrigatório) |
| "grill intenso de arquitetura", "questionar as incertezas da doc", "aprofundar a doc gerada" | `ia/prompts/arquitetura/grill-arquitetura.md` (**Etapa 5/7** — validação lógica; aplica inline; Q&A no QA.md no mesmo turno) |
| "valida visual", "valida template", "verifica padrão visual da doc" | `ia/prompts/arquitetura/validador-visual.md` (**Etapa 6/7** — front/template; SÓ REPORTA; checklist canônico + `ia/tools/validar-doc.sh --front`) |
| "valida sintaxe", "valida mermaid", "verifica diagramas" | `ia/prompts/arquitetura/validador-sintaxe-mermaid.md` (**Etapa 7/7** — sintaxe/Mermaid; SÓ REPORTA; checklist canônico + `ia/tools/validar-doc.sh --mermaid`) |
| "atualizar a doc existente", "conformar doc antiga", "ajustar doc gerada para v2" | `ia/prompts/arquitetura/atualizador-arquitetura.md` (**Complementar — fora da trilha**; doc já existente; 1 task de controle por execução) |
| "sincronizar a doc com o código", "atualizar a doc depois da mudança/merge", "documentar o que mudou na branch" | `ia/prompts/arquitetura/sincronizar-doc-codigo.md` (diff `main...HEAD` → grill do porquê com grill-me + human-architect-mindset → atualiza doc → ADR) |
| "criar ADR", "registrar decisão", "decisão arquitetural", "MADR", "trade-off" | `ia/prompts/arquitetura/gerador-adr.md` (destino: `doc/adr/`) |
| "revisar documentação", "validar ADR", "achar furo na doc", "consistência", "auditoria de doc" | `ia/prompts/arquitetura/grill-doc.md` (revisão geral por 7 lentes, UMA página) |
| "brainstorm", "explorar opções", "ainda não decidi", "ajuda a pensar", "discutir abordagem" | `ia/prompts/arquitetura/brainstorm-arquitetural.md` |
| "design", "cor", "tipografia", "visual", "layout", "como ficar bonito" | `ia/prompts/frontend/designer-ux-controlado.md` |
| "estilo", "paleta", "componente UI", "padrão visual catálogo" | `ia/prompts/frontend/designer-ui-pro-max.md` |
| "design system", "tokens", "padronizar componentes" | `ia/prompts/frontend/design-system-arquitetura.md` |
| "polir", "animação", "micro-interação", "detalhe", "acabamento" | `ia/prompts/frontend/polidor-ui.md` |

**Fluxo canônico de documentação do zero (rev v2 — 2026-06-19) — 7 etapas conceituais / 8 sessões. REGRA MASTER: cada PROMPT em sessão própria. RODE TODAS na ordem 1→7:**

```
1a analisador-de-projeto  →  1b analisador-de-dominio  →  2 arquiteto-de-sistema
→  3 documentador-fluxo  →  4 gerador-runbook  →  5 grill-arquitetura
→  6 validador-visual  →  7 validador-sintaxe-mermaid  →  FIM
```

- Antes da Etapa 1, abra a task de controle em `doc/controle/<AAAA-MM-DD-slug>/` com `TASK.md` + `QA.md` + `LEDGER.md`.
- Para doc **JÁ existente**, use o `atualizador-arquitetura` (complementar, fora da trilha numerada).
- `documentar-servico` deixa de orquestrar — vira o **índice** da trilha.
- `completar-documentacao` **foi aposentado**: os prompts-base (`documentador-fluxo`, `gerador-runbook`) agora são as Etapas 3/7 e 4/7 diretamente.
- O índice e cada prompt seguem disponíveis para refresh pontual de um artefato só.

Quando gerar HTML final, **sempre** aplique também `.github/instructions/frontend-style.instructions.md`.

---

## 3. Esqueleto de página HTML

Todo HTML novo segue este esqueleto (demonstrado em `ia/templates/01-visao-geral.html` — os instaladores copiam as páginas de exemplo por padrão; numa instalação com `--no-examples`, o esqueleto abaixo é a referência completa). Detalhamento em `frontend-style.md`.

**Destino canônico (rev v2):** páginas geradas vivem em **`doc/arquitetura/`** (criada se não existir); ADRs vivem em **`doc/adr/`**. `ia/templates/` é **apenas gabarito de FORMA** (referência), nunca destino de gravação. Detalhes em `frontend-style.md`.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Título · Nome Real do Serviço</title>
  <meta name="description" content="Descrição em uma frase.">
  <link rel="stylesheet" href="../design-system/tokens.css">
  <link rel="stylesheet" href="../design-system/components.css">
</head>
<body>
  <div class="shell">
    <aside id="sidebar" class="sidebar" aria-label="Navegação"></aside>
    <main id="main" class="main">
      <nav class="breadcrumb">...</nav>
      <header class="hero">...</header>
      <h2 class="section-eyebrow">...</h2>
      <!-- conteúdo: tabelas, callouts, code blocks, diagram viewers -->
    </main>
  </div>

  <!-- fontes dos diagramas (uma por diagrama) -->
  <script type="text/mermaid" data-id="...">...</script>

  <!-- scripts clássicos, NÃO module -->
  <script src="sidebar.js"></script>
  <script src="diagram-viewer.js"></script>
</body>
</html>
```

---

## 4. Convenções de redação

### Idioma, voz e tom (convenção da casa — adaptável)

- **Idioma**: português brasileiro. Termos técnicos consagrados ficam em inglês: idempotency, outbox, saga, retry, eventual consistency, circuit breaker, DLQ, exactly-once.
- **Voz ativa**. "O serviço publica o evento" não "o evento é publicado pelo serviço".
- **Pessoa**. Primeira pessoa do plural ("decidimos", "usamos") em ADRs. Terceira pessoa neutra em descrições factuais.
- **Sem qualificadores vagos**. Evite: "robusto", "escalável", "moderno", "de ponta", "simples", "fácil".
- **Números concretos**. Não "alta performance" — "p95 < 500ms".

### Princípios (convenção — discuta com o time real antes de impor)

1. **Decisão antes de implementação**. Documentação responde *por quê*; código responde *como*.
2. **Trade-off explícito**. Toda decisão tem ônus. Listar o que perdemos é parte da decisão.
3. **Auditável**. Cada documento traz autor, data, versão, status.
4. **Não confiar em disciplina** quando há alternativa verificável (fitness function, lint, alarme).

---

## 5. Padrões transacionais — terminologia de referência

Os termos abaixo são definição operacional **no exemplo fictício** "Liquidação Transacional". Em um serviço real, valide cada um contra o domínio do time e o código existente. Se um termo do domínio real conflita, o termo do domínio vence — registre o conflito no glossário do serviço.

| Termo | Definição operacional no exemplo |
|---|---|
| **Idempotência** | Header `Idempotency-Key` validado por hash do payload, TTL 24h em Redis |
| **Outbox Pattern** | Evento gravado na mesma transação do agregado, propagado por relay assíncrono — garante exactly-once *lógico* |
| **Saga** | Transação distribuída coordenada por compensações (quando 2PC não é viável) |
| **Compensação** | Operação que reverte logicamente uma operação anterior (não é rollback de DB) |
| **Eventual consistency** | Estado entre serviços reconcilia em janela definida — **sempre documente a janela em segundos** |
| **At-least-once delivery** | Mensagem pode chegar mais de uma vez. Consumer **deve** ser idempotente |
| **Dead Letter Queue (DLQ)** | Fila de mensagens que falharam após N retries. Sempre tem alarme associado |
| **Circuit Breaker** | Polly. Default no exemplo: 5 falhas em 30s → open por 60s |
| **Correlation ID** | UUID propagado em todos logs e chamadas downstream via `X-Correlation-ID` |

---

## 6. Comportamento de geração

Toda página HTML gerada é gravada em **`doc/arquitetura/`** (crie os diretórios se não existirem). `ia/templates/` é só referência de FORMA.

**NAV editor (regra obrigatória — rev v2):** cada etapa de geração (2/7, 3/7, 4/7) que cria um `.html` **apenda no mesmo passo** a entry `{label, href}` na seção certa do `NAV` em `sidebar.js`. Página sem entry = órfã = rejeitada pelo validador #6 (Etapa 6/7).

### Ao gerar ADR
- Mínimo 3 decision drivers. Mínimo 2 opções consideradas.
- Seção "Implicações transacionais" obrigatória quando o serviço lida com dinheiro ou estado crítico.
- Nunca inventar consequências negativas. Se não há trade-off relevante, escreva "Nenhum impacto negativo identificado" e justifique.
- Sempre proponha métrica de validação ("como saberemos que deu certo?") e gatilho de revisão.

### Ao gerar Runbook
- Toda seção "Failure Mode" exige: sintoma observável + query de log/métrica para confirmar + ação imediata + ação de mitigação permanente.
- Nunca inventar SLO/SLA. Se não souber, **pergunte ao usuário**.

### Ao gerar visão de arquitetura
- Use a persona de `ia/prompts/arquitetura/arquiteto-de-sistema.md`.
- Faça as 5 perguntas-âncora descritas no prompt antes de gerar conteúdo concreto.
- Renderize cada seção como `<section>` HTML semântica com `class="section-eyebrow"` no heading.

### Ao gerar QUALQUER diagrama
- Siga § 1 deste arquivo. Sem exceção. Esta é a única regra rígida de visual.

---

## 7. O que NÃO documentar

- Convenções óbvias do .NET (namespace = pasta, async/await, DI built-in).
- Código de bibliotecas third-party.
- Detalhes de classes individuais (use no máximo nível Component do C4).
- Decisões reversíveis triviais (StyleCop, formatação).

---

## 8. Auto-checklist antes de entregar

> **Rev v2 (2026-06-19):** o enforcement do template **não é mais mental**. As Etapas 6/7 (`validador-visual` + `validador-sintaxe-mermaid`) e o `atualizador-arquitetura` aplicam o **checklist canônico** (`ia/templates/checklist-validador.md`) com evidência `arquivo:linha`, opcionalmente assistidos por `ia/tools/validar-doc.sh`. Cada etapa de geração (2/3/4) é responsável por apendar entry no NAV de `sidebar.js` no mesmo passo da criação do `.html`.

Para geração (Etapas 2-4) e refresh pontual, antes de entregar verifique:

- [ ] Carreguei o(s) prompt(s) correto(s) da tabela § 2?
- [ ] Apliquei `.github/instructions/frontend-style.instructions.md`?
- [ ] Estrutura HTML segue o esqueleto § 3?
- [ ] **Todo diagrama segue § 1 (Mermaid + diagram-viewer + classDef person/sys/ext/extAsync)?**
- [ ] Gravei em `doc/arquitetura/` (e ADRs em `doc/adr/`)?
- [ ] **Apendei a entry no `NAV` em `sidebar.js` no mesmo passo?** (regra v2)
- [ ] Apendei Q&A no `QA.md` da task no mesmo turno em que o usuário respondeu? (status vivo, regra v2)
- [ ] Linguagem em PT-BR, voz ativa, sem qualificadores vagos?
- [ ] Trade-offs explícitos onde decisão aparece?
- [ ] Métricas concretas, sem aspiracionalismo?
- [ ] Substituí o conteúdo de exemplo ("Liquidação Transacional", "FICO Falcon", etc.) pelo serviço real do usuário?
