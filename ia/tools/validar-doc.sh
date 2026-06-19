#!/usr/bin/env bash
# validar-doc.sh — lint estrutural da doc de arquitetura em <pasta>.
# Uso:
#   bash ia/tools/validar-doc.sh <pasta> [--front | --mermaid | --all]
# Exit codes:
#   0 = clean
#   1 = violacoes (lista no stdout: <arquivo>:<linha>:<regra>: <descricao>)
#   2 = erro de uso ou ambiente sem dependencia opcional (fallback)
set -u

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" 2>/dev/null && pwd || true)"

usage() {
  cat <<'EOF'
Uso: bash ia/tools/validar-doc.sh <pasta> [--front | --mermaid | --all]

Flags:
  --front     lint visual/template (vocabulario, esqueleto, cores, NAV, forbidden-terms)
  --mermaid   lint sintaxe/Mermaid (pareamento, classDef, autonumber, labels)
  --all       atalho para os dois

Exit: 0=clean, 1=violacoes, 2=erro de uso ou fallback
EOF
}

[ $# -lt 2 ] && { usage >&2; exit 2; }
TARGET="$1" ; FLAG="$2"
case "$FLAG" in
  --front|--mermaid|--all) ;;
  *) echo "Flag invalida: $FLAG" >&2; usage >&2; exit 2 ;;
esac
[ -d "$TARGET" ] || [ -f "$TARGET" ] || { echo "pasta nao existe: $TARGET" >&2; exit 2; }

VIOLATIONS=0
violation() { echo "$1:$2:$3: $4"; VIOLATIONS=$((VIOLATIONS+1)); }

# Hooks por flag (preenchidos nas tasks B2-B10)
run_front()   { :; }
run_mermaid() { :; }

case "$FLAG" in
  --front)   run_front "$TARGET" ;;
  --mermaid) run_mermaid "$TARGET" ;;
  --all)     run_front "$TARGET"; run_mermaid "$TARGET" ;;
esac

[ "$VIOLATIONS" -eq 0 ] && exit 0 || exit 1
