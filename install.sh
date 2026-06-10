#!/usr/bin/env bash
# install.sh — instala o pack arquitetura (Amazon Q + GitHub Copilot) num repositorio de servico.
#
# Uso:
#   bash install.sh                         # instala no diretorio atual
#   bash install.sh /caminho/do/servico     # instala no repo indicado
#   bash install.sh --with-examples .       # inclui as paginas HTML de exemplo
#   bash install.sh --help                  # mostra esta ajuda
#
# Copia: .amazonq/rules/ (4 rules) + .github/ (camada Copilot: instructions,
#        prompts, skills) + prompts/ (4 trilhas) + design-system/*.css +
#        templates/{diagram-viewer,sidebar}.js + COMO-USAR.html
# NAO copia: arquivos de contexto por-servico (project/business-context nos
#        dois lados) — sao gerados pelos analisadores e preservados em re-runs.
set -euo pipefail

usage() { sed -n '2,14p' "$0" | sed 's/^#$//; s/^# //'; }

WITH_EXAMPLES=0
TARGET=""
for arg in "$@"; do
  case "$arg" in
    --with-examples) WITH_EXAMPLES=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "❌ Opcao desconhecida: $arg"; echo ""; usage; exit 1 ;;
    *)
      if [ -n "$TARGET" ]; then
        echo "❌ Mais de um alvo informado: \"$TARGET\" e \"$arg\". Passe so um."
        exit 1
      fi
      TARGET="$arg"
      ;;
  esac
done

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-$(pwd)}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "❌ Alvo nao existe: ${TARGET}"; exit 1; }

if [ "$TARGET" = "$PACK_DIR" ]; then
  echo "❌ O alvo e o proprio pack. Rode apontando pro repo do SERVICO:"
  echo "   bash \"$PACK_DIR/install.sh\" /caminho/do/seu/servico"
  exit 1
fi

echo "📦 arquitetura (Amazon Q + Copilot)  →  $TARGET"
echo ""

# 1) Rules Amazon Q (nunca tocamos *-context.md, que sao por-servico)
mkdir -p "$TARGET/.amazonq/rules"
[ -e "$TARGET/.amazonq/rules/architecture-style.md" ] && \
  echo "ℹ️  Instalacao existente — atualizo as rules do pack (arquivos de contexto ficam intactos)."
for f in architecture-style.md frontend-style.md negocio-style.md engenharia-style.md; do
  cp "$PACK_DIR/.amazonq/rules/$f" "$TARGET/.amazonq/rules/$f"
  echo "  ✓ .amazonq/rules/$f"
done

# 2) Camada Copilot (instructions nomeadas — nunca tocamos *-context.instructions.md)
mkdir -p "$TARGET/.github/instructions" "$TARGET/.github/prompts" "$TARGET/.github/skills"
cp "$PACK_DIR/.github/copilot-instructions.md" "$TARGET/.github/copilot-instructions.md"
echo "  ✓ .github/copilot-instructions.md"
for f in architecture-style frontend-style negocio-style engenharia-style; do
  cp "$PACK_DIR/.github/instructions/$f.instructions.md" "$TARGET/.github/instructions/$f.instructions.md"
done
echo "  ✓ .github/instructions/ (4 instructions)"
cp -R "$PACK_DIR/.github/prompts/." "$TARGET/.github/prompts/"
cp -R "$PACK_DIR/.github/skills/."  "$TARGET/.github/skills/"
echo "  ✓ .github/prompts/ + .github/skills/ (18 wrappers cada)"

# 3) Prompts (4 trilhas)
mkdir -p "$TARGET/prompts"
for t in arquitetura frontend negocio engenharia; do
  cp -R "$PACK_DIR/prompts/$t" "$TARGET/prompts/"
done
echo "  ✓ prompts/{arquitetura,frontend,negocio,engenharia}"

# 4) Design system (CSS reutilizavel)
mkdir -p "$TARGET/design-system"
cp "$PACK_DIR/design-system/"*.css "$TARGET/design-system/"
echo "  ✓ design-system/*.css"

# 5) Runtime dos templates (viewer + sidebar)
mkdir -p "$TARGET/templates"
cp "$PACK_DIR/templates/diagram-viewer.js" "$TARGET/templates/"
cp "$PACK_DIR/templates/sidebar.js"        "$TARGET/templates/"
echo "  ✓ templates/diagram-viewer.js + sidebar.js"

# 5b) Paginas de exemplo (opcional — so com --with-examples)
if [ "$WITH_EXAMPLES" = "1" ]; then
  if cp "$PACK_DIR/templates/"*.html "$TARGET/templates/" 2>/dev/null; then
    echo "  ✓ templates/*.html (exemplos)"
  else
    echo "  ⚠ templates/*.html nao copiados (nenhum .html no pack?)"
  fi
fi

# 6) Guia de uso (mensagens prontas — abra no navegador)
if cp "$PACK_DIR/COMO-USAR.html" "$TARGET/COMO-USAR.html" 2>/dev/null && [ -f "$TARGET/COMO-USAR.html" ]; then
  echo "  ✓ COMO-USAR.html"
else
  echo "  ⚠ COMO-USAR.html nao copiado (destino bloqueado?)"
fi

# 7) Limpeza de lixo do Finder
find "$TARGET/prompts" "$TARGET/.github" "$TARGET/templates" "$TARGET/design-system" \
  -name '.DS_Store' -delete 2>/dev/null || true

echo ""
echo "✅ Instalado. O Amazon Q le .amazonq/rules/ e o Copilot le .github/ automaticamente."
echo ""
echo "Comece:"
echo "   Tecnica:    \"documenta esse servico\"   (Copilot IDE: /analisador-de-projeto na 1a vez)"
echo "   Negocio:    \"analisa o dominio\" → \"grilla o negocio\""
echo "   Frontend:   \"polir essa pagina\""
echo "   Engenharia: \"investiga esse bug\" · \"planeja a implementacao\""
echo ""
echo "📖 Mensagens prontas por trilha: abra COMO-USAR.html no navegador"
