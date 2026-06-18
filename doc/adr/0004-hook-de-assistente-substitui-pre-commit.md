# ADR-0004 — Hook de início de interação substitui o pre-commit punitivo

- **Status:** aceita
- **Data:** 2026-06-17
- **Autor:** Matheus (com Claude Code)
- **Supersede:** decisões 2 (caminho) e 5 (enforcement) do
  [ADR-0001](0001-protocolo-de-controle-de-contexto.md).

## Contexto e problema

O ADR-0001 escolheu um **pre-commit git** como rede determinística do protocolo de
controle, partindo da premissa de que "Amazon Q/Copilot não têm hooks de assistente".
Esse pre-commit **bloqueava o `git commit` do humano** sempre que faltassem arquivos de
task no stage — efeito colateral indesejado: punia a pessoa, não o agente, e travava
commits legítimos.

Duas coisas mudaram:

1. **A premissa caiu.** O Amazon Q CLI (custom agents, GA jul/2025) tem hooks de
   assistente — `agentSpawn` (1x/sessão) e `userPromptSubmit` (a cada mensagem),
   definidos em `.amazonq/cli-agents/<nome>.json`, cada um rodando um comando cujo
   stdout entra no contexto. O Kiro tem o trigger equivalente `promptSubmit`
   (`.kiro/hooks/*.kiro.hook`). (Verificado na doc oficial em 2026-06-17.)
2. **O intento real** sempre foi *abrir a task no começo do trabalho*, não *bloquear o
   commit no fim*.

## Decisões

1. **Enforcement = hook de início de interação**, não pre-commit. A cada interação o
   hook injeta o lembrete do protocolo, fazendo o agente abrir/atualizar a task ANTES
   de editar:
   - Amazon Q: `.amazonq/cli-agents/arquitetura.json` (`hooks.userPromptSubmit` →
     `.amazonq/hooks/controle-hook.sh`). Ativar com `q chat --agent arquitetura`.
   - Kiro: `.kiro/hooks/controle-prompt.kiro.hook` (`when.type: promptSubmit` →
     `then.type: askAgent`).
   - Copilot: sem hook de início de interação — segue só na rule sempre-on.
2. **Sem trava no `git commit`.** O pre-commit (`tools/pre-commit-controle.sh` +
   `.git/hooks/pre-commit`) é removido; os instaladores apagam a versão antiga em
   re-runs. Os arquivos da task viajam junto com o artefato por disciplina da rule,
   não por bloqueio.
3. **Caminho muda para `docs/controle/`** (era `controle/` na raiz), agrupando o
   protocolo com a demais documentação.

## Consequências

- (+) O humano nunca mais é bloqueado ao commitar; a rede age no momento certo (início),
  não no fim.
- (+) O agente passa a abrir a task proativamente em vez de depender só de obedecer à rule.
- (−) O hook do Amazon Q só dispara com o agente `arquitetura` ativo (`--agent`); a doc
  de instalação destaca isso.
- (−) No Kiro, a ação `askAgent` consome crédito por disparar um loop de agente a cada
  prompt — desligável no painel de hooks se ficar custoso.
- (−) Some a garantia determinística no commit; a cobertura agora depende do hook estar
  ativo. Trade-off aceito: o pre-commit punia quem não devia.

## Validação

Smoke real: (a) Amazon Q com `--agent arquitetura` injeta o lembrete e abre a task num
pedido que gera artefato; (b) Kiro dispara o `promptSubmit`; (c) `git commit` de
qualquer arquivo passa sem bloqueio; (d) instalar sobre uma instalação antiga remove o
`.git/hooks/pre-commit` punitivo.
