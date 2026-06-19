# Plano — iniciativa-b-validador-cliente-maid

**Objetivo:** validador roda de verdade no cliente + gate de parseabilidade no CI.
**Maior risco (materializado):** o parser do gate. Spike mostrou que `maid` é mais estrito
que o renderer real → ver LEDGER; B2 bloqueado na escolha do parser.

## Etapa 1 — install.sh leva o validador
- **Arquivos:** `install.sh` (nova seção 5d, após 5c/linha 144) + comentário "Copia:" do topo.
- **Mudança:** `cp validar-doc.sh` → `ia/tools/`; `mkdir -p ia/tools/lib`; `cp` dos 3 SoT
  (`design-system-classes.txt`, `forbidden-terms.txt`, `mermaid-classdefs.txt`) → `ia/tools/lib/`.
- **Verificação:** `bash install.sh <tmp>` e inspecionar `<tmp>/ia/tools{,/lib}`.
- **Pronto quando:** os 4 arquivos existem no alvo e o validar-doc seedado roda.

## Etapa 2 — install.ps1 espelha
- **Arquivos:** `install.ps1` (seção análoga + comentário "Copia:").
- **Mudança:** `Copy-Item` de validar-doc.sh + 3 SoT pros mesmos destinos.
- **Verificação:** job Windows do CI (pwsh indisponível local).
- **Pronto quando:** paridade textual com install.sh (mesmos 4 arquivos).

## Etapa 3 — guarda funcional (run-tests.sh)
- **Arquivos:** novo `ia/tools/tests/test-install-validador.sh` + plug em `run-tests.sh`.
- **Mudança:** instala em tempdir; roda o validar-doc SEEDADO contra fixtures do pack —
  bom→exit0; `class-bad`→exit1 (prova design-system-classes.txt); `bad-classdef-hex`→exit1
  (prova mermaid-classdefs.txt); `forbidden-bad`→exit1 (prova forbidden-terms.txt).
- **Verificação:** `bash ia/tools/tests/run-tests.sh`.
- **Pronto quando:** novo caso PASS e suite verde.

## Etapa 4 — smoke install.ps1 (Windows) afirma presença
- **Arquivos:** `.github/workflows/ci.yml` (job `windows-install`).
- **Mudança:** `Test-Path` dos 4 arquivos pós-install (validar-doc.sh + 3 SoT).
- **Verificação:** run do CI no push (não roda local).
- **Pronto quando:** step falha se faltar qualquer um dos 4.

## Etapa 5 — brinde checkout v5
- **Arquivos:** `ci.yml` (2 jobs).
- **Mudança:** `actions/checkout@v4` → `@v5`.
- **Verificação:** YAML válido; some o warning de Node 20.
- **Pronto quando:** ambos os jobs em `@v5`.

## Etapa 6 — [B2] gate de parseabilidade — DROPADO (não executada; ver TASK/LEDGER)
- **Arquivos:** `ia/tools/check-mermaid.sh` (+ parser) + `ci.yml` Linux (setup-node) + teste.
- **Mudança:** extrai blocos `<script type=text/mermaid>` → roda parser → exit 0/1; skip sem node.
- **Bloqueio:** escolher o parser — `maid` (rápido/5MB, mas falso-positivo) vs `mermaid@10`
  (autoritativo, casa com o renderer, mais pesado). Decisão do usuário.
- **Pronto quando:** gate VERDE nas templates atuais (AC4) e teste de extração PASS.
