# Índice da trilha de doc de arquitetura — 7 etapas, 8 sessões

**LEIA ESTE BLOCO ANTES DE QUALQUER COISA:**

- A trilha de doc de arquitetura são **7 etapas conceituais** correspondendo a **8 sessões** (Etapa 1 tem 2 sessões).
- **Rode TODAS na ordem 1→7, cada PROMPT em sessão própria** (regra master).
- Este prompt **não orquestra** — ele é só o índice + handoff inicial. Quem gera/valida é cada prompt abaixo, em sessão nova.
- Antes da Etapa 1, abra a **task de controle** (`doc/controle/<AAAA-MM-DD-slug>/` com `TASK.md` + `QA.md` + `LEDGER.md`).

## Sequência

| Etapa | Sessão | Prompt | Onde | Tipo |
|---|---|---|---|---|
| 1 | 1a | `analisador-de-projeto` | `ia/prompts/arquitetura/` | geração — contexto |
| 1 | 1b | `analisador-de-dominio` | `ia/prompts/negocio/` (reusado pela trilha arquitetura) | geração — domínio |
| 2 | 2  | `arquiteto-de-sistema` | `ia/prompts/arquitetura/` | geração — espinha |
| 3 | 3  | `documentador-fluxo`   | `ia/prompts/arquitetura/` | geração — fluxos |
| 4 | 4  | `gerador-runbook`      | `ia/prompts/arquitetura/` | geração — runbook |
| 5 | 5  | `grill-arquitetura`    | `ia/prompts/arquitetura/` | validação **lógica** |
| 6 | 6  | `validador-visual`     | `ia/prompts/arquitetura/` | validação **visual** (só reporta) |
| 7 | 7  | `validador-sintaxe-mermaid` | `ia/prompts/arquitetura/` | validação **forma** (só reporta) |

## Destino canônico de saída

- Páginas geradas → `doc/arquitetura/`.
- ADRs → `doc/adr/`.
- `ia/templates/` é só **gabarito de FORMA** (referência) — nunca destino de gravação.

## QA-ledger (registra o input do usuário)

- A task de controle ganha um `QA.md` (template em `controle-de-tarefa.md`).
- Cada par pergunta → resposta é apendado **no mesmo turno** em que a resposta chega (status vivo).
- Regra binária: **verbatim** sempre que houver decisão (escolha entre opções, nome de tecnologia, restrição numérica); **normalizada** (1 linha) caso contrário.

## NAV (responsabilidade do gerador)

Cada etapa que cria um `.html` em `doc/arquitetura/` (Etapas 2, 3, 4) **DEVE** apendar a entry `{label, href}` na seção certa do `NAV` em `sidebar.js` **no mesmo passo**. Página sem entry = órfã = rejeitada pelo validador #6.

## Próximo passo

> Abra a task de controle e rode a Etapa 1, sessão 1a: **`analisador-de-projeto`** (em sessão própria).

## Para doc JÁ existente

Não use a trilha 1→7 — use o **`atualizador-arquitetura`** (prompt complementar, fora da trilha numerada).
