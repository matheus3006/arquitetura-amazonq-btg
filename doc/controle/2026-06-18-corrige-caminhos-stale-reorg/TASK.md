# TASK — 2026-06-18-corrige-caminhos-stale-reorg

- **fase:** concluida
- **tipo:** trivial (2 arquivos, baixo risco; correcao de caminho em texto/template)
- **pedido:** corrigir as 2 referencias ao layout antigo (`docs/arquitetura/`) que
  sobreviveram ao refactor ia/+doc/, achadas na leitura de validacao.

## Achados (da validacao)
- `ia/prompts/engenharia/controle-de-tarefa.md:129-130` — o esqueleto PLANO.html aponta o CSS
  para `../../docs/arquitetura/design-system/` (pasta inexistente). PLANO.html e gravado em
  `doc/controle/<task-id>/` (controle-style.md §2); dali o design-system esta 3 niveis acima:
  o certo e `../../../ia/design-system/`.
- `README.md:245` — a URL de exemplo usa `docs/arquitetura/templates/index.html`, mas a prosa
  logo acima (linha 242) ja diz `ia/templates/`. O certo e `ia/templates/index.html`.

## Working-model
- `controle-de-tarefa.md` e canonico (ia/prompts/); o caminho stale NAO aparece em nenhum mirror
  (wrappers referenciam o prompt, nao embutem o corpo) — confirmado por git grep. Sem re-sync de
  conteudo; rodar os 3 `--check` so para garantir que nada derivou.
- README.md e standalone (raiz), nao espelhado.

## Criterios de aceite
- [x] AC1: zero ocorrencias de `docs/arquitetura/` em ia/prompts/ e README.md (grep vazio).
- [x] AC2: controle-de-tarefa.md usa `../../../ia/design-system/{tokens,components}.css`.
- [x] AC3: README.md:245 usa `.../arquitetura/ia/templates/index.html`.
- [x] AC4: os 3 `bash ia/tools/sync-*.sh --check` = exit 0, sem DRIFT.

## Checklist de execucao
- [x] editar controle-de-tarefa.md (2 linhas de `<link>`)
- [x] editar README.md (1 linha de exemplo)
- [x] grep de residuo + 3 --check
- [x] LEDGER com evidencias + fechar
