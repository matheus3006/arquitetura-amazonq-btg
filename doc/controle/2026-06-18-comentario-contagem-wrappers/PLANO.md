# PLANO — 2026-06-18-comentario-contagem-wrappers

Mudanca trivial de comentario interno. Os scripts sao canonicos (nao sao mirrors), entao
edita-se direto. Nenhum mirror e regenerado (so comentario; nao muda a saida gerada).

## Tarefa 1 — atualizar cabecalho do sync-copilot.sh
- Linha 9: `.github/prompts/<slug>.prompt.md  (23 wrappers)` -> `(30 wrappers)`.
- Linha 10: `.github/skills/<slug>/SKILL.md   (23 wrappers)` -> `(30 wrappers)`.

## Tarefa 2 — atualizar cabecalho do sync-kiro.sh
- Linha 8: `.kiro/skills/<slug>/SKILL.md   (23 wrappers — Agent Skills, ...)` -> `(30 wrappers — ...)`.

## Verificacao
- `bash tools/sync-copilot.sh --check` e `bash tools/sync-kiro.sh --check` = exit 0
  (confirma que nada quebrou; mirrors seguem em sincronia, pois comentario nao afeta a geracao).

## Fora de escopo
- Nao tornar a contagem dinamica no cabecalho (continua sendo nº fixo no comentario; manter simples).
- Nao mexer em "(5 rules)" (bate com RULES).
- Nao regenerar mirrors (mudanca so de comentario).
