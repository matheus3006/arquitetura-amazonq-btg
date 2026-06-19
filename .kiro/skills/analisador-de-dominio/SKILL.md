---
name: analisador-de-dominio
description: "Etapa 1/7 (sessao 1b, reusado pela trilha arquitetura): analisa o dominio e gera business-context.md em 3 destinos de rules (regras, atores, eventos). Apenda Q&A no QA.md no mesmo turno"
---

Siga TODO o processo descrito em `ia/prompts/negocio/analisador-de-dominio.md` (na raiz deste repositorio), fase por
fase, na ordem em que esta escrito.

Regras de execucao:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o
  prompt pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- As steering rules deste repositorio (`.kiro/steering/`) continuam valendo.
