---
fase: concluida      # planejamento | execucao | concluida | bloqueada
tipo: normal         # normal | trivial
task_id: 2026-06-19-instalador-gitignore-contexto
---

## Objetivo
Instalador semeia (idempotente) um bloco `.gitignore` no repo do produto: ignora as réplicas
pesadas (skills/prompts, ~9,5 MB) e mantém versionada a config + o contexto por-produto. Docs
passam a orientar versionar o contexto. Tira a fricção de cada time inventar a política —
pré-requisito do interno→externo. (Iniciativa E do roadmap A/B/D/E aprovado.)

## Escopo
- SoT do bloco em `ia/tools/lib/gitignore-pack-block.txt` (paths + comentários — fonte única, anti-drift).
- `ia/tools/seed-gitignore.sh` — helper bash idempotente (injeta entre marcadores; shipado ao
  cliente p/ re-seed, espelhando `seed-doc-assets.sh`).
- `install.sh` chama o helper; `install.ps1` injeta em PowerShell lendo a MESMA SoT (sem bash no Windows).
- Teste em `ia/tools/tests/` (idempotência: 2× = 1 bloco; conteúdo == SoT).
- Docs: `README.md:163-164` "não versionar"→"versione"; nota da política + regra "clonou → instala 1×"
  no README e em `ia/INSTALAR.md`.

## Fora de escopo
- Iniciativas A (CI), B (validador no cliente), D (outbound).
- Instalação seletiva por assistente (descartada: equipes heterogêneas usam os 3).
- Mudar o que o instalador COPIA — só adiciona o seed do `.gitignore`.

## Acceptance Criteria
- [x] AC1: `seed-gitignore.sh <dir-sem-.gitignore>` cria `.gitignore` com bloco marcado == SoT.
- [x] AC2: rodar 2× → exatamente 1 bloco (idempotente); conteúdo preexistente do .gitignore preservado.
- [x] AC3: `install.ps1` produz bloco idêntico ao da SoT (paridade sh/ps1; revisão estática se pwsh indisponível).
- [x] AC4: README + `ia/INSTALAR.md`: contexto por-produto = versionar; política + "clonou → instala 1×" documentadas.
- [x] AC5: novo teste PASS e `ia/tools/tests/run-tests.sh` segue verde.

## Checklist (preenchido na aprovação, a partir do PLANO — STATUS VIVO: marque `[x]` na hora)
- [x] 1. SoT `gitignore-pack-block.txt` + `seed-gitignore.sh` (idempotente, marcadores)
- [x] 2. `install.sh` §9 chama o helper
- [x] 3. `install.ps1` §9 injeta lendo a SoT (paridade — revisão estática, pwsh indisponível)
- [x] 4. Teste de idempotência/conteúdo em `ia/tools/tests/` (suite PASS=19 FAIL=0)
- [x] 5. Docs (README 163-164 + nota; `ia/INSTALAR.md`)
- [x] 6. ACs verificados + task fechada (commit pendente de "pode commitar")
