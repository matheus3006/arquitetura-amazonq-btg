# LEDGER — 2026-06-18-comentario-contagem-wrappers

## Decisoes
- Comentario fica com nº fixo (30), nao dinamico — manter o cabecalho simples (decisao do PLANO).
- Sem regenerar mirrors: a mudanca e so de comentario, nao afeta a saida gerada pelos scripts.

## Working-model respeitado
- Editados a mao apenas os canonicos (os proprios scripts sao fonte, nao mirrors):
  tools/sync-copilot.sh (linhas 9-10), tools/sync-kiro.sh (linha 8).
- Nenhum mirror tocado (.github/*, .kiro/* seguem em sincronia — confirmado por --check).

## Evidencias (2026-06-18)
- `grep -rn "23 wrappers" tools/` -> none (zero residuos).
- `bash tools/sync-copilot.sh --check` -> "OK: .github/ em sincronia com o canonico."
- `bash tools/sync-kiro.sh --check` -> "OK: .kiro/ em sincronia com o canonico."
- Contagem real continua vinda de `$count` (= 30 slugs do manifest); comentario agora bate.

## Arquivos tocados
- Canonicos (editados): tools/sync-copilot.sh, tools/sync-kiro.sh (so comentario de cabecalho).
- Controle: docs/controle/2026-06-18-comentario-contagem-wrappers/ (TASK, PLANO, LEDGER).
- Baixada a pendencia em docs/controle/2026-06-17-prompt-sincronizar-doc-codigo/LEDGER.md.

## Fora de escopo (confirmado)
- "(5 rules)" nos cabecalhos: bate com a array RULES — nao tocado.
- Contagem dinamica no comentario: descartada (manter simples).
- Commit: nao solicitado nesta task — nao commitado.
