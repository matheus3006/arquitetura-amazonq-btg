# PLANO — 2026-06-25-junie-integracao

> Aprovado: mirror enxuto, arquivo `.junie/guidelines.md`. Junie e o 4o agente, mas
> SEM superficie de skills -> 1 arquivo de guidelines (analogo do copilot-instructions.md),
> nao 64 skills. Canonico->mirror: gerado por sync-junie.sh, nunca editado a mao.

## .junie/guidelines.md (gerado) — conteudo
1. Header: repo usa o pack; Junie e o agente; canonico em .amazonq/rules + ia/prompts.
2. **Estrutura do repo** (ataca "busca por pasta"): onde cada coisa mora (rules, prompts,
   doc/, skills, templates). Caminhos exatos.
3. **5 padroes sempre-on** (ponteiro, nao inline — enxuto): nome+proposito+path de
   `.amazonq/rules/*.md` (fonte canonica; todos os agentes derivam dela). Junie le sob
   demanda — path explicito funciona mesmo com a fraqueza de busca.
4. **Mapa de gatilhos** (GERADO do manifest): 32 linhas (descricao -> ia/prompts/<trilha>/<slug>.md).
5. **Shell (Windows):** pwsh 7 como default do IDE (NAO Git Bash — JUNIE-1145 forca PowerShell);
   no CLI/bash, guard .bashrc (unset PROMPT_COMMAND no JediTerm) p/ ls/find nao vir vazio.
6. **Protocolo de controle:** resumo + ponteiro p/ controle-style (sem hook, igual Copilot).

## sync-junie.sh
- Header heredoc (itens 1-3,5,6, estaticos) + loop do manifest (item 4) + --check (diff vs
  committed). Cobertura: prompts em ia/prompts == linhas do manifest (igual aos outros sync).
- NAO reescreve as rules (aponta pra elas) -> mais simples que sync-copilot, sem wrappers.

## Wiring
- install.sh §novo + install.ps1 §novo: copiam `.junie/guidelines.md` (igual copilot-instructions).
- ci.yml: step "Anti-drift — Junie" (sync-junie.sh --check) + smoke Windows checa o arquivo.
- INSTALAR.md (slim): Passo 3 ganha bullet do `.junie/guidelines.md`; Passo 5 cita o Junie.
  manual.md: linha na tabela de copia.
- README.md: posicionamento (4 agentes) + arvore. check-counts: invariante Junie (linhas de
  gatilho == manifest) se barato; senao so confirma o arquivo.

## gitignore
- **Inalterado** (no-op). guidelines.md e pequeno e DEVE ser versionado (igual
  copilot-instructions.md). Sem replica pesada -> nada a ignorar. Decisao registrada
  (responde o pedido nº3 do usuario).

## Fora de escopo
- Inline das 5 rules em guidelines.md (mantido enxuto/ponteiro; reabrir se faltar adesao).
- Setar shell do IDE (setting por-dev, nao arquivo de repo) — so documentamos.
- AGENTS.md (nome novo): nao agora; guidelines.md e o alvo. Facil somar depois.
- Commit/push (nao pedido).
