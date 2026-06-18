# TASK — 2026-06-17-ajuste-hooks-amazonq

- **fase:** concluida
- **tipo:** normal
- **pedido:** trocar o "hook do Amazon Q" (era um pre-commit que BLOQUEAVA o commit do
  humano) por um hook de INICIO DE INTERACAO que faz o agente abrir a task de controle
  sozinho, em `docs/controle/`. Nunca impedir o humano de commitar.

## Criterios de aceite
- [x] Nenhum git hook bloqueia `git commit` (pre-commit removido do pack e dos installers).
- [x] Amazon Q tem agente com hook `userPromptSubmit` que orienta abrir/atualizar a task.
- [x] Kiro tem hook `promptSubmit` equivalente.
- [x] Caminho do protocolo e `docs/controle/` em todo lugar (canonico + gerado; so o corpo
      historico do ADR-0001 mantem `controle/`, marcado como superado).
- [x] Camadas geradas (.github, .kiro, COMO-USAR.md) em sincronia (`--check` OK).

## Checklist de execucao
- [x] criar `.amazonq/hooks/controle-hook.sh` + `.amazonq/cli-agents/arquitetura.json`
- [x] criar `.kiro/hooks/controle-prompt.kiro.hook`
- [x] deletar `tools/pre-commit-controle.sh`
- [x] editar canonico: `controle-style.md`, `controle-de-tarefa.md`, `grill-plano.md`
- [x] editar `install.sh` + `install.ps1` (instalar hooks; remover pre-commit; migracao)
- [x] editar ADR-0001 (supersede) + criar ADR-0004; ajustar ADR-0002
- [x] editar `README.md`, `INSTALAR.md`, `COMO-USAR.html`; trocar `controle/` -> `docs/controle/`
- [x] `sync-copilot.sh` (heredoc) + `sync-kiro.sh` + `sync-como-usar.sh` (+ corrigir drift do manifest)
- [x] verificacao final (jq, `bash -n`, saida do hook, greps de regressao, `--check` x3)
