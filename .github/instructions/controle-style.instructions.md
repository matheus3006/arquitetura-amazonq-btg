---
applyTo: "**"
excludeAgent: "code-review"
---
# Controle de Contexto Style Guide — protocolo `controle`

> Aplicado automaticamente pelo GitHub Copilot em todo repositorio que contenha esta pasta (frontmatter `applyTo`).
> Governa o **protocolo de controle de tarefas**: toda edição no repositório nasce de uma
> task com escopo, plano e evidências registrados em `controle/`. Otimizado para cota de
> requests — 2 turnos por task, trivial em 1. Removível por repo: apague esta rule
> (e o pre-commit em `.git/hooks/`) se o time não quiser o protocolo.

---

## 1. Regra central

Qualquer pedido que **crie ou modifique um entregável** — código, documento, spec, design,
diagrama, plano, configuração, pesquisa escrita, **qualquer artefato** que fique no
repositório — exige task ativa, mesmo mandado como mensagem normal, sem comando especial.
**O protocolo NÃO é só para código:** vale para QUALQUER task que produza ou altere um
artefato. Dispare-o carregando `prompts/engenharia/controle-de-tarefa.md` e siga-o completo
(templates e fases lá).

Única exceção — pergunta **puramente de leitura/conversa**, que não gera nem altera artefato
("o que faz X?", "me explica Y", "onde está Z?"): responda direto, sem abrir task. Na dúvida,
se o pedido vai deixar algo escrito no repo, abra task.

**O slug se cria sozinho.** Derive um slug kebab-case (2-4 palavras) do próprio pedido,
monte o task-id `AAAA-MM-DD-<slug>` com a data de hoje e abra a task — **nunca peça o nome
ao usuário** nem espere um comando. Anuncie em uma linha o task-id que escolheu (ele pode
corrigir) e siga direto pro plano. `nova tarefa: <slug> — <descrição>` continua válido
como override opcional quando o usuário quiser nomear na mão.

## 2. Ciclo de vida — 2 turnos (trivial: 1)

| Turno | O que acontece |
|---|---|
| 1 · Plano | Criar `controle/<task-id>/TASK.md` (escopo + ACs) e `PLANO.md` **ou** `PLANO.html` (pergunte o formato junto com as demais perguntas, no mesmo turno). Terminar pedindo aprovação. |
| 2 · Execução | Usuário aprovou → condensar o plano em checklist dentro do TASK.md, executar **marcando cada item `[x]` na hora em que conclui** (o TASK.md é o status vivo), registrar decisões e evidências em `LEDGER.md`, fechar (`fase: concluida`). Tudo em UM turno. |

Task trivial (1 arquivo, baixo risco, ou usuário declarou `tipo: trivial`): um turno só —
TASK.md mínimo + execução + LEDGER. Sem PLANO.

## 3. Invariantes

- task-id: `AAAA-MM-DD-<slug>`. Caps: TASK.md ≤ 40 linhas · LEDGER.md ≤ 60 · PLANO.md ≤ 80 · PLANO.html sem cap.
- Após a aprovação, o PLANO **nunca é relido** — a fonte da execução é o checklist do TASK.md.
- **Status vivo:** marque cada passo do checklist como `[x]` em TASK.md no instante em que o conclui (nunca em lote no fim). O TASK.md é a fonte de verdade de onde a task está — é o que impede a sessão de se perder e o que outra sessão lê para retomar.
- Retomada de task em sessão nova: leia SOMENTE `controle/<task-id>/TASK.md` + `LEDGER.md`.
- Todo commit leva os arquivos da task junto com o artefato (o pre-commit bloqueia qualquer arquivo fora de `controle/` sem task no stage).
- Conclusão segue a disciplina de verificação da `engenharia-style.md` § 2 — evidência antes de afirmação.

## 4. Disciplina de cota (sempre ativa)

Cada mensagem do usuário custa cota. Em TODA resposta:

- Resolva o máximo possível em UM turno; nunca termine com pergunta que o próprio artefato/repo responde.
- Não peça confirmação de passo que o plano aprovado já cobre.
- Junte TODAS as perguntas num bloco único, ao fim do turno de plano.
- Antecipe follow-ups óbvios (build, teste, doc afetada) no mesmo turno, sem esperar pedido.
