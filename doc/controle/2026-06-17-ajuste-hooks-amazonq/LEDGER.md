# LEDGER — 2026-06-17-ajuste-hooks-amazonq

## Decisoes
- **Caminho:** `docs/controle/` (escolha do usuario; antes era `controle/` na raiz).
- **Pre-commit bloqueante:** REMOVIDO de vez. O usuario nao quer trava entre ele e o
  `git commit`. A "rede" sai do commit-time e vai pro inicio da interacao.
- **Cobertura:** Amazon Q + Kiro. Copilot nao tem hook de inicio de interacao -> segue
  so na rule sempre-on.
- **Amazon Q:** custom agent `.amazonq/cli-agents/arquitetura.json` com hook
  `userPromptSubmit` (dispara a cada mensagem). Confirma feature GA jul/2025 — refuta a
  premissa do ADR-0001 ("Amazon Q nao tem hooks de assistente"). O hook roda
  `.amazonq/hooks/controle-hook.sh`, cujo stdout e injetado no contexto. So orienta;
  nao bloqueia. Requer ativar o agente: `q chat --agent arquitetura`.
- **Kiro:** `.kiro/hooks/controle-prompt.kiro.hook`, trigger `promptSubmit` -> `askAgent`.
  Observacao: acao `askAgent` consome credito (dispara loop de agente por prompt); o
  usuario pode desligar no painel de hooks do Kiro se ficar custoso.

## Fontes (verificadas nesta sessao)
- Amazon Q hooks (agentSpawn/userPromptSubmit) + local `.amazonq/cli-agents/<name>.json`:
  docs.aws.amazon.com + aws/amazon-q-developer-cli (agent-format.md).
- Kiro hooks (`promptSubmit`, schema `.kiro.hook` enabled/name/description/version/when/then):
  kiro.dev/docs/hooks + exemplo real awsdataarchitect/kiro-best-practices.

## Evidencias (2026-06-17)
- `jq` valida `.amazonq/cli-agents/arquitetura.json` e `.kiro/hooks/controle-prompt.kiro.hook` — OK.
- `bash -n` em `controle-hook.sh` e `install.sh` — OK. Saida do hook injeta o lembrete com a
  data de hoje e o caminho `docs/controle/2026-06-17-<slug>/` — OK.
- `tools/pre-commit-controle.sh` removido (git rm) e nenhum `.git/hooks/pre-commit` no repo — OK.
- Greps de regressao: unico `controle/` bare restante e o corpo historico do ADR-0001 (marcado
  superado por ADR-0004); as demais mencoes a "pre-commit" sao a logica de migracao dos
  installers + a frase "Nao ha pre-commit" das rules. Mirrors com docs/controle + hook.
- `sync-copilot.sh --check`, `sync-kiro.sh --check`, `sync-como-usar.sh --check` — todos OK.
- Drift pre-existente do wrapper `controle-de-tarefa` (descricao rica hand-edited) corrigido
  na fonte (`tools/manifest.tsv`); apos regen os wrappers voltaram a zero diff.

## Pendencias
- Ativar o agente no uso real: `q chat --agent arquitetura` (Amazon Q). Smoke real do hook
  disparando ainda nao feito nesta sessao (sem ambiente Amazon Q/Kiro aqui).
