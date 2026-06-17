# TASK — 2026-06-17-contraste-templates-html

- **fase:** concluida
- **tipo:** normal
- **pedido:** texto "apagado demais" nos templates HTML de arquitetura. Grill fechou o
  escopo (9 forks) e o usuario expandiu: (1) corrigir contraste dos cinzas no tema escuro,
  (2) tema claro com alternancia, (3) tamanho de fonte ajustavel, (4) highlight de
  palavra-chave. Fonte canonica de cor = tokens.css; .html sao exemplo de forma.

## Decisoes do grill (ver LEDGER)
1. Alvo: AA piso pra todo texto + secondary mais legivel (~AAA)
2. Entrega: uma task em camadas, contraste primeiro
3. Contraste escuro: intensidade Moderada
4. Tema claro: segue o SO + lembra a escolha (paleta a mao, AA)
5. Fonte: 5 niveis (~85%->130%, default 100%)
6. Highlight: estilo aplicado pelo autor (`<mark>`/`.destaque`)
7. Controles: rodape da sidebar
8. Fiacao: editar os 12 HTMLs (prefs.js no <head>, sem flash)
9. Propagacao: esqueleto canonico + sync + doc do design-system

## Criterios de aceite
- [x] Tema escuro: secondary #98a0b0->#aeb6c6 (AAA), muted #5d6677->#7d8698 (AA). Primary intacto.
- [x] Tema claro `[data-theme="light"]` completo em tokens.css, todo texto >= AA.
- [x] prefs.js aplica tema (prefers-color-scheme + persistencia) e escala ANTES do paint.
- [x] sidebar.js renderiza controles no rodape (alternar tema + A-/A+) com aria-labels.
- [x] Highlight `<mark>`/`.destaque` (tokens --color-mark-*), AA nos dois temas.
- [x] 12 HTMLs com `<script src="prefs.js">` no <head> antes do CSS (1x cada).
- [x] Esqueleto canonico (.amazonq/rules/frontend-style.md) + prompt design-system atualizados.
- [x] sync-copilot --check e sync-kiro --check = OK (exit 0).
- [x] Sem mudanca de conteudo/forma; classDef de diagramas intocados.

## Checklist de execucao
- [x] tokens.css: contraste escuro + bloco [data-theme="light"] + tokens de highlight + color-scheme
- [x] components.css: <mark>/.destaque + .sidebar (flex column) + .sidebar__tools/__tool-btn/__scale-label
- [x] prefs.js (novo)
- [x] sidebar.js: render do rodape + wiring no ArchPrefs
- [x] 12 *.html: prefs.js no <head>
- [x] propagacao canonica + sync-copilot/sync-kiro + --check
- [x] verificacao WCAG (escuro corrigido + claro), node --check nos JS, chaves CSS balanceadas
