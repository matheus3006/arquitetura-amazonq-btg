---
fase: concluida      # planejamento | execucao | concluida | bloqueada
tipo: normal         # normal | trivial
task_id: 2026-06-19-arquitetura-v2-0-1
---

## Objetivo
Resolver os 3 findings de severidade MÉDIA da validação adversarial ponta-a-ponta da v2
(2026-06-19) antes de divulgar/instalar o pack em repos de terceiros.

## Escopo
- Finding #1 (+ gap adjacente): instaladores não copiam `prefs.js`; e docs gerados em
  `doc/arquitetura/` referenciam `../templates/` + `../design-system/` (= `doc/templates/`,
  `doc/design-system/`) que nada cria → render sem estilo. Decisão (QA.md): **semear esses
  assets sob `doc/` a partir de `ia/`** (artefato de build) + copiar `prefs.js` nos instaladores.
- Finding #2: `install.ps1:96` aninha `ia/prompts/<t>/<t>/` em re-run no Windows (diverge do `install.sh:92`).
- Finding #3: `validar-doc.sh:178-204` valida só a PRESENÇA dos 4 classDef, não o hex exato que
  `ia/templates/checklist-validador.md:22` e `ia/tools/README-validar-doc.md:31` prometem.

## Fora de escopo
- Os findings de baixa do linter opcional (só-prompt: body-shell, breadcrumb/hero, labels mermaid,
  Butterick, etc.) — outra task.
- Exceção: a frase stale `arquiteto-de-sistema.md:103` (baixa) entra na Etapa D (1 linha, arquivo já tocado).
- Qualquer mudança de comportamento da trilha canônica (1a→7) e dos paths do `<head>` do spec.

## Acceptance Criteria
- [x] AC1: `prefs.js` + CSS resolvem (sem 404) nas páginas entregues E nos docs gerados em
  `doc/arquitetura/` (assets semeados sob `doc/` por `install.sh` e `install.ps1`).
- [x] AC2: `install.ps1` idempotente (glob `/*`; sem `ia/prompts/<t>/<t>/`); paridade com `install.sh` — revisão estática (pwsh indisponível, ver Pendências).
- [x] AC3: a promessa do checklist + README sobre o hex do classDef bate com o enforcement real.
- [x] AC4: `run-tests.sh` PASS=18 FAIL=0 e 3× `--check` = exit 0.

## Checklist (preenchido na aprovação, a partir do PLANO — STATUS VIVO: marque `[x]` na hora)
- [x] 1. Etapa A — `validar-doc.sh` compara hex do classDef vs SoT + fixture `bad-classdef-hex.html` + suite PASS=18
- [x] 2. Etapa B — criar `ia/tools/seed-doc-assets.sh` + `install.sh`/`install.ps1` copiam prefs.js e semeiam doc/ (sh verificado por dry-run)
- [x] 3. Etapa C — alinhar `install.ps1:96` ao padrão glob `/*` (revisão estática — pwsh indisponível)
- [x] 4. Etapa D — 3 geradores citam origem dos assets + conserto `arquiteto-de-sistema.md:103`
- [x] 5. Etapa E — sync 3× + verificação (3× --check, run-tests PASS=18, dry-run) + fechar + commit
