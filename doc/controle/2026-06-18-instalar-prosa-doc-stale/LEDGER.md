# LEDGER — 2026-06-18-instalar-prosa-doc-stale

## Decisoes
- Remover a ressalva "o resto de `doc/arquitetura/` (css, 2 .js, paginas) e copiado": pos-reorg
  nenhum asset do pack vive em `doc/`. A nova prosa aponta `ia/design-system/` + `ia/templates/`
  + `ia/`, coerente com a tabela do Passo 2 (linhas 49-52).
- Manter clara a regra "nao copie a `doc/` do pack — sao do pack, nao do servico".

## Working-model respeitado
- Editado so o canonico `ia/INSTALAR.md` (bloco 83-88). Standalone: nao espelhado por sync,
  nao copiado pro alvo. Nenhum mirror tocado.

## Evidencias (2026-06-18)
- Bloco reescrito (INSTALAR.md:83-88): "nem a `doc/` do pack ... os assets reutilizaveis ...
  vivem em `ia/design-system/`, `ia/templates/` e `ia/` ... nao ha mais nenhum asset do pack
  dentro de `doc/`."
- `find doc/arquitetura -type f` -> so `doc/arquitetura/README.md` (confirma: zero asset em doc/).
- Falso-positivo conferido: INSTALAR.md:56 ("a doc REAL gerada do servico vai em `doc/arquitetura/`;
  os exemplos de forma ficam em `ia/templates/`") esta CORRETO — doc real e output do servico;
  nao e a cláusula stale. Nao tocado.
- `bash ia/tools/sync-copilot.sh --check`   -> OK ... exit=0
  `bash ia/tools/sync-kiro.sh --check`      -> OK ... exit=0
  `bash ia/tools/sync-como-usar.sh --check` -> OK ... exit=0

## Arquivos tocados
- Canonico (editado): ia/INSTALAR.md.
- Controle: doc/controle/2026-06-18-instalar-prosa-doc-stale/ (TASK + LEDGER).

## Fora de escopo (confirmado)
- Item 2 do meu oferecimento (linha no Passo 4 sobre PLANO.html antigos com `<link>` stale):
  o usuario escolheu so o item 1 — nao feito.
- INSTALAR.md:56 (doc real em doc/arquitetura/): correto, nao tocado.
- Push: nao solicitado nesta task.
