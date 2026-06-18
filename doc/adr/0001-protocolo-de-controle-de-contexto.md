# ADR-0001 — Protocolo de controle de contexto otimizado para cota de requests

- **Status:** aceita — decisões **2 (caminho)** e **5 (enforcement)** superadas pelo
  [ADR-0004](0004-hook-de-assistente-substitui-pre-commit.md) em 2026-06-17.
- **Data:** 2026-06-11
- **Autor:** Matheus (sessão de grilling com Claude Code)
- **Contexto de origem:** porte do controle de contexto dos projetos pessoais
  (delivery_cadillac, AlMaFlow, AlMaNutri) para o ambiente BTG, onde o Amazon Q tem
  cota de ~1000 requests/mês por dev.

> **Atualização (2026-06-17):** a premissa de que "Amazon Q/Copilot não têm hooks de
> assistente" caiu — o Amazon Q CLI (custom agents, GA jul/2025) tem `userPromptSubmit`
> e o Kiro tem `promptSubmit`. O enforcement deixou de ser o pre-commit punitivo (que
> bloqueava o commit do humano) e passou a ser um hook de início de interação que faz o
> agente abrir a task sozinho; o caminho mudou de `controle/` para `docs/controle/`. Ver
> [ADR-0004](0004-hook-de-assistente-substitui-pre-commit.md). O texto abaixo é histórico.

## Contexto e problema

O controle de contexto dos projetos pessoais usa 4 arquivos por task (LIMITES.md,
PLANO.html, ESTADO.md, LEDGER.md — caps somados ~410 linhas), ciclo de 7 fases com
aprovação canônica e watchdog hook do Claude Code. No BTG isso é inviável: cada
ida-e-volta no chat consome cota, Amazon Q/Copilot não têm hooks de assistente, e o
overhead de releitura infla o contexto de cada request.

## Decisões

1. **Onde vive:** dentro do pack `arquitetura` (rule + prompt + pre-commit),
   aproveitando instaladores e sync-copilot — não em repo separado.
2. **Formato por task:** `controle/<AAAA-MM-DD-slug>/` com TASK.md (≤40 linhas,
   contrato: escopo+ACs+fase+checklist) + LEDGER.md (≤60, decisões+evidências) +
   PLANO.md (≤80) **ou** PLANO.html (sem cap) — formato do plano escolhido pelo
   usuário por task. O HTML continua permitido porque a cota é por request, não por
   token de output; o custo real do HTML é releitura.
3. **Anti-releitura:** na aprovação, o plano é condensado em checklist dentro do
   TASK.md; o PLANO nunca mais é relido. Retomada de task lê SOMENTE TASK.md+LEDGER.md
   (≤100 linhas).
4. **Ciclo de vida:** 2 turnos (1: TASK+PLANO+pedido de aprovação · 2: checklist+
   execução+ledger+fechamento). Task trivial: 1 turno, sem PLANO.
5. **Enforcement:** rule sempre-on (`controle-style.md`) + pre-commit git determinístico
   (commit que toca código sem arquivos de task no stage é bloqueado). O git substitui
   o watchdog hook. Bypass: `git commit --no-verify`.
6. **Peso sempre-on:** rule dedicada enxuta (~45 linhas); protocolo completo e templates
   vivem em `prompts/engenharia/controle-de-tarefa.md`, carregado 1x por task.
7. **Disciplina de cota:** seção na rule — resolver o máximo por turno, perguntas em
   bloco único, sem confirmações desnecessárias, antecipar follow-ups óbvios.

## Consequências

- (+) ~2 requests por task vs ~4-5 do modelo original; retomada 4x mais barata.
- (+) Protocolo removível por repo (deletar rule + hook) sem afetar as 4 trilhas.
- (−) Sem hook de assistente, o turno 1 depende do modelo obedecer a rule; a rede
  determinística só pega no commit. Risco aceito.
- (−) Repos com pre-commit pre-existente exigem append manual (instaladores avisam).

## Validação

Medir num mês de uso real no BTG: requests gastos por task (alvo ≤ 3) e violações do
protocolo pegas pelo pre-commit. Se o turno único de execução se mostrar arriscado em
tasks grandes, promover a verificação a turno próprio (custo: +1 request/task).
