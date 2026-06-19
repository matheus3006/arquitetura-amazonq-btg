#!/usr/bin/env bash
# check-counts.sh — guard de contagens (padrao check/diff-fail): computa os numeros REAIS
# do pack e falha (exit 1) se as invariantes estruturais quebrarem OU se os numeros
# hardcoded em README.md / ia/INSTALAR.md divergirem da realidade.
# Rode da raiz do pack: bash ia/tools/check-counts.sh
set -u
fail=0
note() { echo "  - $1"; fail=1; }

# ── contagens reais ──────────────────────────────────────────────────────────
P=$(find ia/prompts -name '*.md' -type f | wc -l | tr -d ' ')
PA=$(find ia/prompts/arquitetura -name '*.md' -type f | wc -l | tr -d ' ')
PF=$(find ia/prompts/frontend    -name '*.md' -type f | wc -l | tr -d ' ')
PN=$(find ia/prompts/negocio     -name '*.md' -type f | wc -l | tr -d ' ')
PE=$(find ia/prompts/engenharia  -name '*.md' -type f | wc -l | tr -d ' ')
M=$(grep -vcE '^[[:space:]]*#|^[[:space:]]*$' ia/tools/manifest.tsv)
S=$(find ia/skills -name SKILL.md -type f | wc -l | tr -d ' ')
C=$(find ia/skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
GHS=$(find .github/skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
GHP=$(find .github/prompts -name '*.prompt.md' -type f | wc -l | tr -d ' ')
KS=$(find .kiro/skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

# ── invariantes estruturais (fontes entre si) ────────────────────────────────
[ "$P" = "$M" ]               || note "prompts ($P) != linhas do manifest ($M)"
[ "$((PA+PF+PN+PE))" = "$P" ] || note "soma por-trilha ($((PA+PF+PN+PE))) != total de prompts ($P)"
[ "$GHS" = "$((M+S))" ]       || note ".github/skills ($GHS) != wrappers+importadas ($((M+S)))"
[ "$KS" = "$((M+S))" ]        || note ".kiro/skills ($KS) != wrappers+importadas ($((M+S)))"
[ "$GHP" = "$M" ]             || note ".github/prompts ($GHP) != wrappers ($M)"

# ── numeros hardcoded nos docs vs realidade (diff-fail) ──────────────────────
need() { grep -qE "$2" "$1" || note "$3: padrao ausente em $1 (esperado /$2/)"; }
need README.md     "$S Agent Skills"                                              "README: total de skills importadas"
need README.md     "em $C categorias"                                            "README: categorias"
need README.md     "$GHS: $M wrappers \+ $S importadas"                           "README: composicao .github/.kiro skills"
need README.md     "$M arquivos \.prompt\.md"                                     "README: total .prompt.md"
need README.md     "$C categorias, $S skills"                                     "README: arvore ia/skills"
need README.md     "gera $M wrappers Copilot \+ $M wrappers Kiro = $GHS wrappers" "README: manifest gera wrappers"
need ia/INSTALAR.md "arquitetura $PA, frontend $PF, negocio $PN, engenharia $PE — $P arquivos" "INSTALAR: por-trilha + total"
need ia/INSTALAR.md "$C categorias e $S subpastas"                                "INSTALAR: ia/skills"
need ia/INSTALAR.md "com $GHS subpastas \($M wrappers"                            "INSTALAR: .github/skills subpastas"
need ia/INSTALAR.md "com $KS subpastas"                                           "INSTALAR: .kiro/skills subpastas"

if [ "$fail" = "0" ]; then
  echo "OK: contagens consistentes (prompts=$P [$PA/$PF/$PN/$PE], importadas=$S, categorias=$C, skills .github/.kiro=$GHS)."
fi
[ "$fail" = "0" ]
