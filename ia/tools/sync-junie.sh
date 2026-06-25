#!/usr/bin/env bash
#
# ia/tools/sync-junie.sh — gera a camada Junie (.junie/guidelines.md) a partir do canonico.
#
# Fonte canonica:  .amazonq/rules/ (5 rules, APONTADAS) + ia/tools/manifest.tsv + ia/prompts/**
# Gerado (commitado, NUNCA editado a mao):
#   .junie/guidelines.md   (arquivo unico que o Junie injeta como contexto em TODA task)
#
# Junie NAO tem superficie de "skills"/"prompts" como Copilot/Kiro: le UM arquivo de
# guidelines. Entao geramos um so arquivo — entry-point + estrutura do repo + ponteiro pras
# 5 rules canonicas + mapa de gatilhos (manifest) + bloco de shell (Windows) + protocolo de
# controle. As rules NAO sao reescritas: guidelines.md aponta pra elas (caminho explicito).
#
# Uso:
#   bash ia/tools/sync-junie.sh           # (re)gera .junie/guidelines.md
#   bash ia/tools/sync-junie.sh --check   # exit 1 se o commitado divergir do gerado
#
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="$PACK_DIR/ia/tools/manifest.tsv"

case "${1:-}" in
  --check) MODE="check" ;;
  "")      MODE="generate" ;;
  *) echo "ERRO: argumento desconhecido: ${1} (use --check ou nada)" >&2; exit 2 ;;
esac

if [ "$MODE" = "check" ]; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  OUT="$TMP/.junie"
else
  OUT="$PACK_DIR/.junie"
fi
mkdir -p "$OUT"

# ── 1) Cabecalho estatico (entry-point + estrutura + rules) ──────────────────
cat > "$OUT/guidelines.md" <<'EOF'
# Guidelines do projeto — pack `arquitetura` (para o Junie)

> GERADO por `ia/tools/sync-junie.sh` (ferramenta de manutencao do pack de origem — nao
> existe nos repos instalados) a partir de `.amazonq/rules/` + `ia/tools/manifest.tsv` —
> NAO edite a mao. O Junie injeta este arquivo como contexto em toda task.

Voce e o Junie num repo que usa o pack `arquitetura` (documentacao arquitetural +
disciplinas de engenharia), o mesmo pack usado por Amazon Q, Copilot e Kiro.

## Estrutura do repositorio (use o caminho exato; nao varra pastas)

- `.amazonq/rules/*.md` — os 5 padroes SEMPRE-ON do pack (fonte canonica; todos os agentes
  derivam dela). Trate-os como sempre validos; leia o arquivo relevante quando precisar do detalhe.
- `ia/prompts/<trilha>/<nome>.md` — a metodologia de cada tarefa (arquitetura, frontend,
  negocio, engenharia). E o que voce ABRE quando um gatilho casa (tabela abaixo).
- `doc/arquitetura/` — a documentacao HTML gerada do servico (saida real).
- `doc/controle/` — as tasks do protocolo de controle (TASK.md / PLANO.md / LEDGER.md).
- `doc/adr/`, `doc/specs/`, `doc/planos/` — decisoes (ADR), specs e planos.
- `ia/skills/`, `ia/design-system/`, `ia/templates/` — biblioteca de skills, CSS e templates de FORMA.

## Padroes sempre-on (leia sob demanda em `.amazonq/rules/`)

- `architecture-style.md` — trilha tecnica + a UNICA regra rigida de visual (convencao Mermaid:
  diagram-viewer + classDefs com cores fixas). Releia antes de gerar/editar diagrama.
- `frontend-style.md` — HTML/CSS e o design-system (vocabulario fechado de classes, cores via `var()`).
- `negocio-style.md` — trilha de negocio (regras, atores, eventos, linguagem ubiqua).
- `engenharia-style.md` — disciplinas de engenharia (debug sistematico, plano, TDD, revisao).
- `controle-style.md` — protocolo de controle de tarefas (resumo na secao final).

## Gatilhos -> metodologia (quando a intencao casar, LEIA o arquivo e siga TODO o processo, fase por fase)

| Quando o pedido for | Abra e siga |
|---|---|
EOF

# ── 2) Mapa de gatilhos a partir do manifest ────────────────────────────────
count=0
while IFS=$'\t' read -r slug trilha desc || [ -n "$slug" ]; do
  desc="${desc%$'\r'}"
  [ -z "$slug" ] && continue
  case "$slug" in \#*) continue ;; esac
  case "$desc" in
    ''|*'|'*) echo "ERRO: descricao invalida no manifest para '$slug' (vazia ou contem '|')." >&2; exit 1 ;;
  esac
  canonical="ia/prompts/$trilha/$slug.md"
  if [ ! -f "$PACK_DIR/$canonical" ]; then
    echo "ERRO: manifest aponta para $canonical, que nao existe." >&2
    exit 1
  fi
  printf '| %s | `%s` |\n' "$desc" "$canonical" >> "$OUT/guidelines.md"
  count=$((count + 1))
done < "$MANIFEST"
[ "$count" -gt 0 ] || { echo "ERRO: nenhuma linha de gatilho gerada — manifest vazio ou ilegivel?" >&2; exit 1; }

# ── 3) Rodape estatico (regras de execucao + shell + controle) ───────────────
cat >> "$OUT/guidelines.md" <<'EOF'

Regras de execucao dos prompts:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o prompt
  pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- Use apenas comandos reais do projeto; nao invente scripts de build/teste.

## Shell (Windows) — leia antes de rodar comandos

O Junie roda mal com terminal no Windows (spawna o proprio shell). Para reduzir erro e
desperdicio de token:

- **Plugin do IDE:** deixe o shell padrao em **PowerShell 7+ (`pwsh.exe`)** —
  Settings -> Tools -> Terminal -> Shell path. NAO use Git Bash como padrao do IDE: o Junie
  exige PowerShell e reverte o terminal (limitacao conhecida da JetBrains). O `pwsh` 7 tem
  `&&` e `||`, entao comandos encadeados estilo Unix funcionam.
- **Evite `cmd.exe`** — trava o Junie ao executar comandos.
- **CLI / quem usa Git Bash:** garanta um `.bashrc`/`.bash_profile` limpo para uso
  nao-interativo — `[ -z "$PS1" ] && return` no topo e, no terminal da JetBrains,
  `unset PROMPT_COMMAND` (sem `ls` colorido). Sequencias de escape do prompt poluem a
  saida capturada e fazem `ls`/`find` voltarem VAZIOS.

## Protocolo de controle (resumo — detalhe em `.amazonq/rules/controle-style.md`)

Todo pedido que cria ou altera um artefato (codigo, doc, spec, diagrama, plano) exige uma
task ativa em `doc/controle/<AAAA-MM-DD-slug>/` ANTES de editar: TASK.md (escopo + ACs) +
PLANO.md; depois a execucao marca o checklist e registra evidencias no LEDGER.md. Derive o
slug do proprio pedido — nao peca o nome ao usuario. Pergunta de leitura pura nao abre task.
EOF

# ── 4) Cobertura: todo prompt canonico tem linha no manifest ─────────────────
prompt_files="$(find "$PACK_DIR/ia/prompts" -name '*.md' -type f | wc -l | tr -d ' ')"
if [ "$prompt_files" -ne "$count" ]; then
  echo "ERRO: $prompt_files prompts em ia/prompts/ mas $count linhas no manifest — sincronize ia/tools/manifest.tsv." >&2
  exit 1
fi

# ── 5) Resultado ─────────────────────────────────────────────────────────────
if [ "$MODE" = "check" ]; then
  if diff "$PACK_DIR/.junie/guidelines.md" "$OUT/guidelines.md" > /dev/null 2>&1; then
    echo "OK: .junie/ em sincronia com o canonico."
    exit 0
  else
    echo "DRIFT em .junie/guidelines.md — rode: bash ia/tools/sync-junie.sh" >&2
    diff "$PACK_DIR/.junie/guidelines.md" "$OUT/guidelines.md" 2>&1 | head -20 >&2 || true
    exit 1
  fi
else
  echo "Gerado: .junie/guidelines.md ($count gatilhos) em $OUT"
fi
