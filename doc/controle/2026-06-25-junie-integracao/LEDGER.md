# LEDGER — 2026-06-25-junie-integracao

## Decisoes
- Junie e o 4o agente, mas SEM superficie de skills/prompts → 1 arquivo `.junie/guidelines.md`
  (analogo do copilot-instructions.md), gerado por sync-junie.sh. Sem replica de skills.
- guidelines.md = entry + estrutura do repo + ponteiro pras 5 rules + 32 gatilhos (manifest)
  + bloco Shell + protocolo de controle. As rules NAO sao inline (enxuto; aponta pra elas).
- Correcoes da pesquisa aplicadas: Shell = **pwsh 7** (NAO Git Bash, JUNIE-1145); guard
  .bashrc (JUNIE-1582); arquivo = guidelines.md (auto-detect do AGENTS.md falha, JUNIE-618).
- gitignore INALTERADO (no-op): guidelines.md e pequeno e versionado; sem replica pesada.
- check-counts NAO ganhou invariante Junie: sync-junie.sh --check ja cobre o drift do arquivo.

## Evidencias (2026-06-25)
- `bash ia/tools/sync-junie.sh` → "Gerado: .junie/guidelines.md (32 gatilhos)"; 93 linhas.
- `bash ia/tools/sync-junie.sh --check` → exit 0 (committed == gerado).
- check-counts → OK; run-tests → PASS=21 FAIL=0; 4 sync --check → exit 0.
- install.sh/.ps1: secao 2c copia .junie/guidelines.md; ci.yml: step anti-drift Junie +
  smoke Windows checa o arquivo; INSTALAR.md/manual.md/README citam o Junie.

## Pesquisa
- /deep-research (task wob7u8xu1): 21 fontes primarias, 18 confirmados / 7 derrubados.
  Sintese na memoria `junie-research-findings.md`. Plano do usuario corrigido em
  `/Users/matheus/PESSOAL/plano-otimizacao-junie-windows.md` (Git Bash→pwsh 7, etc.).

## Arquivos tocados
- Criados: ia/tools/sync-junie.sh, .junie/guidelines.md (gerado).
- Editados: install.sh, install.ps1, .github/workflows/ci.yml, ia/INSTALAR.md,
  ia/INSTALAR/manual.md, README.md.
- Controle: doc/controle/2026-06-25-junie-integracao/ (TASK + PLANO + LEDGER).

## Fora de escopo / nao feito
- AGENTS.md (nome novo): nao agora; guidelines.md e o alvo. Facil somar depois.
- Commit/push: nao pedido.
