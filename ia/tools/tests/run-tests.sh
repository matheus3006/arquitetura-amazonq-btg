#!/usr/bin/env bash
# Suite de testes do validar-doc.sh. Cada teste: (fixture, flag, expected_exit, expected_grep).
# Uso: bash ia/tools/tests/run-tests.sh    (rode da raiz do pack)
set -u
PASS=0; FAIL=0
SCRIPT="ia/tools/validar-doc.sh"

run_case() {
  local name="$1" fixture="$2" flag="$3" expected_exit="$4" expected_grep="${5:-}"
  local out exit_code
  out=$(bash "$SCRIPT" "$fixture" "$flag" 2>&1) ; exit_code=$?
  if [ "$exit_code" -ne "$expected_exit" ]; then
    echo "FAIL: $name -- exit $exit_code, esperava $expected_exit"
    echo "      stdout: $out"
    FAIL=$((FAIL+1)) ; return
  fi
  if [ -n "$expected_grep" ] && ! grep -qE "$expected_grep" <<<"$out"; then
    echo "FAIL: $name -- output nao casa /$expected_grep/"
    echo "      stdout: $out"
    FAIL=$((FAIL+1)) ; return
  fi
  echo "PASS: $name"
  PASS=$((PASS+1))
}

# === CLI / exit codes ===
run_case "cli: sem args = exit 2" "" "" 2 "Uso:"
run_case "cli: flag invalida = exit 2" "ia/tools/tests/fixtures" "--xxx" 2 "Flag invalida"
run_case "cli: pasta inexistente = exit 2" "/nao/existe/abc" "--front" 2 "pasta"

echo
echo "Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
