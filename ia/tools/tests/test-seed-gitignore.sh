#!/usr/bin/env bash
# Testa seed-gitignore.sh: cria quando ausente, idempotencia, conteudo == SoT,
# preserva linhas preexistentes do usuario. Rode da raiz do pack.
set -u
SCRIPT="ia/tools/seed-gitignore.sh"
SOT="ia/tools/lib/gitignore-pack-block.txt"
START="# >>> arquitetura-pack (gerado pelo instalador) >>>"
END="# <<< arquitetura-pack <<<"
fail=0
note() { echo "  - $1"; fail=1; }

T="$(mktemp -d)"

# 1) cria .gitignore quando ausente
bash "$SCRIPT" "$T" >/dev/null 2>&1 || note "exit nao-zero no dir novo"
[ -f "$T/.gitignore" ] || note "nao criou .gitignore"

# 2) idempotencia: rodar de novo -> exatamente 1 par de marcadores
bash "$SCRIPT" "$T" >/dev/null 2>&1
n=$(grep -cF "$START" "$T/.gitignore" 2>/dev/null || echo 0)
[ "$n" = "1" ] || note "marcadores != 1 (got $n)"

# 3) miolo entre marcadores == SoT (sem drift)
awk -v s="$START" -v e="$END" 'index($0,s)==1{f=1;next} index($0,e)==1{f=0} f' "$T/.gitignore" > "$T/extr"
diff -q "$SOT" "$T/extr" >/dev/null 2>&1 || note "miolo difere da SoT"

# 4) .gitignore preexistente: preserva linha do usuario e mantem 1 bloco
T2="$(mktemp -d)"; printf 'node_modules/\n' > "$T2/.gitignore"
bash "$SCRIPT" "$T2" >/dev/null 2>&1
grep -qx 'node_modules/' "$T2/.gitignore" || note "perdeu linha preexistente"
n2=$(grep -cF "$START" "$T2/.gitignore" 2>/dev/null || echo 0)
[ "$n2" = "1" ] || note "bloco nao apendado em arquivo existente (got $n2)"

rm -rf "$T" "$T2"
[ "$fail" = "0" ]
