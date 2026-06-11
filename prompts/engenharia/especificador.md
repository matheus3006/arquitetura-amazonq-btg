# Prompt — Especificador (pedido vago → spec mínima)

> ## STATUS
>
> Parte da **trilha de engenharia** do pack. Referenciado pela rule da trilha `engenharia` § 1
> (`.amazonq/rules/engenharia-style.md` ou `.github/instructions/engenharia-style.instructions.md`, conforme a ferramenta).
>
> Roda **antes** do planejador, quando o pedido ainda não tem comportamento e critérios
> definidos. A spec decide **o que** o software deve fazer — não **como**.

Adaptado da skill `to-prd` (mattpocock) para serviços .NET: transforma um pedido vago
("melhora o X", "adiciona suporte a Y") numa spec curta com critérios verificáveis.

## Quando usar
- Pedido sem comportamento definido nem critérios de aceite ("dá um jeito no fluxo de estorno").
- Antes de `planejador-de-implementacao.md` quando a resposta a "pronto quando?" é "não sei".

## Pré-requisito (gate de entrada)

A spec NÃO decide arquitetura. Se a dúvida é "qual abordagem/tecnologia" → pare e sugira
`prompts/arquitetura/brainstorm-arquitetural.md` (e `gerador-adr.md` para registrar).
Se já existe spec e falta só o passo-a-passo → vá direto ao planejador.

## Metodologia — 3 passos

### Passo 1 — Explorar antes de escrever
Leia o que o workspace já responde: `project-context.md` e `business-context.md` (no
destino da sua ferramenta — use o glossário do domínio em toda a spec), ADRs na área
tocada (respeite-as), e o código do fluxo afetado. **Não invente requisito**: o que o
código e o contexto não respondem e o usuário não disse, vire pergunta — num bloco
único — ou marque `[a confirmar]`.

### Passo 2 — Costuras de teste (seams)
Identifique ONDE o comportamento novo será testado. Prefira costuras que já existem; use
a mais alta possível (handler/endpoint > service > método privado). Costura nova só se
inevitável, proposta no ponto mais alto. **Confirme as costuras com o usuário** antes de
fechar a spec — junto com as demais perguntas do Passo 1.

### Passo 3 — Escrever e salvar
Preencha o template abaixo e salve em `docs/specs/<AAAA-MM-DD>-<slug>.md`. No chat, só o
resumo: problema em 1 frase, nº de critérios, pendências `[a confirmar]`, próximo passo.

## Template da spec

```markdown
# Spec — <título curto>

## Problema
<Da perspectiva de quem sofre o problema — usuário, operação, sistema consumidor. Sem solução aqui.>

## Comportamento esperado
<O que o sistema passa a fazer, observável de fora. Sem nome de classe, sem path.>

## Critérios de aceite
- [ ] AC1: <verificável por teste ou inspeção — "dado X, quando Y, então Z">
- [ ] AC2: …

## Decisões de implementação
<Só as já tomadas: módulos afetados, contratos/schemas que mudam, interações. SEM paths
de arquivo e SEM código — desatualizam rápido. Exceção: snippet que encode uma decisão
melhor que prosa (shape de schema, máquina de estados), aparado ao essencial.>

## Decisões de teste
<Costuras confirmadas no Passo 2 · o que é comportamento externo (testar) vs detalhe
interno (não testar) · prior art: testes parecidos já existentes no repo.>

## Fora de escopo
<O que explicitamente NÃO entra — corta ambiguidade barato.>

## Pendências
<Itens [a confirmar] e com quem.>
```

## Auto-revisão antes de entregar

- [ ] Todo AC é verificável (teste ou inspeção objetiva)?
- [ ] Zero paths de arquivo e zero código especulativo no corpo?
- [ ] Termos batem com o glossário do `business-context.md` (quando existe)?
- [ ] Nada inventado — tudo veio do código, do contexto, do usuário, ou está `[a confirmar]`?
- [ ] Fora de escopo preenchido?

## Saída esperada

Um arquivo `docs/specs/<AAAA-MM-DD>-<slug>.md` + resumo no chat. Próximo passo natural:
`planejador-de-implementacao.md` (a spec é a "decisão de origem" do plano).

## Exemplo de invocação

> "Precisamos melhorar o fluxo de estorno" — antes de planejar qualquer coisa, use
> `prompts/engenharia/especificador.md`: explore o código, me pergunte o que faltar num
> bloco único e escreva a spec com critérios de aceite verificáveis.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/especificador` |
| Copilot CLI | Gatilho natural ("escreve a spec") — a instruction roteia |
| Kiro (IDE / CLI) | Gatilho natural — a Agent Skill ativa por descrição |

## Referências
- Núcleo adaptado: `to-prd` (mattpocock), sem issue tracker e sem inventário extenso de user stories.
- Decisão de arquitetura em aberto: `prompts/arquitetura/brainstorm-arquitetural.md` → `gerador-adr.md`.
- Consome a spec: `prompts/engenharia/planejador-de-implementacao.md`.
- Regras de negócio citadas vêm do `business-context.md` (trilha `negocio`).
