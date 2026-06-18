#!/usr/bin/env bash
# controle-hook.sh — hook de INICIO DE INTERACAO do protocolo de controle (pack arquitetura).
#
# Substitui o antigo pre-commit punitivo: em vez de BLOQUEAR o commit do humano, este
# hook roda a CADA mensagem (trigger userPromptSubmit do Amazon Q) e injeta no contexto
# o lembrete pra ABRIR/atualizar a task de controle ANTES de editar qualquer artefato.
# Nao bloqueia nada — so orienta o agente (o stdout vira contexto do prompt).
#
# Ligado por: .amazonq/cli-agents/arquitetura.json (hooks.userPromptSubmit).
# Ative o agente:  q chat --agent arquitetura
# Desligar:        remova o bloco "hooks" desse agente (ou use outro agente).
set -euo pipefail

hoje="$(date +%F)"
cat <<EOF
[protocolo de controle · inicio de interacao · hoje e $hoje]
Se esta mensagem CRIA ou ALTERA qualquer artefato no repo (codigo, doc, spec, design,
diagrama, plano, config — nao so codigo), abra/atualize a task ANTES de editar:
  doc/controle/$hoje-<slug>/  ->  TASK.md (escopo + ACs + checklist) + LEDGER.md
Derive o <slug> (2-4 palavras kebab-case) do proprio pedido; nao peca o nome ao usuario.
Marque cada passo do checklist [x] na hora em que concluir (o TASK.md e o status vivo).
Pergunta pura de leitura/conversa (nao gera artefato): responda direto, sem task.
Protocolo completo: .amazonq/rules/controle-style.md
EOF
