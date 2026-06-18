# LEDGER — 2026-06-17-tema-controles-como-usar

## Decisoes
- Diagnostico (medido antes de tocar): o COMO-USAR.html JA importava tokens.css + components.css,
  que ja traziam `[data-theme="light"]` e `.sidebar__tool-*` desde o commit 4bafad1. Logo, o tema
  claro/escuro ja "existia" no arquivo — faltava so ativar (prefs.js) e expor controles. Nenhum
  mecanismo novo de tema foi criado.
- COMO-USAR.html nao tem sidebar (e pagina unica, `<main class="guide">`). Por isso os controles,
  que nos templates moram no rodape da sidebar, aqui foram pra uma barra FLUTUANTE fixa no canto
  superior direito (escolha do usuario via pergunta).
- prefs.js reusado POR REFERENCIA (`src="docs/arquitetura/templates/prefs.js"`), nao copiado —
  alinhado ao working-model do pack (nao duplicar canonico). Mesma convencao de path relativo que
  os <link> de CSS ja usavam.
- Tema fica UNIFICADO com os templates: prefs.js usa as mesmas chaves localStorage
  (`arch-theme` / `arch-scale`), entao a preferencia atravessa COMO-USAR <-> templates.
- IDs proprios (`guide-theme-toggle` / `guide-font-dec|inc|level`) pra nao colidir com os do
  sidebar.js (`arch-*`); o wiring JS espelha o do sidebar.js (SUN/MOON SVG + sync + listeners).
- O wrapper `.guide-tools` deliberadamente NAO usa as classes `trilha`/`msg-card`/`section` que o
  sync-como-usar.sh parseia => barra e head sao invisiveis pro gerador do .md.

## Evidencias (2026-06-17)
- sync-como-usar.sh: "Gerado: COMO-USAR.md (71 cards)".
- sync-como-usar.sh --check: "OK: COMO-USAR.md em sincronia" (exit 0).
- git diff --stat COMO-USAR.md: vazio => conteudo do .md inalterado (so o .html mudou).
- Ordem no <head>: prefs.js (linha 10) ANTES de tokens.css (linha 11) => sem flash.
- node --check: 2 scripts inline (copiar + wiring) = OK.
- Markup: .guide-tools + guide-theme-toggle + guide-font-dec/level/inc presentes, aria-labels pt-BR.
- CSS: .guide-tools so com tokens (--color-surface/--color-border/--radius-md/--shadow-lg/--z-sidebar),
  + @media (max-width:720px) e @media print { display:none }. Zero hex de cor cru (so fallbacks).

## Arquivos tocados
- Canonico: COMO-USAR.html (head: prefs.js; <style>: .guide-tools; <body>: barra; fim: script wiring).
- Gerado: COMO-USAR.md regenerado pelo sync (conteudo identico — so reexecutado).
- Controle: docs/controle/2026-06-17-tema-controles-como-usar/ (TASK, PLANO, LEDGER).

## Fora de escopo (confirmado)
- 3 frame-template.html da skill brainstorming (copias verbatim importadas).
- Sidebar de navegacao, conteudo dos cards, tokens/components.css (so consumidos).

## Pendencia
- Validacao visual em navegador (toggle/escala clicando) nao executada nesta sessao — verificacao
  foi estatica (sintaxe + estrutura + sync). Mecanismo identico ao ja validado nos 12 templates.
