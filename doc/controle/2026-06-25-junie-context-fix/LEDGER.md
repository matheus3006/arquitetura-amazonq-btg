# LEDGER — 2026-06-25-junie-context-fix

## Decisoes
- Lacuna real: Junie le so o guidelines.md; os outros 3 agentes carregam o contexto do
  servico automatico (Q le todo .amazonq/rules, Copilot .github/instructions, Kiro
  .kiro/steering). Fix: o guidelines manda o Junie ler `.amazonq/rules/{project,business}-
  context.md` explicitamente (gate "sem project-context, nao gere doc"). NAO criamos 4o
  destino — Junie reusa o do .amazonq/rules/ (por isso o INSTALAR Passo 5 diz "le o do Q").
- Bloco no header ESTATICO do sync-junie.sh (guidelines e gerado, nunca editado a mao).

## Evidencias (2026-06-25)
- `bash ia/tools/sync-junie.sh` -> "32 gatilhos"; guidelines.md 93 -> 101 linhas.
- grep no guidelines.md: "Contexto do servico" x1, "project-context.md" x2.
- sync-junie --check OK; check-counts OK; run-tests PASS=21/0; 4 anti-drift exit 0.
- INSTALAR.md Passo 5 cita Junie (gatilho via guidelines + "le o do .amazonq/rules/");
  Passo 3 (greps do check-counts) intacto.

## Arquivos tocados
- Editados: ia/tools/sync-junie.sh (bloco contexto), ia/INSTALAR.md (Passo 5).
- Regenerado: .junie/guidelines.md.
- Controle: doc/controle/2026-06-25-junie-context-fix/ (TASK + LEDGER).

## Fora de escopo
- AGENTS.md (#3) e pesquisa de file-search/indexacao (#4): nao agora.
