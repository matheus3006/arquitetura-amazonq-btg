# LEDGER — 2026-06-17-ajuste-paleta-temas

## Decisoes
- Mudanca 100% em tokens.css (canonico, sem mirror/sync). Confirmado por grep que os hex de texto
  so vivem nele + nos registros de controle historicos (nao tocados). Templates e COMO-USAR
  consomem por var() => mudanca propaga sozinha, sem editar mais nada.
- "Off-white completo" (escolha do usuario): surface deixou de ser branco puro (#fff -> #f8fafc) e
  o bg desceu (#f5f7fa -> #e9edf3) pra os cards continuarem saltando. Escala de superficies inteira
  remanejada (gradiente, surface-2, hover, active) p/ manter luminancia monotonica.
- Letras: claro mais escuro (secondary 7.3->8.7, muted 4.9->5.9), escuro mais claro (primary
  18.1->19.1, secondary 9.6->12.0, muted 5.3->7.2). Como so aumentam contraste, AA nunca corre risco.
- Escopo cirurgico: accent, semanticas, borders, code, shadows, text-inverse NAO mudaram (nao
  pedidos). Verificado que o accent #1c5fb8 segue AA (5.3) sobre o novo bg claro — nao precisou ajuste.
- text-inverse claro segue #ffffff de proposito (e texto sobre fundo escuro/accent — deve ser branco).

## Evidencias (2026-06-17) — recalculo WCAG nos valores GRAVADOS
- DARK (bg #0a0c12 / surface #14171f):
  primary #fbfcff 19.1/17.5 AAA; secondary #c4cbd8 12.0/11.0 AAA; muted #949dae 7.2/6.6 (AAA/AA).
- LIGHT (bg #e9edf3 / surface #f8fafc / surf2 #e1e7ef):
  primary #0e1219 16.0/17.9/15.1 AAA; secondary #3a4150 8.7/9.8/8.2 AAA; muted #525a6a 5.9/6.6/5.6 AA.
- Escala clara monotonica: surface 0.954 > bg 0.844 > surf2 0.794 > hover 0.74 > active 0.681.
- accent #1c5fb8 (mantido) sobre o novo bg claro: 5.3 AA.
- Chaves CSS { } = 4/4. git diff --stat: so tokens.css, 15 insercoes / 15 delecoes.
- Unico hex "antigo" restante: --color-text-inverse #ffffff (linha 169), intencional.

## Arquivos tocados
- Canonico: docs/arquitetura/design-system/tokens.css (3 textos dark + 7 superficies/3 textos/
  mark-text light + 5 comentarios de contraste).
- Controle: docs/controle/2026-06-17-ajuste-paleta-temas/ (TASK, PLANO, LEDGER).

## Fora de escopo (confirmado)
- frontend-style.md / mirrors / COMO-USAR / templates: referenciam a paleta por var(), nada a propagar.
- classDef de diagramas Mermaid (cores fixas; fora do sistema de tema, como na task de contraste).

## Pendencia
- Validacao visual em navegador nao executada nesta sessao (verificacao foi numerica: WCAG +
  monotonia + chaves). Os arquivos estao no preview; dada a natureza so-CSS, o risco e baixo.
