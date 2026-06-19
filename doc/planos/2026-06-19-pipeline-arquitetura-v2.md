# Pipeline de Arquitetura v2 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementar o redesign do pipeline de arquitetura do pack `arquitetura`: 7 etapas/8 sessões + 2 validadores + atualizador + QA-ledger + destino unificado, com checklist verificável + script lint opcional, conforme spec aprovado [doc/specs/2026-06-19-pipeline-arquitetura-v2-design.md](../specs/2026-06-19-pipeline-arquitetura-v2-design.md).

**Architecture:** Conteúdo (markdown/HTML) é o produto principal — editado nos canônicos `.amazonq/rules/`, `ia/prompts/`, `ia/COMO-USAR.html`. Mirrors `.github/` e `.kiro/` são regenerados por `ia/tools/sync-*.sh` (nunca editados à mão). Único código novo: `ia/tools/validar-doc.sh` (lint bash + 3 listas SoT em `ia/tools/lib/`). Verificação genuinamente TDD para o script (fixtures HTML válido/inválido + assert exit code); para conteúdo, verificação por grep + `--check` dos sync scripts.

**Tech Stack:** bash 3.2+ (compat macOS), markdown, HTML/CSS, mermaid (não rodado — só lint estrutural por regex). Nenhuma dep nova. Working-model do pack: canônico→mirror via `sync-*.sh`; protocolo de controle em `doc/controle/` com QA.md vivo. Commit direto na `main` (sem branch/PR) — preferência registrada em [commit-direct-to-main](.../memory/commit-direct-to-main.md).

**Convenções deste plano:**
- Cada task = 1 commit lógico ao final.
- Mensagens de commit: `<tipo>(<area>): <imperativo curto>` (`feat`, `fix`, `docs`, `refactor`, `chore`).
- Para markdown, "teste" = verificação por `grep`/`diff`/`--check` (TDD adaptado para conteúdo).
- Para `validar-doc.sh`, TDD genuíno: fixture HTML → rodar script → assertar exit code + stdout.
- Os 3 `sync --check` são gate final de cada fase que toca canônicos espelhados.

---

## Fase 0 — Setup

### Task 0: Verificar baseline antes de mexer

**Files:** nenhum modificado nesta task.

- [ ] **Step 1: Confirmar baseline limpo**

Run:
```bash
cd /Users/matheus/PESSOAL/arquitetura
git status --short
```
Expected: vazio (working tree clean). Se houver mudanças não-commitadas, pause e resolva.

- [ ] **Step 2: Confirmar os 3 sync em sincronia**

Run:
```bash
bash ia/tools/sync-copilot.sh   --check
bash ia/tools/sync-kiro.sh      --check
bash ia/tools/sync-como-usar.sh --check
```
Expected (3 vezes): `OK: ... em sincronia com o canonico.` (exit 0 cada).

- [ ] **Step 3: Confirmar contagem real de hoje**

Run:
```bash
for t in arquitetura frontend negocio engenharia; do
  printf '%-12s %s\n' "$t:" "$(find ia/prompts/$t -maxdepth 1 -name '*.md' -type f | wc -l | tr -d ' ')"
done
```
Expected: `arquitetura: 11`, `frontend: 4`, `negocio: 5`, `engenharia: 10` (total 30).

---

## Fase A — Source of Truth (listas + checklist canônico)

### Task A1: Criar `ia/tools/lib/design-system-classes.txt`

**Files:**
- Create: `ia/tools/lib/design-system-classes.txt`

- [ ] **Step 1: Criar o diretório**

Run: `mkdir -p ia/tools/lib`

- [ ] **Step 2: Escrever o arquivo com a lista canônica de classes**

Conteúdo (extraído de `ia/design-system/components.css` + estruturais do esqueleto):

```
# Lista canônica de classes do design-system do pack arquitetura.
# Fonte: ia/design-system/components.css (+ estruturais do esqueleto).
# Adicionar/remover classe = editar este arquivo (uma por linha, comentários começam com #).
# Lida por: validador-visual.md (prompt) e ia/tools/validar-doc.sh --front.
shell
sidebar
sidebar__brand
sidebar__brand-mark
sidebar__brand-name
sidebar__link
sidebar__scale-label
sidebar__section
sidebar__section--bar
sidebar__section--circle
sidebar__section-title
sidebar__tool-btn
sidebar__tools
sidebar__tools-group
main
breadcrumb
hero
hero__eyebrow
hero__title
hero__subtitle
accent-word
tech-pills
tech-pill
section-eyebrow
prose
data-table
decision-callout
decision-callout__body
decision-callout__icon
decision-callout__label
doc-grid
doc-card
doc-card__desc
doc-card__icon
doc-card__title
code-block
code-block__header
code-inline
diagram-figure
diagram-viewer
diagram-viewer__btn
diagram-viewer__canvas
diagram-viewer__controls
diagram-viewer__error
diagram-viewer__error-body
diagram-viewer__error-title
diagram-viewer__hint
diagram-viewer__loading
status-badge
status-badge--accepted
status-badge--deprecated
status-badge--proposed
destaque
no-print
print-only
skip-link
sr-only
```

- [ ] **Step 3: Verificar leitura**

Run: `wc -l ia/tools/lib/design-system-classes.txt`
Expected: `58 ia/tools/lib/design-system-classes.txt` (4 comentários + 54 classes).

- [ ] **Step 4: Commit**

```bash
git add ia/tools/lib/design-system-classes.txt
git commit -m "feat(validador): SoT do vocabulario de classes do design-system"
```

### Task A2: Criar `ia/tools/lib/mermaid-classdefs.txt`

**Files:**
- Create: `ia/tools/lib/mermaid-classdefs.txt`

- [ ] **Step 1: Escrever o arquivo com os 4 classDef hex exatos**

Conteúdo (extraído de `architecture-style.md` §1.4, linhas 106-109):

```
# Os 4 classDef obrigatorios em todo diagrama de relacao (architecture-style.md §1.4).
# Cada linha: <classe> | <fill> | <stroke> | <color> | <stroke-width> | [stroke-dasharray]
# Validado por: validador-sintaxe-mermaid.md (prompt) e ia/tools/validar-doc.sh --mermaid.
person   | #1c4e93 | #0a0c12 | #ffffff | 2px
sys      | #4a8fe7 | #0a0c12 | #ffffff | 2.5px
ext      | #ffffff | #1f2937 | #0a0c12 | 1.5px
extAsync | #f9fafb | #6b7280 | #0a0c12 | 1.5px | 5 3
```

- [ ] **Step 2: Verificar**

Run: `grep -cE '^[a-z]' ia/tools/lib/mermaid-classdefs.txt`
Expected: `4`

- [ ] **Step 3: Commit**

```bash
git add ia/tools/lib/mermaid-classdefs.txt
git commit -m "feat(validador): SoT dos 4 classDef obrigatorios do Mermaid"
```

### Task A3: Criar `ia/tools/lib/forbidden-terms.txt`

**Files:**
- Create: `ia/tools/lib/forbidden-terms.txt`

- [ ] **Step 1: Escrever o arquivo**

Conteúdo:

```
# Termos do exemplo ficticio do pack que NUNCA podem vazar para doc real.
# Validado por: validador-visual.md (prompt) e ia/tools/validar-doc.sh --front.
# Match: substring case-insensitive em texto visivel (fora de tags <script>).
# Adicionar termos: uma string por linha (comentarios com #).
Liquidação Transacional
Liquidacao Transacional
FICO Falcon
```

- [ ] **Step 2: Verificar**

Run: `grep -cE '^[A-Z]' ia/tools/lib/forbidden-terms.txt`
Expected: `3`

- [ ] **Step 3: Commit**

```bash
git add ia/tools/lib/forbidden-terms.txt
git commit -m "feat(validador): SoT de termos proibidos do exemplo ficticio"
```

### Task A4: Criar `ia/templates/checklist-validador.md`

**Files:**
- Create: `ia/templates/checklist-validador.md`

- [ ] **Step 1: Escrever o template canônico do checklist**

Conteúdo:

````markdown
# Checklist canônico dos validadores

> Embutido pelos prompts `validador-visual` e `validador-sintaxe-mermaid` no INÍCIO da
> resposta. Sem este bloco preenchido, a etapa NÃO conta como concluída.

## Checklist do validador

| Regra | Status | Evidência |
|---|---|---|
| 5.1.1 NAV: cada .html tem entry em sidebar.js | PASS / FAIL / N-A | `arquivo:linha` |
| 5.1.1 NAV: href resolve para arquivo existente | PASS / FAIL / N-A | `arquivo:linha` |
| 5.1.2 Ordem fixa do <head> | PASS / FAIL / N-A | `arquivo:linha` |
| 5.1.2 Body em shell > sidebar + main | PASS / FAIL / N-A | `arquivo:linha` |
| 5.1.2 Toda classe em design-system-classes.txt | PASS / FAIL / N-A | trecho |
| 5.1.2 Zero hex hardcoded fora dos classDef | PASS / FAIL / N-A | trecho |
| 5.1.3 Cabeçalho h2.section-eyebrow / texto p.prose | PASS / FAIL / N-A | trecho |
| 5.1.3 Página de conteúdo abre com breadcrumb + hero | PASS / FAIL / N-A | trecho |
| 5.1.3 Diagrama: figure.diagram-figure + script[data-id] pareados | PASS / FAIL / N-A | trecho |
| 5.1.3 Sem resíduo (forbidden-terms.txt) | PASS / FAIL / N-A | grep |
| 5.2 Pareamento data-diagram ↔ data-id 1:1 | PASS / FAIL / N-A | trecho |
| 5.2 1ª linha do bloco = tipo válido | PASS / FAIL / N-A | trecho |
| 5.2 4 classDef com hex exatos (mermaid-classdefs.txt) | PASS / FAIL / N-A | trecho |
| 5.2 Labels entre aspas, sem `<`/`>` crus, sem `\n` | PASS / FAIL / N-A | trecho |
| 5.2 sequenceDiagram tem `autonumber` (sempre) | PASS / FAIL / N-A | trecho |
| 5.2 Tipografia Butterick onde aplicável | PASS / FAIL / N-A | trecho |

**Modo:** lint (validar-doc.sh exit 0|1) | fallback (checklist textual) | misto

**Veredito:** PASS (zero FAIL) | FAIL (N violações listadas abaixo)

## Violações (somente se FAIL)
- `<arquivo>:<linha>:<regra>: <descricao curta>`
- ...
````

- [ ] **Step 2: Verificar**

Run: `grep -c '| PASS / FAIL / N-A |' ia/templates/checklist-validador.md`
Expected: `16` (16 regras no template).

- [ ] **Step 3: Commit**

```bash
git add ia/templates/checklist-validador.md
git commit -m "feat(validador): template canonico do checklist (gate de resposta)"
```

---

## Fase B — `ia/tools/validar-doc.sh` (TDD genuíno)

### Task B1: Esqueleto + parse de CLI + exit codes

**Files:**
- Create: `ia/tools/validar-doc.sh`
- Create: `ia/tools/tests/run-tests.sh`
- Create: `ia/tools/tests/fixtures/.gitkeep`

- [ ] **Step 1: Escrever o teste primeiro (run-tests.sh)**

Conteúdo de `ia/tools/tests/run-tests.sh`:

```bash
#!/usr/bin/env bash
# Suite de testes do validar-doc.sh. Cada teste: (fixture, flag, expected_exit, expected_grep).
# Uso: bash ia/tools/tests/run-tests.sh    (rode da raiz do pack)
set -u
PASS=0; FAIL=0
SCRIPT="ia/tools/validar-doc.sh"

run_case() {
  local name="$1" fixture="$2" flag="$3" expected_exit="$4" expected_grep="${5:-}"
  local out exit_code
  out=$(bash "$SCRIPT" "$fixture" "$flag" 2>&1) ; exit_code=$?
  if [ "$exit_code" -ne "$expected_exit" ]; then
    echo "FAIL: $name -- exit $exit_code, esperava $expected_exit"
    echo "      stdout: $out"
    FAIL=$((FAIL+1)) ; return
  fi
  if [ -n "$expected_grep" ] && ! grep -qE "$expected_grep" <<<"$out"; then
    echo "FAIL: $name -- output nao casa /$expected_grep/"
    echo "      stdout: $out"
    FAIL=$((FAIL+1)) ; return
  fi
  echo "PASS: $name"
  PASS=$((PASS+1))
}

# CLI / exit codes
run_case "cli: sem args = exit 2" "" "" 2 "Uso:"
run_case "cli: flag invalida = exit 2" "ia/tools/tests/fixtures" "--xxx" 2 "Flag invalida"
run_case "cli: pasta inexistente = exit 2" "/nao/existe/abc" "--front" 2 "pasta"

echo
echo "Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
```

Run: `mkdir -p ia/tools/tests/fixtures && touch ia/tools/tests/fixtures/.gitkeep && chmod +x ia/tools/tests/run-tests.sh`

- [ ] **Step 2: Rodar o teste — deve falhar (script ainda não existe)**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: 3 FAIL (script `ia/tools/validar-doc.sh` ainda não existe → exit 127 ≠ 2).

- [ ] **Step 3: Escrever esqueleto mínimo do script**

Conteúdo de `ia/tools/validar-doc.sh`:

```bash
#!/usr/bin/env bash
# validar-doc.sh — lint estrutural da doc de arquitetura em <pasta>.
# Uso:
#   bash ia/tools/validar-doc.sh <pasta> [--front | --mermaid | --all]
# Exit codes:
#   0 = clean
#   1 = violacoes (lista no stdout: <arquivo>:<linha>:<regra>: <descricao>)
#   2 = erro de uso ou ambiente sem dependencia opcional (fallback)
set -u

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" 2>/dev/null && pwd || true)"

usage() {
  cat <<'EOF'
Uso: bash ia/tools/validar-doc.sh <pasta> [--front | --mermaid | --all]

Flags:
  --front     lint visual/template (vocabulario, esqueleto, cores, NAV, forbidden-terms)
  --mermaid   lint sintaxe/Mermaid (pareamento, classDef, autonumber, labels)
  --all       atalho para os dois

Exit: 0=clean, 1=violacoes, 2=erro de uso ou fallback
EOF
}

[ $# -lt 2 ] && { usage >&2; exit 2; }
TARGET="$1" ; FLAG="$2"
case "$FLAG" in
  --front|--mermaid|--all) ;;
  *) echo "Flag invalida: $FLAG" >&2; usage >&2; exit 2 ;;
esac
[ -d "$TARGET" ] || { echo "pasta nao existe: $TARGET" >&2; exit 2; }

VIOLATIONS=0
violation() { echo "$1:$2:$3: $4"; VIOLATIONS=$((VIOLATIONS+1)); }

# Hooks por flag (preenchidos nas tasks seguintes)
run_front()   { :; }
run_mermaid() { :; }

case "$FLAG" in
  --front)   run_front "$TARGET" ;;
  --mermaid) run_mermaid "$TARGET" ;;
  --all)     run_front "$TARGET"; run_mermaid "$TARGET" ;;
esac

[ "$VIOLATIONS" -eq 0 ] && exit 0 || exit 1
```

Run: `chmod +x ia/tools/validar-doc.sh`

- [ ] **Step 4: Rodar o teste — agora deve passar**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: `Total: PASS=3 FAIL=0`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add ia/tools/validar-doc.sh ia/tools/tests/run-tests.sh ia/tools/tests/fixtures/.gitkeep
git commit -m "feat(validador): esqueleto do validar-doc.sh + suite de testes (CLI + exit codes)"
```

### Task B2: TDD — regra `--front` ordem fixa do `<head>`

**Files:**
- Create: `ia/tools/tests/fixtures/front/head-ok.html`
- Create: `ia/tools/tests/fixtures/front/head-bad-order.html`
- Modify: `ia/tools/tests/run-tests.sh` (adicionar 2 casos)
- Modify: `ia/tools/validar-doc.sh` (preencher `run_front` — regra ordem)

- [ ] **Step 1: Escrever fixture válida (head correto)**

`ia/tools/tests/fixtures/front/head-ok.html`:

```html
<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>OK</title>
<meta name="description" content="ok">
<script src="../templates/prefs.js"></script>
<link rel="stylesheet" href="../design-system/tokens.css">
<link rel="stylesheet" href="../design-system/components.css">
</head>
<body><div class="shell"><aside id="sidebar" class="sidebar"></aside><main id="main" class="main"></main></div></body>
</html>
```

- [ ] **Step 2: Escrever fixture inválida (CSS antes do prefs.js)**

`ia/tools/tests/fixtures/front/head-bad-order.html`:

```html
<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>BAD</title>
<link rel="stylesheet" href="../design-system/tokens.css">
<script src="../templates/prefs.js"></script>
<link rel="stylesheet" href="../design-system/components.css">
</head>
<body><div class="shell"><aside id="sidebar" class="sidebar"></aside><main id="main" class="main"></main></div></body>
</html>
```

- [ ] **Step 3: Adicionar casos ao run-tests.sh**

Inserir antes da linha `echo` final:

```bash
# Regra: ordem do <head> (front)
run_case "front: head correto"        "ia/tools/tests/fixtures/front/head-ok.html"        "--front" 0 ""
run_case "front: prefs.js depois de CSS = FAIL" "ia/tools/tests/fixtures/front/head-bad-order.html" "--front" 1 "head: prefs.js deve vir ANTES dos links de CSS"
```

- [ ] **Step 4: Rodar — devem falhar (run_front ainda é `:`)**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: o `head-bad-order` falha (script retorna 0 esperando 1).

- [ ] **Step 5: Implementar a regra em `run_front`**

Substituir `run_front() { :; }` por:

```bash
# Aceita arquivo unico OU pasta (varre *.html). Cada regra grava violation se falhar.
_iter_html() {
  if [ -f "$1" ]; then echo "$1"
  else find "$1" -name '*.html' -type f
  fi
}

# Regra: dentro do <head>, prefs.js deve aparecer ANTES do primeiro <link ... .css>
_rule_head_order() {
  local file="$1"
  local prefs_line css_line
  prefs_line=$(grep -nE 'src="[^"]*prefs\.js"' "$file" | head -1 | cut -d: -f1)
  css_line=$(grep -nE '<link[^>]*rel="stylesheet"' "$file" | head -1 | cut -d: -f1)
  [ -z "$prefs_line" ] && return 0
  [ -z "$css_line" ] && return 0
  if [ "$prefs_line" -gt "$css_line" ]; then
    violation "$file" "$prefs_line" "head-order" "prefs.js deve vir ANTES dos links de CSS"
  fi
}

run_front() {
  local target="$1" file
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    _rule_head_order "$file"
  done < <(_iter_html "$target")
}
```

- [ ] **Step 6: Rodar — todos devem passar**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: `Total: PASS=5 FAIL=0`.

- [ ] **Step 7: Commit**

```bash
git add ia/tools/tests/fixtures/front/head-ok.html ia/tools/tests/fixtures/front/head-bad-order.html ia/tools/tests/run-tests.sh ia/tools/validar-doc.sh
git commit -m "feat(validador): regra --front head-order (prefs.js antes de CSS)"
```

### Task B3: TDD — regra `--front` classes fora do design-system

**Files:**
- Create: `ia/tools/tests/fixtures/front/class-bad.html`
- Modify: `ia/tools/tests/run-tests.sh`
- Modify: `ia/tools/validar-doc.sh`

- [ ] **Step 1: Fixture inválida com classe fora do lib**

`ia/tools/tests/fixtures/front/class-bad.html`:

```html
<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<title>BAD</title>
<script src="../templates/prefs.js"></script>
<link rel="stylesheet" href="../design-system/tokens.css">
<link rel="stylesheet" href="../design-system/components.css">
</head>
<body><div class="shell"><aside class="sidebar"></aside><main class="main">
<section class="my-custom-section"><h2 class="prose">Olá</h2></section>
</main></div></body>
</html>
```

- [ ] **Step 2: Adicionar casos ao run-tests.sh**

```bash
# Regra: vocabulario fechado de classes (front)
run_case "front: class fora do lib = FAIL" "ia/tools/tests/fixtures/front/class-bad.html" "--front" 1 "class-unknown.*my-custom-section"
```

- [ ] **Step 3: Rodar — deve falhar**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: o `class-bad` retorna 0 onde esperamos 1.

- [ ] **Step 4: Implementar a regra**

Adicionar (antes de `run_front()`):

```bash
_load_classes() {
  [ -f "$LIB_DIR/design-system-classes.txt" ] || return 1
  grep -vE '^(#|$)' "$LIB_DIR/design-system-classes.txt"
}

_rule_known_classes() {
  local file="$1" allowed line classes c
  allowed=$(_load_classes 2>/dev/null) || return 0
  # extrai cada token de class="..." (preserva linha)
  while IFS=: read -r line content; do
    classes=$(echo "$content" | grep -oE 'class="[^"]*"' | sed -E 's/class="([^"]*)"/\1/g')
    for c in $classes; do
      # ignora pseudo-classes BEM com -- (variantes ja listadas individualmente)
      grep -qxE "$c" <<<"$allowed" && continue
      violation "$file" "$line" "class-unknown" "classe '$c' nao esta em design-system-classes.txt"
    done
  done < <(grep -nE 'class="[^"]*"' "$file")
}
```

E acrescentar `_rule_known_classes "$file"` dentro do loop em `run_front`:

```bash
run_front() {
  local target="$1" file
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    _rule_head_order "$file"
    _rule_known_classes "$file"
  done < <(_iter_html "$target")
}
```

- [ ] **Step 5: Rodar — todos passam**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: `Total: PASS=6 FAIL=0`.

- [ ] **Step 6: Commit**

```bash
git add ia/tools/tests/fixtures/front/class-bad.html ia/tools/tests/run-tests.sh ia/tools/validar-doc.sh
git commit -m "feat(validador): regra --front classe fora do design-system-classes.txt"
```

### Task B4: TDD — regra `--front` cor hex hardcoded (fora de classDef)

**Files:**
- Create: `ia/tools/tests/fixtures/front/hex-bad.html`
- Modify: `ia/tools/tests/run-tests.sh`
- Modify: `ia/tools/validar-doc.sh`

- [ ] **Step 1: Fixture inválida (hex em style inline)**

`ia/tools/tests/fixtures/front/hex-bad.html`:

```html
<!doctype html>
<html lang="pt-BR"><head>
<meta charset="utf-8"><title>BAD</title>
<script src="../templates/prefs.js"></script>
<link rel="stylesheet" href="../design-system/tokens.css">
<link rel="stylesheet" href="../design-system/components.css">
</head><body><div class="shell"><aside class="sidebar"></aside><main class="main">
<p class="prose" style="color:#ff00aa">erro: cor hex direto</p>
</main></div></body></html>
```

- [ ] **Step 2: Adicionar caso**

```bash
run_case "front: hex inline = FAIL" "ia/tools/tests/fixtures/front/hex-bad.html" "--front" 1 "hex-hardcoded"
```

- [ ] **Step 3: Implementar a regra**

```bash
_rule_no_hex() {
  local file="$1" line content
  # Ignora linhas dentro de <script type="text/mermaid"> (classDef precisa de hex).
  awk '
    /<script[^>]*text\/mermaid/ { inm=1; next }
    /<\/script>/                { inm=0; next }
    inm                          { next }
    { print NR":"$0 }
  ' "$file" | while IFS=: read -r line content; do
    if echo "$content" | grep -qE '#[0-9a-fA-F]{3,8}'; then
      violation "$file" "$line" "hex-hardcoded" "use var(--color-*) em vez de hex"
    fi
  done
}
```

Adicionar `_rule_no_hex "$file"` no loop de `run_front`.

- [ ] **Step 4: Rodar — todos passam**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: `Total: PASS=7 FAIL=0`.

- [ ] **Step 5: Commit**

```bash
git add ia/tools/tests/fixtures/front/hex-bad.html ia/tools/tests/run-tests.sh ia/tools/validar-doc.sh
git commit -m "feat(validador): regra --front sem hex hardcoded fora de classDef"
```

### Task B5: TDD — regra `--front` resíduo do exemplo fictício (forbidden-terms)

**Files:**
- Create: `ia/tools/tests/fixtures/front/forbidden-bad.html`
- Modify: `ia/tools/tests/run-tests.sh`
- Modify: `ia/tools/validar-doc.sh`

- [ ] **Step 1: Fixture inválida**

`ia/tools/tests/fixtures/front/forbidden-bad.html`:

```html
<!doctype html>
<html lang="pt-BR"><head>
<meta charset="utf-8"><title>X</title>
<script src="../templates/prefs.js"></script>
<link rel="stylesheet" href="../design-system/tokens.css">
<link rel="stylesheet" href="../design-system/components.css">
</head><body><div class="shell"><aside class="sidebar"></aside><main class="main">
<h1 class="hero__title">Sistema de Liquidação Transacional</h1>
</main></div></body></html>
```

- [ ] **Step 2: Adicionar caso**

```bash
run_case "front: forbidden term = FAIL" "ia/tools/tests/fixtures/front/forbidden-bad.html" "--front" 1 "forbidden-term.*Liquida"
```

- [ ] **Step 3: Implementar a regra**

```bash
_rule_forbidden_terms() {
  local file="$1" terms term line
  [ -f "$LIB_DIR/forbidden-terms.txt" ] || return 0
  terms=$(grep -vE '^(#|$)' "$LIB_DIR/forbidden-terms.txt")
  while IFS= read -r term; do
    [ -z "$term" ] && continue
    # case-insensitive substring; ignora linhas dentro de <script>
    while IFS=: read -r line _; do
      violation "$file" "$line" "forbidden-term" "encontrou '$term' (lista: forbidden-terms.txt)"
    done < <(grep -niF "$term" "$file" | grep -vE '<script')
  done <<<"$terms"
}
```

Adicionar `_rule_forbidden_terms "$file"` no loop de `run_front`.

- [ ] **Step 4: Rodar**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: `Total: PASS=8 FAIL=0`.

- [ ] **Step 5: Commit**

```bash
git add ia/tools/tests/fixtures/front/forbidden-bad.html ia/tools/tests/run-tests.sh ia/tools/validar-doc.sh
git commit -m "feat(validador): regra --front resíduo do exemplo ficticio"
```

### Task B6: TDD — regra `--front` NAV órfão (página sem entry em sidebar.js)

**Files:**
- Create: `ia/tools/tests/fixtures/front/nav-good/index.html`
- Create: `ia/tools/tests/fixtures/front/nav-good/sidebar.js`
- Create: `ia/tools/tests/fixtures/front/nav-bad/index.html`
- Create: `ia/tools/tests/fixtures/front/nav-bad/orfa.html`
- Create: `ia/tools/tests/fixtures/front/nav-bad/sidebar.js`
- Modify: `ia/tools/tests/run-tests.sh`
- Modify: `ia/tools/validar-doc.sh`

- [ ] **Step 1: Fixture VÁLIDA — pasta com `index.html` listado em `sidebar.js`**

`ia/tools/tests/fixtures/front/nav-good/index.html`: cabeça mínima válida:

```html
<!doctype html><html lang="pt-BR"><head>
<meta charset="utf-8"><title>Início</title>
<script src="../templates/prefs.js"></script>
<link rel="stylesheet" href="../design-system/tokens.css">
<link rel="stylesheet" href="../design-system/components.css">
</head><body><div class="shell"><aside class="sidebar"></aside><main class="main"></main></div></body></html>
```

`ia/tools/tests/fixtures/front/nav-good/sidebar.js`:

```js
const NAV = { sections: [ { title: "X", items: [ { label: "Início", href: "index.html" } ] } ] };
```

- [ ] **Step 2: Fixture INVÁLIDA — `orfa.html` existe mas não está no NAV**

`ia/tools/tests/fixtures/front/nav-bad/index.html`: igual ao válido.

`ia/tools/tests/fixtures/front/nav-bad/orfa.html`:

```html
<!doctype html><html lang="pt-BR"><head>
<meta charset="utf-8"><title>Órfã</title>
<script src="../templates/prefs.js"></script>
<link rel="stylesheet" href="../design-system/tokens.css">
<link rel="stylesheet" href="../design-system/components.css">
</head><body><div class="shell"><aside class="sidebar"></aside><main class="main"></main></div></body></html>
```

`ia/tools/tests/fixtures/front/nav-bad/sidebar.js`: idêntica à do good (NAV não cita `orfa.html`).

- [ ] **Step 3: Adicionar casos**

```bash
run_case "front: NAV completo (pasta)" "ia/tools/tests/fixtures/front/nav-good" "--front" 0 ""
run_case "front: pagina orfa = FAIL"   "ia/tools/tests/fixtures/front/nav-bad"  "--front" 1 "nav-orfa.*orfa.html"
```

- [ ] **Step 4: Implementar a regra (só roda quando TARGET é pasta com `sidebar.js`)**

Adicionar antes de `run_front()`:

```bash
_rule_nav_orphan() {
  local dir="$1" sidebar pages page base
  sidebar="$dir/sidebar.js"
  [ -f "$sidebar" ] || return 0
  pages=$(find "$dir" -maxdepth 1 -name '*.html' -type f)
  while IFS= read -r page; do
    [ -z "$page" ] && continue
    base=$(basename "$page")
    if ! grep -qE "href:[[:space:]]*\"$base\"" "$sidebar"; then
      violation "$page" 1 "nav-orfa" "arquivo $base nao tem entry no NAV em sidebar.js"
    fi
  done <<<"$pages"
}
```

Em `run_front`, chamar `_rule_nav_orphan "$target"` ANTES do loop por arquivo (vale só pra pasta — se `target` é arquivo, a função retorna sem fazer nada quando não acha `sidebar.js`).

- [ ] **Step 5: Rodar**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: `Total: PASS=10 FAIL=0`.

- [ ] **Step 6: Commit**

```bash
git add ia/tools/tests/fixtures/front/nav-good ia/tools/tests/fixtures/front/nav-bad ia/tools/tests/run-tests.sh ia/tools/validar-doc.sh
git commit -m "feat(validador): regra --front pagina orfa do NAV (sidebar.js)"
```

### Task B7: TDD — regra `--mermaid` pareamento data-diagram ↔ data-id

**Files:**
- Create: `ia/tools/tests/fixtures/mermaid/ok-pair.html`
- Create: `ia/tools/tests/fixtures/mermaid/bad-pair.html`
- Modify: `ia/tools/tests/run-tests.sh`
- Modify: `ia/tools/validar-doc.sh`

- [ ] **Step 1: Fixture VÁLIDA — par 1:1**

`ia/tools/tests/fixtures/mermaid/ok-pair.html`:

```html
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><title>OK</title></head>
<body>
<figure class="diagram-figure"><div class="diagram-viewer" data-diagram="d1"></div></figure>
<script type="text/mermaid" data-id="d1">
flowchart LR
classDef person   fill:#1c4e93,stroke:#0a0c12,color:#ffffff,stroke-width:2px
classDef sys      fill:#4a8fe7,stroke:#0a0c12,color:#ffffff,stroke-width:2.5px
classDef ext      fill:#ffffff,stroke:#1f2937,color:#0a0c12,stroke-width:1.5px
classDef extAsync fill:#f9fafb,stroke:#6b7280,color:#0a0c12,stroke-width:1.5px,stroke-dasharray:5 3
A:::sys --> B:::ext
</script>
</body></html>
```

- [ ] **Step 2: Fixture INVÁLIDA — `data-diagram` sem script correspondente**

`ia/tools/tests/fixtures/mermaid/bad-pair.html`:

```html
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><title>BAD</title></head>
<body>
<figure class="diagram-figure"><div class="diagram-viewer" data-diagram="orphan"></div></figure>
</body></html>
```

- [ ] **Step 3: Adicionar casos**

```bash
run_case "mermaid: par OK"                 "ia/tools/tests/fixtures/mermaid/ok-pair.html"  "--mermaid" 0 ""
run_case "mermaid: data-diagram sem par"   "ia/tools/tests/fixtures/mermaid/bad-pair.html" "--mermaid" 1 "mermaid-pair.*orphan"
```

- [ ] **Step 4: Implementar a regra em `run_mermaid`**

Substituir `run_mermaid() { :; }` por:

```bash
_rule_mermaid_pair() {
  local file="$1" id line
  while IFS= read -r line; do
    id=$(echo "$line" | sed -E 's/.*data-diagram="([^"]+)".*/\1/')
    if ! grep -qE "type=\"text/mermaid\"[^>]*data-id=\"$id\"" "$file"; then
      local n
      n=$(grep -nE "data-diagram=\"$id\"" "$file" | head -1 | cut -d: -f1)
      violation "$file" "$n" "mermaid-pair" "data-diagram=\"$id\" sem script[type=text/mermaid][data-id=\"$id\"] correspondente"
    fi
  done < <(grep -E 'data-diagram="[^"]+"' "$file")
}

run_mermaid() {
  local target="$1" file
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    _rule_mermaid_pair "$file"
  done < <(_iter_html "$target")
}
```

- [ ] **Step 5: Rodar**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: `Total: PASS=12 FAIL=0`.

- [ ] **Step 6: Commit**

```bash
git add ia/tools/tests/fixtures/mermaid/ok-pair.html ia/tools/tests/fixtures/mermaid/bad-pair.html ia/tools/tests/run-tests.sh ia/tools/validar-doc.sh
git commit -m "feat(validador): regra --mermaid pareamento data-diagram <-> data-id"
```

### Task B8: TDD — regra `--mermaid` tipo válido na 1ª linha

**Files:**
- Create: `ia/tools/tests/fixtures/mermaid/bad-type.html`
- Modify: `ia/tools/tests/run-tests.sh`
- Modify: `ia/tools/validar-doc.sh`

- [ ] **Step 1: Fixture inválida (1ª linha = `graph TD`, banido)**

`ia/tools/tests/fixtures/mermaid/bad-type.html`:

```html
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><title>BAD</title></head>
<body>
<figure class="diagram-figure"><div class="diagram-viewer" data-diagram="x"></div></figure>
<script type="text/mermaid" data-id="x">
graph TD
A --> B
</script>
</body></html>
```

- [ ] **Step 2: Caso**

```bash
run_case "mermaid: tipo invalido = FAIL" "ia/tools/tests/fixtures/mermaid/bad-type.html" "--mermaid" 1 "mermaid-type"
```

- [ ] **Step 3: Implementar**

Adicionar antes do `run_mermaid`:

```bash
_rule_mermaid_type() {
  local file="$1"
  awk '
    /<script[^>]*text\/mermaid/ { inm=1; first=1; line=NR; next }
    /<\/script>/                { inm=0; next }
    inm && first && /^[[:space:]]*$/ { next }
    inm && first {
      gsub(/^[[:space:]]+|[[:space:]]+$/,"",$0)
      if ($0 !~ /^(flowchart|sequenceDiagram|classDiagram|stateDiagram-v2|erDiagram)/) {
        print line":mermaid-type:1a linha invalida (use flowchart|sequenceDiagram|classDiagram|stateDiagram-v2|erDiagram): "$0
      }
      first=0
    }
  ' "$file" | while IFS=: read -r ln rule rest; do
    violation "$file" "$ln" "$rule" "$rest"
  done
}
```

Adicionar `_rule_mermaid_type "$file"` no loop de `run_mermaid`.

- [ ] **Step 4: Rodar**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: `Total: PASS=13 FAIL=0`.

- [ ] **Step 5: Commit**

```bash
git add ia/tools/tests/fixtures/mermaid/bad-type.html ia/tools/tests/run-tests.sh ia/tools/validar-doc.sh
git commit -m "feat(validador): regra --mermaid tipo valido na 1a linha"
```

### Task B9: TDD — regra `--mermaid` 4 classDef obrigatórios

**Files:**
- Create: `ia/tools/tests/fixtures/mermaid/missing-classdef.html`
- Modify: `ia/tools/tests/run-tests.sh`
- Modify: `ia/tools/validar-doc.sh`

- [ ] **Step 1: Fixture inválida (faltando `extAsync`)**

`ia/tools/tests/fixtures/mermaid/missing-classdef.html`:

```html
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><title>X</title></head>
<body>
<figure class="diagram-figure"><div class="diagram-viewer" data-diagram="x"></div></figure>
<script type="text/mermaid" data-id="x">
flowchart LR
classDef person   fill:#1c4e93,stroke:#0a0c12,color:#ffffff,stroke-width:2px
classDef sys      fill:#4a8fe7,stroke:#0a0c12,color:#ffffff,stroke-width:2.5px
classDef ext      fill:#ffffff,stroke:#1f2937,color:#0a0c12,stroke-width:1.5px
A --> B
</script>
</body></html>
```

- [ ] **Step 2: Caso**

```bash
run_case "mermaid: falta classDef = FAIL" "ia/tools/tests/fixtures/mermaid/missing-classdef.html" "--mermaid" 1 "mermaid-classdef.*extAsync"
```

- [ ] **Step 3: Implementar (lê de mermaid-classdefs.txt; só verifica `flowchart`)**

```bash
_rule_mermaid_classdefs() {
  local file="$1" need=("person" "sys" "ext" "extAsync") name found block_line
  # Bloco mermaid em flowchart precisa dos 4 classDef. Para sequenceDiagram, regra nao aplica.
  awk '
    /<script[^>]*text\/mermaid/ { inm=1; buf=""; line=NR; next }
    /<\/script>/                { if(inm){ print line"\037"buf }; inm=0; next }
    inm                          { buf=buf"\n"$0 }
  ' "$file" | while IFS=$'\037' read -r block_line block; do
    [ -z "$block" ] && continue
    # so flowchart exige os 4 classDef
    echo "$block" | grep -qE '^[[:space:]]*flowchart' || continue
    for name in "${need[@]}"; do
      if ! echo "$block" | grep -qE "^[[:space:]]*classDef[[:space:]]+$name[[:space:]]"; then
        violation "$file" "$block_line" "mermaid-classdef" "falta classDef $name no bloco (ver mermaid-classdefs.txt)"
      fi
    done
  done
}
```

Adicionar `_rule_mermaid_classdefs "$file"` no loop.

- [ ] **Step 4: Rodar**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: `Total: PASS=14 FAIL=0`.

- [ ] **Step 5: Commit**

```bash
git add ia/tools/tests/fixtures/mermaid/missing-classdef.html ia/tools/tests/run-tests.sh ia/tools/validar-doc.sh
git commit -m "feat(validador): regra --mermaid 4 classDef obrigatorios em flowchart"
```

### Task B10: TDD — regra `--mermaid` autonumber em sequenceDiagram + suite `--all`

**Files:**
- Create: `ia/tools/tests/fixtures/mermaid/seq-no-autonum.html`
- Create: `ia/tools/tests/fixtures/mermaid/seq-ok.html`
- Modify: `ia/tools/tests/run-tests.sh`
- Modify: `ia/tools/validar-doc.sh`

- [ ] **Step 1: Fixture inválida (sequenceDiagram sem autonumber)**

`ia/tools/tests/fixtures/mermaid/seq-no-autonum.html`:

```html
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><title>X</title></head>
<body>
<figure class="diagram-figure"><div class="diagram-viewer" data-diagram="s1"></div></figure>
<script type="text/mermaid" data-id="s1">
sequenceDiagram
A->>B: hi
</script>
</body></html>
```

- [ ] **Step 2: Fixture válida**

`ia/tools/tests/fixtures/mermaid/seq-ok.html`:

```html
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><title>OK</title></head>
<body>
<figure class="diagram-figure"><div class="diagram-viewer" data-diagram="s1"></div></figure>
<script type="text/mermaid" data-id="s1">
sequenceDiagram
autonumber
A->>B: hi
</script>
</body></html>
```

- [ ] **Step 3: Casos (incluindo `--all` sobre a pasta `fixtures/mermaid`)**

```bash
run_case "mermaid: seq sem autonumber = FAIL" "ia/tools/tests/fixtures/mermaid/seq-no-autonum.html" "--mermaid" 1 "mermaid-autonumber"
run_case "mermaid: seq com autonumber"         "ia/tools/tests/fixtures/mermaid/seq-ok.html"          "--mermaid" 0 ""
run_case "all: pasta com mistura = FAIL"       "ia/tools/tests/fixtures/mermaid"                       "--all"     1 "mermaid-"
```

- [ ] **Step 4: Implementar**

```bash
_rule_mermaid_autonumber() {
  local file="$1" block_line block
  awk '
    /<script[^>]*text\/mermaid/ { inm=1; buf=""; line=NR; next }
    /<\/script>/                { if(inm){ print line"\037"buf }; inm=0; next }
    inm                          { buf=buf"\n"$0 }
  ' "$file" | while IFS=$'\037' read -r block_line block; do
    [ -z "$block" ] && continue
    echo "$block" | grep -qE '^[[:space:]]*sequenceDiagram' || continue
    if ! echo "$block" | grep -qE '^[[:space:]]*autonumber'; then
      violation "$file" "$block_line" "mermaid-autonumber" "sequenceDiagram sem 'autonumber' (regra binaria: sempre)"
    fi
  done
}
```

Adicionar `_rule_mermaid_autonumber "$file"` no loop.

- [ ] **Step 5: Rodar suite final**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: `Total: PASS=17 FAIL=0`.

- [ ] **Step 6: Commit**

```bash
git add ia/tools/tests/fixtures/mermaid/seq-no-autonum.html ia/tools/tests/fixtures/mermaid/seq-ok.html ia/tools/tests/run-tests.sh ia/tools/validar-doc.sh
git commit -m "feat(validador): regra --mermaid autonumber + suite --all"
```

### Task B11: README do validar-doc.sh + entrada no `ia/tools/manifest.tsv`? (NÃO)

**Files:**
- Create: `ia/tools/README-validar-doc.md`

> Nota: `validar-doc.sh` é **ferramenta de manutenção do pack**, não é um prompt — NÃO entra no `manifest.tsv` (que dirige só prompts/skills). Não vai pro alvo via installer (installer só copia `ia/tools/sync-*` e o `lib/`+script só por **referência** dos validadores). Conferir no §A4 do plano de execução.

- [ ] **Step 1: Escrever README curto**

Conteúdo de `ia/tools/README-validar-doc.md`:

```markdown
# validar-doc.sh — lint estrutural da doc gerada

Camada determinística opcional dos validadores #6 (front/template) e #7 (sintaxe/Mermaid)
da trilha de arquitetura (spec: doc/specs/2026-06-19-pipeline-arquitetura-v2-design.md).

## Uso

    bash ia/tools/validar-doc.sh <pasta> [--front | --mermaid | --all]

`<pasta>` é tipicamente `doc/arquitetura/`. Aceita também caminho de arquivo único.

| Flag       | O que verifica |
|------------|---------------|
| `--front`   | Vocabulário fechado de classes, ordem do `<head>`, cor hex hardcoded, NAV órfão, resíduo do exemplo |
| `--mermaid` | Pareamento `data-diagram`↔`data-id`, tipo válido na 1ª linha, 4 `classDef`, `autonumber` em sequence |
| `--all`     | Roda os dois |

## Exit codes

- `0` clean
- `1` violações (lista no stdout, formato `arquivo:linha:regra: descrição`)
- `2` erro de uso ou ambiente sem dep opcional (fallback gracioso)

## Fontes (SoT)

Editáveis em `ia/tools/lib/`:
- `design-system-classes.txt` — vocabulário fechado.
- `mermaid-classdefs.txt` — 4 classDef com hex exatos.
- `forbidden-terms.txt` — termos proibidos do exemplo fictício.

## Testes

    bash ia/tools/tests/run-tests.sh

Suite com fixtures válidas e inválidas em `ia/tools/tests/fixtures/`.
```

- [ ] **Step 2: Commit**

```bash
git add ia/tools/README-validar-doc.md
git commit -m "docs(validador): README do validar-doc.sh (uso, exit codes, SoT)"
```

---

## Fase C — Prompts novos (`validador-visual`, `validador-sintaxe-mermaid`, `atualizador-arquitetura`)

### Task C1: Criar `ia/prompts/arquitetura/validador-visual.md`

**Files:**
- Create: `ia/prompts/arquitetura/validador-visual.md`

- [ ] **Step 1: Conteúdo do prompt**

```markdown
# Validador Visual — front/template (Etapa 6/7)

**STATUS — leia ANTES de responder:**
- Esta é a **Etapa 6 de 7** da trilha de doc de arquitetura. Roda em **sessão própria** (regra master).
- Você é um validador: **só REPORTA**, nunca edita os HTML. Correções voltam para o gerador (Etapas 2/3/4) ou para o `atualizador-arquitetura`.
- Saída obrigatória: o **checklist canônico** (formato em `ia/templates/checklist-validador.md`) **logo no início da resposta**, com PASS/FAIL/N-A por regra e evidência `arquivo:linha`. Sem o bloco, a etapa não conta como concluída.
- Próximo passo (handoff): Etapa 7 — `validador-sintaxe-mermaid`.

## O que você valida (alvo: `doc/arquitetura/`)

As 3 dimensões refletem os 3 MUSTs do template (spec §5.1).

### 5.1.1 Navegabilidade (DEVE ser navegável)
- Cada `.html` em `doc/arquitetura/` tem entry `{label, href}` na seção certa do `NAV` em `sidebar.js`.
- Todo `href` no `NAV` resolve para arquivo existente (sem entries órfãs inversas).

### 5.1.2 Estilo visual (DEVE seguir)
- `<head>` na ordem fixa: `meta charset` → `meta viewport` → `title` → `meta description` → `script src="../templates/prefs.js"` → `link tokens.css` → `link components.css`.
- Body em `div.shell > aside#sidebar.sidebar + main#main.main`.
- Toda classe usada está em `ia/tools/lib/design-system-classes.txt` (fonte única). Lista fechada — classe nova = rejeita.
- Toda cor de UI via `var(--color-*)`. Zero hex hardcoded fora de `classDef` Mermaid.
- Scripts finais: `sidebar.js` sempre; `diagram-viewer.js` apenas se houver diagrama; classic script (nunca `type=module`).

### 5.1.3 Regras de UI/UX (DEVE obedecer)
- Cabeçalho de seção SEMPRE `h2.section-eyebrow`; subseção `h3`; texto `p.prose`.
- Página de conteúdo abre com `nav.breadcrumb + header.hero` (`hero__eyebrow`, `hero__title` com `span.accent-word`, `hero__subtitle`).
- Diagrama: padrão 2 partes (`figure.diagram-figure > div.diagram-viewer[data-diagram=ID]` + `script[type=text/mermaid][data-id=ID]`, pareados 1:1).
- Sem resíduo do exemplo: lista em `ia/tools/lib/forbidden-terms.txt` (case-insensitive substring).

**NÃO é violação:** quantidade de seções ou páginas — quebrar para evitar HTML extenso é incentivado.

## Como você opera

1. Comece a resposta com o **bloco de checklist canônico** (template em `ia/templates/checklist-validador.md`).
2. Tente **uma vez** rodar a camada determinística: `bash ia/tools/validar-doc.sh doc/arquitetura/ --front`.
   - exit 0 → preencha PASS no checklist e cole nada na seção "Violações".
   - exit 1 → marque FAIL nas regras correspondentes e cole as linhas do stdout em "Violações".
   - exit 2 ou comando indisponível → registre "modo fallback" e preencha o checklist por leitura direta dos arquivos. **Não pergunte ao usuário**; não bloqueie a etapa.
3. Veredito final: `PASS` (zero FAIL) ou `FAIL` com lista de violações `arquivo:linha`.
4. Não edite nenhum arquivo. Aponte qual etapa ou o `atualizador-arquitetura` deve aplicar.

## Handoff

> Etapa 6/7 concluída. Próxima sessão: `validador-sintaxe-mermaid` (Etapa 7/7) — abra uma nova sessão.
```

- [ ] **Step 2: Verificar referências internas**

Run: `grep -nE 'ia/tools/lib/|ia/templates/checklist-validador.md|validar-doc.sh' ia/prompts/arquitetura/validador-visual.md`
Expected: pelo menos 4 referências (cada arquivo citado).

- [ ] **Step 3: Commit**

```bash
git add ia/prompts/arquitetura/validador-visual.md
git commit -m "feat(prompt): validador-visual (Etapa 6/7) — front/template, so reporta"
```

### Task C2: Criar `ia/prompts/arquitetura/validador-sintaxe-mermaid.md`

**Files:**
- Create: `ia/prompts/arquitetura/validador-sintaxe-mermaid.md`

- [ ] **Step 1: Conteúdo**

```markdown
# Validador Sintaxe + Mermaid (Etapa 7/7)

**STATUS — leia ANTES de responder:**
- Esta é a **Etapa 7 de 7** da trilha de doc de arquitetura. Última etapa. Roda em **sessão própria** (regra master).
- Você é um validador: **só REPORTA**, nunca edita. Correções voltam para o gerador (Etapas 2/3/4) ou para o `atualizador-arquitetura`.
- Saída obrigatória: o **checklist canônico** (`ia/templates/checklist-validador.md`) no início da resposta com PASS/FAIL/N-A + evidência.
- Próximo passo (handoff): FIM. A trilha 1→7 está completa.

## O que você valida (alvo: `doc/arquitetura/`)

Mira as regras de §5.2 do spec.

- **Pareamento:** todo `div.diagram-viewer[data-diagram=X]` tem `script[type=text/mermaid][data-id=X]` correspondente (1:1).
- **Tipo válido na 1ª linha** do bloco mermaid: `flowchart`, `sequenceDiagram`, `classDiagram`, `stateDiagram-v2` ou `erDiagram`. `graph TD/LR` (legado) e `C4Context` (instável) são REJEITADOS.
- **4 `classDef` obrigatórios** em todo `flowchart`, com hex exatos lidos de `ia/tools/lib/mermaid-classdefs.txt`: `person`, `sys`, `ext`, `extAsync`.
- **Labels:** entre aspas quando contêm espaço/pontuação; sem `<` `>` crus (use `&gt;` / `&lt;`); sem `\n` dentro de label.
- **Sequence diagram:** `autonumber` SEMPRE (regra binária — sem exceção) logo após `sequenceDiagram`.
- **Tipografia Butterick** (`frontend-style.md` §7, linhas 205-241): aspas tipográficas, em/en dash, reticências (`…`), sinal de multiplicação (`×`), `≥`/`≤`, número PT-BR `1.234,56` onde aplicável.

## Como você opera

1. Comece com o **bloco de checklist canônico**.
2. Tente uma vez: `bash ia/tools/validar-doc.sh doc/arquitetura/ --mermaid`.
   - exit 0 → PASS; exit 1 → FAIL + linhas do stdout; exit 2 ou indisponível → fallback (leia direto), sem perguntar.
3. Veredito final + lista de violações `arquivo:linha`.
4. Não edite. Aponte qual prompt gerador (Etapas 2/3/4) ou o `atualizador-arquitetura` deve aplicar.

## Handoff

> Etapa 7/7 concluída. Trilha completa. Se houver FAILs, rode o prompt apontado em "Violações" para corrigir.
```

- [ ] **Step 2: Verificar**

Run: `grep -nE 'mermaid-classdefs|--mermaid|frontend-style.md' ia/prompts/arquitetura/validador-sintaxe-mermaid.md`
Expected: ao menos 3 referências.

- [ ] **Step 3: Commit**

```bash
git add ia/prompts/arquitetura/validador-sintaxe-mermaid.md
git commit -m "feat(prompt): validador-sintaxe-mermaid (Etapa 7/7) — so reporta"
```

### Task C3: Criar `ia/prompts/arquitetura/atualizador-arquitetura.md`

**Files:**
- Create: `ia/prompts/arquitetura/atualizador-arquitetura.md`

- [ ] **Step 1: Conteúdo**

```markdown
# Atualizador de Arquitetura (complementar — doc já existente)

**STATUS — leia ANTES de responder:**
- Este prompt é **complementar** (fora da trilha numerada 1→7). Use-o em **doc já existente** que precisa ser conformada às novas regras (v2).
- Roda em **sessão própria** (regra master).
- Abre **1 task de controle por execução** cobrindo toda a pasta `doc/arquitetura/` analisada (decisão #10 do spec).
- Diferente dos validadores #6/#7: o atualizador **pode editar** (é quem aplica correções de drift de front in-place).

## Pré-requisito (uma vez por execução)

Abra a task de controle ANTES de editar qualquer artefato. Derive um slug kebab-case (ex.: `atualizar-doc-arquitetura`), monte o task-id `AAAA-MM-DD-<slug>` e crie:
- `doc/controle/<task-id>/TASK.md` (escopo + ACs + checklist).
- `doc/controle/<task-id>/QA.md` (vazio com o cabeçalho do template — preenchido na hora em cada pergunta respondida).
- `doc/controle/<task-id>/LEDGER.md` (decisões + evidências, ao final).

## O que você faz

Ordem proposta (coerente com a ramificação aprovada em QA.md verbatim):

1. **Diagnóstico geral** — varra `doc/arquitetura/` e classifique cada problema encontrado por tipo:
   - **Drift de FRONT (UI/UX / template / classes / Mermaid / NAV / resíduo do exemplo).**
   - **Drift LÓGICO (arquitetural — incertezas, garantias não resolvidas, lacuna de conteúdo).**

2. **Compara com template** — `ia/templates/01-visao-geral.html` (página de conteúdo) e `index.html` (landing) são o gabarito de FORMA.

3. **Roda validadores embutidos** — execute internamente as regras de §5.1 (front) e §5.2 (mermaid). Tente:
   - `bash ia/tools/validar-doc.sh doc/arquitetura/ --all`
   - exit 0 → nenhum drift de front; exit 1 → use o stdout como lista de correções; exit 2 ou indisponível → fallback (leia direto).

4. **Ramifica por tipo** (verbatim QA.md):
   - **Drift de FRONT** → escreva um **plano de ajuste** como seção `## Plano de ajuste de front` no `TASK.md` da task, depois **CONFORME in-place** (você está autorizado a editar). Após cada correção, marque `[x]` no checklist do TASK.md.
   - **Drift LÓGICO** → abra um **grill** (use o protocolo de `grill-arquitetura.md`): pergunta-uma-por-vez ao usuário. Para CADA pergunta, **apenda no QA.md no mesmo turno** em que a resposta chega (status vivo). Verbatim quando houver decisão; normalizada caso contrário (formato em `controle-de-tarefa.md`).

5. **Verificação final** — re-rode `validar-doc.sh --all`; só feche a task com exit 0 (ou checklist textual sem FAILs).

## Saídas

- Edições in-place em `doc/arquitetura/*.html` (drift de front).
- `doc/controle/<task-id>/TASK.md` com fase=concluida e checklist marcado.
- `doc/controle/<task-id>/QA.md` com todo o grilling.
- `doc/controle/<task-id>/LEDGER.md` com decisões + evidências.

## NÃO faz

- Não gera páginas novas do zero (isso é a trilha 1→7).
- Não move arquivos entre pastas sem grilling.
- Não pergunta o slug — derive do pedido.
```

- [ ] **Step 2: Verificar**

Run: `grep -nE '1 task de controle por execução|QA.md|validar-doc.sh' ia/prompts/arquitetura/atualizador-arquitetura.md | wc -l | tr -d ' '`
Expected: ≥ 3.

- [ ] **Step 3: Commit**

```bash
git add ia/prompts/arquitetura/atualizador-arquitetura.md
git commit -m "feat(prompt): atualizador-arquitetura (complementar; doc existente; 1 task por execucao)"
```

---

## Fase D — Manifest + sync

### Task D1: Editar `ia/tools/manifest.tsv` (delete + reescrever + renumber + +3)

**Files:**
- Modify: `ia/tools/manifest.tsv`

- [ ] **Step 1: Snapshot do estado atual**

Run: `grep -nE '^(documentar-servico|completar-documentacao|grill-arquitetura|arquiteto-de-sistema|documentador-fluxo|gerador-runbook)\b' ia/tools/manifest.tsv`
Expected: linhas atuais (rótulos `Etapa N de 3` em 27/28/29). Anote-as.

- [ ] **Step 2: Aplicar as 4 operações**

Use Edit/Write para deixar o manifest.tsv assim (4 operações combinadas: deletar `completar-documentacao`, reescrever descrição de `documentar-servico` como índice, renumerar `grill-arquitetura` para 5/7, adicionar 3 linhas novas; renumerar etapas 2-4 nos rótulos correspondentes):

- Linha de `documentar-servico` (atual: Etapa 1 de 3): vira:

```
documentar-servico	arquitetura	Indice da trilha de 7 etapas (8 sessoes — Etapa 1 = 2 sessoes). Aponta as etapas 1-7 em sequencia; cada prompt em sessao propria; NAO orquestra (deprecado o atalho anterior)
```

- Linha de `completar-documentacao` (atual: Etapa 2 de 3): **DELETAR**.

- Linha de `grill-arquitetura` (atual: Etapa 3 de 3): vira:

```
grill-arquitetura	arquitetura	Etapa 5/7: grill intenso codigo-primeiro sobre a doc gerada — cada incerteza resolvida pelo codigo (com nivel de certeza) ou perguntada ao humano; respostas apendadas no QA.md no mesmo turno
```

- Linhas de `arquiteto-de-sistema`, `documentador-fluxo`, `gerador-runbook`: **garantir** que a descrição comece com `Etapa N/7:` (renumerar quem hoje diga `Etapa N de 3` se houver; senão prefixar):

```
arquiteto-de-sistema	arquitetura	Etapa 2/7: arquitetura/espinha (5 perguntas-ancora + grill + paginas-nucleo). Cada pagina criada em doc/arquitetura/ + entry no NAV de sidebar.js no mesmo passo
documentador-fluxo	arquitetura	Etapa 3/7: pagina(s) de fluxo critico em doc/arquitetura/ (sequenceDiagram com autonumber). Apenda entry no NAV de sidebar.js
gerador-runbook	arquitetura	Etapa 4/7: doc/arquitetura/runbook.html (4 campos obrigatorios por failure mode, nada inventado). Apenda entry no NAV de sidebar.js
```

- **Adicionar 3 linhas novas** (qualquer posição na seção arquitetura):

```
validador-visual	arquitetura	Etapa 6/7: validador visual/template (so reporta; checklist canonico + ia/tools/validar-doc.sh --front opcional). Verifica navegabilidade, esqueleto, vocabulario fechado de classes, cores via var(--color-*), forbidden-terms
validador-sintaxe-mermaid	arquitetura	Etapa 7/7: validador sintaxe + Mermaid (so reporta; checklist canonico + ia/tools/validar-doc.sh --mermaid opcional). Pareamento data-id, tipo valido, 4 classDef, autonumber sempre em sequence
atualizador-arquitetura	arquitetura	Complementar (fora da trilha 1-7): conforma doc ja existente em doc/arquitetura/ as regras v2. Diagnostica, ramifica (front->plano+aplica; logico->grill+QA.md), 1 task de controle por execucao
```

- [ ] **Step 3: Verificar contagem**

Run:
```bash
echo "arquitetura: $(awk -F'\t' '$2=="arquitetura"{c++} END{print c}' ia/tools/manifest.tsv)"
echo "total entries:  $(awk -F'\t' '$1!=""&&$1!~/^#/{c++} END{print c}' ia/tools/manifest.tsv)"
```
Expected: `arquitetura: 13`, `total entries: 32` (era 11+30 → agora 13+32 = +3 −1).

- [ ] **Step 4: Commit (ainda SEM rodar sync — os .md novos já existem da Fase C, mas a próxima task vai consolidar)**

```bash
git add ia/tools/manifest.tsv
git commit -m "refactor(manifest): trilha arquitetura 3->7 etapas + atualizador complementar"
```

### Task D2: Deletar `completar-documentacao.md`, regenerar mirrors, validar 3× `--check`

**Files:**
- Delete: `ia/prompts/arquitetura/completar-documentacao.md`
- Modify (regenerado): `.github/prompts/*.prompt.md`, `.github/skills/*/SKILL.md`, `.kiro/skills/*/SKILL.md`

- [ ] **Step 1: Deletar o canônico aposentado**

Run: `git rm ia/prompts/arquitetura/completar-documentacao.md`

- [ ] **Step 2: Regenerar mirrors (Copilot + Kiro)**

Run:
```bash
bash ia/tools/sync-copilot.sh
bash ia/tools/sync-kiro.sh
```
Expected: cada um termina com `Mirrors regenerados.` (ou linguagem equivalente).

- [ ] **Step 3: Verificar contagem de wrappers**

Run:
```bash
echo "github/prompts: $(ls .github/prompts/*.prompt.md 2>/dev/null | wc -l | tr -d ' ')"
echo "github/skills wrappers (slugs no manifest): $(awk -F'\t' '$1!=""&&$1!~/^#/{c++} END{print c}' ia/tools/manifest.tsv)"
echo "kiro/skills:    $(find .kiro/skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
```
Expected:
- `github/prompts: 32`
- `github/skills wrappers: 32`
- `kiro/skills: 64` (32 wrappers + 32 importadas)

> Se `completar-documentacao` ainda existir como wrapper em `.github/prompts/` ou `.kiro/skills/`, é porque os scripts de sync não fazem `--prune`. Nesse caso:
> Run: `rm -f .github/prompts/completar-documentacao.prompt.md && rm -rf .github/skills/completar-documentacao .kiro/skills/completar-documentacao`
> e re-rode os syncs.

- [ ] **Step 4: 3× `--check`**

Run:
```bash
bash ia/tools/sync-copilot.sh   --check
bash ia/tools/sync-kiro.sh      --check
bash ia/tools/sync-como-usar.sh --check
```
Expected: 3 × `OK: ... em sincronia com o canonico.` (exit 0 cada).

- [ ] **Step 5: Commit (mirrors + delete num único commit lógico)**

```bash
git add -A
git commit -m "feat(pack): aposenta completar-documentacao + sync mirrors (Copilot + Kiro)"
```

---

## Fase E — Handoffs nos prompts existentes

Cada prompt da cadeia ganha 3 mudanças padronizadas:
1. **STATUS de topo** menciona o número Etapa N/7 + regra "sessão própria".
2. **Handoff em prosa** ao final aponta o nome do próximo prompt.
3. **(Apenas para etapas que geram `.html` — 2/3/4)** bullet de saída obrigatória: "apendar entry no NAV de `sidebar.js`".
4. **(Apenas para prompts da Etapa 1 e o grill)** regra de **apendar Q&A no QA.md no mesmo turno** (status vivo).

### Task E1: Repropósito de `documentar-servico.md` como ÍNDICE da trilha

**Files:**
- Modify: `ia/prompts/arquitetura/documentar-servico.md` (rewrite)

- [ ] **Step 1: Reescrever inteiro como índice**

Conteúdo:

```markdown
# Índice da trilha de doc de arquitetura — 7 etapas, 8 sessões

**LEIA ESTE BLOCO ANTES DE QUALQUER COISA:**

- A trilha de doc de arquitetura são **7 etapas conceituais** correspondendo a **8 sessões** (Etapa 1 tem 2 sessões).
- **Rode TODAS na ordem 1→7, cada PROMPT em sessão própria** (regra master).
- Este prompt **não orquestra** — ele é só o índice + handoff inicial. Quem gera/valida é cada prompt abaixo, em sessão nova.
- Antes da Etapa 1, abra a **task de controle** (`doc/controle/<AAAA-MM-DD-slug>/` com `TASK.md` + `QA.md` + `LEDGER.md`).

## Sequência

| Etapa | Sessão | Prompt | Onde |
|---|---|---|---|
| 1 | 1a | `analisador-de-projeto` | `ia/prompts/arquitetura/` |
| 1 | 1b | `analisador-de-dominio` | `ia/prompts/negocio/` (reusado pela trilha arquitetura) |
| 2 | 2  | `arquiteto-de-sistema` | `ia/prompts/arquitetura/` |
| 3 | 3  | `documentador-fluxo`   | `ia/prompts/arquitetura/` |
| 4 | 4  | `gerador-runbook`      | `ia/prompts/arquitetura/` |
| 5 | 5  | `grill-arquitetura`    | `ia/prompts/arquitetura/` |
| 6 | 6  | `validador-visual`     | `ia/prompts/arquitetura/` |
| 7 | 7  | `validador-sintaxe-mermaid` | `ia/prompts/arquitetura/` |

## Destino canônico de saída

- Páginas geradas → `doc/arquitetura/`.
- ADRs → `doc/adr/`.
- `ia/templates/` é só **gabarito de FORMA** (referência) — nunca destino.

## Próximo passo

> Abra a task de controle e rode a Etapa 1, sessão 1a: `analisador-de-projeto` (em sessão própria).

## Para doc JÁ existente

Não use a trilha 1→7 — use o `atualizador-arquitetura` (prompt complementar).
```

- [ ] **Step 2: Verificar**

Run: `grep -cE '(Etapa [0-9]/7|sessão própria|doc/arquitetura/)' ia/prompts/arquitetura/documentar-servico.md`
Expected: ≥ 5.

- [ ] **Step 3: Commit**

```bash
git add ia/prompts/arquitetura/documentar-servico.md
git commit -m "refactor(prompt): documentar-servico vira indice da trilha (7 etapas / 8 sessoes)"
```

### Task E2: `analisador-de-projeto.md` (sessão 1a) — abre task + apenda QA.md + handoff

**Files:**
- Modify: `ia/prompts/arquitetura/analisador-de-projeto.md`

- [ ] **Step 1: Adicionar bloco STATUS no topo (antes de qualquer outra coisa)**

Inserir como primeiras linhas do arquivo:

```markdown
**STATUS (rev 2026-06-19):**
- Esta é a **sessão 1a da Etapa 1/7** da trilha. Roda em **sessão própria** (regra master).
- Antes de gerar `project-context.md`, abra a task de controle: `doc/controle/<AAAA-MM-DD-slug>/` com `TASK.md` (escopo+ACs+checklist), `QA.md` (vazio com cabeçalho do template), `LEDGER.md`.
- Para CADA pergunta-âncora respondida pelo usuário, **apenda no QA.md NO MESMO TURNO** em que a resposta chega (status vivo). Regra binária: **verbatim** sempre que houver decisão (escolha entre opções, nome de tecnologia, restrição numérica); normalizada (1 linha) caso contrário. Template em `controle-de-tarefa.md`.
- Próximo passo (handoff): **sessão 1b — `analisador-de-dominio`** (em sessão nova).

---

```

- [ ] **Step 2: Substituir/adicionar handoff ao final do arquivo**

Acrescentar (ou substituir o handoff existente) no fim:

```markdown

## Handoff

> Sessão 1a/Etapa 1 concluída. Próxima sessão: **`analisador-de-dominio`** (sessão 1b/Etapa 1) em sessão nova. Não orquestre — abra nova sessão.
```

- [ ] **Step 3: Verificar**

Run: `grep -cE '(sessão 1a|QA.md no MESMO TURNO|analisador-de-dominio)' ia/prompts/arquitetura/analisador-de-projeto.md`
Expected: ≥ 3.

- [ ] **Step 4: Commit**

```bash
git add ia/prompts/arquitetura/analisador-de-projeto.md
git commit -m "refactor(prompt): analisador-de-projeto (sessao 1a) — abre task + QA.md vivo + handoff"
```

### Task E3: `analisador-de-dominio.md` (sessão 1b) — QA.md + handoff

**Files:**
- Modify: `ia/prompts/negocio/analisador-de-dominio.md`

- [ ] **Step 1: Bloco STATUS no topo**

Inserir como primeiras linhas:

```markdown
**STATUS (rev 2026-06-19):**
- Esta é a **sessão 1b da Etapa 1/7** da trilha de doc de arquitetura (reusado: vive em `ia/prompts/negocio/`, mas é a 2ª sessão da Etapa 1).
- Roda em **sessão própria** (regra master). A task de controle já foi aberta na sessão 1a — você apenda neste mesmo `doc/controle/<task-id>/QA.md`.
- Para CADA pergunta-âncora respondida, **apenda no QA.md NO MESMO TURNO** (status vivo). Regra binária: verbatim quando houver decisão; normalizada caso contrário.
- Próximo passo (handoff): **Etapa 2/7 — `arquiteto-de-sistema`** (sessão nova).

---

```

- [ ] **Step 2: Handoff ao final**

```markdown

## Handoff

> Sessão 1b/Etapa 1 concluída. Etapa 1 inteira fechada. Próxima sessão: **`arquiteto-de-sistema`** (Etapa 2/7) em sessão nova.
```

- [ ] **Step 3: Verificar**

Run: `grep -cE '(sessão 1b|QA.md|arquiteto-de-sistema)' ia/prompts/negocio/analisador-de-dominio.md`
Expected: ≥ 3.

- [ ] **Step 4: Commit**

```bash
git add ia/prompts/negocio/analisador-de-dominio.md
git commit -m "refactor(prompt): analisador-de-dominio (sessao 1b) — QA.md vivo + handoff p/ arquiteto"
```

### Task E4: `arquiteto-de-sistema.md` (Etapa 2/7) — NAV editor + handoff

**Files:**
- Modify: `ia/prompts/arquitetura/arquiteto-de-sistema.md`

- [ ] **Step 1: STATUS no topo**

```markdown
**STATUS (rev 2026-06-19):**
- Esta é a **Etapa 2/7** da trilha. Roda em **sessão própria** (regra master).
- Destino canônico: **`doc/arquitetura/`** (páginas) — `ia/templates/` é só gabarito de FORMA.
- **NAV editor (regra obrigatória):** AO criar cada `.html` em `doc/arquitetura/`, **apenda no mesmo passo** a entry `{label, href}` na seção certa do `NAV` em `sidebar.js`. Página sem entry = órfã = rejeitada pelo validador #6.
- Cada pergunta de grilling respondida pelo usuário entra no `QA.md` da task no mesmo turno (status vivo).
- Próximo passo (handoff): **Etapa 3/7 — `documentador-fluxo`** (sessão nova).

---

```

- [ ] **Step 2: Handoff ao final**

```markdown

## Handoff

> Etapa 2/7 concluída. Próxima sessão: **`documentador-fluxo`** (Etapa 3/7) em sessão nova.
```

- [ ] **Step 3: Verificar**

Run: `grep -cE '(Etapa 2/7|NAV editor|doc/arquitetura/|documentador-fluxo)' ia/prompts/arquitetura/arquiteto-de-sistema.md`
Expected: ≥ 4.

- [ ] **Step 4: Commit**

```bash
git add ia/prompts/arquitetura/arquiteto-de-sistema.md
git commit -m "refactor(prompt): arquiteto-de-sistema (Etapa 2/7) — NAV editor + destino + handoff"
```

### Task E5: `documentador-fluxo.md`, `gerador-runbook.md`, `grill-arquitetura.md` (Etapas 3/7, 4/7, 5/7)

**Files:**
- Modify: `ia/prompts/arquitetura/documentador-fluxo.md`
- Modify: `ia/prompts/arquitetura/gerador-runbook.md`
- Modify: `ia/prompts/arquitetura/grill-arquitetura.md`

- [ ] **Step 1: `documentador-fluxo.md` — STATUS + handoff**

STATUS no topo:

```markdown
**STATUS (rev 2026-06-19):**
- Esta é a **Etapa 3/7** da trilha. Roda em **sessão própria** (regra master).
- Destino canônico: **`doc/arquitetura/`**.
- **NAV editor (obrigatório):** ao criar cada página de fluxo, apenda entry `{label, href}` na seção certa do `NAV` em `sidebar.js` no mesmo passo.
- Mermaid: use `sequenceDiagram` com `autonumber` (regra binária — sempre); 4 `classDef` obrigatórios; labels entre aspas; sem `<` `>` crus.
- Próximo passo (handoff): **Etapa 4/7 — `gerador-runbook`** (sessão nova).

---
```

Handoff ao final:

```markdown

## Handoff

> Etapa 3/7 concluída. Próxima sessão: **`gerador-runbook`** (Etapa 4/7) em sessão nova.
```

- [ ] **Step 2: `gerador-runbook.md` — STATUS + handoff**

STATUS no topo:

```markdown
**STATUS (rev 2026-06-19):**
- Esta é a **Etapa 4/7** da trilha. Roda em **sessão própria** (regra master).
- Destino canônico: **`doc/arquitetura/runbook.html`**.
- **NAV editor (obrigatório):** apenda entry no `NAV` de `sidebar.js`.
- Próximo passo (handoff): **Etapa 5/7 — `grill-arquitetura`** (sessão nova).

---
```

Handoff:

```markdown

## Handoff

> Etapa 4/7 concluída. Próxima sessão: **`grill-arquitetura`** (Etapa 5/7) em sessão nova.
```

- [ ] **Step 3: `grill-arquitetura.md` — STATUS + handoff**

STATUS no topo:

```markdown
**STATUS (rev 2026-06-19):**
- Esta é a **Etapa 5/7** da trilha (1ª das 3 validações; única que **APLICA** correções inline após confirmação no grill). Roda em **sessão própria** (regra master).
- Para CADA par pergunta→resposta do grilling, **apenda no QA.md NO MESMO TURNO** (status vivo). Regra binária: verbatim quando houver decisão; normalizada caso contrário.
- Próximo passo (handoff): **Etapa 6/7 — `validador-visual`** (sessão nova).

---
```

Handoff:

```markdown

## Handoff

> Etapa 5/7 concluída. Próxima sessão: **`validador-visual`** (Etapa 6/7) em sessão nova.
```

- [ ] **Step 4: Verificar todos os 3**

Run:
```bash
grep -cE '(Etapa 3/7|Etapa 4/7|Etapa 5/7)' ia/prompts/arquitetura/documentador-fluxo.md ia/prompts/arquitetura/gerador-runbook.md ia/prompts/arquitetura/grill-arquitetura.md
```
Expected: cada um ≥ 2 (STATUS + handoff).

- [ ] **Step 5: Commit**

```bash
git add ia/prompts/arquitetura/documentador-fluxo.md ia/prompts/arquitetura/gerador-runbook.md ia/prompts/arquitetura/grill-arquitetura.md
git commit -m "refactor(prompt): documentador-fluxo/gerador-runbook/grill (Etapas 3-5/7) — STATUS + handoffs"
```

### Task E6: Sync mirrors após Fase E

**Files:**
- Modify (regenerado): `.github/`, `.kiro/`

- [ ] **Step 1: Regenerar**

Run:
```bash
bash ia/tools/sync-copilot.sh
bash ia/tools/sync-kiro.sh
```

- [ ] **Step 2: 3× `--check`**

Run:
```bash
bash ia/tools/sync-copilot.sh   --check
bash ia/tools/sync-kiro.sh      --check
bash ia/tools/sync-como-usar.sh --check
```
Expected: 3 × exit 0.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore(sync): regenera mirrors apos refactor da Fase E"
```

---

## Fase F — Rules (architecture, frontend, gerador-adr, sincronizar, controle)

### Task F1: `architecture-style.md` — fluxo 3→7, destino único, regra master de sessão

**Files:**
- Modify: `.amazonq/rules/architecture-style.md`

- [ ] **Step 1: Localizar as 3 zonas a editar**

Run: `sed -n '139,162p' .amazonq/rules/architecture-style.md`
Anote as linhas exatas dos rótulos `Etapa N/3`, do bloco "Fluxo canônico" e dos blocos de destino (172/247).

- [ ] **Step 2: Aplicar as edições**

Aplique (use Edit por trecho — preserve o restante do arquivo):

a) **Tabela de gatilhos (linhas ~139-155):** rótulos `Etapa N de 3` → `Etapa N/7`; adicionar 1 linha por prompt novo (`validador-visual`, `validador-sintaxe-mermaid`, `atualizador-arquitetura`). Exemplo do formato esperado por linha: `| "valida visual" / "valida template" | validador-visual.md | Etapa 6/7 — só reporta |`.

b) **Bloco "Fluxo canônico" (~linhas 157-162):** substituir prosa "3 etapas obrigatórias" por:

```markdown
## Fluxo canônico (rev v2 — 2026-06-19)

A doc de arquitetura tem **7 etapas conceituais correspondendo a 8 sessões** (Etapa 1 = 2 sessões).
**Rode TODAS na ordem 1→7, cada PROMPT em sessão própria** (regra master).

1a `analisador-de-projeto`  →  1b `analisador-de-dominio`  →  2 `arquiteto-de-sistema`
→  3 `documentador-fluxo`  →  4 `gerador-runbook`  →  5 `grill-arquitetura`
→  6 `validador-visual`  →  7 `validador-sintaxe-mermaid`  →  FIM

Antes da Etapa 1, abra task de controle em `doc/controle/<AAAA-MM-DD-slug>/` com TASK.md + QA.md + LEDGER.md.
Para doc JÁ existente, use o `atualizador-arquitetura` (complementar).
```

c) **Destinos (linhas ~172 e ~247):** trocar todas as menções `ia/templates/` (como destino) por:

```
Páginas geradas → `doc/arquitetura/`. ADRs → `doc/adr/`. `ia/templates/` é apenas
gabarito de FORMA (referência), nunca destino de gravação.
```

d) **Auto-checklist mental (linha ~280):** substituir "verifique mentalmente" pela frase:

```
O enforcement do template **não é mais mental**. As Etapas 6/7 (validadores) e o
`atualizador-arquitetura` aplicam o checklist canônico (`ia/templates/checklist-validador.md`)
com evidência `arquivo:linha`. Cada etapa de geração (2/3/4) é responsável por
apendar entry no NAV de `sidebar.js` no mesmo passo da criação do `.html`.
```

- [ ] **Step 3: Verificar**

Run:
```bash
grep -cE '(Etapa [1-7]/7|sessão própria|doc/arquitetura/|validador-visual|validador-sintaxe-mermaid|atualizador-arquitetura)' .amazonq/rules/architecture-style.md
```
Expected: ≥ 8.

- [ ] **Step 4: Garantir que NÃO sobrou "Etapa N de 3"**

Run: `grep -nE 'Etapa [0-9]+ de 3' .amazonq/rules/architecture-style.md`
Expected: vazio.

- [ ] **Step 5: Commit**

```bash
git add .amazonq/rules/architecture-style.md
git commit -m "feat(rules): architecture-style — fluxo 3->7, destino unico, regra master de sessao"
```

### Task F2: `frontend-style.md` — referência ao validador #6 + checklist canônico

**Files:**
- Modify: `.amazonq/rules/frontend-style.md`

- [ ] **Step 1: Substituir "mentalmente cheque" (linha ~301)**

Use Edit; substituir o bloco que contém `mentalmente` por:

```
O enforcement do template e da tipografia é executado pelo **Etapa 6/7 — `validador-visual`**
(checklist canônico em `ia/templates/checklist-validador.md` + `ia/tools/validar-doc.sh --front`).
As regras de UI/UX desta página são gate dele.
```

- [ ] **Step 2: Verificar**

Run: `grep -cE '(validador-visual|checklist-validador|--front)' .amazonq/rules/frontend-style.md`
Expected: ≥ 2.

- [ ] **Step 3: Commit**

```bash
git add .amazonq/rules/frontend-style.md
git commit -m "feat(rules): frontend-style aponta enforcement para o validador #6"
```

### Task F3: `gerador-adr.md` + `sincronizar-doc-codigo.md` — destino `docs/<servico>/` → `doc/`

**Files:**
- Modify: `ia/prompts/arquitetura/gerador-adr.md`
- Modify: `ia/prompts/arquitetura/sincronizar-doc-codigo.md`

- [ ] **Step 1: Corrigir `gerador-adr.md:91`**

Localizar a frase que cita `docs/<servico>/adr/` e substituir por:

```
Os ADRs vivem em `doc/adr/` (irmão de `doc/arquitetura/`, espelhando o layout do pack).
A numeração `NNNN-slug` segue do maior `NNNN` existente em `doc/adr/`.
```

- [ ] **Step 2: Corrigir `sincronizar-doc-codigo.md:42,59,68`**

Substituir todas as 3 menções `docs/<servico>/` por `doc/arquitetura/` (páginas) ou `doc/adr/` (ADRs), conforme o contexto.

- [ ] **Step 3: Verificar**

Run:
```bash
grep -nE 'docs/<servico>|docs/[^a-z]' ia/prompts/arquitetura/gerador-adr.md ia/prompts/arquitetura/sincronizar-doc-codigo.md
```
Expected: vazio (ou só matches que não usam o caminho antigo).

- [ ] **Step 4: Commit**

```bash
git add ia/prompts/arquitetura/gerador-adr.md ia/prompts/arquitetura/sincronizar-doc-codigo.md
git commit -m "fix(prompts): gerador-adr + sincronizar-doc-codigo unificam destino em doc/"
```

### Task F4: `controle-de-tarefa.md` + `controle-style.md` — template QA.md + regra de status vivo

**Files:**
- Modify: `ia/prompts/engenharia/controle-de-tarefa.md`
- Modify: `.amazonq/rules/controle-style.md`

- [ ] **Step 1: Adicionar seção "Template — QA.md" em `controle-de-tarefa.md`**

Inserir após a seção "Template — LEDGER.md" (~linha 120):

````markdown

## Template — QA.md (quando a task é de **doc** ou **grill**)

````markdown
# QA — <task-id>

> Status vivo: apendado NO MESMO TURNO em que a resposta chega.
> Regra binária: **verbatim** sempre que houver decisão (escolha entre opções, nome de tecnologia,
> restrição numérica/temporal); **normalizada** (1 linha) caso contrário.

## Perguntas & Respostas
- [AAAA-MM-DD] P: <pergunta feita ao usuário>
  R: <normalizada em 1 linha>          # se NÃO houver decisão
  R: verbatim: "<trecho do usuário>"   # se houver decisão
````

````

- [ ] **Step 2: Adicionar à `controle-style.md` a regra do QA.md**

Inserir na seção "3. Invariantes" (após a linha sobre Status vivo do checklist) o bullet:

```
- **QA.md (tasks de doc ou grill):** crie `doc/controle/<task-id>/QA.md` a partir do template em
  `controle-de-tarefa.md`. Apenda cada par P→R **no mesmo turno** em que a resposta chega.
  Regra binária: **verbatim** sempre que houver decisão (escolha, nome de tecnologia,
  restrição numérica); **normalizada** caso contrário. O cap de 60 linhas do LEDGER.md
  **não** se aplica ao QA.md.
```

- [ ] **Step 3: Verificar**

Run: `grep -cE 'QA\.md' ia/prompts/engenharia/controle-de-tarefa.md .amazonq/rules/controle-style.md`
Expected: ≥ 3 (template + regra invariante).

- [ ] **Step 4: Commit**

```bash
git add ia/prompts/engenharia/controle-de-tarefa.md .amazonq/rules/controle-style.md
git commit -m "feat(controle): template QA.md + regra status vivo (mesmo turno; verbatim em decisao)"
```

### Task F5: Espelhar rules nos mirrors (Copilot `.github/instructions/` + Kiro `.kiro/steering/`)

**Files:**
- Modify (regenerado): `.github/instructions/`, `.kiro/steering/`

- [ ] **Step 1: Regenerar**

Run:
```bash
bash ia/tools/sync-copilot.sh
bash ia/tools/sync-kiro.sh
```

- [ ] **Step 2: 3× `--check`**

Run:
```bash
bash ia/tools/sync-copilot.sh   --check
bash ia/tools/sync-kiro.sh      --check
bash ia/tools/sync-como-usar.sh --check
```
Expected: exit 0 cada.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore(sync): regenera mirrors apos edicao das rules (Fase F)"
```

---

## Fase G — `ia/COMO-USAR.html` (entregável) + sync

### Task G1: Reescrever a trilha de arquitetura no COMO-USAR.html

**Files:**
- Modify: `ia/COMO-USAR.html`

- [ ] **Step 1: Localizar os blocos atuais**

Run:
```bash
grep -nE '(Etapa 1/3|Etapa 2/3|Etapa 3/3|combo|combo-arquitetura)' ia/COMO-USAR.html | head -30
```
Anote as linhas dos 3 cards atuais e do bloco COMBO.

- [ ] **Step 2: Adicionar bloco de cabeçalho explícito**

Antes do primeiro card da trilha de arquitetura, inserir:

```html
<aside class="decision-callout" id="trilha-arquitetura-header">
  <div class="decision-callout__icon">▶</div>
  <div class="decision-callout__body">
    <div class="decision-callout__label">Trilha de arquitetura — leia antes de começar</div>
    <p class="prose">
      A trilha tem <strong>7 etapas conceituais correspondendo a 8 sessões</strong>
      (Etapa 1 = 2 sessões). <strong>Rode TODAS na ordem 1→7, cada prompt em sessão própria.</strong>
      Antes da Etapa 1, abra a task de controle (<code>doc/controle/&lt;AAAA-MM-DD-slug&gt;/</code>).
      Para doc JÁ existente, pule a trilha e use o <code>atualizador-arquitetura</code>.
    </p>
  </div>
</aside>
```

- [ ] **Step 3: Substituir os 3 cards "Etapa N/3" por 7 cards "Etapa N/7"**

Cada card segue o padrão existente (`doc-card` com `__title`, `__desc`, `pre.msg`). Use o card atual da Etapa 1/3 como gabarito de forma e substitua o conteúdo:

- **Etapa 1/7 — Fundação (2 sessões):** explicita que rode `analisador-de-projeto` (1a) **e depois** `analisador-de-dominio` (1b) em sessão nova cada.
- **Etapa 2/7 — Arquitetura/espinha:** `arquiteto-de-sistema`.
- **Etapa 3/7 — Fluxos:** `documentador-fluxo`.
- **Etapa 4/7 — Runbook:** `gerador-runbook`.
- **Etapa 5/7 — Grill (lógica):** `grill-arquitetura`.
- **Etapa 6/7 — Validador visual:** `validador-visual`.
- **Etapa 7/7 — Validador sintaxe/Mermaid:** `validador-sintaxe-mermaid`.

Mensagens prontas (no `pre.msg` de cada card) — exemplos:
- Card 1/7: `"Rode o analisador-de-projeto. Depois, em sessão nova, rode o analisador-de-dominio."`
- Card 2/7: `"Rode o arquiteto-de-sistema na pasta do serviço. Páginas em doc/arquitetura/."`
- Card 6/7: `"Rode o validador-visual sobre doc/arquitetura/."`
- Card 7/7: `"Rode o validador-sintaxe-mermaid sobre doc/arquitetura/."`

- [ ] **Step 4: Substituir o card COMBO**

Localizar o card COMBO (atualmente identificado por linhas ~927-939). Adicionar `id="combo-arquitetura"` no elemento raiz do card (âncora estável). Trocar a lista de 3 itens por 7:

```html
<ol class="prose">
  <li>Sessão 1a — <code>analisador-de-projeto</code></li>
  <li>Sessão 1b — <code>analisador-de-dominio</code> (em sessão nova)</li>
  <li>Etapa 2/7 — <code>arquiteto-de-sistema</code></li>
  <li>Etapa 3/7 — <code>documentador-fluxo</code></li>
  <li>Etapa 4/7 — <code>gerador-runbook</code></li>
  <li>Etapa 5/7 — <code>grill-arquitetura</code></li>
  <li>Etapa 6/7 — <code>validador-visual</code></li>
  <li>Etapa 7/7 — <code>validador-sintaxe-mermaid</code></li>
</ol>
```

- [ ] **Step 5: Adicionar card do `atualizador-arquitetura` (subseção "doc já existente")**

Inserir após o COMBO um card com título *"Atualizador — doc já existente"*, descrição da decisão #10 (1 task por execução; ramifica front→plano+aplica / lógico→grill no QA.md) e mensagem pronta: *"Rode o atualizador-arquitetura sobre doc/arquitetura/."*

- [ ] **Step 6: Verificar**

Run:
```bash
grep -cE '(Etapa [1-7]/7|combo-arquitetura|atualizador-arquitetura)' ia/COMO-USAR.html
```
Expected: ≥ 9 (7 etapas + COMBO id + atualizador).

Run: `grep -cE 'Etapa [1-3]/3' ia/COMO-USAR.html`
Expected: `0` (rótulos antigos sumiram).

- [ ] **Step 7: Commit**

```bash
git add ia/COMO-USAR.html
git commit -m "feat(como-usar): trilha de arquitetura 7 etapas/8 sessoes + atualizador + combo"
```

### Task G2: Regenerar `ia/COMO-USAR.md` + 3× `--check`

**Files:**
- Modify (regenerado): `ia/COMO-USAR.md`

- [ ] **Step 1: Sync**

Run: `bash ia/tools/sync-como-usar.sh`

- [ ] **Step 2: 3× `--check`**

Run:
```bash
bash ia/tools/sync-copilot.sh   --check
bash ia/tools/sync-kiro.sh      --check
bash ia/tools/sync-como-usar.sh --check
```
Expected: exit 0 cada.

- [ ] **Step 3: Commit**

```bash
git add ia/COMO-USAR.md
git commit -m "chore(sync): regenera COMO-USAR.md a partir do .html"
```

---

## Fase H — Contagens stale (varredura completa)

### Task H1: Corrigir `ia/INSTALAR.md` (breakdown por trilha + totais)

**Files:**
- Modify: `ia/INSTALAR.md`

- [ ] **Step 1: Snapshot**

Run: `sed -n '95,105p' ia/INSTALAR.md`

- [ ] **Step 2: Editar linha 99 (breakdown por trilha)**

Substituir `arquitetura 10, frontend 4, negocio 5, engenharia 10 — 30 arquivos` por `arquitetura 13, frontend 4, negocio 5, engenharia 10 — 32 arquivos`.

- [ ] **Step 3: Editar outras contagens correlatas (linhas 97-100)**

Substituir cada `30 arquivos `.prompt.md`` por `32 arquivos `.prompt.md``; cada `62 subpastas` por `64 subpastas`; cada `30 wrappers` por `32 wrappers`.

- [ ] **Step 4: Verificar**

Run: `grep -nE '(arquitetura 10|30 wrappers|30 arquivos|62 subpastas)' ia/INSTALAR.md`
Expected: vazio.

Run: `grep -nE '(arquitetura 13|32 wrappers|32 arquivos|64 subpastas)' ia/INSTALAR.md | wc -l | tr -d ' '`
Expected: ≥ 4.

- [ ] **Step 5: Commit**

```bash
git add ia/INSTALAR.md
git commit -m "docs(installar): atualiza contagens pos-v2 (32 prompts; arquitetura 13; 64 skills)"
```

### Task H2: Corrigir contagens stale em README/install/sync headers/skills README

**Files:**
- Modify: `README.md`
- Modify: `install.sh`
- Modify: `install.ps1`
- Modify: `ia/tools/sync-copilot.sh`
- Modify: `ia/tools/sync-kiro.sh`
- Modify: `ia/skills/README.md`

- [ ] **Step 1: Inventário stale (rode antes para mapear)**

Run:
```bash
grep -rEn '(30 wrappers|62 skills|62:|29 prompts|31 skills|31 Agent Skills|60 wrappers|87 |arquitetura 10)' \
  README.md install.sh install.ps1 ia/tools/sync-copilot.sh ia/tools/sync-kiro.sh ia/skills/README.md 2>/dev/null
```
Anote cada match.

- [ ] **Step 2: Substituir as contagens (preservando a sintaxe ao redor)**

Aplicar regra geral:
- `30 wrappers` → `32 wrappers`
- `30 prompts` → `32 prompts`
- `30 arquivos` → `32 arquivos`
- `62: 30+32` → `64: 32+32`
- `62 subpastas` → `64 subpastas`
- `62 Agent Skills` → `64 Agent Skills`
- `29 prompts` → `32 prompts`
- `31 skills` → `32 skills`
- `60 wrappers` → `64 wrappers`
- `87 ` (no contexto de wrappers totais) → recalcular conforme `README.md` (geralmente `64 wrappers + 32 importadas = 96`; ajustar se a fórmula original for diferente — preserve a fórmula explicitada na prosa).
- `arquitetura 10` → `arquitetura 13`

- [ ] **Step 3: Verificar (a varredura deve voltar vazia)**

Run:
```bash
grep -rEn '(30 wrappers|62 skills|62: 30|62 subpastas|62 Agent Skills|29 prompts|31 skills|60 wrappers|arquitetura 10)' \
  README.md install.sh install.ps1 ia/tools/sync-copilot.sh ia/tools/sync-kiro.sh ia/skills/README.md 2>/dev/null
```
Expected: vazio.

- [ ] **Step 4: 3× `--check` (garantir que os sync scripts ainda batem com mirror)**

Run:
```bash
bash ia/tools/sync-copilot.sh   --check
bash ia/tools/sync-kiro.sh      --check
bash ia/tools/sync-como-usar.sh --check
```
Expected: exit 0 cada. *(Os cabeçalhos dos sync scripts são comentários — não afetam mirror.)*

- [ ] **Step 5: Commit**

```bash
git add README.md install.sh install.ps1 ia/tools/sync-copilot.sh ia/tools/sync-kiro.sh ia/skills/README.md
git commit -m "docs: atualiza todas as contagens hardcoded pos-v2 (32 prompts / 64 wrappers)"
```

---

## Fase I — Verificação final + fechar task

### Task I1: Smoke test end-to-end + fechar task

**Files:**
- Modify: `doc/controle/2026-06-19-pipeline-arquitetura-v2/TASK.md`
- Create: `doc/controle/2026-06-19-pipeline-arquitetura-v2/LEDGER.md`

- [ ] **Step 1: Suite de testes do validar-doc.sh**

Run: `bash ia/tools/tests/run-tests.sh`
Expected: `Total: PASS=17 FAIL=0`.

- [ ] **Step 2: 3× `--check` final**

Run:
```bash
bash ia/tools/sync-copilot.sh   --check
bash ia/tools/sync-kiro.sh      --check
bash ia/tools/sync-como-usar.sh --check
```
Expected: exit 0 cada.

- [ ] **Step 3: Contagem final correta**

Run:
```bash
echo "ia/prompts (.md):     $(find ia/prompts -name '*.md' -type f | wc -l | tr -d ' ')"
echo "manifest entries:      $(awk -F'\t' '$1!=""&&$1!~/^#/{c++} END{print c}' ia/tools/manifest.tsv)"
echo "github/prompts:        $(ls .github/prompts/*.prompt.md 2>/dev/null | wc -l | tr -d ' ')"
echo "github/skills:         $(find .github/skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
echo "kiro/skills:           $(find .kiro/skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
echo "ia/prompts/arquitetura: $(find ia/prompts/arquitetura -maxdepth 1 -name '*.md' -type f | wc -l | tr -d ' ')"
```
Expected:
- `ia/prompts (.md): 32`
- `manifest entries: 32`
- `github/prompts: 32`
- `github/skills: 64` (32 wrappers + 32 importadas)
- `kiro/skills: 64`
- `ia/prompts/arquitetura: 13`

- [ ] **Step 4: Varredura final por rótulos antigos**

Run:
```bash
grep -rnE '(Etapa [0-9]+ de 3|Etapa [1-3]/3)' .amazonq/rules/ ia/prompts/ ia/COMO-USAR.html .github/ .kiro/ 2>/dev/null
```
Expected: vazio.

Run:
```bash
grep -rnE 'docs/<servico>' ia/prompts/ .amazonq/rules/ 2>/dev/null
```
Expected: vazio.

- [ ] **Step 5: Atualizar TASK.md (fase=concluida, AC5 marcado)**

Editar `doc/controle/2026-06-19-pipeline-arquitetura-v2/TASK.md`: mudar `**fase:** plano` para `**fase:** concluida`; marcar `[x] AC5: plano de implementação criado` e `[x] writing-plans (plano de implementação)` se ainda estiverem abertos.

- [ ] **Step 6: Escrever LEDGER.md**

Conteúdo:

```markdown
# LEDGER — 2026-06-19-pipeline-arquitetura-v2

## Decisoes
- Brainstorming concluido com 6 perguntas-fork + 3 confirmacoes finais + Decisao #10 confirmada (1 task por execucao no atualizador). Spec v1.1 aprovado.
- Auto-revisao adversarial (4 criticos, 28 findings) corrigiu contradicoes de sessao/etapa/prompt, aritmetica, NAV editor, CLI do validar-doc.sh, SoT das listas, e mais 23 itens (ver spec §13).
- Implementacao decomposta em 9 fases (A-I), cada task = 1 commit logico. TDD genuino para validar-doc.sh (17 casos); verificacao por grep + 3 sync --check para conteudo.

## Verificacao
- AC1-AC5: passed (ver TASK.md).
- Suite de testes do script: PASS=17 FAIL=0.
- 3 sync --check: exit 0.
- Contagens: 32 prompts (13 arquitetura), 32 github/prompts, 64 github/skills, 64 kiro/skills.

## Pendencias
- (vazio)

## Arquivos tocados (resumo)
- Canonicos editados: 11 prompts + 4 rules + 2 standalones (COMO-USAR.html, INSTALAR.md) + manifest + sync scripts (cabecalhos) + README + installers.
- Canonicos criados: 3 prompts (validador-visual, validador-sintaxe-mermaid, atualizador-arquitetura) + 3 SoT em ia/tools/lib/ + checklist-validador.md + validar-doc.sh + suite de testes + README do validador.
- Mirrors regenerados via sync-*.sh: .github/ e .kiro/.
- Controle: doc/controle/2026-06-19-pipeline-arquitetura-v2/ (TASK + QA + LEDGER).
```

- [ ] **Step 7: Commit final**

```bash
git add doc/controle/2026-06-19-pipeline-arquitetura-v2/TASK.md doc/controle/2026-06-19-pipeline-arquitetura-v2/LEDGER.md
git commit -m "chore(controle): fecha task 2026-06-19-pipeline-arquitetura-v2 (todos os AC ok)"
```

---

## Self-review (do autor do plano)

### Cobertura do spec (mapeamento)
- §1 Objetivo, §2 Decisões, §3 Trilha 7/8 → Fases C, D, E (prompts novos + manifest + handoffs).
- §4 Destino único → Fase F (rules + gerador-adr + sincronizar-doc-codigo).
- §5 Validadores #6/#7 + checklist + validar-doc.sh + SoT → Fases A, B, C.
- §6 Rigidez transversal (sessão master + texto) → Fase F (architecture-style).
- §7 Controle + QA.md → Fase F (controle-de-tarefa + controle-style).
- §8 Atualizador → Fase C (prompt) + handoff em §9 (card no COMO-USAR).
- §9 COMO-USAR → Fase G.
- §10 Ripple/contagens → Fases D, H.
- §11 Não-objetivos → respeitados (sem orquestração programática; validar-doc.sh é opcional; sem stub).
- §12 Riscos → Decisão #11 (NAV editor) implementada em Fase E (Etapas 2/3/4 ganham bullet de saída obrigatória).
- §13 Mudanças da revisão 1.1 → todas refletidas (aritmética 11→13, sessão master, atualizador 1 task, SoT, validador só reporta, autonumber sempre, status vivo mesmo turno, verbatim em decisão).

### Sem placeholders
Conferido: cada step de código mostra o trecho concreto; cada step de markdown mostra o conteúdo completo; verificações usam comandos exatos com expected output.

### Consistência de tipos/nomes
Slugs estáveis: `validador-visual`, `validador-sintaxe-mermaid`, `atualizador-arquitetura`. Caminhos: `ia/tools/lib/`, `ia/tools/validar-doc.sh`, `ia/templates/checklist-validador.md`, `doc/arquitetura/`, `doc/adr/`, `doc/controle/<task-id>/{TASK,QA,LEDGER}.md`. Flags: `--front`, `--mermaid`, `--all`. Exit codes: 0/1/2. Os nomes não mudam entre tasks.

---

**Plano completo. Total: 26 tasks em 9 fases.**

Próximo passo: você escolhe o modo de execução.
