---
name: grill-negocio
description: "Interrogatorio por fases com ledger para extrair regras nao escritas do dominio"
---

Siga TODO o processo descrito em `prompts/negocio/grill-negocio.md` (na raiz deste repositorio), fase por
fase, na ordem em que esta escrito.

Regras de execucao:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o
  prompt pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- As steering rules deste repositorio (`.kiro/steering/`) continuam valendo.
