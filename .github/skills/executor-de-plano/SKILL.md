---
name: executor-de-plano
description: "Executa o plano aprovado etapa por etapa com verificacao por etapa, regra de desvio e parada em bloqueio"
---

Siga TODO o processo descrito em `ia/prompts/engenharia/executor-de-plano.md` (na raiz deste repositorio), fase por
fase, na ordem em que esta escrito.

Regras de execucao:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o
  prompt pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- As instructions deste repositorio (`.github/instructions/`) continuam valendo.
