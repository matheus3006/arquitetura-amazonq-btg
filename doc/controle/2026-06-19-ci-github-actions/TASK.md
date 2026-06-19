---
fase: concluida      # planejamento | execucao | concluida | bloqueada
tipo: normal         # normal | trivial
task_id: 2026-06-19-ci-github-actions
---

## Objetivo
CI no repo do pack (GitHub Actions): roda em todo push(main)/PR os validadores que hoje são
manuais — fecha os medos de drift/output no próprio repo e dá o selo verde pra abrir externamente
(interno→externo). Keystone do roadmap (iniciativa A).

## Escopo
- `.github/workflows/ci.yml` — job **ubuntu**: `run-tests.sh` (validador via fixtures + seed-gitignore
  + check-counts) + `sync-{copilot,kiro,como-usar}.sh --check` + `check-counts.sh`; job **windows**: roda
  `install.ps1` 2× e assere 1 bloco no `.gitignore` + sem aninhamento `ia/prompts/<t>/<t>` (exercita
  o ps1 que a iniciativa E só revisou estático).
  NB: `validar-doc ia/templates` NÃO entra — templates = exemplo fictício (forbidden-terms por design)
  + não-conformidade Mermaid pré-existente; conformá-los é task à parte (ver LEDGER).
- `ia/tools/check-counts.sh` — computa contagens reais (prompts, skills wrappers+importadas,
  categorias) e falha se os números hardcoded no README/`ia/INSTALAR.md` divergirem. Fiado em `run-tests.sh`.

## Fora de escopo
- Iniciativas B (validador no cliente/maid) e D (outbound).
- Branch protection / required checks (config no GitHub remoto — não versionável aqui; só instruo).
- Mudar os validadores em si — o CI só os orquestra.

## Acceptance Criteria
- [x] AC1: `.github/workflows/ci.yml` é YAML válido; dispara em push(main)+PR; job ubuntu roda os 5 checks + count guard.
- [x] AC2: `check-counts.sh` passa hoje (contagens batem) e FALHA quando um número é adulterado (teste rápido).
- [x] AC3: job windows roda `install.ps1` 2× e checa 1 bloco `.gitignore` (validável no 1º push; local = revisão estática do YAML/PS, sem pwsh).
- [x] AC4: `sync-copilot.sh --check` segue OK com o `ci.yml` presente (workflow não vira drift).
- [x] AC5: `run-tests.sh` inclui `check-counts` e segue verde (FAIL=0).

## Checklist (preenchido na aprovação, a partir do PLANO — STATUS VIVO: marque `[x]` na hora)
- [x] 1. `check-counts.sh` (contagens reais vs docs) + fiado em `run-tests.sh`; sem stale hoje (contagens batem)
- [x] 2. `.github/workflows/ci.yml` (jobs ubuntu + windows)
- [x] 3. Verificado local: run-tests (PASS=20), 3× sync --check, check-counts (validar-doc ia/templates removido — ver LEDGER)
- [x] 4. `ci.yml` não vira drift (`sync-copilot.sh --check` OK) + YAML válido
- [x] 5. Task fechada; commit pendente de "pode commitar" (AC3 windows confirma no 1º push)
