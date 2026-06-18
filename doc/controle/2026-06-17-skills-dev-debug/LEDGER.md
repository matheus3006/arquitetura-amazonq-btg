# LEDGER — 2026-06-17-skills-dev-debug

## Decisoes
- **Tipo:** os dois — importar skills (verbatim) + criar prompts autorais (escolha do usuario).
- **Imports (superpowers, unicas fontes verbatim nos caches instalados):** receiving-code-review,
  using-git-worktrees, finishing-a-development-branch, subagent-driven-development,
  dispatching-parallel-agents. (As de performance/testing/refactoring nao tem fonte
  importavel — viraram prompts autorais.)
- **Categorias novas em skills/:** `fluxo-dev/` (worktrees + finishing-branch) e
  `orquestracao/` (subagent-driven + parallel-agents). receiving-code-review entra na
  `code-review/` existente.
- **Prompts autorais (escolha do usuario, 3):** refatorador-incremental, estrategista-de-testes,
  revisor-de-codigo. (Cacador-de-performance foi oferecido mas nao escolhido.)
- **Proveniencia:** skills sao puro verbatim (convencao confirmada: nenhuma nota e adicionada;
  o CREATION-LOG.md das skills e do proprio original). A proveniencia vai no catalogo
  skills/README.md.
- **Contradicao corrigida:** engenharia-style § 3 dizia "nao tente emular subagentes/worktrees";
  agora aponta pras skills importadas (orquestracao/, fluxo-dev/).

## Evidencias (2026-06-17)
- Imports verbatim: 5 dirs copiados de superpowers; `skills/` agora tem 30 skills em 13
  categorias; todas com SKILL.md (subagent-driven traz 3 prompts auxiliares).
- 3 prompts autorais criados em prompts/engenharia/ (estilo fases+gate, igual depurador).
- manifest: 26 linhas == 26 prompts .md (cobertura do sync satisfeita).
- engenharia-style: 3 rotas novas no § 1 + § 3 reescrito; propagado pros 2 mirrors
  (.github/instructions + .kiro/steering) — grep confirma rotas:3 e s3-ok:1 nos tres.
- Regen: sync-copilot/sync-kiro -> 26 wrappers + 30 importadas = 56 em cada camada;
  wrappers novos (refatorador/estrategista/revisor) presentes; 5 skills espelhadas.
- `sync-copilot --check`, `sync-kiro --check`, `sync-como-usar --check` -> todos OK.
- Contagens: grep nao acha nenhuma referencia velha (25/11/48/69/23) em README/INSTALAR/
  installers/skills-README; COMO-USAR sem contagem dura afetada.

## Pendencias
- COMO-USAR.html sem cards para os 8 novos itens (opcional — ver TASK.md).
