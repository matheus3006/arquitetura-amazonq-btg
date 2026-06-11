# Prompt — Controle de Tarefa

> ## STATUS
>
> Este prompt é referenciado pela rule do protocolo `controle` (`.amazonq/rules/controle-style.md`
> ou `.github/instructions/controle-style.instructions.md`, conforme a ferramenta).
>
> Carregue-o UMA vez por task, no turno de plano. Depois disso a fonte de verdade é o
> próprio `controle/<task-id>/` — não recarregue este arquivo durante a execução.

Protocolo de controle de contexto otimizado para cota de requests: o trabalho inteiro de
uma task cabe em **2 turnos** (trivial: 1), e qualquer retomada custa no máximo 100 linhas
de leitura (TASK.md + LEDGER.md).

## Quando usar
- O usuário escreveu `nova tarefa: <slug> — <descrição>`.
- O usuário pediu qualquer edição no repositório e não há task ativa em `controle/`.

## Estrutura de uma task

```
controle/<AAAA-MM-DD>-<slug>/
├── TASK.md     ≤ 40 linhas — contrato: escopo, ACs, fase, checklist (após aprovação)
├── LEDGER.md   ≤ 60 linhas — histórico: decisões e evidências de verificação
└── PLANO.md    ≤ 80 linhas — OU PLANO.html (sem cap; formato escolhido pelo usuário)
```

Task trivial não tem PLANO — só TASK.md + LEDGER.md.

## Turno 1 — Plano

1. Crie `controle/<task-id>/TASK.md` pelo template abaixo, com `fase: planejamento`.
2. Crie o PLANO. Etapas no formato do `prompts/engenharia/planejador-de-implementacao.md`
   (arquivos exatos, mudança concreta, verificação, pronto quando) — para mudança que toca
   3+ arquivos, siga aquele prompt por inteiro.
3. Termine a resposta com: resumo do plano em ≤ 6 bullets + **bloco único de perguntas**
   (inclua a escolha `PLANO.md` ou `PLANO.html` se o usuário ainda não disse; default: `.md`)
   + pedido de aprovação.

Proibido no turno 1: editar qualquer arquivo fora de `controle/<task-id>/`.

## Turno 2 — Execução (após "aprovado")

1. Condense o plano aprovado em checklist numerado dentro do TASK.md; mude para `fase: execucao`.
   A partir daqui o PLANO **não é relido** — execute pelo checklist.
2. Execute o checklist inteiro. Decisão tomada no meio do caminho → 1 linha no LEDGER.md, na hora.
3. Verifique cada AC com comando real e registre o output (resumido) em LEDGER.md § Verificação
   — disciplina da `engenharia-style.md` § 2: evidência antes de afirmação.
4. Feche: `fase: concluida` no TASK.md, ACs marcados, pendências (se houver) na última seção
   do LEDGER.md. Commit inclui código + arquivos da task juntos.

Bloqueou no meio (falta decisão do usuário)? Registre o bloqueio no LEDGER, pare e pergunte
TUDO que falta num bloco só — não pingue uma pergunta por turno.

## Retomada (sessão nova)

Leia `controle/<task-id>/TASK.md` + `LEDGER.md`. Nada mais — nem PLANO, nem histórico de
chat. O checklist diz onde parou; o LEDGER diz o que já foi decidido.

## Template — TASK.md

```markdown
---
fase: planejamento   # planejamento | execucao | concluida | bloqueada
tipo: normal         # normal | trivial
task_id: AAAA-MM-DD-slug
---

## Objetivo
<1-2 frases: o que entrega e por quê>

## Escopo
- <o que entra>

## Fora de escopo
- <o que NÃO entra — corta ambiguidade barato>

## Acceptance Criteria
- [ ] AC1: <observável e verificável por comando ou inspeção>

## Checklist (preenchido na aprovação, a partir do PLANO)
- [ ] 1. <passo concreto>
```

## Template — LEDGER.md

```markdown
# Ledger — <slug>

## Decisões
- AAAA-MM-DD — <decisão em 1 linha + motivo curto>

## Verificação
- AC1: <comando rodado → resultado real> — passed|failed

## Pendências
- <vazio ou itens que ficaram para outra task>
```

## Template — PLANO.html (quando o usuário escolher visual)

Esqueleto mínimo usando o design system do pack (ajuste o caminho relativo se necessário):

```html
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8">
<title>Plano — [TASK_ID]</title>
<link rel="stylesheet" href="../../docs/arquitetura/design-system/tokens.css">
<link rel="stylesheet" href="../../docs/arquitetura/design-system/components.css">
</head><body>
<main class="container">
  <h1>Plano — [TÍTULO]</h1>
  <p><strong>Objetivo:</strong> … · <strong>Maior risco:</strong> …</p>
  <section><h2>Etapa N — [título]</h2>
    <p><strong>Arquivos:</strong> … <strong>Mudança:</strong> …
       <strong>Verificação:</strong> … <strong>Pronto quando:</strong> …</p>
  </section>
</main></body></html>
```

## Auto-revisão antes de pedir aprovação (turno 1)

- [ ] TASK.md ≤ 40 linhas, com fora-de-escopo e ACs verificáveis?
- [ ] Toda etapa do PLANO tem os 4 campos (arquivos, mudança, verificação, pronto quando)?
- [ ] As perguntas estão TODAS num bloco único no fim (incluindo formato do plano)?
- [ ] Nenhum arquivo fora de `controle/` foi tocado?

## Exemplo de invocação

> nova tarefa: idempotencia-redis — mover chave de idempotência do Postgres para Redis

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | `nova tarefa: <slug> — <descrição>` — a rule roteia para este prompt |
| Copilot (VS Code / Visual Studio / JetBrains) | `/controle-de-tarefa` ou a mesma mensagem |
| Copilot CLI | Gatilho natural (`nova tarefa: ...`) — a instruction roteia |

## Referências
- Protocolo resumido + disciplina de cota: `.amazonq/rules/controle-style.md` ou `.github/instructions/controle-style.instructions.md`, conforme a ferramenta
- Planos grandes (3+ arquivos): `prompts/engenharia/planejador-de-implementacao.md`
- Bug no meio da execução: `prompts/engenharia/depurador-sistematico.md`
- Watchdog determinístico: pre-commit instalado pelo `install.sh` do pack (bypass: `git commit --no-verify`)
