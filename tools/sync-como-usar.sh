#!/usr/bin/env bash
#
# tools/sync-como-usar.sh — gera COMO-USAR.md a partir do COMO-USAR.html (canonico).
#
# Fonte canonica:  COMO-USAR.html (raiz do pack)
# Gerado (commitado, NUNCA editado a mao):  COMO-USAR.md (raiz do pack)
#
# Uso:
#   bash tools/sync-como-usar.sh           # (re)gera COMO-USAR.md
#   bash tools/sync-como-usar.sh --check   # exit 1 se o .md commitado divergir do gerado
#
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$PACK_DIR/COMO-USAR.html"
DST="$PACK_DIR/COMO-USAR.md"
[ -f "$SRC" ] || { echo "ERRO: $SRC nao existe." >&2; exit 1; }

case "${1:-}" in
  --check) MODE="check" ;;
  "")      MODE="generate" ;;
  *) echo "ERRO: argumento desconhecido: ${1} (use --check ou nada)" >&2; exit 2 ;;
esac

OUT="$DST"
if [ "$MODE" = "check" ]; then
  OUT="$(mktemp)"
  trap 'rm -f "$OUT"' EXIT
fi

python3 - "$SRC" "$OUT" <<'PYEOF'
import re, sys, html

src, dst = sys.argv[1], sys.argv[2]
doc = open(src, encoding="utf-8").read()

def strip_tags(fragment):
    fragment = re.sub(r"<[^>]+>", "", fragment)
    return html.unescape(fragment).strip()

def table_to_md(tbl):
    rows = re.findall(r"<tr>(.*?)</tr>", tbl, re.S)
    out = []
    for i, row in enumerate(rows):
        cells = [strip_tags(c) for c in re.findall(r"<t[hd][^>]*>(.*?)</t[hd]>", row, re.S)]
        out.append("| " + " | ".join(cells) + " |")
        if i == 0:
            out.append("|" + "---|" * len(cells))
    return "\n".join(out)

lines = [
    "# Como usar — pack arquitetura (Amazon Q + Copilot + Kiro)",
    "",
    "> GERADO de `COMO-USAR.html` por `tools/sync-como-usar.sh` — NAO edite a mao.",
    "> Prefere botao de copiar? Abra `COMO-USAR.html` (mesma raiz) no navegador.",
    "",
]

for section in re.findall(r'<section class="trilha">(.*?)</section>', doc, re.S):
    title = strip_tags(re.search(r'<h2 class="section-eyebrow">(.*?)</h2>', section, re.S).group(1))
    lines += [f"## {title}", ""]

    body = re.split(r'<div class="cards">', section)[0]
    tbl = re.search(r"<table>(.*?)</table>", body, re.S)
    if tbl:
        lines += [table_to_md(tbl.group(1)), ""]
    for p in re.findall(r"<p>(.*?)</p>", body, re.S):
        lines += [re.sub(r"\s+", " ", strip_tags(p)), ""]

    for card in re.findall(r'<article class="msg-card">(.*?)</article>', section, re.S):
        h3 = strip_tags(re.search(r"<h3>(.*?)</h3>", card, re.S).group(1))
        quando = strip_tags(re.search(r'<p class="quando">(.*?)</p>', card, re.S).group(1))
        msg = strip_tags(re.search(r'<pre class="msg">(.*?)</pre>', card, re.S).group(1))
        slug = strip_tags(re.search(r'<span class="slug">(.*?)</span>', card, re.S).group(1))
        lines += [f"### {h3}", "", f"**Quando:** {quando}", "", "```text", msg, "```", "", f"_{slug}_", ""]

open(dst, "w", encoding="utf-8").write("\n".join(lines).rstrip() + "\n")
PYEOF

if [ "$MODE" = "check" ]; then
  if diff -q "$DST" "$OUT" > /dev/null 2>&1; then
    echo "OK: COMO-USAR.md em sincronia com o COMO-USAR.html."
  else
    echo "DRIFT em COMO-USAR.md — rode: bash tools/sync-como-usar.sh" >&2
    diff "$DST" "$OUT" 2>&1 | head -10 >&2 || true
    exit 1
  fi
else
  cards="$(grep -c '^### ' "$DST" || true)"
  echo "Gerado: COMO-USAR.md ($cards cards) a partir do COMO-USAR.html"
fi
