#!/usr/bin/env bash
# seed-doc-assets.sh — semeia os assets de runtime sob doc/ para os docs gerados.
#
# As paginas geradas em doc/arquitetura/ referenciam ../templates/prefs.js e
# ../design-system/*.css (a partir de doc/arquitetura/, isso aponta para doc/templates/
# e doc/design-system/). Estes dirs sao ARTEFATO DE BUILD: copiados de ia/ (fonte unica),
# nunca editados a mao. Idempotente — re-rode sempre que ia/ for atualizado.
#
# Uso: bash ia/tools/seed-doc-assets.sh [raiz-do-repo]   (default: diretorio atual)
# Exit: 0 = semeado; 2 = raiz invalida ou ia/ ausente (instale o pack primeiro)
set -eu

ROOT="${1:-$(pwd)}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd)" || { echo "seed-doc-assets: raiz nao existe: ${1:-.}" >&2; exit 2; }

SRC_TPL="$ROOT/ia/templates"
SRC_DS="$ROOT/ia/design-system"
if [ ! -d "$SRC_TPL" ] || [ ! -d "$SRC_DS" ]; then
  echo "seed-doc-assets: faltam ia/templates/ e/ou ia/design-system/ em $ROOT (instale o pack primeiro)" >&2
  exit 2
fi

mkdir -p "$ROOT/doc/templates" "$ROOT/doc/design-system"
for j in prefs.js sidebar.js diagram-viewer.js; do
  if [ -f "$SRC_TPL/$j" ]; then cp "$SRC_TPL/$j" "$ROOT/doc/templates/$j"; fi
done
cp "$SRC_DS/"*.css "$ROOT/doc/design-system/" 2>/dev/null || true

echo "  ✓ doc/templates/ + doc/design-system/ semeados de ia/ (artefato de build)"
