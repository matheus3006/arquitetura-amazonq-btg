#!/usr/bin/env bash
#
# ia/tools/sync-kiro.sh — gera a camada Kiro (.kiro/) a partir do canonico.
#
# Fonte canonica:  .amazonq/rules/*.md  +  ia/tools/manifest.tsv  +  ia/prompts/**
# Gerado (commitado, NUNCA editado a mao):
#   .kiro/steering/<rule>.md        (5 rules, frontmatter `inclusion: always`)
#   .kiro/skills/<slug>/SKILL.md    (30 wrappers — Agent Skills, padrao aberto)
#
# Arquivos por-servico NUNCA gerados aqui (vivem so nos repos alvo):
#   .kiro/steering/project-context.md / business-context.md (analisadores)
#   .kiro/steering/product.md / tech.md / structure.md (foundation files do Kiro)
#
# Uso:
#   bash ia/tools/sync-kiro.sh           # (re)gera .kiro/
#   bash ia/tools/sync-kiro.sh --check   # exit 1 se .kiro/ commitado divergir do gerado
#
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="$PACK_DIR/ia/tools/manifest.tsv"
RULES=(architecture-style frontend-style negocio-style engenharia-style controle-style)

case "${1:-}" in
  --check) MODE="check" ;;
  "")      MODE="generate" ;;
  *) echo "ERRO: argumento desconhecido: ${1} (use --check ou nada)" >&2; exit 2 ;;
esac

if [ "$MODE" = "check" ]; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  OUT="$TMP/.kiro"
else
  OUT="$PACK_DIR/.kiro"
  rm -rf "$OUT/steering" "$OUT/skills"
fi
mkdir -p "$OUT/steering" "$OUT/skills"

# ── 1) Rules canonicas → steering ───────────────────────────────────────────
# Reescreve apenas os paths das rules de estilo. Paths de contexto
# (project/business-context) NAO sao reescritos: o texto canonico cita os tres
# (Amazon Q, Copilot e Kiro).
rewrite_for_kiro() {
  sed \
    -e 's|\.amazonq/rules/architecture-style\.md|.kiro/steering/architecture-style.md|g' \
    -e 's|\.amazonq/rules/frontend-style\.md|.kiro/steering/frontend-style.md|g' \
    -e 's|\.amazonq/rules/negocio-style\.md|.kiro/steering/negocio-style.md|g' \
    -e 's|\.amazonq/rules/engenharia-style\.md|.kiro/steering/engenharia-style.md|g' \
    -e 's|\.amazonq/rules/controle-style\.md|.kiro/steering/controle-style.md|g' \
    -e 's|Lido automaticamente pelo Amazon Q em todo workspace que contenha esta pasta\.|Carregado automaticamente pelo Kiro (steering `inclusion: always`) em todo workspace que contenha esta pasta.|g'
}

for r in "${RULES[@]}"; do
  src="$PACK_DIR/.amazonq/rules/$r.md"
  [ -f "$src" ] || { echo "ERRO: rule canonica ausente: $src" >&2; exit 1; }
  {
    printf -- '---\ninclusion: always\n---\n'
    rewrite_for_kiro < "$src"
  } > "$OUT/steering/$r.md"
  if grep -qi 'lido automaticamente pelo Amazon Q' "$OUT/steering/$r.md"; then
    echo "ERRO: frase de auto-load nao reescrita em steering/$r.md — padronize a frase no canonico." >&2
    exit 1
  fi
done

# ── 2) Wrappers (Agent Skills) a partir do manifest ─────────────────────────
count=0
while IFS=$'\t' read -r slug trilha desc || [ -n "$slug" ]; do
  desc="${desc%$'\r'}"
  [ -z "$slug" ] && continue
  case "$slug" in \#*) continue ;; esac
  case "$desc" in
    ''|*'"'*|*'\'*) echo "ERRO: descricao invalida no manifest para '$slug' (vazia ou contem \" ou \\)." >&2; exit 1 ;;
  esac
  canonical="ia/prompts/$trilha/$slug.md"
  if [ ! -f "$PACK_DIR/$canonical" ]; then
    echo "ERRO: manifest aponta para $canonical, que nao existe." >&2
    exit 1
  fi

  mkdir -p "$OUT/skills/$slug"
  cat > "$OUT/skills/$slug/SKILL.md" <<EOF
---
name: $slug
description: "$desc"
---

Siga TODO o processo descrito em \`$canonical\` (na raiz deste repositorio), fase por
fase, na ordem em que esta escrito.

Regras de execucao:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o
  prompt pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- As steering rules deste repositorio (\`.kiro/steering/\`) continuam valendo.
EOF
  count=$((count + 1))
done < "$MANIFEST"
[ "$count" -gt 0 ] || { echo "ERRO: nenhum wrapper gerado — manifest vazio ou ilegivel?" >&2; exit 1; }

# ── 2b) Biblioteca de skills importadas (ia/skills/<categoria>/<slug>/ → verbatim) ──
imported=0
if [ -d "$PACK_DIR/ia/skills" ]; then
  for d in "$PACK_DIR"/ia/skills/*/*/; do
    [ -f "$d/SKILL.md" ] || continue
    slug="$(basename "$d")"
    if [ -e "$OUT/skills/$slug" ]; then
      echo "ERRO: colisao de slug '$slug' entre ia/skills/ e os wrappers do manifest." >&2
      exit 1
    fi
    cp -R "$d" "$OUT/skills/$slug"
    imported=$((imported + 1))
  done
fi

# ── 3) Cobertura ─────────────────────────────────────────────────────────────
for f in "$PACK_DIR"/.amazonq/rules/*-style.md; do
  base="$(basename "$f" .md)"
  found=0
  for r in "${RULES[@]}"; do [ "$r" = "$base" ] && found=1; done
  [ "$found" -eq 1 ] || { echo "ERRO: $base.md existe no canonico mas nao esta em RULES." >&2; exit 1; }
done
prompt_files="$(find "$PACK_DIR/ia/prompts" -name '*.md' -type f | wc -l | tr -d ' ')"
if [ "$prompt_files" -ne "$count" ]; then
  echo "ERRO: $prompt_files prompts em ia/prompts/ mas $count linhas no manifest — sincronize ia/tools/manifest.tsv." >&2
  exit 1
fi

# ── 4) Resultado ────────────────────────────────────────────────────────────
if [ "$MODE" = "check" ]; then
  status=0
  for p in steering skills; do
    if ! diff -r "$PACK_DIR/.kiro/$p" "$OUT/$p" > /dev/null 2>&1; then
      echo "DRIFT em .kiro/$p — rode: bash ia/tools/sync-kiro.sh" >&2
      diff -r "$PACK_DIR/.kiro/$p" "$OUT/$p" 2>&1 | head -20 >&2 || true
      status=1
    fi
  done
  if [ "$status" -eq 0 ]; then
    echo "OK: .kiro/ em sincronia com o canonico."
  fi
  exit "$status"
else
  echo "Gerado: ${#RULES[@]} steering rules + $count skills wrappers + $imported skills importadas em $OUT"
fi
