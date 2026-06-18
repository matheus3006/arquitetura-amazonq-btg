---
name: sincronizar-doc-codigo
description: "Atualiza a doc a partir do diff da branch: analisa o codigo, grilla o porque (grill-me + human-architect-mindset) e registra ADR quando a mudanca nao partiu de uma ADR existente"
---

Siga TODO o processo descrito em `ia/prompts/arquitetura/sincronizar-doc-codigo.md` (na raiz deste repositorio), fase por
fase, na ordem em que esta escrito.

Regras de execucao:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o
  prompt pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- As steering rules deste repositorio (`.kiro/steering/`) continuam valendo.
