#!/usr/bin/env bash
# pre-commit-controle.sh — watchdog do protocolo de controle (pack arquitetura).
#
# Regra que ele garante (ver .amazonq/rules/controle-style.md § 3):
#   todo commit que toca arquivos fora de controle/ deve incluir TAMBEM arquivos
#   da task em controle/<task-id>/ — TASK.md/LEDGER.md viajam junto com o artefato
#   (qualquer artefato: codigo, doc, spec, design, plano... nao so codigo).
#
# Instalado pelo install.sh/install.ps1 do pack:
#   copia versionada:  .amazonq/hooks/pre-commit-controle.sh  (este arquivo)
#   gancho do git:     .git/hooks/pre-commit                  (wrapper que chama a copia)
#
# Bypass pontual:  git commit --no-verify
# Desativar:       remova .git/hooks/pre-commit (ou a chamada dentro dele)
set -euo pipefail

STAGED="$(git diff --cached --name-only --diff-filter=ACMRD)"
[ -z "$STAGED" ] && exit 0

outside=0
inside=0
while IFS= read -r f; do
  case "$f" in
    controle/*) inside=1 ;;
    *)          outside=1 ;;
  esac
done <<< "$STAGED"

if [ "$outside" -eq 1 ] && [ "$inside" -eq 0 ]; then
  {
    echo "pre-commit (controle): mudancas fora de controle/ sem arquivos de task no commit."
    echo "  Protocolo: .amazonq/rules/controle-style.md - crie/atualize controle/<task-id>/"
    echo "  (TASK.md + LEDGER.md) e commite junto com o artefato."
    echo "  Bypass consciente: git commit --no-verify"
  } >&2
  exit 1
fi
exit 0
