# TASK — 2026-06-18-comentario-contagem-wrappers

- **fase:** concluida
- **tipo:** limpeza (comentario interno; sem mudanca de comportamento)
- **pedido:** o cabecalho de tools/sync-copilot.sh documenta a saida como "(23 wrappers)"
  para .github/prompts/<slug>.prompt.md e .github/skills/<slug>/SKILL.md. Numero defasado:
  o manifest tem 30 slugs e os scripts imprimem "30 prompt files + 30 skills wrappers".
  Atualizar 23 -> 30 e checar contagens defasadas no mesmo cabecalho e no sync-kiro.sh.

## Contexto
- Pendencia herdada: docs/controle/2026-06-17-prompt-sincronizar-doc-codigo/LEDGER.md (linha 47)
  ja registrou esse "23 wrappers" como candidato a limpeza futura.

## Achados
- "23 wrappers" aparece em 3 lugares: sync-copilot.sh:9, sync-copilot.sh:10, sync-kiro.sh:8.
- Demais contagens dos cabecalhos: "(5 rules)" bate com a array RULES (5 entradas) — manter.
- A contagem impressa pelos scripts vem de `$count` = nº de slugs do manifest (30), nao e hardcoded.

## Criterios de aceite
- [x] sync-copilot.sh cabecalho: 23 -> 30 (linhas 9 e 10).
- [x] sync-kiro.sh cabecalho: 23 -> 30 (linha 8).
- [x] nenhuma outra contagem defasada nos cabecalhos.
- [x] `bash tools/sync-copilot.sh --check` = OK.
- [x] `bash tools/sync-kiro.sh --check` = OK.

## Checklist de execucao
- [x] editar sync-copilot.sh (2 linhas) e sync-kiro.sh (1 linha)
- [x] --check de ambos
- [x] LEDGER com evidencias + baixar a pendencia do LEDGER anterior
