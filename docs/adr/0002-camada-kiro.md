# ADR-0002 — Camada Kiro gerada a partir do canônico

- **Status:** aceita
- **Data:** 2026-06-11
- **Autor:** Matheus (com Claude Code)
- **Contexto de origem:** o time do BTG passou a usar o Kiro além do Amazon Q e do
  GitHub Copilot. O pack precisava cobrir a terceira ferramenta.

## Contexto e problema

O Kiro NÃO lê `.amazonq/rules/` nem `.github/instructions/`. Mecanismos próprios
(verificados na doc oficial kiro.dev em 2026-06-11): steering em `.kiro/steering/*.md`
com frontmatter `inclusion: always|fileMatch|manual|auto`; Agent Skills (padrão aberto
SKILL.md) em `.kiro/skills/<slug>/`; foundation files (`product.md`, `tech.md`,
`structure.md`) gerados pelo próprio Kiro em `.kiro/steering/`; `AGENTS.md` na raiz é
lido sempre, sem modos de inclusão.

## Decisões

1. **Mesma arquitetura do porte Copilot:** `.amazonq/rules/` permanece canônico;
   `tools/sync-kiro.sh` gera `.kiro/steering/` (5 rules com `inclusion: always`) e
   `.kiro/skills/` (19 wrappers SKILL.md) a partir do mesmo `manifest.tsv`. Camada
   commitada, nunca editada à mão; `--check` para CI/pré-commit de manutenção.
2. **Gate de contexto vira TRIPLO:** analisadores gravam `project-context.md` /
   `business-context.md` também em `.kiro/steering/` (com `inclusion: always` —
   sem o frontmatter o arquivo existe mas o conteúdo entra; explícito é à prova de
   mudança de default). Sem a terceira cópia o Kiro operaria sem contexto (quebra
   silenciosa, mesma armadilha do `applyTo` no Copilot).
3. **Skills, não custom agents:** os 19 prompts viram Agent Skills (ativação por
   descrição + progressive disclosure), não `.kiro/agents/*.json` — skills são
   versionáveis no workspace, funcionam em IDE e CLI e seguem o padrão aberto já
   usado na camada Copilot.
4. **Instaladores copiam só as 5 rules nomeadas + skills/** — contextos por-serviço
   e foundation files do Kiro nunca são tocados em re-runs.
5. **AGENTS.md não é usado** — redundante com steering instalado.

## Consequências

- (+) Um canônico, três ferramentas; manutenção = editar rule e rodar os dois syncs.
- (+) O hook de início de interação do protocolo de controle roda nativo no Kiro
  (`promptSubmit` em `.kiro/hooks/`), espelhando o `userPromptSubmit` do Amazon Q —
  ver [ADR-0004](0004-hook-de-assistente-substitui-pre-commit.md).
- (−) Dois geradores para manter em paralelo (`sync-copilot.sh` + `sync-kiro.sh`).
- (−) Steering sempre-on triplica em repos que usam as três ferramentas — sem custo
  cruzado (cada ferramenta lê só a própria pasta).

## Validação

Smoke no Kiro real do BTG: (a) steering carregado (perguntar "quais regras de
documentação valem aqui?"); (b) skill ativando por gatilho natural ("documenta esse
serviço" → analisador); (c) analisador gravando o contexto nos três destinos.
