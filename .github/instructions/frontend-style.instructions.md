---
applyTo: "**"
excludeAgent: "code-review"
---
# Frontend / HTML Output Style Guide

> Aplicado automaticamente pelo GitHub Copilot em todo repositorio que contenha esta pasta (frontmatter `applyTo`).
> Aplicado em conjunto com `architecture-style.md` toda vez que o Amazon Q gerar HTML ou CSS neste workspace.
> Filosofia: documentação técnica com cuidado editorial. Inspiração: Linear docs, Stripe docs, Vercel docs.

---

## 0. STATUS

| Item | Status |
|---|---|
| Esqueleto HTML, padrão de carregamento de scripts, padrão `.diagram-viewer` | **REGRA** |
| Tokens de cor, espaço, tipografia em `ia/design-system/tokens.css` | **REGRA de uso** (via `var(--*)`) |
| Componentes em `ia/design-system/components.css` | **CATÁLOGO disponível** — use o existente, evite reinventar |
| Conteúdo das páginas em `ia/templates/` | **EXEMPLO** — substitua substância pelo serviço real |
| Visual final (paleta navy/azul; tema escuro padrão + tema claro opcional) | **CONVENÇÃO da casa** — discutível com o time real, hoje é o padrão |
| Controles de leitura (alternar tema, tamanho de fonte) via `prefs.js` + rodapé da `sidebar.js` | **REGRA** — incluir `prefs.js` no `<head>` |

---

## 1. Esqueleto HTML obrigatório

Todo documento gerado começa com este esqueleto. Os pontos marcados com **REGRA** são não-negociáveis.

```html
<!DOCTYPE html>
<html lang="pt-BR">                              <!-- REGRA: lang pt-BR -->
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><Título> · <Nome Real do Serviço></title>
  <meta name="description" content="<Descrição em uma frase>">
  <script src="prefs.js"></script>                               <!-- REGRA: tema+fonte ANTES do CSS (sem flash) -->
  <link rel="stylesheet" href="../design-system/tokens.css">     <!-- REGRA: estes 2 arquivos -->
  <link rel="stylesheet" href="../design-system/components.css">
</head>
<body>
  <div class="shell">                            <!-- REGRA: shell wrap -->
    <aside id="sidebar" class="sidebar"></aside> <!-- REGRA: sidebar injetada por sidebar.js -->
    <main id="main" class="main">
      <nav class="breadcrumb">...</nav>
      <header class="hero">...</header>
      <!-- seções de conteúdo -->
    </main>
  </div>

  <!-- Fontes dos diagramas: ver § 3 -->

  <script src="sidebar.js"></script>             <!-- REGRA: classic script, NÃO module -->
  <script src="diagram-viewer.js"></script>      <!-- REGRA: classic script, NÃO module -->
</body>
</html>
```

### Carregamento de scripts — REGRAS

| ❌ Errado (quebra em `file://`) | ✅ Certo |
|---|---|
| `<script type="module" src="diagram-viewer.js">` | `<script src="diagram-viewer.js">` |
| `<script type="module"> import mermaid from "..."; </script>` | Não fazer. Usar `diagram-viewer.js` que carrega via tag |
| `<script src="https://cdn.jsdelivr.net/npm/mermaid@10/...esm.min.mjs" type="module">` | Não fazer. `diagram-viewer.js` injeta o CDN classic |

**Motivo:** Chrome bloqueia silenciosamente ES Modules carregados de `file://`. Toda doc precisa funcionar abrindo direto no navegador (sem servidor). Por isso `diagram-viewer.js` é IIFE clássico.

---

## 2. Semântica HTML5

- Use sempre tags semânticas: `<header>`, `<main>`, `<aside>`, `<article>`, `<section>`, `<nav>`, `<footer>`.
- **Um e apenas um** `<h1>` por documento (no `.hero__title`).
- Hierarquia de heading nunca pula nível. `<h2>` depois de `<h1>`, nunca `<h3>`.
- Listas semânticas: `<ul>` não-ordenadas, `<ol>` sequenciais, `<dl>` definições.
- Toda tabela de dados: `<thead>`, `<tbody>`, `<th scope="col|row">`.
- Links com texto descritivo. Banido: "clique aqui".
- Toda imagem (raras nesta doc) tem `alt`. Decorativas: `alt=""`.

---

## 3. PADRÃO DE DIAGRAMAS — A regra fixa de visual

Detalhe completo em `architecture-style.md` § 1. Repetido aqui pela importância.

```html
<!-- onde o diagrama aparece no conteúdo -->
<figure class="diagram-figure">
  <div class="diagram-viewer" data-diagram="ID_UNICO_NA_PAGINA"></div>
  <figcaption>Figura N — descrição curta.</figcaption>
</figure>

<!-- ao final do body, ANTES dos scripts de sidebar.js / diagram-viewer.js -->
<script type="text/mermaid" data-id="ID_UNICO_NA_PAGINA">
flowchart LR
    classDef person   fill:#1c4e93,stroke:#0a0c12,color:#ffffff,stroke-width:2px
    classDef sys      fill:#4a8fe7,stroke:#0a0c12,color:#ffffff,stroke-width:2.5px
    classDef ext      fill:#ffffff,stroke:#1f2937,color:#0a0c12,stroke-width:1.5px
    classDef extAsync fill:#f9fafb,stroke:#6b7280,color:#0a0c12,stroke-width:1.5px,stroke-dasharray:5 3

    A["Canal"]
    B["Serviço Documentado"]
    C["Dependência síncrona"]
    D["Auditoria assíncrona"]

    A --> B
    B --> C
    B -.-> D

    class A person
    class B sys
    class C ext
    class D extAsync
</script>
```

**Erros comuns a evitar:**

| ❌ | ✅ |
|---|---|
| `<div class="mermaid">flowchart...</div>` inline | `<script type="text/mermaid" data-id="x">` + `<div class="diagram-viewer" data-diagram="x">` |
| `<figure class="mermaid-frame">` (classe antiga, removida) | `<figure class="diagram-figure">` |
| `C4Context` syntax | `flowchart LR` ou `flowchart TB` com classDef |
| `\n` em labels | `<br/>` em labels |
| Cores inventadas em classDef | Os 4 fills da convenção (§ 1 architecture-style.md) |

---

## 4. CSS — arquitetura

Dois arquivos, nesta ordem:

1. **`tokens.css`** — variáveis CSS (`--*`) com todos os tokens (cor, espaço, tipografia, raios, sombras, motion). Nunca hardcode no HTML gerado.
2. **`components.css`** — componentes reutilizáveis usando os tokens.

**Convenções de classes:**
- kebab-case. Ex: `.doc-card`, `.status-badge`.
- BEM leve quando útil: `.card`, `.card__title`, `.card--accepted`.
- `!important` apenas em utilitários (`.sr-only`, `.no-print`, `.hidden`).
- Sem inline styles, exceto valores dinâmicos.

**Banido:**
- Frameworks pesados (Tailwind via CDN, Bootstrap). Vanilla CSS + tokens.
- jQuery e similares. Vanilla JS.
- Web fonts custom remotas sem fallback de system fonts.

---

## 5. Componentes existentes em `components.css`

Use estes. Reinventar é dívida. Se faltar componente, abra discussão com o time real antes de criar.

### Layout
- `.shell` — wrapper grid (sidebar + main)
- `.sidebar`, `.sidebar__brand`, `.sidebar__section`, `.sidebar__link` — navegação lateral (renderizada por `sidebar.js`)
- `.sidebar__tools`, `.sidebar__tool-btn`, `.sidebar__scale-label` — controles de leitura no rodapé da sidebar (tema + tamanho de fonte; renderizados por `sidebar.js`, ligados ao `prefs.js`)
- `.main`, `.breadcrumb`, `.prose` — área de conteúdo

### Hero
- `.hero`, `.hero__eyebrow`, `.hero__title`, `.hero__subtitle`, `.accent-word`

### Seções
- `.section-eyebrow` — heading H2 com diamante accent à esquerda

### Pills e badges
- `.tech-pill`, `.tech-pills` — pills com dot accent (usadas no hero)
- `.status-badge`, `.status-badge--accepted/--proposed/--deprecated`

### Callouts
- `.decision-callout`, `.decision-callout__icon`, `.decision-callout__label`, `.decision-callout__body`

### Tabelas
- `.data-table` — tabela com header em accent e tabular numerals

### Código
- `.code-inline` — código em linha
- `.code-block`, `.code-block__header` — bloco com header de linguagem
- `pre/code` dentro do `.code-block` herdam estilo correto

### Realce de texto
- `<mark>` ou `.destaque` — realça palavra-chave dentro da frase (fundo accent-suave via `--color-mark-*`, contraste AA nos dois temas). Aplicado manualmente pelo autor.

### Diagramas
- `.diagram-figure`, `.diagram-viewer`, `.diagram-viewer__canvas`, `.diagram-viewer__controls`, `.diagram-viewer__btn`, `.diagram-viewer__hint`, `.diagram-viewer__error`, `.diagram-viewer__loading`

### Cards de navegação
- `.doc-grid`, `.doc-card`, `.doc-card__icon`, `.doc-card__title`, `.doc-card__desc`

### Utilitários
- `.sr-only` — esconder visualmente, manter para leitor de tela
- `.no-print`, `.print-only` — controle de impressão
- `.skip-link` — acessibilidade (no `sidebar.js`)

---

## 6. Acessibilidade — mínimo WCAG 2.1 AA

- **Contraste**: 4.5:1 para texto normal, 3:1 para texto grande (≥18pt).
- **Focus visível**: `:focus-visible` sempre estilizado. Nunca `outline: none` sem substituição.
- **Skip link**: incluso automaticamente pela `sidebar.js`.
- **ARIA apenas quando necessário**. HTML semântico vence ARIA.
- **Cor nunca é o único canal**. Badges/callouts com cor têm também texto e/ou ícone.
- **Tudo interativo é tabulável.**

---

## 7. Tipografia — regras editoriais (Butterick)

Aplicadas silenciosamente em todo HTML gerado.

### Caracteres certos

| ❌ Errado | ✅ Certo |
|---|---|
| `"texto"` (aspas retas) | `"texto"` (aspas tipográficas) |
| `'apostrofo'` | `'apostrofo'` |
| `-` para parênteses | `—` (em dash) |
| `1-10` em ranges | `1–10` (en dash) |
| `...` (três pontos) | `…` (ellipsis) |
| `(c)`, `(tm)` | `©`, `™` |
| Dois espaços entre frases | Um espaço |
| `5x` em multiplicação | `5×` |
| `>=`, `<=` | `≥`, `≤` |

### Hierarquia tipográfica (definida em CSS — não duplique em HTML)

- `h1` apenas no `.hero__title`
- `h2` via `.section-eyebrow` para seção principal
- `h3` para subseção
- `h4` para terciário (evite ir mais fundo)
- Body 1rem, line-height 1.65 em prose
- Mono 0.92em para code inline

### Medida da linha

`.prose` tem `max-width: 68ch` automaticamente. Não force outra largura.

### Números em PT-BR

- Prosa: separador de milhar `.`, decimal `,`. Ex: `1.234,56`.
- Em código: padrão da linguagem. Ex: `1_234_567` em C#.
- Em tabelas: `font-variant-numeric: tabular-nums` já aplicado em `.data-table` (números alinham em colunas).

---

## 8. Cor — uso

A paleta vive em `tokens.css`, em **dois temas**: escuro (`:root`, padrão) e claro (`[data-theme="light"]`). O `prefs.js` aplica o tema antes do paint (segue `prefers-color-scheme`; a escolha do usuário persiste) e o rodapé da `sidebar.js` alterna. Ambos os temas têm texto ≥ AA. Regras:

- Texto primário: `var(--color-text-primary)` (off-white).
- Texto secundário/metadado: `var(--color-text-secondary)`.
- Links: `var(--color-accent)` (azul institucional).
- Status:
  - `Accepted` / OK → `--color-success` (verde sóbrio).
  - `Proposed` / em revisão → `--color-warning` (âmbar quente).
  - `Deprecated` / `Superseded` → cinza muted.
  - `Critical` / `P1` → `--color-danger` (vermelho contido).
- Diagramas: cores fixas da convenção § 1 architecture-style.md.
- Realce de palavra-chave: `<mark>`/`.destaque` (usa `--color-mark-*`).
- **Sempre via `var(--*)`** — nunca hardcode hex no HTML; é o que faz o tema claro funcionar.

**Banido na documentação principal**: gradientes coloridos vibrantes, sombras coloridas grandes, glow excessivo, neon. Sutileza vence.

---

## 9. Motion (Emil Kowalski)

Detalhes em `ia/prompts/frontend/polidor-ui.md`. Princípios:

- **Press feedback obrigatório** em elementos clicáveis: `transform: scale(0.97)` no `:active`. Já aplicado em `.doc-card`, `.sidebar__link`, `.diagram-viewer__btn`.
- **Easings customizados** (`--ease-out-strong: cubic-bezier(0.23, 1, 0.32, 1)`) em vez dos CSS defaults.
- **Durações 100-300ms** em interações.
- **Nunca `transition: all`** — propriedades explícitas.
- **Nunca `ease-in`** em UI.
- **`prefers-reduced-motion: reduce`** já desliga animações globalmente (em `tokens.css`).

---

## 10. Performance

- Mermaid e Panzoom carregados sob demanda pelo `diagram-viewer.js` quando há `.diagram-viewer` na página. Páginas sem diagrama não baixam essas libs.
- Diagrama é texto (Mermaid), não PNG. Versionável e diffável.
- CSS dividido em tokens + components — único request adicional além do HTML.

---

## 11. Print

`@media print` definido em `components.css` cobre:
- Layout empilha (sem sidebar)
- Cores invertem (preto sobre branco)
- "Próximas Leituras" são removidas
- Diagramas viram estáticos
- Page breaks evitados dentro de blocos visuais
- URLs aparecem após links externos

Para gerar PDF: `Cmd+P` → Salvar como PDF, marcar "Gráficos de fundo".

---

## 12. Verificação final do HTML gerado

Antes de entregar, mentalmente cheque:

- [ ] `<html lang="pt-BR">`.
- [ ] Title descritivo + meta description.
- [ ] Um único `<h1>` (no `.hero__title`).
- [ ] Heading levels sem pulos.
- [ ] Scripts carregados como **classic**, não `type="module"`.
- [ ] `<script src="prefs.js">` no `<head>`, antes dos CSS (tema/fonte sem flash).
- [ ] Sidebar via `<aside id="sidebar">` + `<script src="sidebar.js">`.
- [ ] Cada diagrama: `<div class="diagram-viewer" data-diagram>` + `<script type="text/mermaid" data-id>`.
- [ ] Diagramas usam os 4 classDefs da convenção.
- [ ] `<figure class="diagram-figure">` com `<figcaption>` numerada.
- [ ] Tipografia: aspas tipográficas, em/en dashes, ellipsis correta.
- [ ] Sem hardcode de cor/espaço (apenas tokens via `var(--*)`).
- [ ] Conteúdo é do serviço REAL, não copiado do exemplo "Liquidação Transacional".
