# PLANO — 2026-06-19-arquitetura-v2-0-1

> **Objetivo:** resolver os 3 findings MÉDIA da validação v2 + o gap adjacente (assets dos docs gerados).
> **Maior risco:** mexer no instalador e no validador sem regressão — mitigado por `run-tests.sh` + 3× `--check` + dry-run.
> **Forks resolvidos (QA.md):** #3 = estender o script (hex completo); #1 = semear assets sob `doc/` a partir de `ia/`.

## Etapa A — Finding #3: classDef hex no validar-doc.sh
- **Arquivos:** `ia/tools/validar-doc.sh` (`_rule_mermaid_classdefs`, ~178-204); `ia/tools/tests/run-tests.sh` + nova fixture `ia/tools/tests/fixtures/mermaid/bad-classdef-hex.html`.
- **Mudança:** ao casar `classDef <nome> ...`, extrair `fill:`/`stroke:`/`color:` e comparar com `ia/tools/lib/mermaid-classdefs.txt` (carregar o SoT no awk); emitir `mermaid-classdef-hex: <nome> <prop> diverge do SoT (esperado <hex>)`.
- **Verificação:** fixture com `person fill:#ff0000` → FAIL com `arquivo:linha`; `bash ia/tools/tests/run-tests.sh` → PASS=18 FAIL=0.
- **Pronto quando:** hex divergente = exit 1; checklist:22 + README:31 ("hex exatos") passam a ser verdadeiros.

## Etapa B — Helper de seeding + Finding #1 (prefs.js)
- **Arquivos:** NOVO `ia/tools/seed-doc-assets.sh`; `install.sh` (§5 runtime, ~106-110); `install.ps1` (~112-117).
- **Mudança:** (1) `seed-doc-assets.sh <target>` idempotente: cria `doc/templates/` + `doc/design-system/`, copia `ia/templates/{prefs,sidebar,diagram-viewer}.js` e `ia/design-system/{tokens,components}.css`. (2) Instaladores passam a copiar `prefs.js` → `<target>/ia/templates/` (fix #1 original) **e** chamam o seed para `<target>/doc/`.
- **Verificação:** `T=$(mktemp -d); bash install.sh "$T"` → existem `$T/ia/templates/prefs.js`, `$T/doc/templates/prefs.js`, `$T/doc/design-system/tokens.css`; rodar o helper 2× = sem erro/duplicação.
- **Pronto quando:** dry-run exit 0; `prefs.js` + CSS resolvem para páginas-exemplo, COMO-USAR.html e docs gerados.

## Etapa C — Finding #2: install.ps1 re-run (Windows)
- **Arquivos:** `install.ps1:96`.
- **Mudança:** trocar `Copy-Item (ia/prompts/$t) -Recurse` (dir bare) por glob `ia/prompts/$t/*` + `New-Item` do destino, alinhando às outras 4 cópias (linhas 74,75,89,103).
- **Verificação:** revisão estática + diff vs padrão das demais (pwsh indisponível neste ambiente — validação em Windows real fica como follow-up no LEDGER).
- **Pronto quando:** linha 96 usa o mesmo padrão glob; sem `ia/prompts/<t>/<t>/` por construção.

## Etapa D — Geradores cientes do seed + frase stale (#4 baixa)
- **Arquivos:** `ia/prompts/arquitetura/{arquiteto-de-sistema,documentador-fluxo,gerador-runbook}.md`.
- **Mudança:** (1) 1 linha perto da regra NAV-editor: "Assets vivem em `doc/templates/` + `doc/design-system/` (semeados de `ia/`; se faltarem, rode `ia/tools/seed-doc-assets.sh`) — não edite à mão." (2) Reescrever `arquiteto-de-sistema.md:103` alinhando à Decisão #11 (gerador apenda no NAV; validador #6 só confere).
- **Verificação:** `grep` confirma a linha de assets nos 3; linha 103 sem "o usuário ajusta a navegação separadamente".
- **Pronto quando:** os 3 geradores citam a origem dos assets e a linha 103 não contradiz mais a linha 7.

## Etapa E — Sincronizar mirrors + verificação final
- **Arquivos:** mirrors via `ia/tools/sync-copilot.sh`, `sync-kiro.sh`, `sync-como-usar.sh`.
- **Mudança:** rodar os 3 sync após editar canônicos (Etapa D).
- **Verificação:** 3× `--check` exit 0; `run-tests.sh` PASS=18; `install.sh` dry-run exit 0 com assets presentes.
- **Pronto quando:** tudo verde → `fase: concluida` no TASK.md, ACs marcados, commit (artefatos + arquivos da task juntos) direto na `main`.
