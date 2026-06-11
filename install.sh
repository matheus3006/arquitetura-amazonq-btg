#!/usr/bin/env bash
# install.sh — instala o pack arquitetura (Amazon Q + GitHub Copilot) num repositorio de servico.
#
# Uso:
#   bash install.sh                         # instala no diretorio atual
#   bash install.sh /caminho/do/servico     # instala no repo indicado
#   bash install.sh --no-examples .         # NAO inclui as paginas HTML de exemplo
#   bash install.sh --help                  # mostra esta ajuda
#
# Copia: .amazonq/rules/ (5 rules) + .github/ (camada Copilot: instructions,
#        prompts, skills) + prompts/ (4 trilhas) e
#        docs/arquitetura/ (css do design system, js dos templates, COMO-USAR.html,
#        paginas HTML de exemplo — referencia de FORMA pros prompts; nunca
#        sobrescreve arquivo ja existente no alvo)
#        + watchdog do protocolo de controle (.amazonq/hooks/ + .git/hooks/pre-commit)
# NAO copia: arquivos de contexto por-servico (project/business-context nos
#        dois lados) — sao gerados pelos analisadores e preservados em re-runs.
set -euo pipefail

usage() { sed -n '2,17p' "$0" | sed 's/^#$//; s/^# //'; }

NO_EXAMPLES=0
TARGET=""
for arg in "$@"; do
  case "$arg" in
    --no-examples) NO_EXAMPLES=1 ;;
    --with-examples) ;; # aceito por compatibilidade — exemplos ja sao o padrao
    -h|--help) usage; exit 0 ;;
    -*) echo "❌ Opcao desconhecida: $arg" >&2; echo "" >&2; usage >&2; exit 1 ;;
    *)
      if [ -n "$TARGET" ]; then
        echo "❌ Mais de um alvo informado: \"$TARGET\" e \"$arg\". Passe so um." >&2
        exit 1
      fi
      TARGET="$arg"
      ;;
  esac
done

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-$(pwd)}"
RESOLVED="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "❌ Alvo nao existe: $TARGET" >&2; exit 1; }
TARGET="$RESOLVED"

if [ "$TARGET" -ef "$PACK_DIR" ]; then
  echo "❌ O alvo e o proprio pack. Rode apontando pro repo do SERVICO:" >&2
  echo "   bash \"$PACK_DIR/install.sh\" /caminho/do/seu/servico" >&2
  exit 1
fi

echo "📦 arquitetura (Amazon Q + Copilot)  →  $TARGET"
echo ""

# 1) Rules Amazon Q (nunca tocamos *-context.md, que sao por-servico)
mkdir -p "$TARGET/.amazonq/rules"
[ -e "$TARGET/.amazonq/rules/architecture-style.md" ] && \
  echo "ℹ️  Instalacao existente — atualizo as rules do pack (arquivos de contexto ficam intactos)."
for f in architecture-style.md frontend-style.md negocio-style.md engenharia-style.md controle-style.md; do
  cp "$PACK_DIR/.amazonq/rules/$f" "$TARGET/.amazonq/rules/$f"
  echo "  ✓ .amazonq/rules/$f"
done

# 2) Camada Copilot (instructions nomeadas — nunca tocamos *-context.instructions.md)
mkdir -p "$TARGET/.github/instructions" "$TARGET/.github/prompts" "$TARGET/.github/skills"
cp "$PACK_DIR/.github/copilot-instructions.md" "$TARGET/.github/copilot-instructions.md"
echo "  ✓ .github/copilot-instructions.md"
for f in architecture-style frontend-style negocio-style engenharia-style controle-style; do
  cp "$PACK_DIR/.github/instructions/$f.instructions.md" "$TARGET/.github/instructions/$f.instructions.md"
done
echo "  ✓ .github/instructions/ (5 instructions)"
cp -R "$PACK_DIR/.github/prompts/." "$TARGET/.github/prompts/"
cp -R "$PACK_DIR/.github/skills/."  "$TARGET/.github/skills/"
echo "  ✓ .github/prompts/ + .github/skills/ (19 wrappers cada)"

# 3) Prompts (4 trilhas)
mkdir -p "$TARGET/prompts"
for t in arquitetura frontend negocio engenharia; do
  cp -R "$PACK_DIR/prompts/$t" "$TARGET/prompts/"
done
echo "  ✓ prompts/{arquitetura,frontend,negocio,engenharia}"

# 4) Design system (CSS reutilizavel)
mkdir -p "$TARGET/docs/arquitetura/design-system"
cp "$PACK_DIR/docs/arquitetura/design-system/"*.css "$TARGET/docs/arquitetura/design-system/"
echo "  ✓ docs/arquitetura/design-system/*.css"

# 5) Runtime dos templates (viewer + sidebar)
mkdir -p "$TARGET/docs/arquitetura/templates"
cp "$PACK_DIR/docs/arquitetura/templates/diagram-viewer.js" "$TARGET/docs/arquitetura/templates/"
cp "$PACK_DIR/docs/arquitetura/templates/sidebar.js"        "$TARGET/docs/arquitetura/templates/"
echo "  ✓ docs/arquitetura/templates/diagram-viewer.js + sidebar.js"

# 5b) Paginas de exemplo — referencia de FORMA pros prompts (padrao; pule com
#     --no-examples). NUNCA sobrescreve: paginas ja geradas no alvo ficam intactas.
if [ "$NO_EXAMPLES" = "1" ]; then
  echo "  ↷ docs/arquitetura/templates/*.html (exemplos) pulados (--no-examples)"
else
  copied=0; kept=0
  for f in "$PACK_DIR/docs/arquitetura/templates/"*.html; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    if [ -e "$TARGET/docs/arquitetura/templates/$base" ]; then
      kept=$((kept + 1))
    else
      cp "$f" "$TARGET/docs/arquitetura/templates/$base"
      copied=$((copied + 1))
    fi
  done
  if [ "$((copied + kept))" -eq 0 ]; then
    echo "  ⚠ docs/arquitetura/templates/*.html nao copiados (nenhum .html no pack?)"
  else
    echo "  ✓ docs/arquitetura/templates/*.html (exemplos de forma: $copied copiados, $kept preservados)"
  fi
fi

# 6) Guia de uso (mensagens prontas — abra no navegador)
if [ ! -f "$PACK_DIR/docs/arquitetura/COMO-USAR.html" ]; then
  echo "  ⚠ docs/arquitetura/COMO-USAR.html ausente no pack — pulado"
elif [ -d "$TARGET/docs/arquitetura/COMO-USAR.html" ]; then
  echo "  ⚠ docs/arquitetura/COMO-USAR.html nao copiado (existe um DIRETORIO com esse nome no alvo)"
elif cp "$PACK_DIR/docs/arquitetura/COMO-USAR.html" "$TARGET/docs/arquitetura/COMO-USAR.html" 2>/dev/null && [ -f "$TARGET/docs/arquitetura/COMO-USAR.html" ]; then
  echo "  ✓ docs/arquitetura/COMO-USAR.html"
else
  echo "  ⚠ docs/arquitetura/COMO-USAR.html nao copiado (destino bloqueado?)"
fi

# 7) Watchdog do protocolo de controle (pre-commit git)
mkdir -p "$TARGET/.amazonq/hooks"
cp "$PACK_DIR/tools/pre-commit-controle.sh" "$TARGET/.amazonq/hooks/pre-commit-controle.sh"
chmod +x "$TARGET/.amazonq/hooks/pre-commit-controle.sh"
echo "  ✓ .amazonq/hooks/pre-commit-controle.sh"
HOOK="$TARGET/.git/hooks/pre-commit"
if [ ! -d "$TARGET/.git" ]; then
  echo "  ⚠ .git/hooks/pre-commit nao instalado (alvo nao e raiz de repo git)"
elif [ -f "$HOOK" ] && ! grep -q 'pre-commit-controle' "$HOOK" 2>/dev/null; then
  echo "  ⚠ pre-commit existente preservado — acrescente nele a linha:"
  echo "      bash .amazonq/hooks/pre-commit-controle.sh || exit 1"
else
  printf '#!/usr/bin/env bash\n# gerado pelo pack arquitetura — chama o watchdog do protocolo de controle\nbash .amazonq/hooks/pre-commit-controle.sh || exit 1\n' > "$HOOK"
  chmod +x "$HOOK"
  echo "  ✓ .git/hooks/pre-commit (watchdog do controle; bypass: git commit --no-verify)"
fi

# 8) Limpeza de lixo do Finder
find "$TARGET/prompts" "$TARGET/.github" "$TARGET/docs/arquitetura" \
  -name '.DS_Store' -delete 2>/dev/null || true

echo ""
echo "✅ Instalado. O Amazon Q le .amazonq/rules/ e o Copilot le .github/ automaticamente."
echo ""
echo "Comece:"
echo "   Tecnica:    \"documenta esse servico\"   (Copilot IDE: /analisador-de-projeto na 1a vez)"
echo "   Negocio:    \"analisa o dominio\" → \"grilla o negocio\""
echo "   Frontend:   \"polir essa pagina\""
echo "   Engenharia: \"investiga esse bug\" · \"planeja a implementacao\""
echo "   Controle:   \"nova tarefa: <slug> — <descricao>\"  (protocolo de 2 turnos)"
echo ""
echo "📖 Mensagens prontas por trilha: abra docs/arquitetura/COMO-USAR.html no navegador"
