# Architecture Documentation Style Guide

> Este arquivo é lido automaticamente pelo Amazon Q em todo workspace que contenha esta pasta.
> Define **o que é exemplo e o que é regra**, mapeia gatilhos de usuário para prompts especializados,
> e estabelece a única convenção rígida deste workspace: a criação de diagramas.

---

## GATE OBRIGATÓRIO — `project-context.md`

**Antes de qualquer geração de documentação**, verifique se `.amazonq/rules/project-context.md` existe.

```
Pedido de geração chega
        ↓
project-context.md existe?
        │
        ├── NÃO → carregue `prompts/arquitetura/analisador-de-projeto.md` PRIMEIRO.
        │        Pare a geração original. Conclua a análise. Peça confirmação.
        │        Depois disso o usuário pode reinvocar o pedido original.
        │
        └── SIM → leia-o COMPLETO. Use-o como fonte de verdade para:
                 • Nome do serviço (não use "Liquidação Transacional")
                 • Stack real (não copie a do exemplo)
                 • Padrões que NÃO se aplicam (não documente o que está listado como "não usado")
                 • SLO, criticidade, glossário do domínio
                 Depois prossiga normalmente com o prompt indicado pelo gatilho.
```

`project-context.md` tem **peso de regra**, igual a este arquivo. Quando ele afirma "não usamos Outbox",
isso **sobrescreve** qualquer exemplo em `templates/` que mencione Outbox.

---

## 0. STATUS DESTE WORKSPACE

Antes de qualquer coisa, entenda como tratar o que existe aqui:

| Pasta / arquivo | Status | Como usar |
|---|---|---|
| `.amazonq/rules/architecture-style.md` (este arquivo) | **REGRA** | Aplique sempre. Convenções de geração e hooks de prompt. |
| `.amazonq/rules/frontend-style.md` | **REGRA** | Aplique sempre. Estrutura HTML e padrão de diagramas. |
| `.amazonq/rules/project-context.md` | **REGRA por projeto** (gerada pelo analisador) | Define este projeto específico. Sobrescreve exemplos. Se não existir, executar o analisador antes de qualquer geração. |
| `prompts/arquitetura/*.md` | **REGRA** (metodologia) | Carregue conforme tabela de hooks. Siga a metodologia descrita. |
| `prompts/frontend/*.md` | **REGRA** (metodologia) | Carregue para tarefas visuais. |
| `design-system/tokens.css` e `components.css` | **REGRA** (CSS) | Use `var(--*)` sempre. Nunca hardcode cor/espaço/raio. |
| `templates/*.html` | **EXEMPLO** | Páginas de um serviço **fictício** chamado "Liquidação Transacional". Demonstram aplicação dos prompts. **Substitua toda substância (nomes, decisões, latências, stack, glossário) pelo serviço REAL** ao gerar nova documentação. Mantenha apenas o esqueleto estrutural. |
| `templates/sidebar.js` e `templates/diagram-viewer.js` | **REGRA** (runtime) | Inclua em toda página gerada. Não substitua por alternativa. |

**Resumo:** estilo de redação, convenção de diagrama, estrutura HTML básica, fluxo dos prompts → **regra**.
Conteúdo concreto, nomes de serviços, decisões específicas, valores de latência, terminologia de domínio → **exemplo, adaptar à realidade**.

---

## 1. A ÚNICA REGRA RÍGIDA DE VISUAL: Convenção de Diagrama

Esta é **a única regra prescritiva sobre visual** neste workspace. Aplicação obrigatória em todo diagrama gerado.

### 1.1 Tecnologia: Mermaid via `diagram-viewer.js`

- Use **Mermaid** (não outras ferramentas de diagrama, não imagens PNG, não SVG estático).
- Renderização via o leitor estático em `templates/diagram-viewer.js`. Esse leitor:
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
| **Primeira invocação em um repositório** OU "analisa o projeto", "refresh project context", "atualiza contexto" OU `project-context.md` ausente | `prompts/arquitetura/analisador-de-projeto.md` (sempre antes de qualquer outro prompt) |
| "documentar serviço", "começar arquitetura", "system context", "container diagram", "visão geral" | `prompts/arquitetura/arquiteto-de-sistema.md` |
| "criar ADR", "registrar decisão", "decisão arquitetural", "MADR", "trade-off" | `prompts/arquitetura/gerador-adr.md` |
| "runbook", "documentação operacional", "failure mode", "on-call", "SLO" | `prompts/arquitetura/gerador-runbook.md` |
| "documentar fluxo", "sequência transacional", "fluxograma de processo", "saga", "fluxo de autorização" | `prompts/arquitetura/documentador-fluxo.md` |
| "revisar documentação", "validar ADR", "achar furo na doc", "consistência", "auditoria de doc" | `prompts/arquitetura/grill-doc.md` |
| "brainstorm", "explorar opções", "ainda não decidi", "ajuda a pensar", "discutir abordagem" | `prompts/arquitetura/brainstorm-arquitetural.md` |
| "design", "cor", "tipografia", "visual", "layout", "como ficar bonito" | `prompts/frontend/designer-ux-controlado.md` |
| "estilo", "paleta", "componente UI", "padrão visual catálogo" | `prompts/frontend/designer-ui-pro-max.md` |
| "design system", "tokens", "padronizar componentes" | `prompts/frontend/design-system-arquitetura.md` |
| "polir", "animação", "micro-interação", "detalhe", "acabamento" | `prompts/frontend/polidor-ui.md` |

Quando gerar HTML final, **sempre** aplique também `.amazonq/rules/frontend-style.md`.

---

## 3. Esqueleto de página HTML

Todo HTML novo segue este esqueleto (confirma o padrão demonstrado em `templates/01-visao-geral.html` em diante). Detalhamento em `frontend-style.md`.

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

### Ao gerar ADR
- Mínimo 3 decision drivers. Mínimo 2 opções consideradas.
- Seção "Implicações transacionais" obrigatória quando o serviço lida com dinheiro ou estado crítico.
- Nunca inventar consequências negativas. Se não há trade-off relevante, escreva "Nenhum impacto negativo identificado" e justifique.
- Sempre proponha métrica de validação ("como saberemos que deu certo?") e gatilho de revisão.

### Ao gerar Runbook
- Toda seção "Failure Mode" exige: sintoma observável + query de log/métrica para confirmar + ação imediata + ação de mitigação permanente.
- Nunca inventar SLO/SLA. Se não souber, **pergunte ao usuário**.

### Ao gerar visão de arquitetura
- Use a persona de `prompts/arquitetura/arquiteto-de-sistema.md`.
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

Antes de fornecer uma resposta com HTML gerado, verifique mentalmente:

- [ ] Carreguei o(s) prompt(s) correto(s) da tabela § 2?
- [ ] Apliquei `.amazonq/rules/frontend-style.md`?
- [ ] Estrutura HTML segue o esqueleto § 3?
- [ ] **Todo diagrama segue § 1 (Mermaid + diagram-viewer + classDef person/sys/ext/extAsync)?**
- [ ] Linguagem em PT-BR, voz ativa, sem qualificadores vagos?
- [ ] Trade-offs explícitos onde decisão aparece?
- [ ] Métricas concretas, sem aspiracionalismo?
- [ ] Substituí o conteúdo de exemplo ("Liquidação Transacional", "FICO Falcon", etc.) pelo serviço real do usuário?
