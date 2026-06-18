# Prompt — Completar a Documentação (Etapa 2 de 3 · fluxos + operação)

> ## STATUS
>
> Este prompt é referenciado pela rule da trilha `arquitetura` § 2 (`.amazonq/rules/architecture-style.md` ou `.github/instructions/architecture-style.instructions.md`, conforme a ferramenta).
>
> É a **Etapa 2 do fluxo canônico de documentação do zero** (3 etapas obrigatórias):
> 1. `documentar-servico` (fundação + arquitetura) → **2. `completar-documentacao` (este)** →
> 3. `grill-arquitetura` (grill intenso, em outra sessão).
>
> **Orquestrador, não reescrita:** chama os processos de `documentador-fluxo.md` e
> `gerador-runbook.md` em sequência. Regra rígida de visual: diagramas em `architecture-style.md` § 1.

## Quando usar
- Logo **após a Etapa 1** (`documentar-servico`): a espinha de arquitetura existe, falta o runtime e a operação.
- "completar a documentação", "documentar os fluxos e o runbook", "fechar a doc técnica".

Pré-requisito: `project-context` + `business-context` + a visão geral já existem (Etapa 1). Se não existem, volte pra Etapa 1.

## Stack de skills (qualidade top tier)
- `ia/skills/arquitetura-review/improve-codebase-architecture/SKILL.md` — confirmar cada chamada/estado no código real.
- `ia/skills/documentacao/doc-coauthoring/SKILL.md` — estruturar e testar a doc com o leitor (quem vai usar o runbook às 3h).
- `ia/skills/backend/verification-before-completion/SKILL.md` — nenhum SLO/threshold/fluxo inventado; o que falta vira `[a confirmar]`.

## Metodologia — 2 fases com gate (checkpoint do usuário entre cada uma)

### Fase A — Fluxo(s) crítico(s)
Para o(s) fluxo(s) mais crítico(s) do serviço, rode TODO o processo de
`ia/prompts/arquitetura/documentador-fluxo.md`: sequence diagram com `autonumber` (e `BEGIN/COMMIT`
onde houver transação), payloads relevantes, e os estados de erro, retry e timeout —
**confirmando cada chamada no código antes de desenhar** (nada de fluxo aspiracional).

**Gate de saída:** caminho feliz + caminhos de falha desenhados, batendo com o código. Mais de um fluxo crítico? combine com o usuário quantos entram agora. **PARE e confirme** antes da Fase B.

### Fase B — Runbook operacional
Rode TODO o processo de `ia/prompts/arquitetura/gerador-runbook.md`: cada failure mode com
sintoma observável, query de log/métrica pra confirmar, ação imediata e mitigação permanente.
**Não invente** SLO, threshold nem nome de dashboard — pergunte num bloco único o que o código
e a config não revelam.

**Gate de saída:** todo failure mode com os 4 campos preenchidos e nenhum valor inventado.

## Handoff (obrigatório no fim)
Feche entregando, em uma linha clara:

> **Etapa 2 concluída.** Fluxos críticos + runbook gerados. **Próximo passo obrigatório:**
> em uma **sessão nova**, rode a **Etapa 3 — `grill-arquitetura.md`** sobre toda a documentação
> gerada (Etapas 1 e 2) — o grill intenso que ataca as incertezas, código-primeiro.

> Por que sessão nova: a Etapa 3 relê a doc com olhos frescos; herdar o contexto de geração
> contamina a busca por incertezas.

## Regras de comportamento
- Confirme tudo no código antes de desenhar/afirmar — fluxo ou failure mode aspiracional é pior que ausência.
- Não duplique a metodologia dos prompts-base — siga cada um por inteiro.
- Incerteza que o código não fecha → `⚠ a confirmar` (a Etapa 3 ataca).
- Disciplina de conclusão (`engenharia-style.md` § 2): evidência antes de afirmação.

## Saída esperada
1. Resumo do que foi gerado (fluxos + runbook, com paths).
2. Lista dos `⚠ a confirmar` acumulados (Etapa 1 + Etapa 2) que a Etapa 3 vai atacar.
3. O handoff acima.

## Exemplo de invocação

> Etapa 1 do `conciliacao-banco` está pronta. Siga `ia/prompts/arquitetura/completar-documentacao.md`
> — Etapa 2: documente o fluxo de conciliação e o runbook.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/completar-documentacao` |
| Copilot CLI | Gatilho natural ("completar a documentação") — a instruction roteia |
| Kiro (IDE / CLI) | Descreva o pedido — a Agent Skill ativa por descrição |

## Referências
- Etapa 1: `ia/prompts/arquitetura/documentar-servico.md` · Etapa 3: `ia/prompts/arquitetura/grill-arquitetura.md`.
- Prompts-base orquestrados: `documentador-fluxo.md`, `gerador-runbook.md`.
- Convenção de diagramas (regra rígida): `architecture-style.md` § 1.
