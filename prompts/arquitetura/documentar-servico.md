# Prompt — Documentar Serviço (Etapa 1 de 3 · fundação + arquitetura)

> ## STATUS
>
> Este prompt é referenciado pela rule da trilha `arquitetura` § 2 (`.amazonq/rules/architecture-style.md` ou `.github/instructions/architecture-style.instructions.md`, conforme a ferramenta).
>
> É a **Etapa 1 do fluxo canônico de documentação do zero** (3 etapas obrigatórias):
> **1. `documentar-servico` (este)** → 2. `completar-documentacao` (fluxos + runbook) →
> 3. `grill-arquitetura` (grill intenso, em outra sessão).
>
> **Orquestrador, não reescrita:** este prompt **chama** os processos de
> `analisador-de-projeto.md`, `analisador-de-dominio.md` e `arquiteto-de-sistema.md` em
> sequência — cada um continua sendo a metodologia daquela fase. A **única regra rígida de
> visual** é a convenção de diagramas em `architecture-style.md` § 1.

## Quando usar
- "documentar o serviço do zero", "começar a documentação", "preparar e documentar este repo", primeira passada completa de doc técnica.
- Substitui a necessidade de rodar `analisador-de-projeto` e depois `arquiteto-de-sistema` na mão: aqui é um fluxo só, com checkpoint seu entre as fases.

Não use para: refresh pontual de UMA página (use o prompt-base direto) nem para fluxo/runbook (isso é a Etapa 2).

## Stack de skills (qualidade top tier — use em todas as fases)
- `skills/arquitetura/human-architect-mindset/SKILL.md` — modelo de domínio e restrições antes de tecnologia.
- `skills/arquitetura-review/improve-codebase-architecture/SKILL.md` — ler a arquitetura real do código (não a aspiracional).
- `skills/documentacao/doc-coauthoring/SKILL.md` — co-autoria: juntar contexto → refinar/estruturar → testar com o leitor.
- `skills/backend/verification-before-completion/SKILL.md` — nada de "pronto" sem evidência; o que não foi confirmado vira `[a confirmar]`.

## Metodologia — 3 fases com gate (checkpoint do usuário entre cada uma)

### Fase A — Contexto técnico  (gate de tudo)
Rode TODO o processo de `prompts/arquitetura/analisador-de-projeto.md`: detecte stack e
padrões do código, pergunte o que o código não revela (uma por vez), inclua a lista negativa
e grave `project-context.md` nos TRÊS destinos (Amazon Q, Copilot, Kiro).

**Gate de saída:** os três `project-context.md` existem, idênticos, e o usuário revisou o resumo. **PARE e confirme** antes da Fase B.

### Fase B — Domínio de negócio
Rode TODO o processo de `prompts/negocio/analisador-de-dominio.md`: regras candidatas no
código, atores, eventos, grilling por fases, e grave `business-context` nos TRÊS destinos.

**Gate de saída:** os três `business-context` existem, idênticos, e o usuário revisou o resumo. **PARE e confirme** antes da Fase C.

### Fase C — Arquitetura (a espinha do template)
Rode TODO o processo de `prompts/arquitetura/arquiteto-de-sistema.md`: as 5 perguntas-âncora
+ o grilling ramo a ramo (1ª passada — o exaustivo é a Etapa 3), produzindo as páginas HTML
no padrão da casa. Cubra a **espinha**:
- **Visão geral** (`01-visao-geral` como referência de forma) — propósito, contexto, integrações, fluxo principal, stack, quality goals.
- **Páginas-núcleo que derivam direto** do contexto+domínio: padrões transacionais aplicáveis, modelo de dados, infraestrutura — **só as que o código sustenta** (não force páginas do exemplo que não se aplicam).

Cada decisão difícil-de-reverter + surpreendente + com trade-off real → ofereça ADR
(`gerador-adr.md`). Incerteza que o código não fecha → marque `⚠ a confirmar` (a Etapa 3 ataca isso).

**Gate de saída:** páginas geradas com os diagramas na convenção rígida (§ 1), conteúdo do serviço REAL (zero "Liquidação Transacional"), e cada `⚠` explicitamente aceito pelo usuário ou deixado para a Etapa 3.

## Handoff (obrigatório no fim)
Feche entregando, em uma linha clara:

> **Etapa 1 concluída.** Contexto + domínio + arquitetura (espinha) gerados. **Próximo passo
> obrigatório:** rode a **Etapa 2 — `completar-documentacao.md`** (fluxos críticos + runbook).
> Depois dela, a **Etapa 3 — `grill-arquitetura.md`** numa sessão nova.

## Regras de comportamento
- Não pule fase nem o gate dela — cada fase alimenta a próxima; contexto/domínio incompletos produzem arquitetura que mente.
- Não duplique a metodologia dos prompts-base — siga cada um por inteiro, não a sua lembrança dele.
- Não invente SLO, latência, stack nem regra — o que ninguém confirmou vira `[a confirmar com <quem>]`.
- Disciplina de conclusão (`engenharia-style.md` § 2): afirmação só com evidência.

## Saída esperada
1. Resumo por fase (o que foi gerado, onde).
2. Lista dos `⚠ a confirmar` que passam pra Etapa 3.
3. O handoff acima.

## Exemplo de invocação

> Quero documentar do zero o serviço de Conciliação Bancária (repo `conciliacao-banco`).
> Siga `prompts/arquitetura/documentar-servico.md` — Etapa 1 do fluxo de 3 etapas.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/documentar-servico` |
| Copilot CLI | Gatilho natural ("documentar o serviço do zero") — a instruction roteia |
| Kiro (IDE / CLI) | Descreva o pedido — a Agent Skill ativa por descrição |

## Referências
- Etapa 2: `prompts/arquitetura/completar-documentacao.md` · Etapa 3: `prompts/arquitetura/grill-arquitetura.md`.
- Prompts-base orquestrados: `analisador-de-projeto.md`, `prompts/negocio/analisador-de-dominio.md`, `arquiteto-de-sistema.md`.
- Convenção de diagramas (regra rígida): `architecture-style.md` § 1. Esqueleto HTML: `frontend-style.md` § 1.
