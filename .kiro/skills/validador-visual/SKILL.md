---
name: validador-visual
description: "Etapa 6/7: validador visual/template (so reporta; checklist canonico + ia/tools/validar-doc.sh --front opcional). Verifica navegabilidade, esqueleto, vocabulario fechado de classes, cores via var(--color-*), forbidden-terms"
---

Siga TODO o processo descrito em `ia/prompts/arquitetura/validador-visual.md` (na raiz deste repositorio), fase por
fase, na ordem em que esta escrito.

Regras de execucao:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o
  prompt pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- As steering rules deste repositorio (`.kiro/steering/`) continuam valendo.
