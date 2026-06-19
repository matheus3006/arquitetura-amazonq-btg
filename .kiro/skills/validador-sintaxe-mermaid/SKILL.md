---
name: validador-sintaxe-mermaid
description: "Etapa 7/7: validador sintaxe + Mermaid (so reporta; checklist canonico + ia/tools/validar-doc.sh --mermaid opcional). Pareamento data-id, tipo valido, 4 classDef, autonumber sempre em sequence"
---

Siga TODO o processo descrito em `ia/prompts/arquitetura/validador-sintaxe-mermaid.md` (na raiz deste repositorio), fase por
fase, na ordem em que esta escrito.

Regras de execucao:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o
  prompt pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- As steering rules deste repositorio (`.kiro/steering/`) continuam valendo.
