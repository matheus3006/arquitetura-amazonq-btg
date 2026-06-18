# LEDGER — 2026-06-17-instalar-migracao-antiga

## Decisoes
- O Passo 4 do INSTALAR.md (antes generico, "rodar de novo e seguro") virou runbook de
  MIGRACAO: tabela sinal-de-versao-antiga → correcao + re-verificacao explicita.
- Estendi tambem install.sh e install.ps1 (bloco 7c) pra mover controle/ → docs/controle/,
  apesar do pedido citar so o INSTALAR.md: o goal ("corrigir pro estado novo") so funciona
  pelo script se ele tambem migrar o caminho. Os scripts ja removiam o pre-commit (7b) e
  instalavam os hooks novos (7); faltava o caminho.
- Movicao preserva dados do usuario: task ja existente em docs/controle/ NAO e sobrescrita
  (fica em controle/ com aviso); controle/ so e removido se ficar vazio.

## Evidencias (2026-06-17)
- `bash -n install.sh` OK.
- Teste e2e: montei instalacao antiga fake (pre-commit bloqueante + controle/2026-01-01-
  tarefa-antiga/) e rodei `install.sh` real. Resultado: pre-commit e pre-commit-controle.sh
  removidos, controle/ migrado pra docs/controle/ (task preservada), cli-agents/arquitetura.json
  + controle-hook.sh (+x) + kiro controle-prompt.kiro.hook instalados, skills/orquestracao e
  prompt refatorador-incremental presentes. Todos os checks = SIM.
- install.ps1: espelha a logica validada do bash (7c). Nao executado aqui (sem pwsh no
  ambiente) — mesma estrutura do 7b, ja existente.

## Pendencias
- (nenhuma)
