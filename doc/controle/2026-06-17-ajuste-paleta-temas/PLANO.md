# PLANO — 2026-06-17-ajuste-paleta-temas

Um arquivo canonico: `docs/arquitetura/design-system/tokens.css` (sem mirror/sync).
Confirmado por grep: os hex de texto so existem nele + nos registros de controle historicos
(que NAO se tocam). Nenhuma propagacao.

## Edicao 1 — :root (tema escuro), letras mais claras
- `--color-text-primary`   #f4f6f9 -> #fbfcff
- `--color-text-secondary` #aeb6c6 -> #c4cbd8  + comentario: `/* contraste: 12.0:1 no fundo, 11.0:1 no card (AAA) */`
- `--color-text-muted`     #7d8698 -> #949dae  + comentario: `/* contraste: 7.2:1 no fundo, 6.6:1 no card (AA)  */`

## Edicao 2 — [data-theme="light"], off-white + letras mais escuras
Superficies (escala remanejada, monotonica — surface no topo):
- `--color-bg`               #f5f7fa -> #e9edf3
- `--color-bg-gradient-from` #f5f7fa -> #e9edf3
- `--color-bg-gradient-to`   #eef1f6 -> #e1e7ef
- `--color-surface`          #ffffff -> #f8fafc
- `--color-surface-2`        #eef1f6 -> #e1e7ef
- `--color-surface-hover`    #e8edf4 -> #d9e0ea
- `--color-surface-active`   #dde4ee -> #cfd8e6

Textos:
- `--color-text-primary`   #11151c -> #0e1219  comentario `/* 16.0:1 / 17.9:1 (AAA) */`
- `--color-text-secondary` #4a5263 -> #3a4150  comentario `/* 8.7:1 / 9.8:1  (AAA) */`
- `--color-text-muted`     #646d7e -> #525a6a  comentario `/* 5.9:1 / 6.6:1  (AA)  */`
- `--color-mark-text`      #11151c -> #0e1219

## Verificacao (no fechamento)
- Recalculo WCAG (script) dos 6 textos nos dois temas, sobre bg/surface/surf2 — todos >= AA.
- Escala clara: surface > bg > surface-2 > hover > active (luminancia monotonica) e gradiente
  from > to (mesma direcao do atual).
- Chaves CSS balanceadas (contagem { } igual ao antes).
- grep: os valores antigos de surface/text sumiram do tokens.css; os novos presentes 1x cada.
- Escopo: git diff toca SO docs/arquitetura/design-system/tokens.css.

## Fora de escopo
- accent, semanticas, borders, code, shadows, text-inverse (nao pedidos; ja AA).
- classDef de diagramas Mermaid (cores fixas, fora do sistema de tema — como na task anterior).
- frontend-style.md / mirrors / COMO-USAR (referenciam por var(), nao por hex — nada a propagar).
