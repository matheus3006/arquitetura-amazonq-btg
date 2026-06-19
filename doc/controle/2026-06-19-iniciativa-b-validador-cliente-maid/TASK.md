---
fase: concluida
tipo: normal
task_id: 2026-06-19-iniciativa-b-validador-cliente-maid
---

## Objetivo
Iniciativa B: levar `validar-doc.sh` + lib SoT pro repo do cliente (destrava as etapas 6/7 da
trilha, que já o chamam mas caem no fallback por falta do arquivo) e adicionar um gate de
PARSEABILIDADE de Mermaid no CI do pack. Princípio nº4: enforcement verificável > disciplina.

## Escopo
- B1: `install.sh` + `install.ps1` copiam `validar-doc.sh` → `ia/tools/` e os 3 SoT → `ia/tools/lib/`.
- B1: guarda funcional — teste que instala em tempdir e roda o validar-doc seedado (exit0/exit1
  provando que script + 3 SoT chegaram); smoke do `install.ps1` (Windows) afirma os 4 arquivos.
- Brinde: bump `actions/checkout` v4→v5.

## Fora de escopo
- Não mexer nos prompts de geração (2/3/4) nem nas etapas 6/7 (fork 1: só destravar).
- Não conformar `ia/templates` ao validar-doc estrutural (chip `task_d8458acd`, ortogonal).
- B2 (gate de parseabilidade) — DROPADO: o cliente já vê erro de render no browser +
  validar-doc estrutural; gate de CI só guardaria os exemplos (baixo valor). Ver LEDGER.

## Acceptance Criteria
- [x] AC1: `install.sh` em tempdir limpo deixa validar-doc.sh + 3 SoT e o validar-doc seedado roda:
      exit 0 em página conforme, exit 1 em não-conforme detectada via SoT seedado. (test PASS)
- [~] AC2: smoke do `install.ps1` (Windows CI) afirma presença dos 4 arquivos. (no CI; pwsh n/a local)
- [x] AC3: `run-tests.sh` verde com o novo caso (rodado local). PASS=21 FAIL=0.
- [—] AC4: gate de parseabilidade no CI — CORTADO (B2 dropado; ver LEDGER 2026-06-19).
- [x] AC5: bump `checkout@v5` nos 2 jobs. (YAML válido)

## Checklist (STATUS VIVO — marque [x] na hora)
- [x] 1. install.sh: copia validar-doc.sh + 3 SoT (+ comentário "Copia:")
- [x] 2. install.ps1: espelha as cópias (+ comentário)
- [x] 3. test-install-validador.sh + plug no run-tests.sh
- [x] 4. install.ps1 smoke (ci.yml Windows): afirma os 4 arquivos
- [x] 5. rodar run-tests.sh local → verde (AC1/AC3) — PASS=21 FAIL=0
- [x] 6. bump checkout v4→v5 nos 2 jobs (AC5) — YAML válido
- [—] 7-9. [B2] gate de parseabilidade — DROPADO (decisão do usuário; ver LEDGER). Não há
      artefato de B2 no working tree: o spike rodou só em /tmp.
