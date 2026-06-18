# PLANO — 2026-06-17-tema-controles-como-usar

Tudo em UM arquivo canonico: `COMO-USAR.html` (o `.md` e gerado dele pelo sync).
Reuso maximo do que o commit 4bafad1 ja entregou — nada de mecanismo novo.

## Camada 1 — prefs.js no <head>
- Inserir `<script src="docs/arquitetura/templates/prefs.js"></script>` ANTES dos 2 `<link>`
  de CSS (hoje na linha 8). Render-blocking no <head> = aplica tema/escala antes do paint (sem FOUC).
- Path relativo a partir da raiz, mesma convencao do `href` dos CSS ja usados no arquivo.
- Compartilha `window.ArchPrefs` e as chaves localStorage `arch-theme`/`arch-scale` com os
  templates => quem escolheu claro nos templates ja chega claro aqui.

## Camada 2 — barra de controles flutuante
- Novo wrapper `<div class="guide-tools" role="group" aria-label="Preferencias de leitura">`
  inserido como primeiro filho do `<body>` (antes do `<main class="guide">`).
- Conteudo reusa as classes JA existentes no components.css:
  - `<button class="sidebar__tool-btn" id="guide-theme-toggle">` (sol/lua)
  - `<div class="sidebar__tools-group">` com `A-` / `<span class="sidebar__scale-label">` / `A+`
- CSS novo (so posicionamento), no `<style>` inline da pagina:
  ```
  .guide-tools { position: fixed; top: 16px; right: 16px; z-index: 50;
                 display: flex; align-items: center; gap: 8px;
                 background: var(--color-surface); border: 1px solid var(--color-border);
                 border-radius: var(--radius-md); padding: 6px; box-shadow: var(--shadow-...); }
  @media (max-width: 720px) { .guide-tools { top: 8px; right: 8px; } }
  @media print { .guide-tools { display: none; } }
  ```
  (valores finais ancorados nos tokens existentes; sem hex/px magico de cor.)

## Camada 3 — JS inline de wiring
- Espelha o trecho de controles do `sidebar.js` (SUN/MOON SVG + syncTheme/syncScale + 3 listeners),
  consumindo `window.ArchPrefs`. Degrada sem quebrar se prefs.js faltar (`if (!prefs) return`).
- Vai junto do `<script>` de copiar ja existente no fim do <body> (classic script, roda em file://).

## Camada 4 — regenerar o .md
- `bash tools/sync-como-usar.sh` e depois `--check`.
- Esperado: COMO-USAR.md IDENTICO ao commitado (as mudancas estao todas fora de
  regra-banner/trilha/msg-card). `--check` exit 0 = prova de que conteudo nao mudou.

## Verificacao (no fechamento)
- prefs.js aparece exatamente 1x e antes do tokens.css.
- `node --check` no JS inline (extraido pra arquivo temporario).
- Tema claro/escuro e os 4 controles presentes no markup; aria-labels pt-BR.
- sync --check = OK.

## Fora de escopo
- Sidebar de navegacao (COMO-USAR e pagina unica; nao precisa).
- 3 frame-template.html da skill brainstorming (copias verbatim importadas).
- Qualquer mudanca no conteudo/cards do guia ou nos tokens/components.css (so consumo).
