# PLANO — 2026-06-17-contraste-templates-html

Desenho aprovado pelo usuario ("aprovado") antes de qualquer edicao.

## Camada 1 — Contraste (tema escuro), em tokens.css
| Token | Antes | Depois | Contraste depois (fundo / card) |
|---|---|---|---|
| `--color-text-primary` | #f4f6f9 | (intacto) | 18.1 / 16.6 — AAA |
| `--color-text-secondary` | #98a0b0 | **#aeb6c6** | 9.6 / 8.8 — AAA |
| `--color-text-muted` | #5d6677 | **#7d8698** | 5.3 / 4.9 — AA (era reprovado) |
| `--color-accent` | #4a8fe7 | (intacto) | 5.9 / 5.4 — AA |

## Camada 2 — Tema claro, bloco `[data-theme="light"]` em tokens.css
Paleta a mao (nao inversao). bg #f5f7fa / surface #fff / surface-2 #eef1f6.
text primary #11151c (AAA), secondary #4a5263 (AAA), muted #646d7e (AA), accent/link #1c5fb8 (AA).
Semanticas escurecidas p/ badge >= AA: success #0f6b42, warning #7c540d, danger #b03131.
Bordas/code/sombras ajustados; `color-scheme` por tema.

## Camada 3 — Tamanho de fonte
prefs.js seta `font-size` do :root em 5 niveis [85, 92, 100, 115, 130]% (default indice 2).
Persistido em localStorage `arch-scale`. Larguras fixas em px nao escalam (intencional).

## Camada 4 — Highlight
`<mark>` e `.destaque` em components.css usando `--color-mark-bg` / `--color-mark-text`.
AAA nos dois temas. Aplicado manualmente pelo autor.

## Controles + fiacao
- prefs.js (novo, templates/): aplica tema+escala no <head> antes do paint (sem flash);
  segue prefers-color-scheme; escolha do usuario persiste; expoe window.ArchPrefs.
- sidebar.js: rodape `.sidebar__tools` com botao de tema (sol/lua, SVG) + A-/A+ + indicador
  de %, com aria-labels pt-BR. `.sidebar` virou flex column p/ ancorar no rodape.
- 12 *.html: `<script src="prefs.js">` no <head>, antes dos 2 <link> de CSS.

## Propagacao (working-model do pack)
- Canonico: `.amazonq/rules/frontend-style.md` (skeleton + status + catalogo + § cor + checklist)
  e `prompts/frontend/design-system-arquitetura.md` (tokens de tema/highlight + catalogo).
- Mirrors regenerados por `tools/sync-copilot.sh` e `tools/sync-kiro.sh` (nunca editados a mao).

## Fora de escopo
classDef dos diagramas Mermaid; controles no mobile (sidebar some <=900px, mantido); conteudo das paginas.
