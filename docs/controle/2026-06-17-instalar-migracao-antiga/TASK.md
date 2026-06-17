# TASK — 2026-06-17-instalar-migracao-antiga

- **fase:** concluida
- **tipo:** normal
- **pedido:** quem ja instalou a versao antiga precisa migrar. O INSTALAR.md deve mandar o
  agente instalador VERIFICAR a instalacao existente e CORRIGIR pro estado novo
  (sem pre-commit bloqueante, com os hooks novos, tasks em docs/controle/).

## Criterios de aceite
- [x] Passo 4 do INSTALAR.md tem tabela sinal→correcao cobrindo: pre-commit, hooks novos,
      controle/ → docs/controle/, skills/prompts novos, rules sobrescritas + re-verificacao.
- [x] install.sh e install.ps1 movem controle/ → docs/controle/ (preservando tasks; sem sobrescrever).
- [x] `bash -n install.sh` OK; migracao validada rodando install.sh real em sandbox.

## Checklist de execucao
- [x] reescrever Passo 4 do INSTALAR.md (migracao de versao antiga)
- [x] install.sh: bloco 7c (migracao de caminho controle/ → docs/controle/)
- [x] install.ps1: bloco 7c equivalente
- [x] verificacao (bash -n + teste e2e do install.sh numa instalacao antiga fake)
