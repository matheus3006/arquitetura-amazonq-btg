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

# ============================================================================
# Helpers
# ============================================================================

# Aceita arquivo unico OU pasta (varre *.html).
_iter_html() {
  if [ -f "$1" ]; then echo "$1"
  else find "$1" -name '*.html' -type f 2>/dev/null
  fi
}

# ============================================================================
# Regras --front
# ============================================================================

_load_classes() {
  [ -f "$LIB_DIR/design-system-classes.txt" ] || return 1
  grep -vE '^(#|$)' "$LIB_DIR/design-system-classes.txt"
}

# Regra class-unknown: toda classe usada DEVE estar em design-system-classes.txt.
_rule_known_classes() {
  local file="$1" allowed line content classes c
  allowed=$(_load_classes 2>/dev/null) || return 0
  while IFS=: read -r line content; do
    classes=$(echo "$content" | grep -oE 'class="[^"]*"' | sed -E 's/class="([^"]*)"/\1/g')
    for c in $classes; do
      # match exato (Fx) — escape-safe para classes com -- ou __
      grep -qFx "$c" <<<"$allowed" && continue
      violation "$file" "$line" "class-unknown" "classe '$c' nao esta em design-system-classes.txt"
    done
  done < <(grep -nE 'class="[^"]*"' "$file")
}

# Regra head-order: prefs.js DEVE aparecer ANTES do primeiro <link ... .css>.
_rule_head_order() {
  local file="$1" prefs_line css_line
  prefs_line=$(grep -nE 'src="[^"]*prefs\.js"' "$file" | head -1 | cut -d: -f1)
  css_line=$(grep -nE '<link[^>]*rel="stylesheet"' "$file" | head -1 | cut -d: -f1)
  [ -z "$prefs_line" ] && return 0
  [ -z "$css_line" ] && return 0
  if [ "$prefs_line" -gt "$css_line" ]; then
    violation "$file" "$prefs_line" "head-order" "prefs.js deve vir ANTES dos links de CSS"
  fi
}

run_front() {
  local target="$1" file
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    _rule_head_order "$file"
    _rule_known_classes "$file"
  done < <(_iter_html "$target")
}

run_mermaid() { :; }

case "$FLAG" in
  --front)   run_front "$TARGET" ;;
  --mermaid) run_mermaid "$TARGET" ;;
  --all)     run_front "$TARGET"; run_mermaid "$TARGET" ;;
esac

[ "$VIOLATIONS" -eq 0 ] && exit 0 || exit 1
