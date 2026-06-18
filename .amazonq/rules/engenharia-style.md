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
| `ia/prompts/engenharia/*.md` | **REGRA** (metodologia) | Carregue conforme a tabela de hooks § 1. |

**Sem gate de contexto:** as disciplinas desta trilha funcionam em qualquer repositório,
com ou sem contexto de projeto. Quando o contexto existir, use-o.

---

## 1. Hooks — gatilho → prompt (engenharia)

| Quando o usuário pedir / mencionar | Carregue |
|---|---|
| "debugga", "investiga esse bug", "não funciona", "causa raiz", "por que está quebrando", "teste falhando" | `ia/prompts/engenharia/depurador-sistematico.md` |
| "planeja a implementação", "plano de implementação", "quebra em etapas", "como implementar isso passo a passo" | `ia/prompts/engenharia/planejador-de-implementacao.md` |
| "escreve a spec", "especifica isso", pedido vago sem comportamento/critérios definidos | `ia/prompts/engenharia/especificador.md` |
| "grilla o plano", "estressa esse plano", "revisa o plano antes de executar", "pre-mortem do plano" | `ia/prompts/engenharia/grill-plano.md` |
| "executa o plano", "implementa o plano aprovado", "segue o plano" | `ia/prompts/engenharia/executor-de-plano.md` |
| "TDD", "test-first", "escreve o teste primeiro", etapa de código dentro de um plano | `ia/prompts/engenharia/tdd-disciplinado.md` |
| "refatora", "limpa esse código", "reduz a duplicação", "extrai isso", "renomeia sem mudar comportamento" | `ia/prompts/engenharia/refatorador-incremental.md` |
| "estratégia de testes", "que testes escrever", "falta cobertura", "testes de regressão", "que nível de teste" | `ia/prompts/engenharia/estrategista-de-testes.md` |
| "revisa esse código", "code review", "revisa o PR/diff", "o que tem de errado aqui" | `ia/prompts/engenharia/revisor-de-codigo.md` |

Pedido ambíguo entre investigar e implementar ("conserta o X") → primeiro o depurador
(causa raiz demonstrada), depois proponha o planejador se a correção for maior que um fix pontual.
Dúvida ainda pré-decisão ("não sei qual abordagem") → `ia/prompts/arquitetura/brainstorm-arquitetural.md` primeiro (ver architecture-style § 2).

**Fluxo completo de uma feature** (cada elo é opcional, a ordem não):
pedido vago → `especificador` → (abordagem em aberto? `brainstorm-arquitetural` → `gerador-adr`)
→ `planejador-de-implementacao` → `grill-plano` → aprovação → `executor-de-plano`
(com `tdd-disciplinado` em cada etapa de código).

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
- Orquestração de subagentes/worktrees tem agora skills próprias importadas
  (`ia/skills/orquestracao/` — subagent-driven-development, dispatching-parallel-agents; e
  `ia/skills/fluxo-dev/` — using-git-worktrees, finishing-a-development-branch): use-as nos
  harnesses que suportam (Claude Code, Copilot CLI, Kiro). Onde o harness não suporta, não
  tente emular à mão.
