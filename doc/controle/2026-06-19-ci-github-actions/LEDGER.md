# Ledger — ci-github-actions

## Decisões
- 2026-06-19 — Iniciativa A (keystone) do roadmap A/B/D/E. Vem depois de E (commit `cbef236`).
- 2026-06-19 — `.github/workflows/ci.yml` é SEGURO no repo do pack: `sync-copilot.sh --check` só diffa
  `copilot-instructions.md`+`instructions`+`prompts`+`skills`; o generate só faz `rm -rf` dessas 3 →
  não clobbera nem acusa `workflows/`. Instaladores não copiam `workflows/` pro cliente.
- 2026-06-19 — Inclui job **windows-latest** que roda `install.ps1` (fecha o gap do AC3 da iniciativa E,
  que ficou só em revisão estática por falta de pwsh local).
- 2026-06-19 — Inclui **count guard** leve (`check-counts.sh`) porque o usuário flagou "contagens
  hardcoded no README" como medo de drift. (Escopo dos 2 a confirmar na aprovação.)

## Verificação
- AC1: `python3 yaml.safe_load` em ci.yml → válido; jobs [checks, windows-install]; triggers push(main)+pull_request — passed
- AC2: `check-counts.sh` → exit 0 hoje; com README adulterado ("31 Agent Skills") → exit 1 + msg; restaurado via git — passed
- AC4: `sync-copilot.sh --check` com ci.yml presente → "OK: .github/ em sincronia" (workflow não acusado) — passed
- AC5: `run-tests.sh` → Total PASS=20 FAIL=0 (inclui seed-gitignore + check-counts) — passed
- Cobertura local do job ubuntu: validar-doc(fixtures via run-tests) + 3× sync --check + check-counts → todos verdes — passed
- AC3 (job windows install.ps1): YAML/PS revisados; SEM runtime local (pwsh ausente) — confirmar no 1º push — pending
- Instaladores não copiam `.github/workflows/` (grep 0 refs) — passed

## Decisão de meio de execução
- 2026-06-19 — REMOVIDO do CI o passo `validar-doc ia/templates --all`: as páginas de exemplo
  disparam forbidden-terms POR DESIGN (são o exemplo fictício "Liquidação Transacional"/"FICO Falcon")
  e têm não-conformidade Mermaid pré-existente (flowcharts sem os 4 classDef; `ext fill #f9fafb` vs
  SoT `#ffffff` em 02-padroes.html/06-infraestrutura.html, classDef faltando em 03-dados/07-fluxo-autorizacao).
  Conformá-las é task à parte (fora do escopo do A). O validador segue exercitado pelas fixtures.

## Pendências
- AC3 confirmado só no 1º push (sem pwsh local).
- ACHADO p/ task futura: páginas de exemplo não passam `validar-doc --mermaid` (não-conformidade real
  na própria referência de qualidade). Decidir: conformar as páginas OU revisar a rigidez da regra dos
  4 classDef; depois adicionar `validar-doc ia/templates --mermaid` ao CI.
