# TASK — 2026-06-17-como-usar-prioridade

- **fase:** concluida
- **tipo:** normal
- **pedido:** reorganizar o COMO-USAR por PRIORIDADE de trilha (Arquitetura > Debugging >
  Escrita de codigo > UI/UX > demais), reagrupando os cards por trilha e adicionando os
  cards que faltam (3 prompts novos + 6 skills importadas sem card).

## Criterios de aceite
- [x] Ordem das secoes: (topo: banner controle + como invocar + preparar repo) ->
      Arquitetura -> Debugging -> Escrita de codigo -> UI/UX -> Negocio -> Produto -> Combos.
- [x] Cards de arquitetura e de codigo, hoje dispersos, ficam cada um na sua trilha.
- [x] Os 9 cards novos existem, no formato dos demais (msg + footer de ferramenta/skill).
- [x] Nenhum card existente perdido (68 = 59 + 9; <article> abre/fecha 68/68).
- [x] sync-como-usar --check OK (md regenerado bate com o html).

## Checklist de execucao
- [x] inventario dos 59 cards + estrutura HTML
- [x] reescrita do COMO-USAR.html na nova ordem (9 secoes trilha por prioridade)
- [x] realocacao de cada card pra sua trilha (arquitetura e codigo, antes dispersos)
- [x] 9 cards novos: refatorador, estrategista-de-testes, revisor (Escrita de codigo);
      receiving-code-review, using-git-worktrees, finishing-a-development-branch,
      subagent-driven-development, dispatching-parallel-agents (Escrita de codigo);
      doc-coauthoring (Arquitetura)
- [x] hero intro + section-eyebrows + intros das secoes novas
- [x] sync-como-usar.sh -> COMO-USAR.md (68 cards) + --check OK
- [x] verificacao: 68 cards, tags balanceadas, ordem correta, slugs novos presentes
