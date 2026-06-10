# Engineering Discipline Style Guide — trilha `engenharia`

> Lido automaticamente pelo Amazon Q em todo workspace que contenha esta pasta.
> Governa a **trilha de engenharia** do pack: disciplinas de processo portadas do superpowers
> (debugging sistemático, planejamento de implementação, verificação antes de concluir).
> **Complementa** as demais rules — vale para QUALQUER tarefa de código, não só documentação.

---

## 0. STATUS DESTA TRILHA

| Pasta / arquivo | Status | Como usar |
|---|---|---|
| `.amazonq/rules/engenharia-style.md` (esta) | **REGRA** | Disciplina de conclusão sempre ativa + hooks da trilha. |
| `prompts/engenharia/*.md` | **REGRA** (metodologia) | Carregue conforme a tabela de hooks § 1. |

**Sem gate de contexto:** as disciplinas desta trilha funcionam em qualquer repositório,
com ou sem contexto de projeto. Quando o contexto existir, use-o.

---

## 1. Hooks — gatilho → prompt (engenharia)

| Quando o usuário pedir / mencionar | Carregue |
|---|---|
| "debugga", "investiga esse bug", "não funciona", "causa raiz", "por que está quebrando", "teste falhando" | `prompts/engenharia/depurador-sistematico.md` |
| "planeja a implementação", "plano de implementação", "quebra em etapas", "como implementar isso passo a passo" | `prompts/engenharia/planejador-de-implementacao.md` |

Pedido ambíguo entre investigar e implementar ("conserta o X") → primeiro o depurador
(causa raiz demonstrada), depois proponha o planejador se a correção for maior que um fix pontual.

---

## 2. Disciplina de conclusão (sempre ativa)

Porte destilado de `superpowers:verification-before-completion`. Vale para TODA resposta
que afirme progresso ou conclusão, em qualquer trilha deste pack:

- **Nunca afirme "pronto", "corrigido", "funcionando" ou "passando" sem ter rodado o comando
  de verificação na MESMA resposta e mostrado o output real.**
- Teste falhando é reportado como **falhando**, com o output. Não minimize, não prometa.
- Passo pulado é **declarado** ("não rodei X porque Y") — nunca omitido.
- Build/teste que você não pode executar → diga explicitamente que a verificação está
  pendente e qual comando o usuário deve rodar.
- Evidência ANTES de afirmação. Sem exceção.

---

## 3. O que esta trilha NÃO cobre

- Convenções de documentação (trilhas `arquitetura`/`negocio`) e visual (`frontend`).
- Orquestração de subagentes/worktrees — específica de outros harnesses; não tente emular.
