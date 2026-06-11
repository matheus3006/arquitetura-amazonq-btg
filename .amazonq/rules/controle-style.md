# Controle de Contexto Style Guide — protocolo `controle`

> Lido automaticamente pelo Amazon Q em todo workspace que contenha esta pasta.
> Governa o **protocolo de controle de tarefas**: toda edição no repositório nasce de uma
> task com escopo, plano e evidências registrados em `controle/`. Otimizado para cota de
> requests — 2 turnos por task, trivial em 1. Removível por repo: apague esta rule
> (e o pre-commit em `.git/hooks/`) se o time não quiser o protocolo.

---

## 1. Regra central

Edição fora de `controle/` exige task ativa. **Qualquer pedido que mexa em código** —
mandado como mensagem normal, sem comando especial — dispara o protocolo: carregue
`prompts/engenharia/controle-de-tarefa.md` e siga-o completo (templates e fases lá).

**O slug se cria sozinho.** Derive um slug kebab-case (2-4 palavras) do próprio pedido,
monte o task-id `AAAA-MM-DD-<slug>` com a data de hoje e abra a task — **nunca peça o nome
ao usuário** nem espere um comando. Anuncie em uma linha o task-id que escolheu (ele pode
corrigir) e siga direto pro plano. `nova tarefa: <slug> — <descrição>` continua válido
como override opcional quando o usuário quiser nomear na mão.

## 2. Ciclo de vida — 2 turnos (trivial: 1)

| Turno | O que acontece |
|---|---|
| 1 · Plano | Criar `controle/<task-id>/TASK.md` (escopo + ACs) e `PLANO.md` **ou** `PLANO.html` (pergunte o formato junto com as demais perguntas, no mesmo turno). Terminar pedindo aprovação. |
| 2 · Execução | Usuário aprovou → condensar o plano em checklist dentro do TASK.md, executar, registrar decisões e evidências em `LEDGER.md`, fechar (`fase: concluida`). Tudo em UM turno. |

Task trivial (1 arquivo, baixo risco, ou usuário declarou `tipo: trivial`): um turno só —
TASK.md mínimo + execução + LEDGER. Sem PLANO.

## 3. Invariantes

- task-id: `AAAA-MM-DD-<slug>`. Caps: TASK.md ≤ 40 linhas · LEDGER.md ≤ 60 · PLANO.md ≤ 80 · PLANO.html sem cap.
- Após a aprovação, o PLANO **nunca é relido** — a fonte da execução é o checklist do TASK.md.
- Retomada de task em sessão nova: leia SOMENTE `controle/<task-id>/TASK.md` + `LEDGER.md`.
- Todo commit leva os arquivos da task junto com o código (o pre-commit bloqueia código sem task no stage).
- Conclusão segue a disciplina de verificação da `engenharia-style.md` § 2 — evidência antes de afirmação.

## 4. Disciplina de cota (sempre ativa)

Cada mensagem do usuário custa cota. Em TODA resposta:

- Resolva o máximo possível em UM turno; nunca termine com pergunta que o código responde.
- Não peça confirmação de passo que o plano aprovado já cobre.
- Junte TODAS as perguntas num bloco único, ao fim do turno de plano.
- Antecipe follow-ups óbvios (build, teste, doc afetada) no mesmo turno, sem esperar pedido.
