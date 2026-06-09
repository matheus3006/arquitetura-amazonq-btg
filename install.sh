#!/usr/bin/env bash
#
# install.sh — instala o pack arquitetura-amazonq (trilha tecnica + de negocio)
#              num repositorio de servico, pronto pro Amazon Q ler sozinho.
#
# Uso:
#   bash install.sh                         # instala no diretorio atual
#   bash install.sh /caminho/do/servico     # instala no repo indicado
#   bash install.sh --with-examples .       # inclui as paginas HTML de exemplo
#
# O que copia: .amazonq/rules/ (as 3 rules) + prompts/ (2 trilhas) +
#              design-system/*.css + templates/{diagram-viewer,sidebar}.js + COMO-USAR.md
# O que NAO copia: project-context.md e business-context.md (sao por-servico, gerados pelos analisadores).
#
set -euo pipefail

WITH_EXAMPLES=0
TARGET=""
for arg in "$@"; do
  case "$arg" in
    --with-examples) WITH_EXAMPLES=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^#\{1,\} \{0,1\}//'; exit 0 ;;
    *) TARGET="$arg" ;;
  esac
done

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-$(pwd)}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "❌ Alvo nao existe."; exit 1; }

if [ "$TARGET" = "$PACK_DIR" ]; then
  echo "❌ O alvo e o proprio pack. Rode apontando pro repo do SERVICO:"
  echo "   bash \"$PACK_DIR/install.sh\" /caminho/do/seu/servico"
  exit 1
fi

echo "📦 arquitetura-amazonq  →  $TARGET"
echo ""

# 1) Rules — o que o Amazon Q le automaticamente (nao tocamos *-context.md, que sao por-servico)
mkdir -p "$TARGET/.amazonq/rules"
[ -e "$TARGET/.amazonq/rules/architecture-style.md" ] && \
  echo "ℹ️  .amazonq/rules ja existe — atualizo as rules do pack (project/business-context.md ficam intactos)."
for f in architecture-style.md frontend-style.md negocio-style.md; do
  cp "$PACK_DIR/.amazonq/rules/$f" "$TARGET/.amazonq/rules/$f"
  echo "  ✓ .amazonq/rules/$f"
done

# 2) Prompts (as duas trilhas)
mkdir -p "$TARGET/prompts"
cp -R "$PACK_DIR/prompts/arquitetura" "$TARGET/prompts/"
cp -R "$PACK_DIR/prompts/negocio"     "$TARGET/prompts/"
echo "  ✓ prompts/arquitetura + prompts/negocio"

# 3) Design system (CSS reutilizavel)
mkdir -p "$TARGET/design-system"
cp "$PACK_DIR/design-system/"*.css "$TARGET/design-system/"
echo "  ✓ design-system/*.css"

# 4) Runtime dos templates (viewer + sidebar) — necessario pras paginas geradas
mkdir -p "$TARGET/templates"
cp "$PACK_DIR/templates/diagram-viewer.js" "$TARGET/templates/"
cp "$PACK_DIR/templates/sidebar.js"        "$TARGET/templates/"
echo "  ✓ templates/diagram-viewer.js + sidebar.js"

# 4b) Paginas de exemplo (opcional — so com --with-examples)
if [ "$WITH_EXAMPLES" = "1" ]; then
  cp "$PACK_DIR/templates/"*.html "$TARGET/templates/" 2>/dev/null || true
  echo "  ✓ templates/*.html (exemplos)"
fi

# 5) Guia de uso
cp "$PACK_DIR/COMO-USAR.md" "$TARGET/COMO-USAR.md" 2>/dev/null || true
echo "  ✓ COMO-USAR.md"

echo ""
echo "✅ Instalado. O Amazon Q le .amazonq/rules/ automaticamente neste repo."
echo ""
echo "Comece (com @workspace aberto no repo do servico):"
echo "   1.  \"analisa o dominio\"                      → gera o business-context.md"
echo "   2.  \"documenta o fluxo de negocio do <X>\"    → diagrama caminho feliz/triste"
echo "   3.  \"grilla o negocio\"                       → interrogatorio por fases"
echo ""
echo "📖 Todos os gatilhos (tecnico + negocio): COMO-USAR.md"
