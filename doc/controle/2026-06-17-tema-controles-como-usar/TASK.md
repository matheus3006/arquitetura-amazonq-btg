# TASK — 2026-06-17-tema-controles-como-usar

- **fase:** concluida
- **tipo:** normal
- **pedido:** o COMO-USAR.html ficou de fora do tema claro/escuro + controles de leitura
  que os templates de arquitetura ganharam no commit 4bafad1. Adicionar os mesmos controles
  (alternar tema + tamanho de fonte) reusando o mecanismo ja existente, sem reinventar.

## Diagnostico (medido antes de tocar)
- COMO-USAR.html ja carrega tokens.css + components.css, que JA tem `[data-theme="light"]`
  e os estilos `.sidebar__tool-btn` / `.sidebar__tools-group` / `.sidebar__scale-label`.
- So falta: (1) puxar prefs.js no <head>, (2) renderizar a barra de controles, (3) wiring JS.
- COMO-USAR.html e standalone (`<main class="guide">`, SEM sidebar) — por isso os controles
  nao tem onde morar. Decisao do usuario: barra FLUTUANTE no canto superior direito.
- sync-como-usar.sh so parseia `regra-banner` / `section.trilha` / `msg-card` => mudancas no
  <head> e numa barra fora dessas classes NAO afetam o COMO-USAR.md gerado.
- Escopo = so o COMO-USAR.html. Os 3 frame-template.html (skill brainstorming) sao copias
  verbatim importadas, fora do padrao de docs da casa — fora de escopo.

## Decisoes
1. Posicao dos controles: barra flutuante fixa no canto superior direito (escolha do usuario).
2. Mecanismo: reusar prefs.js dos templates por referencia (nao duplicar) + classes ja existentes.
3. Tema compartilhado: mesmas chaves localStorage (`arch-theme`/`arch-scale`) => consistente
   com os templates de arquitetura.
4. Formato deste registro de controle: Markdown (.md).

## Criterios de aceite
- [x] `<script src="docs/arquitetura/templates/prefs.js">` no <head>, antes dos 2 <link> de CSS (1x). (linha 10 < 11)
- [x] Barra flutuante (position: fixed, topo direito) com botao de tema (sol/lua SVG) + A-/%/A+.
- [x] Reusa `.sidebar__tool-btn` / `.sidebar__tools-group` / `.sidebar__scale-label` — so o wrapper
      de posicionamento (`.guide-tools`) e novo, no <style> inline da pagina.
- [x] aria-labels em pt-BR nos controles; sem flash (FOUC) — prefs.js render-blocking no <head>.
- [x] `@media print { .guide-tools { display: none } }`.
- [x] Tema persiste e e o mesmo dos templates (chaves localStorage compartilhadas).
- [x] `bash tools/sync-como-usar.sh --check` = OK (COMO-USAR.md inalterado — git diff vazio).
- [x] JS inline sintaticamente valido (node --check nos 2 scripts = OK).

## Checklist de execucao
- [x] COMO-USAR.html: prefs.js no <head>
- [x] COMO-USAR.html: <style> .guide-tools (posicionamento fixo + responsivo + print)
- [x] COMO-USAR.html: markup da barra de controles (reuso das classes existentes)
- [x] COMO-USAR.html: JS inline de wiring (consome window.ArchPrefs, degrada sem ele)
- [x] sync-como-usar.sh (regenera .md) + --check OK
- [x] verificacao: prefs.js 1x antes do CSS, node --check 2/2, barra+controles no markup
