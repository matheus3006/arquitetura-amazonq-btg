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

# Regra nav-orfa: cada .html da pasta tem entry no NAV de sidebar.js.
# Roda so quando target e PASTA com sidebar.js (arquivo unico = N-A).
_rule_nav_orphan() {
  local dir="$1" sidebar page base
  [ -d "$dir" ] || return 0
  sidebar="$dir/sidebar.js"
  [ -f "$sidebar" ] || return 0
  while IFS= read -r page; do
    [ -z "$page" ] && continue
    base=$(basename "$page")
    if ! grep -qE "href:[[:space:]]*\"$base\"" "$sidebar"; then
      violation "$page" 1 "nav-orfa" "arquivo $base nao tem entry no NAV em sidebar.js"
    fi
  done < <(find "$dir" -maxdepth 1 -name '*.html' -type f)
}

# Regra forbidden-terms: zero residuo do exemplo ficticio (case-insensitive substring).
_rule_forbidden_terms() {
  local file="$1" term line content
  [ -f "$LIB_DIR/forbidden-terms.txt" ] || return 0
  while IFS= read -r term; do
    [ -z "$term" ] && continue
    [[ "$term" =~ ^# ]] && continue
    while IFS=: read -r line content; do
      # ignora linhas dentro de <script>
      echo "$content" | grep -qE '<script' && continue
      violation "$file" "$line" "forbidden-term" "encontrou '$term' (lista: forbidden-terms.txt)"
    done < <(grep -niF -- "$term" "$file" 2>/dev/null)
  done < <(grep -vE '^(#|$)' "$LIB_DIR/forbidden-terms.txt")
}

# Regra no-hex: zero cor hex hardcoded fora dos classDef Mermaid.
_rule_no_hex() {
  local file="$1" ln rule rest
  while IFS=: read -r ln rule rest; do
    [ -z "$ln" ] && continue
    violation "$file" "$ln" "$rule" "$rest"
  done < <(awk '
    /<script[^>]*text\/mermaid/ { inm=1; next }
    /<\/script>/                { inm=0; next }
    inm                          { next }
    /#[0-9a-fA-F]{3,8}/         { print NR":hex-hardcoded:use var(--color-*) em vez de hex" }
  ' "$file")
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
  _rule_nav_orphan "$target"
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    _rule_head_order "$file"
    _rule_known_classes "$file"
    _rule_no_hex "$file"
    _rule_forbidden_terms "$file"
  done < <(_iter_html "$target")
}

# ============================================================================
# Regras --mermaid
# ============================================================================

# Regra mermaid-pair: cada data-diagram="X" tem script[type=text/mermaid][data-id="X"].
_rule_mermaid_pair() {
  local file="$1" id line n
  while IFS= read -r line; do
    id=$(echo "$line" | sed -E 's/.*data-diagram="([^"]+)".*/\1/')
    if ! grep -qE "type=\"text/mermaid\"[^>]*data-id=\"$id\"" "$file"; then
      n=$(grep -nE "data-diagram=\"$id\"" "$file" | head -1 | cut -d: -f1)
      violation "$file" "$n" "mermaid-pair" "data-diagram=\"$id\" sem script[type=text/mermaid][data-id=\"$id\"] correspondente"
    fi
  done < <(grep -E 'data-diagram="[^"]+"' "$file")
}

# Regra mermaid-type: 1a linha nao-vazia do bloco DEVE ser tipo valido.
_rule_mermaid_type() {
  local file="$1" ln rule rest
  while IFS=: read -r ln rule rest; do
    [ -z "$ln" ] && continue
    violation "$file" "$ln" "$rule" "$rest"
  done < <(awk '
    /<script[^>]*text\/mermaid/ { inm=1; first=1; line=NR; next }
    /<\/script>/                { inm=0; next }
    inm && first && /^[[:space:]]*$/ { next }
    inm && first {
      gsub(/^[[:space:]]+|[[:space:]]+$/,"",$0)
      if ($0 !~ /^(flowchart|sequenceDiagram|classDiagram|stateDiagram-v2|erDiagram)/) {
        print line":mermaid-type:1a linha invalida (use flowchart|sequenceDiagram|classDiagram|stateDiagram-v2|erDiagram): "$0
      }
      first=0
    }
  ' "$file")
}

# Regra mermaid-classdef-hex: os NOMES RESERVADOS da paleta C4 (person/sys/ext/extAsync) —
# quando declarados num flowchart — DEVEM usar os hex EXATOS do SoT
# (ia/tools/lib/mermaid-classdefs.txt: fill/stroke/color). NAO exigimos os 4 em todo flowchart:
# so o diagrama de CONTEXTO usa a taxonomia C4; os demais (camadas, infra, pipeline, decisao)
# tem classDefs proprios de nome livre. Se o SoT nao for encontrado, a checagem de hex e
# pulada (fallback gracioso).
_rule_mermaid_classdefs() {
  local file="$1" ln rule rest
  while IFS=: read -r ln rule rest; do
    [ -z "$ln" ] && continue
    violation "$file" "$ln" "$rule" "$rest"
  done < <(awk -v lib="$LIB_DIR/mermaid-classdefs.txt" '
    function loadsot(   l,n,a,cls,f,s,c) {
      while ((getline l < lib) > 0) {
        if (l ~ /^[[:space:]]*#/ || l ~ /^[[:space:]]*$/) continue
        n = split(l, a, "|"); if (n < 4) continue
        cls = a[1]; gsub(/[[:space:]]/, "", cls)
        f = a[2]; gsub(/[[:space:]]/, "", f); exp_fill[cls]   = tolower(f)
        s = a[3]; gsub(/[[:space:]]/, "", s); exp_stroke[cls] = tolower(s)
        c = a[4]; gsub(/[[:space:]]/, "", c); exp_color[cls]  = tolower(c)
      }
      close(lib)
    }
    function chk(lno, text, cls, prop, want,   val) {
      if (want == "") return
      if (match(text, prop ":[[:space:]]*#[0-9a-fA-F]+")) {
        val = substr(text, RSTART, RLENGTH); sub(/^[^#]*#/, "#", val); val = tolower(val)
        if (val != want)
          print lno":mermaid-classdef-hex:classDef "cls" "prop" "val" diverge do SoT (esperado "want", ver mermaid-classdefs.txt)"
      } else {
        print lno":mermaid-classdef-hex:classDef "cls" sem "prop" (esperado "want", ver mermaid-classdefs.txt)"
      }
    }
    BEGIN { loadsot() }
    /<script[^>]*text\/mermaid/ { inm=1; isflow=0; next }
    /<\/script>/                { inm=0; next }
    inm && /^[[:space:]]*flowchart/ { isflow=1; next }
    inm && isflow && /^[[:space:]]*classDef[[:space:]]+/ {
      cls = $0
      sub(/^[[:space:]]*classDef[[:space:]]+/, "", cls)
      sub(/[[:space:]].*/, "", cls)
      if (cls in exp_fill) {
        chk(NR, $0, cls, "fill",   exp_fill[cls])
        chk(NR, $0, cls, "stroke", exp_stroke[cls])
        chk(NR, $0, cls, "color",  exp_color[cls])
      }
    }
  ' "$file")
}

# Regra mermaid-autonumber: TODO sequenceDiagram tem 'autonumber' (regra binaria).
_rule_mermaid_autonumber() {
  local file="$1" ln rule rest
  while IFS=: read -r ln rule rest; do
    [ -z "$ln" ] && continue
    violation "$file" "$ln" "$rule" "$rest"
  done < <(awk '
    /<script[^>]*text\/mermaid/ { inm=1; line=NR; isseq=0; hasauto=0; next }
    /<\/script>/ {
      if (inm && isseq && !hasauto) print line":mermaid-autonumber:sequenceDiagram sem '\''autonumber'\'' (regra binaria: sempre)"
      inm=0; next
    }
    inm && /^[[:space:]]*sequenceDiagram/ { isseq=1; next }
    inm && isseq && /^[[:space:]]*autonumber/ { hasauto=1 }
  ' "$file")
}

run_mermaid() {
  local target="$1" file
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    _rule_mermaid_pair "$file"
    _rule_mermaid_type "$file"
    _rule_mermaid_classdefs "$file"
    _rule_mermaid_autonumber "$file"
  done < <(_iter_html "$target")
}

case "$FLAG" in
  --front)   run_front "$TARGET" ;;
  --mermaid) run_mermaid "$TARGET" ;;
  --all)     run_front "$TARGET"; run_mermaid "$TARGET" ;;
esac

[ "$VIOLATIONS" -eq 0 ] && exit 0 || exit 1
