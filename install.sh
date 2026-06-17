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
#        prompts, skills) + .kiro/ (camada Kiro: steering, skills)
#        + prompts/ (4 trilhas) + skills/ (biblioteca de 31 skills importadas) e
#        COMO-USAR.html (raiz) + docs/arquitetura/ (css do design system, js dos
#        templates, paginas HTML de exemplo — referencia de FORMA pros prompts;
#        nunca sobrescreve arquivo ja existente no alvo)
#        + hooks de inicio de interacao do protocolo de controle (.amazonq/cli-agents/
#        + .amazonq/hooks/ + .kiro/hooks/) — orientam o agente a abrir a task; NAO bloqueiam commit
# NAO copia: arquivos de contexto por-servico (project/business-context nos
#        tres lados) nem os foundation files do Kiro (product/tech/structure.md)
#        — sao gerados por-servico e preservados em re-runs.
set -euo pipefail

usage() { sed -n '2,19p' "$0" | sed 's/^#$//; s/^# //'; }

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

echo "📦 arquitetura (Amazon Q + Copilot + Kiro)  →  $TARGET"
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
echo "  ✓ .github/prompts/ (29 wrappers) + .github/skills/ (60: 29 wrappers + 31 importadas)"

# 2b) Camada Kiro (steering + Agent Skills). Copiamos SO as 5 rules de estilo:
#     *-context.md e os foundation files do Kiro (product/tech/structure.md)
#     sao por-servico e ficam intactos.
mkdir -p "$TARGET/.kiro/steering" "$TARGET/.kiro/skills"
for f in architecture-style frontend-style negocio-style engenharia-style controle-style; do
  cp "$PACK_DIR/.kiro/steering/$f.md" "$TARGET/.kiro/steering/$f.md"
done
echo "  ✓ .kiro/steering/ (5 rules)"
cp -R "$PACK_DIR/.kiro/skills/." "$TARGET/.kiro/skills/"
echo "  ✓ .kiro/skills/ (60 Agent Skills: 29 wrappers + 31 importadas)"

# 3) Prompts (4 trilhas)
mkdir -p "$TARGET/prompts"
for t in arquitetura frontend negocio engenharia; do
  cp -R "$PACK_DIR/prompts/$t" "$TARGET/prompts/"
done
echo "  ✓ prompts/{arquitetura,frontend,negocio,engenharia}"

# 3b) Biblioteca de skills importadas (fonte canonica das copias verbatim)
mkdir -p "$TARGET/skills"
cp -R "$PACK_DIR/skills/." "$TARGET/skills/"
echo "  ✓ skills/ (biblioteca: 31 skills importadas em 14 categorias)"

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

# 6) Guia de uso (mensagens prontas — fica na RAIZ; abra no navegador)
if [ ! -f "$PACK_DIR/COMO-USAR.html" ]; then
  echo "  ⚠ COMO-USAR.html ausente no pack — pulado"
elif [ -d "$TARGET/COMO-USAR.html" ]; then
  echo "  ⚠ COMO-USAR.html nao copiado (existe um DIRETORIO com esse nome no alvo)"
elif cp "$PACK_DIR/COMO-USAR.html" "$TARGET/COMO-USAR.html" 2>/dev/null && [ -f "$TARGET/COMO-USAR.html" ]; then
  echo "  ✓ COMO-USAR.html (raiz do repo)"
  if [ -f "$PACK_DIR/COMO-USAR.md" ]; then
    cp "$PACK_DIR/COMO-USAR.md" "$TARGET/COMO-USAR.md"
    echo "  ✓ COMO-USAR.md (versao markdown, mesma raiz)"
  fi
  # migracao: instalacoes antigas tinham o guia em docs/arquitetura/ — remove a copia obsoleta
  if [ -f "$TARGET/docs/arquitetura/COMO-USAR.html" ]; then
    rm "$TARGET/docs/arquitetura/COMO-USAR.html"
    echo "  ✓ docs/arquitetura/COMO-USAR.html (local antigo) removido — agora vive na raiz"
  fi
else
  echo "  ⚠ COMO-USAR.html nao copiado (destino bloqueado?)"
fi

# 7) Hooks de inicio de interacao do protocolo de controle. Substituem o antigo
#    pre-commit punitivo: a cada interacao orientam o agente a abrir/atualizar a task
#    em docs/controle/ ANTES de editar — NUNCA bloqueiam o commit do humano.
mkdir -p "$TARGET/.amazonq/cli-agents" "$TARGET/.amazonq/hooks" "$TARGET/.kiro/hooks"
cp "$PACK_DIR/.amazonq/cli-agents/arquitetura.json" "$TARGET/.amazonq/cli-agents/arquitetura.json"
echo "  ✓ .amazonq/cli-agents/arquitetura.json (ative com: q chat --agent arquitetura)"
cp "$PACK_DIR/.amazonq/hooks/controle-hook.sh" "$TARGET/.amazonq/hooks/controle-hook.sh"
chmod +x "$TARGET/.amazonq/hooks/controle-hook.sh"
echo "  ✓ .amazonq/hooks/controle-hook.sh (userPromptSubmit)"
cp "$PACK_DIR/.kiro/hooks/controle-prompt.kiro.hook" "$TARGET/.kiro/hooks/controle-prompt.kiro.hook"
echo "  ✓ .kiro/hooks/controle-prompt.kiro.hook (promptSubmit)"

# 7b) Migracao: instalacoes antigas tinham o pre-commit punitivo do controle. Remove-o
#     para destravar o commit do humano (so se for exatamente o gerado pelo pack).
OLD_HOOK="$TARGET/.git/hooks/pre-commit"
if [ -f "$OLD_HOOK" ] && grep -q 'pre-commit-controle' "$OLD_HOOK" 2>/dev/null; then
  body="$(grep -v -e '^[[:space:]]*$' -e '^[[:space:]]*#' "$OLD_HOOK" || true)"
  if [ "$body" = "bash .amazonq/hooks/pre-commit-controle.sh || exit 1" ]; then
    rm "$OLD_HOOK"
    echo "  ✓ .git/hooks/pre-commit (punitivo antigo do pack) removido — commit destravado"
  else
    echo "  ⚠ .git/hooks/pre-commit tem outras linhas — apague a mao a chamada de pre-commit-controle"
  fi
fi
if [ -f "$TARGET/.amazonq/hooks/pre-commit-controle.sh" ]; then
  rm "$TARGET/.amazonq/hooks/pre-commit-controle.sh"
  echo "  ✓ .amazonq/hooks/pre-commit-controle.sh (script antigo) removido"
fi

# 7c) Migracao de caminho: a versao antiga guardava as tasks em controle/ na raiz.
#     Move pra docs/controle/, preservando cada task (nunca sobrescreve task ja existente).
if [ -d "$TARGET/controle" ] && [ ! -L "$TARGET/controle" ]; then
  mkdir -p "$TARGET/docs/controle"
  moved=0
  for d in "$TARGET/controle"/*/; do
    [ -e "$d" ] || continue
    base="$(basename "$d")"
    if [ -e "$TARGET/docs/controle/$base" ]; then
      echo "  ⚠ docs/controle/$base ja existe — task '$base' deixada em controle/ (resolva a mao)"
    else
      mv "$d" "$TARGET/docs/controle/$base"
      moved=$((moved + 1))
    fi
  done
  if [ -z "$(ls -A "$TARGET/controle" 2>/dev/null)" ]; then
    rmdir "$TARGET/controle"
    echo "  ✓ controle/ (raiz, versao antiga) migrado pra docs/controle/ ($moved task(s))"
  elif [ "$moved" -gt 0 ]; then
    echo "  ⚠ controle/ migrado em parte ($moved task(s)); restou conteudo — verifique a mao"
  fi
fi

# 8) Limpeza de lixo do Finder
find "$TARGET/prompts" "$TARGET/skills" "$TARGET/.github" "$TARGET/.kiro" "$TARGET/docs/arquitetura" \
  -name '.DS_Store' -delete 2>/dev/null || true

echo ""
echo "✅ Instalado. O Amazon Q le .amazonq/rules/, o Copilot le .github/ e o Kiro le .kiro/ automaticamente."
echo ""
echo "Comece:"
echo "   Tecnica:    \"documenta esse servico\"   (Copilot IDE: /analisador-de-projeto na 1a vez)"
echo "   Negocio:    \"analisa o dominio\" → \"grilla o negocio\""
echo "   Frontend:   \"polir essa pagina\""
echo "   Engenharia: \"investiga esse bug\" · \"planeja a implementacao\""
echo "   Controle:   \"nova tarefa: <slug> — <descricao>\"  (protocolo de 2 turnos)"
echo ""
echo "📖 Mensagens prontas por trilha: abra COMO-USAR.html (raiz do repo) no navegador"
