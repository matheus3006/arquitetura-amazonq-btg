# LEDGER — 2026-06-25-instalar-granular-split

## Decisoes
- Split real (dispatcher fino + sub-arquivos), nao reordenacao in-place: so dividir em
  arquivos reduz o que um agente carrega (ao dar Read ele ingere o arquivo inteiro).
- INSTALAR.md continua entry point (README aponta pra ele); caminho-feliz auto-contido
  (Passo 0/1/3/5). Passos 2/4/4b viraram stubs com gatilho + caminho EXATO pras sub-paginas.
- Numeracao preservada (0,1,2,3,4,4b,5) pra nao quebrar cross-refs.
- Passo 3 (verificacao) ficou no INSTALAR.md → os 4 greps do check-counts seguem validos.

## Evidencias (2026-06-25)
- wc -l: INSTALAR.md 211 → 106; sub-paginas manual.md 71, migracao.md 37, doc-v2.md 45.
- `bash ia/tools/check-counts.sh` → OK (exit 0): os 4 padroes do Passo 3 preservados.
- `bash ia/tools/tests/run-tests.sh` → PASS=21 FAIL=0.
- 3 sync --check (copilot/kiro/como-usar) → exit 0 (nenhum mirror tocado).
- manual.md lista `ia/INSTALAR/` em "nao copie" (sub-paginas = runbook do pack, nao vao pro alvo).

## Working-model respeitado
- INSTALAR.md e canonico standalone (nao espelhado por sync, nao copiado pro alvo).
  As novas sub-paginas seguem a mesma regra. Nenhum mirror (.github/.kiro) tocado.

## Arquivos tocados
- Reescrito: ia/INSTALAR.md (slim). Criados: ia/INSTALAR/{manual,migracao,doc-v2}.md.
- Controle: doc/controle/2026-06-25-instalar-granular-split/ (TASK + PLANO + LEDGER).

## Fora de escopo (confirmado)
- check-counts/README: nao alterados (Passo 3 intacto). Junie: task separada. Commit: nao pedido.
