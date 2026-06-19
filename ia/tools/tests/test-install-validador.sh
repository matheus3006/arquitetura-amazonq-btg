#!/usr/bin/env bash
# test-install-validador.sh — guarda funcional da Iniciativa B (B1).
# Instala o pack num tempdir e prova que o validar-doc SEEDADO roda de verdade no cliente:
# nao basta o script chegar — cada um dos 3 SoT em lib/ tem de chegar tambem. Por isso os
# casos "ruins" sao escolhidos para so disparar SE o SoT correspondente estiver presente
# (o validar-doc degrada gracioso quando um SoT falta — ver validar-doc.sh _load_classes /
# _rule_forbidden_terms / _rule_mermaid_classdefs). exit 0 = tudo certo; !=0 = falha.
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
FIX="$ROOT/ia/tools/tests/fixtures"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail=0
note() { echo "  - $1"; fail=1; }

# 1) instala no tempdir (saida silenciada; mostra se quebrar)
if ! out=$(bash "$ROOT/install.sh" "$TMP" 2>&1); then
  echo "install.sh falhou:"; echo "$out" | sed 's/^/      /'; exit 1
fi

V="$TMP/ia/tools/validar-doc.sh"
LIB="$TMP/ia/tools/lib"

# 2) os 4 arquivos chegaram?
[ -f "$V" ] || note "validar-doc.sh nao foi seedado em ia/tools/"
for sot in design-system-classes.txt forbidden-terms.txt mermaid-classdefs.txt; do
  [ -f "$LIB/$sot" ] || note "SoT ausente: ia/tools/lib/$sot"
done

# 3) o validar-doc SEEDADO roda e cada SoT esta ativo (exit esperado por caso)
expect() { # nome fixture flag esperado [grep]
  local name="$1" fixture="$2" flag="$3" want="$4" g="${5:-}" o c
  o=$(bash "$V" "$fixture" "$flag" 2>&1); c=$?
  [ "$c" = "$want" ] || { note "$name: exit $c, esperava $want"; return; }
  [ -z "$g" ] || grep -qE "$g" <<<"$o" || note "$name: output nao casa /$g/"
}
expect "pagina conforme = exit 0"          "$FIX/front/head-ok.html"            --front   0
expect "class fora do SoT (prova classes)" "$FIX/front/class-bad.html"          --front   1 "class-unknown"
expect "hex de classDef (prova mermaid)"   "$FIX/mermaid/bad-classdef-hex.html" --mermaid 1 "mermaid-classdef-hex"
expect "forbidden-term (prova forbidden)"  "$FIX/front/forbidden-bad.html"      --front   1 "forbidden-term"

[ "$fail" = "0" ]
