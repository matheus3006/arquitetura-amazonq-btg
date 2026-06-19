# LEDGER — 2026-06-19-pipeline-arquitetura-v2

## Decisões
- Brainstorming concluído com 6 perguntas-fork + 3 confirmações finais + Decisão #10
  confirmada (1 task por execução no atualizador). Spec v1.1 aprovado.
- Auto-revisão adversarial: painel de 4 críticos, 28 findings corrigidos (ver spec §13).
  Bugs reais pegos: contradição sessão/etapa/prompt resolvida com "7 etapas conceituais,
  8 sessões"; aritmética por trilha confirmada 11→13 (não 10→12); NAV editor cravado como
  responsabilidade do gerador (não do validador); CLI canônica do validar-doc.sh definida.
- Implementação inline (executing-plans) decomposta em 9 fases (A-I); cada task = 1 commit
  lógico. TDD genuíno no validar-doc.sh com fixtures HTML válidas/inválidas; verificação
  por grep + 3× sync --check para conteúdo.
- Bugs reais detectados durante a implementação:
  - Pipe `awk | while read` perde contador por subshell → process substitution.
  - `read` não funciona em buf com `\n` → awk emite violações diretamente em vez de blocos.

## Verificação
- AC1-AC5: passed (ver TASK.md).
- Suite `bash ia/tools/tests/run-tests.sh`: **PASS=17 FAIL=0** cobrindo CLI + 5 regras
  `--front` (head-order, class-unknown, no-hex, forbidden-terms, nav-órfã) + 4 regras
  `--mermaid` (pair, type, classdef, autonumber) + `--all`.
- `bash ia/tools/sync-copilot.sh   --check` → exit 0.
- `bash ia/tools/sync-kiro.sh      --check` → exit 0.
- `bash ia/tools/sync-como-usar.sh --check` → exit 0.
- Contagens finais: ia/prompts=32, manifest=32, github/prompts=32, github/skills=64,
  kiro/skills=64, ia/prompts/arquitetura=13 (todas conforme esperado).
- Varredura final por rótulos antigos: zero "Etapa N de 3" ou "Etapa N/3" em rules/prompts/
  COMO-USAR/mirrors; zero `docs/<servico>` em prompts/rules; única menção a
  `completar-documentacao` é em `architecture-style.md:171` como nota informativa
  ("foi aposentado") — intencional, não resíduo.

## Pendências
- (vazio)

## Arquivos tocados (resumo)
- **Canônicos criados:** 3 prompts (`validador-visual.md`, `validador-sintaxe-mermaid.md`,
  `atualizador-arquitetura.md`) + 3 SoT em `ia/tools/lib/` (`design-system-classes.txt`,
  `mermaid-classdefs.txt`, `forbidden-terms.txt`) + `ia/templates/checklist-validador.md`
  + `ia/tools/validar-doc.sh` + suite `ia/tools/tests/run-tests.sh` + 13 fixtures
  (`front/*.html`, `mermaid/*.html`, `nav-good/`, `nav-bad/`) + `ia/tools/README-validar-doc.md`.
- **Canônicos editados:** `documentar-servico.md` (vira índice), `analisador-de-projeto.md`,
  `analisador-de-dominio.md`, `arquiteto-de-sistema.md`, `documentador-fluxo.md`,
  `gerador-runbook.md`, `grill-arquitetura.md` (STATUS + handoffs); `gerador-adr.md` e
  `sincronizar-doc-codigo.md` (destino `docs/<servico>/` → `doc/`); `controle-de-tarefa.md`
  (template QA.md) + `controle-style.md` (regra QA.md status vivo); 3 rules
  (`architecture-style.md`, `frontend-style.md` — enforcement v2); `ia/tools/manifest.tsv`
  (4 ops: delete + reescrever + renumber + +3); `ia/COMO-USAR.html` (7 cards + cabeçalho
  + COMBO + atualizador); contagens stale (`README.md`, `ia/INSTALAR.md`, `install.sh`,
  `install.ps1`, `ia/tools/sync-copilot.sh`, `ia/tools/sync-kiro.sh`, `ia/skills/README.md`).
- **Canônicos aposentados:** `ia/prompts/arquitetura/completar-documentacao.md` (deletado;
  sync com prune removeu wrappers em `.github/` e `.kiro/`).
- **Mirrors regenerados:** `.github/` (32 prompts + 64 skills) + `.kiro/` (64 skills) +
  `ia/COMO-USAR.md` (74 cards) — via `sync-*.sh`, nunca editados à mão.
- **Controle:** `doc/controle/2026-06-19-pipeline-arquitetura-v2/` (TASK + QA + LEDGER —
  QA.md dogfooda a feature deste próprio redesign).
- **Spec + plano:** `doc/specs/2026-06-19-pipeline-arquitetura-v2-design.md` (v1.1) e
  `doc/planos/2026-06-19-pipeline-arquitetura-v2.md`.

## Working-model respeitado
- Edições só em canônicos; mirrors regenerados por `sync-*.sh` em todas as fases que tocaram
  canônicos espelhados. 3× `--check` exit 0 em cada checkpoint.
- Protocolo de controle: task de controle aberta ANTES de qualquer edição; status vivo no
  TASK.md (checklist marcado a cada fase); QA.md apendado no mesmo turno; LEDGER ao final.
- Commit direto na `main` (sem branch/PR), conforme preferência em memory.
