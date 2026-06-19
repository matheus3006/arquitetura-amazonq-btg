# Plano — ci-github-actions

**Objetivo:** GitHub Actions roda os validadores (hoje manuais) em todo push(main)/PR + smoke-test do install.ps1.
**Maior risco:** count guard brittle (prosa) ou contagens stale fazendo o CI nascer vermelho → Etapa 1 corrige stale antes de fiar.

## Etapa 1 — check-counts.sh + fiação
- **Arquivos:** `ia/tools/check-counts.sh` (novo); `ia/tools/tests/run-tests.sh` (fiar como 1 caso).
- **Mudança:** script computa contagens REAIS — prompts (`find ia/prompts -name '*.md'`), wrappers
  (linhas não-comentário do `manifest.tsv`), skills importadas (`ia/skills/*/*/SKILL.md`), categorias
  (`ia/skills/*/`), total `.github/skills/*` — e assere que os números hardcoded no `README.md` e
  `ia/INSTALAR.md` batem (lista curada de pares número↔contexto; exit 1 + mensagem no 1º desvio).
  Se achar contagem stale nos docs HOJE, corrige (1 linha cada) pra suite nascer verde.
- **Verificação:** `bash ia/tools/check-counts.sh` → exit 0; adulterar 1 número num doc temp → exit 1.
- **Pronto quando:** passa no estado atual e falha sob adulteração; `run-tests.sh` mostra o caso.

## Etapa 2 — ci.yml
- **Arquivos:** `.github/workflows/ci.yml` (novo).
- **Mudança:** `on: push:branches:[main] + pull_request`. Job **checks** (ubuntu-latest):
  checkout → `run-tests.sh` → `validar-doc.sh ia/templates --all` → `sync-copilot/kiro/como-usar --check`
  → `check-counts.sh`. Job **windows-install** (windows-latest, shell pwsh): checkout → `install.ps1`
  num temp 2× → assert 1 bloco `# >>> arquitetura-pack` no `.gitignore` e ausência de `ia/prompts/<t>/<t>`.
- **Verificação:** YAML sanity (parse) + revisão estática dos passos; jobs batem com os comandos locais.
- **Pronto quando:** workflow descreve os checks exatamente como rodados à mão.

## Etapa 3 — Verificação local dos checks
- **Arquivos:** nenhum (execução).
- **Mudança:** rodar a mesma sequência do job ubuntu localmente.
- **Verificação:** `run-tests.sh` (PASS, FAIL=0) · `validar-doc.sh ia/templates --all` (exit 0) ·
  3× `sync --check` (OK) · `check-counts.sh` (exit 0).
- **Pronto quando:** todos verdes — o CY ubuntu passaria.

## Etapa 4 — ci.yml não vira drift
- **Arquivos:** nenhum.
- **Mudança:** confirmar que o workflow novo não é acusado pelo mirror.
- **Verificação:** `bash ia/tools/sync-copilot.sh --check` → OK com `.github/workflows/ci.yml` presente.
- **Pronto quando:** sync --check verde com o workflow no lugar.

## Etapa 5 — Fechar
- **Arquivos:** TASK.md, LEDGER.md.
- **Mudança:** ACs marcados (AC3 windows = "confirmar no 1º push"), fase concluida.
- **Verificação:** evidências no LEDGER § Verificação.
- **Pronto quando:** task fechada; commit pendente de "pode commitar".
