# LEDGER — 2026-06-17-contraste-templates-html

## Decisoes
- Diagnostico (medido antes de tocar): primary ja AAA (18.1) — nao era a fonte do "apagado".
  O culpado era o secondary (#98a0b0) carregando subtitulos/descricoes/links de sidebar;
  o muted (#5d6677) era o unico que REPROVAVA AA (3.1 no card, 2.9 em surface-2).
- Cores de texto sao 100% canonicas em tokens.css; nos .html so havia cor inline em
  `classDef` de diagrama (fora de escopo). Confirmado que design-system/*.css e templates/*.html
  sao canonicos (nao mirrors) — editados direto.
- Escopo expandiu no grill (decisao do usuario): tema claro + tamanho de fonte + highlight,
  alem do contraste. Reverteu o "nao tocar lógica/HTML" original — passou a tocar JS e os 12 HTMLs.
- Sem-flash exigiu prefs.js render-blocking no <head> (antes do CSS). Escolha do usuario: editar
  os 12 HTMLs em vez de aceitar FOUC.
- Mobile: a sidebar (e os controles) some <=900px por design ja existente; mantido desktop-first.
- Propagacao total: esqueleto canonico + prompt design-system, p/ paginas futuras nascerem iguais.

## Evidencias (2026-06-17)
- WCAG recalculado nos valores GRAVADOS:
  - Escuro: primary 18.1/16.6 AAA; secondary 9.6/8.8 AAA; muted 5.3/4.9 AA; accent 5.9/5.4 AA;
    <mark> 12.1 AAA.
  - Claro: primary 17.0/18.3 AAA; secondary 7.3/7.8 AAA; muted 4.9/5.2 AA; accent 5.8/6.2 AA;
    <mark> 14.8 AAA.
  - Claro semanticas (texto do badge sobre o proprio soft): success 5.3, warning 5.4, danger 5.0 — AA.
- node --check: prefs.js OK, sidebar.js OK.
- Chaves CSS balanceadas: tokens.css 4/4, components.css 195/195.
- 12/12 HTML com prefs.js exatamente 1x e antes do tokens.css (linha 8 -> 9).
- sync-copilot.sh: 5 instructions + 29 prompts + wrappers/skills; sync-kiro.sh: 5 steering + wrappers.
- sync-copilot.sh --check = OK (exit 0); sync-kiro.sh --check = OK (exit 0).
- prefs.js propagado pros 2 mirrors (frontend-style em .github/instructions e .kiro/steering).

## Arquivos tocados
- Canonico: docs/arquitetura/design-system/tokens.css, components.css;
  docs/arquitetura/templates/prefs.js (novo), sidebar.js, e 01/02/03/04/05/06/07/08/09/13/14 + index .html (12).
- Propagacao: .amazonq/rules/frontend-style.md, prompts/frontend/design-system-arquitetura.md;
  mirrors regenerados em .github/ e .kiro/ via sync.
- Controle: docs/controle/2026-06-17-contraste-templates-html/ (TASK, PLANO, LEDGER).
