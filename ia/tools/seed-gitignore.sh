#!/usr/bin/env bash
# seed-gitignore.sh — injeta (idempotente) o bloco .gitignore do pack no repo alvo.
#
# Uso: bash ia/tools/seed-gitignore.sh <pasta-do-repo>   (default: .)
#
# Cria o .gitignore se ausente; se já tem os marcadores do pack, substitui só o miolo
# (preservando posição e o resto do arquivo); senão, apenda o bloco no fim.
# O CONTEÚDO do bloco vem de lib/gitignore-pack-block.txt (fonte única — mesma lida por
# install.sh e install.ps1, para não haver drift entre os instaladores).
set -eu

TARGET="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOT="$SCRIPT_DIR/lib/gitignore-pack-block.txt"
GI="$TARGET/.gitignore"
START="# >>> arquitetura-pack (gerado pelo instalador) >>>"
END="# <<< arquitetura-pack <<<"

[ -f "$SOT" ] || { echo "❌ SoT do bloco ausente: $SOT" >&2; exit 2; }
[ -d "$TARGET" ] || { echo "❌ alvo não existe: $TARGET" >&2; exit 2; }

# imprime o bloco completo (marcadores + miolo da SoT)
block() { printf '%s\n' "$START"; cat "$SOT"; printf '%s\n' "$END"; }

if [ ! -f "$GI" ]; then
  block > "$GI"
  echo "  ✓ .gitignore criado com o bloco do pack"
elif grep -qF "$START" "$GI"; then
  tmp="$(mktemp)"
  awk -v s="$START" 'index($0,s)==1{exit} {print}' "$GI" > "$tmp"   # tudo antes do START
  block >> "$tmp"                                                    # bloco fresco (posição preservada)
  awk -v e="$END" 'p{print} index($0,e)==1{p=1}' "$GI" >> "$tmp"    # tudo depois do END
  mv "$tmp" "$GI"
  echo "  ✓ .gitignore atualizado (bloco do pack)"
else
  { printf '\n'; block; } >> "$GI"
  echo "  ✓ .gitignore: bloco do pack apendado"
fi
