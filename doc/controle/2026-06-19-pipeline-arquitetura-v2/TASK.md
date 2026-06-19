# TASK — 2026-06-19-pipeline-arquitetura-v2

- **fase:** plano (brainstorming → spec; aguarda revisão do spec antes da implementação)
- **tipo:** design + spec (esforço de implementação grande, será decomposto no plano)
- **pedido:** redesenhar o pipeline de arquitetura do pack para ser rígido e granular — doc gerada
  não seguia o template. Brainstorming conduzido com superpowers:brainstorming + human-architect-mindset.

## Escopo
- Trilha de arquitetura = 7 etapas sequenciais (5 geração + 2 validadores), cada uma em sessão própria.
- 2 validadores novos: #6 front/template, #7 sintaxe/Mermaid (enforcement híbrido).
- 8º prompt `atualizador-arquitetura` (conforma doc existente).
- Acoplar "iniciar doc → abrir task" + `QA.md` registrando input do usuário (status vivo).
- Unificar destino em `doc/arquitetura/` + `doc/adr/`.
- Melhorar `ia/COMO-USAR.html` refletindo o novo pipeline.

## Fora de escopo
- Maquinaria de orquestração programática (handoffs continuam em prosa).
- Renomear repo; mexer nas trilhas negócio/frontend/engenharia.
- Reescrever conteúdo do template (só promovê-lo a gabarito obrigatório).

## Acceptance Criteria
- [x] AC1: design aprovado pelo usuário (6 forks + 3 confirmações finais + Decisão #10 — ver QA.md).
- [x] AC2: spec escrito em doc/specs/2026-06-19-pipeline-arquitetura-v2-design.md (rev 1.1).
- [x] AC3: QA.md registra o brainstorming (dogfooding da feature; Q&A do atualizador apendado no mesmo turno da resposta).
- [x] AC4: usuário revisou o spec v1.1 e aprovou (Decisão #10 confirmada via QA.md verbatim "deva ser somente uma task").
- [x] AC5: plano de implementação criado: doc/planos/2026-06-19-pipeline-arquitetura-v2.md (26 tasks em 9 fases A-I; TDD genuíno para validar-doc.sh com 17 casos).

## Checklist (status vivo)
- [x] brainstorming (explorar contexto via workflow de mapeamento + grilling fork-a-fork)
- [x] escrever spec v1.0 + QA.md + TASK.md
- [x] auto-revisão adversarial do spec (painel de 4 críticos: completude / fidelidade / consistência / ambiguidade — 28 findings)
- [x] aplicar correções: spec v1.1 (ver §13 do spec — resumo dos 28 findings resolvidos)
- [x] revisão do spec v1.1 pelo usuário (aprovado; Decisão #10 confirmada)
- [x] writing-plans (plano de implementação em doc/planos/2026-06-19-pipeline-arquitetura-v2.md)
- [ ] execução do plano (próximo turno — modo a escolher: subagent-driven / inline)
