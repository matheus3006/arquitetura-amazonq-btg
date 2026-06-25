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
#        + ia/prompts/ (4 trilhas) + ia/skills/ (biblioteca de 32 skills importadas) e
#        ia/COMO-USAR.html + ia/design-system/ (css) + ia/templates/ (prefs.js + viewer +
#        sidebar + paginas HTML de exemplo — referencia de FORMA pros prompts;
#        nunca sobrescreve arquivo ja existente no alvo)
#        + doc/templates/ + doc/design-system/ (assets de runtime semeados de ia/ pros
#        docs gerados em doc/arquitetura/) + ia/tools/seed-doc-assets.sh (re-semear)
#        + ia/tools/validar-doc.sh + ia/tools/lib/ (3 SoT) — validacao determinista que os
#        prompts validadores (etapas 6/7 da trilha) rodam no "done" da geracao
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

echo "📦 arquitetura (Amazon Q + Copilot + Kiro + Junie)  →  $TARGET"
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
echo "  ✓ .github/prompts/ (32 wrappers) + .github/skills/ (64: 32 wrappers + 32 importadas)"

# 2b) Camada Kiro (steering + Agent Skills). Copiamos SO as 5 rules de estilo:
#     *-context.md e os foundation files do Kiro (product/tech/structure.md)
#     sao por-servico e ficam intactos.
mkdir -p "$TARGET/.kiro/steering" "$TARGET/.kiro/skills"
for f in architecture-style frontend-style negocio-style engenharia-style controle-style; do
  cp "$PACK_DIR/.kiro/steering/$f.md" "$TARGET/.kiro/steering/$f.md"
done
echo "  ✓ .kiro/steering/ (5 rules)"
cp -R "$PACK_DIR/.kiro/skills/." "$TARGET/.kiro/skills/"
echo "  ✓ .kiro/skills/ (64 Agent Skills: 32 wrappers + 32 importadas)"

# 2c) Camada Junie (JetBrains) — arquivo unico de guidelines. Junie NAO tem skills/prompts:
#     le .junie/guidelines.md e injeta o conteudo em toda task. Gerado por sync-junie.sh (pack-only).
mkdir -p "$TARGET/.junie"
cp "$PACK_DIR/.junie/guidelines.md" "$TARGET/.junie/guidelines.md"
echo "  ✓ .junie/guidelines.md (Junie le automaticamente)"

# 3) Prompts (4 trilhas)
mkdir -p "$TARGET/ia/prompts"
for t in arquitetura frontend negocio engenharia; do
  cp -R "$PACK_DIR/ia/prompts/$t" "$TARGET/ia/prompts/"
done
echo "  ✓ ia/prompts/{arquitetura,frontend,negocio,engenharia}"

# 3b) Biblioteca de skills importadas (fonte canonica das copias verbatim)
mkdir -p "$TARGET/ia/skills"
cp -R "$PACK_DIR/ia/skills/." "$TARGET/ia/skills/"
echo "  ✓ ia/skills/ (biblioteca: 32 skills importadas em 14 categorias)"

# 4) Design system (CSS reutilizavel)
mkdir -p "$TARGET/ia/design-system"
cp "$PACK_DIR/ia/design-system/"*.css "$TARGET/ia/design-system/"
echo "  ✓ ia/design-system/*.css"

# 5) Runtime dos templates (prefs + viewer + sidebar)
mkdir -p "$TARGET/ia/templates"
cp "$PACK_DIR/ia/templates/prefs.js"          "$TARGET/ia/templates/"
cp "$PACK_DIR/ia/templates/diagram-viewer.js" "$TARGET/ia/templates/"
cp "$PACK_DIR/ia/templates/sidebar.js"        "$TARGET/ia/templates/"
echo "  ✓ ia/templates/prefs.js + diagram-viewer.js + sidebar.js"

# 5b) Paginas de exemplo — referencia de FORMA pros prompts (padrao; pule com
#     --no-examples). NUNCA sobrescreve: paginas ja geradas no alvo ficam intactas.
if [ "$NO_EXAMPLES" = "1" ]; then
  echo "  ↷ ia/templates/*.html (exemplos) pulados (--no-examples)"
else
  copied=0; kept=0
  for f in "$PACK_DIR/ia/templates/"*.html; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    if [ -e "$TARGET/ia/templates/$base" ]; then
      kept=$((kept + 1))
    else
      cp "$f" "$TARGET/ia/templates/$base"
      copied=$((copied + 1))
    fi
  done
  if [ "$((copied + kept))" -eq 0 ]; then
    echo "  ⚠ ia/templates/*.html nao copiados (nenhum .html no pack?)"
  else
    echo "  ✓ ia/templates/*.html (exemplos de forma: $copied copiados, $kept preservados)"
  fi
fi

# 5c) Assets de runtime sob doc/ — os docs gerados em doc/arquitetura/ referenciam
#     ../templates/prefs.js e ../design-system/*.css. Artefato de build: semeado de ia/
#     (idempotente). Instala tambem o helper para re-semear quando ia/ mudar.
mkdir -p "$TARGET/ia/tools"
cp "$PACK_DIR/ia/tools/seed-doc-assets.sh" "$TARGET/ia/tools/seed-doc-assets.sh"
chmod +x "$TARGET/ia/tools/seed-doc-assets.sh" 2>/dev/null || true
bash "$PACK_DIR/ia/tools/seed-doc-assets.sh" "$TARGET"

# 5d) Validador de doc — roda NO CLIENTE nas etapas 6/7 da trilha (validador-visual --front e
#     validador-sintaxe-mermaid --mermaid). Sem o script + os 3 SoT em lib/, aqueles prompts
#     caem no fallback textual: a camada deterministica (principio nº4) so existe se o
#     instalador a levar. Bash puro — o cliente NAO precisa de node. lib/ resolve relativo ao
#     script (validar-doc.sh:11), entao basta colocar script e SoT lado a lado.
mkdir -p "$TARGET/ia/tools/lib"
cp "$PACK_DIR/ia/tools/validar-doc.sh" "$TARGET/ia/tools/validar-doc.sh"
chmod +x "$TARGET/ia/tools/validar-doc.sh" 2>/dev/null || true
for sot in design-system-classes.txt forbidden-terms.txt mermaid-classdefs.txt; do
  cp "$PACK_DIR/ia/tools/lib/$sot" "$TARGET/ia/tools/lib/$sot"
done
echo "  ✓ ia/tools/validar-doc.sh + lib/ (3 SoT) — validacao roda no done da trilha"

# 6) Guia de uso (mensagens prontas — fica em ia/; abra no navegador)
if [ ! -f "$PACK_DIR/ia/COMO-USAR.html" ]; then
  echo "  ⚠ COMO-USAR.html ausente no pack — pulado"
elif [ -d "$TARGET/ia/COMO-USAR.html" ]; then
  echo "  ⚠ COMO-USAR.html nao copiado (existe um DIRETORIO com esse nome no alvo)"
elif cp "$PACK_DIR/ia/COMO-USAR.html" "$TARGET/ia/COMO-USAR.html" 2>/dev/null && [ -f "$TARGET/ia/COMO-USAR.html" ]; then
  echo "  ✓ ia/COMO-USAR.html"
  if [ -f "$PACK_DIR/ia/COMO-USAR.md" ]; then
    cp "$PACK_DIR/ia/COMO-USAR.md" "$TARGET/ia/COMO-USAR.md"
    echo "  ✓ ia/COMO-USAR.md (versao markdown)"
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
#    em doc/controle/ ANTES de editar — NUNCA bloqueiam o commit do humano.
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
#     Move pra doc/controle/, preservando cada task (nunca sobrescreve task ja existente).
if [ -d "$TARGET/controle" ] && [ ! -L "$TARGET/controle" ]; then
  mkdir -p "$TARGET/doc/controle"
  moved=0
  for d in "$TARGET/controle"/*/; do
    [ -e "$d" ] || continue
    base="$(basename "$d")"
    if [ -e "$TARGET/doc/controle/$base" ]; then
      echo "  ⚠ doc/controle/$base ja existe — task '$base' deixada em controle/ (resolva a mao)"
    else
      mv "$d" "$TARGET/doc/controle/$base"
      moved=$((moved + 1))
    fi
  done
  if [ -z "$(ls -A "$TARGET/controle" 2>/dev/null)" ]; then
    rmdir "$TARGET/controle"
    echo "  ✓ controle/ (raiz, versao antiga) migrado pra doc/controle/ ($moved task(s))"
  elif [ "$moved" -gt 0 ]; then
    echo "  ⚠ controle/ migrado em parte ($moved task(s)); restou conteudo — verifique a mao"
  fi
fi

# 7d) Migracao de LAYOUT (pre-ia/doc): o pack agora vive em ia/ e os outputs em doc/.
#     Move os DADOS do usuario (docs/*) pra doc/ e remove as copias antigas do pack na raiz
#     (reinstaladas em ia/ nas secoes acima). Preserva tudo do usuario; nunca sobrescreve.
if [ -d "$TARGET/docs" ]; then
  mkdir -p "$TARGET/doc"
  for d in "$TARGET/docs"/*/; do
    [ -d "$d" ] || continue
    b="$(basename "$d")"
    if [ "$b" = "arquitetura" ]; then
      mkdir -p "$TARGET/doc/arquitetura"
      for item in "$d"*; do
        [ -e "$item" ] || continue
        ib="$(basename "$item")"
        case "$ib" in
          templates|design-system) rm -rf "$item" ;;   # do pack — ja reinstalado em ia/
          *) [ -e "$TARGET/doc/arquitetura/$ib" ] || mv "$item" "$TARGET/doc/arquitetura/$ib" ;;
        esac
      done
      rmdir "$d" 2>/dev/null || true
    elif [ ! -e "$TARGET/doc/$b" ]; then
      mv "$d" "$TARGET/doc/$b"; echo "  ✓ docs/$b (layout antigo) -> doc/$b"
    fi
  done
  rmdir "$TARGET/docs" 2>/dev/null || true
fi
for old in prompts skills tools COMO-USAR.html COMO-USAR.md; do
  if [ -e "$TARGET/$old" ]; then rm -rf "$TARGET/$old"; echo "  ✓ $old (raiz, layout antigo) removido — agora em ia/"; fi
done

# 8) Limpeza de lixo do Finder
find "$TARGET/ia" "$TARGET/.github" "$TARGET/.kiro" "$TARGET/doc" \
  -name '.DS_Store' -delete 2>/dev/null || true

# 9) .gitignore do produto — bloco idempotente: ignora as replicas pesadas (skills/prompts,
#    ~9,5 MB) e mantem versionada a config + o contexto por-servico + doc/. O conteudo vem de
#    ia/tools/lib/gitignore-pack-block.txt (fonte unica, lida tambem pelo install.ps1 — sem drift).
mkdir -p "$TARGET/ia/tools/lib"
cp "$PACK_DIR/ia/tools/seed-gitignore.sh" "$TARGET/ia/tools/seed-gitignore.sh"
cp "$PACK_DIR/ia/tools/lib/gitignore-pack-block.txt" "$TARGET/ia/tools/lib/gitignore-pack-block.txt"
chmod +x "$TARGET/ia/tools/seed-gitignore.sh" 2>/dev/null || true
bash "$PACK_DIR/ia/tools/seed-gitignore.sh" "$TARGET"

echo ""
echo "✅ Instalado. O Amazon Q le .amazonq/rules/, o Copilot le .github/, o Kiro le .kiro/ e o Junie le .junie/guidelines.md."
echo ""
echo "Comece:"
echo "   Tecnica:    \"documenta esse servico\"   (Copilot IDE: /analisador-de-projeto na 1a vez)"
echo "   Negocio:    \"analisa o dominio\" → \"grilla o negocio\""
echo "   Frontend:   \"polir essa pagina\""
echo "   Engenharia: \"investiga esse bug\" · \"planeja a implementacao\""
echo "   Controle:   \"nova tarefa: <slug> — <descricao>\"  (protocolo de 2 turnos)"
echo ""
echo "📖 Mensagens prontas por trilha: abra ia/COMO-USAR.html no navegador"
