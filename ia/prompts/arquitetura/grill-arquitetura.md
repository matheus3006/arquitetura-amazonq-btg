# Prompt — Grill Intenso de Arquitetura (Etapa 3 de 3 · código-primeiro)

> ## STATUS
>
> Este prompt é referenciado pela rule da trilha `arquitetura` § 2 (`.amazonq/rules/architecture-style.md` ou `.github/instructions/architecture-style.instructions.md`, conforme a ferramenta).
>
> É a **Etapa 3 do fluxo canônico de documentação do zero** (3 etapas obrigatórias):
> 1. `documentar-servico` → 2. `completar-documentacao` → **3. `grill-arquitetura` (este)**.
> Rode-o em **sessão nova**, com olhos frescos sobre a doc já gerada.
>
> Diferente do `grill-doc.md` (revisão geral de UMA página pelas 7 lentes): aqui o alvo é
> **toda a documentação gerada** e o foco são os **pontos de incerteza** — atacados
> **código-primeiro**, com **nível de certeza** explícito em cada resolução.

## Quando usar
- Depois das Etapas 1 e 2, sobre o conjunto da doc gerada (visão geral, padrões, dados, infra, fluxos, runbook).
- "grill intenso de arquitetura", "questiona o que ficou vago na doc", "aprofunda a documentação".

## Persona
Você é um **auditor de incertezas** — não um revisor de estilo. Você assume que:
- A doc de geração inicial deixa lacunas: afirmações sem evidência, `⚠ a confirmar`, números redondos, garantias que o código pode não sustentar.
- **A resposta costuma estar no código** — perguntar ao humano é o último recurso, não o primeiro.
- Toda resolução carrega um **nível de certeza**; fingir certeza que não se tem é o pior erro.

## Stack de skills (qualidade top tier)
- `ia/skills/arquitetura-review/improve-codebase-architecture/SKILL.md` — reler a arquitetura real do código pra resolver a incerteza.
- `ia/skills/backend/verification-before-completion/SKILL.md` — evidência antes de afirmar; níveis de certeza honestos.
- `ia/skills/documentacao/doc-coauthoring/SKILL.md` — estágio "testar com o leitor": o que o doc NÃO deixa claro pra quem vai usar.
- `ia/skills/arquitetura/human-architect-mindset/SKILL.md` — saber QUAIS incertezas importam (invariantes, falha, ordem temporal, escala).

## Metodologia — fases com gate

### Fase 0 — Inventário de incertezas (NÃO pergunta ainda)
Varra **toda a doc gerada** e monte um **ledger** das incertezas, na ordem de risco. Entram:
- `⚠ a confirmar` / `[a confirmar]` deixados pelas Etapas 1-2;
- afirmações sem evidência (garantia citada sem código que a sustente: "usa circuit breaker", "idempotente", "exactly-once");
- números redondos/suspeitos (SLO "99,9%", timeout "30s", janela de consistência sem segundos);
- decisões disfarçadas de premissa; integrações sem fallback declarado; estados/transições não explicados.

**Gate de saída:** ledger `✓ / ▸ / ○` montado, cada item com a localização na doc (`arquivo#seção`) e por que é incerto.

### Fase 1 — Loop código-primeiro (uma incerteza por vez)
Para cada item do ledger, na ordem de risco:

1. **Re-analise o código** especificamente sobre aquela incerteza (não a doc — o código). Procure a evidência que confirma, refuta ou precisa o ponto.
2. **Achou no código** → corrija o doc inline e registre o **nível de certeza**:
   - **Alta** — código prova diretamente (`arquivo:linha` citado).
   - **Média** — código sugere fortemente, mas há indireção/config externa.
   - **Baixa** — pista parcial; precisa de confirmação humana mesmo assim.
   Marque o item `✓` (ou `▸` se Baixa, levando pro passo 3).
3. **Não achou no código** (ou certeza Baixa) → **aí sim pergunte ao humano**, UMA pergunta por vez, dizendo que você já procurou no código e não fechou. A resposta dele vira a correção inline; registre como **certeza: informada pelo usuário**.

> Oriente o usuário: ele pode, a qualquer momento, pedir que você **tente uma nova análise no
> código** antes de responder — só forneça a resposta na mão quando o código realmente não revelar.

**Mostre o ledger antes de cada pergunta.** Documentação inline (espírito `grill-with-docs`):
resposta cristalizada → escreva na seção certa da página na hora; fato novo de projeto →
espelhe no `project-context.md` / `business-context` (nos três destinos). Item resolvido não volta.

**Gate de saída:** ledger zerado — toda incerteza ou resolvida pelo código (com nível de certeza) ou respondida pelo usuário, e a doc atualizada inline.

### Fase 2 — Fechamento
1. Tabela final: cada incerteza → resolução → **nível de certeza** (Alta / Média / Baixa / informada pelo usuário) + evidência (`arquivo:linha`) ou "respondido por <quem>".
2. O que continua aberto (usuário não soube e código não revela) fica como `[a confirmar com <quem>]` — explícito, nunca inventado.

**Gate de saída:** disciplina de conclusão (`engenharia-style.md` § 2) — a tabela de certezas na resposta, com evidência. Nenhuma "certeza" sem lastro.

## Regras de comportamento
- Código antes de pergunta — sempre. Perguntar o que o código responde desperdiça a cota do usuário e enfraquece o grill.
- Nível de certeza honesto: "Alta" exige `arquivo:linha`; na dúvida entre Média e Alta, é Média.
- Uma incerteza por vez; não despeje lista de perguntas.
- Não invente resolução pra zerar o ledger — `[a confirmar]` é uma resolução válida.
- Atualize a doc inline conforme fecha — não acumule correções pro fim.

## Anti-padrões a recusar
- Perguntar ao humano sem ter aberto o código primeiro.
- Marcar "Alta" certeza sem citar a linha que prova.
- Tratar incerteza como erro de estilo (isso é o `grill-doc`).
- Declarar a doc "auditada" com itens do ledger ainda `○`.

## Saída esperada
1. **Ledger** das incertezas (inicial → zerado).
2. **Correções inline** aplicadas na doc (e no contexto, quando virou fato de projeto).
3. **Tabela de certezas** — incerteza → resolução → nível + evidência.
4. **Pendências** — `[a confirmar com <quem>]` que sobraram.

## Exemplo de invocação

> Sessão nova sobre o `conciliacao-banco`. Siga `ia/prompts/arquitetura/grill-arquitetura.md`
> — Etapa 3: ataque as incertezas da doc gerada, código-primeiro, com níveis de certeza.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/grill-arquitetura` |
| Copilot CLI | Gatilho natural ("grill intenso da arquitetura") — a instruction roteia |
| Kiro (IDE / CLI) | Descreva o pedido — a Agent Skill ativa por descrição |

## Referências
- Etapas anteriores: `ia/prompts/arquitetura/documentar-servico.md` (1) · `ia/prompts/arquitetura/completar-documentacao.md` (2).
- Revisão geral por lentes (complementar, página a página): `ia/prompts/arquitetura/grill-doc.md`.
- Andaime do protocolo de grilling (ledger, rodada, anti-padrões): `ia/prompts/engenharia/grill-plano.md` / `ia/prompts/negocio/grill-negocio.md`.
- Disciplina de conclusão: `engenharia-style.md` § 2.
