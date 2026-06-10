#!/usr/bin/env bash
#
# tools/sync-copilot.sh — gera a camada GitHub Copilot (.github/) a partir do canonico.
#
# Fonte canonica:  .amazonq/rules/*.md  +  tools/manifest.tsv  +  prompts/**
# Gerado (commitado, NUNCA editado a mao):
#   .github/copilot-instructions.md
#   .github/instructions/<rule>.instructions.md     (4 rules)
#   .github/prompts/<slug>.prompt.md                (18 wrappers)
#   .github/skills/<slug>/SKILL.md                  (18 wrappers)
#
# Uso:
#   bash tools/sync-copilot.sh           # (re)gera .github/
#   bash tools/sync-copilot.sh --check   # exit 1 se .github/ commitado divergir do gerado
#
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$PACK_DIR/tools/manifest.tsv"
RULES=(architecture-style frontend-style negocio-style engenharia-style)

MODE="generate"
if [ "${1:-}" = "--check" ]; then MODE="check"; fi

if [ "$MODE" = "check" ]; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  OUT="$TMP/.github"
else
  OUT="$PACK_DIR/.github"
  rm -rf "$OUT/instructions" "$OUT/prompts" "$OUT/skills"
fi
mkdir -p "$OUT/instructions" "$OUT/prompts" "$OUT/skills"

# ── 1) Rules canonicas → instructions ───────────────────────────────────────
# Reescreve apenas os paths das 4 rules de estilo. Paths de contexto
# (project/business-context) NAO sao reescritos: o texto canonico cita os dois.
rewrite_for_copilot() {
  sed \
    -e 's|\.amazonq/rules/architecture-style\.md|.github/instructions/architecture-style.instructions.md|g' \
    -e 's|\.amazonq/rules/frontend-style\.md|.github/instructions/frontend-style.instructions.md|g' \
    -e 's|\.amazonq/rules/negocio-style\.md|.github/instructions/negocio-style.instructions.md|g' \
    -e 's|\.amazonq/rules/engenharia-style\.md|.github/instructions/engenharia-style.instructions.md|g' \
    -e 's|Lido automaticamente pelo Amazon Q em todo workspace que contenha esta pasta\.|Aplicado automaticamente pelo GitHub Copilot em todo repositorio que contenha esta pasta (frontmatter `applyTo`).|g'
}

for r in "${RULES[@]}"; do
  src="$PACK_DIR/.amazonq/rules/$r.md"
  [ -f "$src" ] || { echo "ERRO: rule canonica ausente: $src" >&2; exit 1; }
  {
    printf -- '---\napplyTo: "**"\nexcludeAgent: "code-review"\n---\n'
    rewrite_for_copilot < "$src"
  } > "$OUT/instructions/$r.instructions.md"
done

# ── 2) Entry point ──────────────────────────────────────────────────────────
cat > "$OUT/copilot-instructions.md" <<'EOF'
# Pack de documentacao arquitetural — instrucoes para o GitHub Copilot

> GERADO por `tools/sync-copilot.sh` a partir de `.amazonq/rules/` — NAO edite a mao.
> Este repositorio usa o pack `arquitetura` com Amazon Q **e** GitHub Copilot.

## Como este repo esta organizado para o Copilot

- As regras completas estao em `.github/instructions/*.instructions.md` (aplicadas
  automaticamente): `architecture-style` (trilha tecnica), `negocio-style` (negocio),
  `frontend-style` (HTML/CSS), `engenharia-style` (disciplinas de engenharia).
- A metodologia de cada tarefa mora em `prompts/<trilha>/<nome>.md`. As tabelas de
  gatilhos nas instructions mapeiam a intencao do usuario para o prompt certo. Quando
  um gatilho casar, LEIA o arquivo do prompt e siga TODO o processo descrito, fase por
  fase — nunca achate fases interativas em checklist ou despejo de perguntas.
- Atalhos: cada prompt existe como slash command (`.github/prompts/`, use `/<slug>` no
  chat das IDEs) e como Agent Skill (`.github/skills/`, Copilot CLI).

## Gate de contexto (resumo)

Antes de gerar documentacao, o contexto do projeto precisa existir em DOIS arquivos de
mesmo conteudo: `.github/instructions/project-context.instructions.md` (Copilot) e
`.amazonq/rules/project-context.md` (Amazon Q). Se nenhum existir, rode primeiro
`prompts/arquitetura/analisador-de-projeto.md` (`/analisador-de-projeto`). Se so um
existir, espelhe no outro. Doc de NEGOCIO exige tambem o par `business-context`
(criado por `prompts/negocio/analisador-de-dominio.md`).

## Regra inegociavel

Todo diagrama segue a convencao Mermaid da instruction `architecture-style` secao 1
(diagram-viewer + classDefs com cores fixas). E a unica regra rigida de visual.
EOF

# ── 3) Wrappers a partir do manifest ───────────────────────────────────────
count=0
while IFS=$'\t' read -r slug trilha desc; do
  [ -z "$slug" ] && continue
  case "$slug" in \#*) continue ;; esac
  canonical="prompts/$trilha/$slug.md"
  if [ ! -f "$PACK_DIR/$canonical" ]; then
    echo "ERRO: manifest aponta para $canonical, que nao existe." >&2
    exit 1
  fi

  cat > "$OUT/prompts/$slug.prompt.md" <<EOF
---
description: "$desc"
---

Siga TODO o processo descrito em \`$canonical\` (na raiz deste repositorio), fase por
fase, na ordem em que esta escrito.

Regras de execucao:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o
  prompt pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- As instructions deste repositorio (\`.github/instructions/\`) continuam valendo.
EOF

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
- As instructions deste repositorio (\`.github/instructions/\`) continuam valendo.
EOF
  count=$((count + 1))
done < "$MANIFEST"

# ── 4) Resultado ────────────────────────────────────────────────────────────
if [ "$MODE" = "check" ]; then
  if diff -r "$PACK_DIR/.github" "$OUT" > /dev/null 2>&1; then
    echo "OK: .github/ em sincronia com o canonico."
  else
    echo "DRIFT: .github/ difere do que seria gerado. Rode: bash tools/sync-copilot.sh" >&2
    diff -r "$PACK_DIR/.github" "$OUT" 2>&1 | head -40 >&2 || true
    exit 1
  fi
else
  echo "Gerado: ${#RULES[@]} instructions + copilot-instructions.md + $count prompt files + $count skills em $OUT"
fi
