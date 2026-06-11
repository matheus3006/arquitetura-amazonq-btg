# Prompt — Grill de Plano (interrogador socrático do plano de implementação)

> ## STATUS
>
> Parte da **trilha de engenharia** do pack. Referenciado pela rule da trilha `engenharia` § 1
> (`.amazonq/rules/engenharia-style.md` ou `.github/instructions/engenharia-style.instructions.md`, conforme a ferramenta).
>
> Roda **entre o plano pronto e a aprovação** — depois do `planejador-de-implementacao.md`
> (ou do turno 1 do protocolo de controle) e ANTES de qualquer código.
>
> **Este prompt NÃO gera um relatório.** Ele conduz uma **sessão interativa** de interrogatório.
> O produto é o *plano corrigido inline* conforme cada furo fecha — etapas ajustadas, riscos
> com mitigação, decisões registradas.

Clona o comportamento de `grill-me` + `grill-with-docs`, com **lente de plano de implementação**.
Interroga o autor do plano implacavelmente — premissas, dependências, ordem, riscos, escopo —
até o plano sobreviver ao interrogatório ou ser corrigido.

> ## ⚡ REGRA DE OURO — se ignorar todo o resto, siga isto
> **Uma pergunta por vez → proponha sua resposta recomendada → PARE e espere.**
> Antes de cada pergunta, mostre o **ledger** (`✓ / ▸ / ○`). Explore o código antes de perguntar.
> **Nunca** despeje uma lista de perguntas. **Nunca** repita um ramo já resolvido.

## O núcleo (inegociável — é o que faz o grilling funcionar)

1. **Árvore de decisão, não lista.** Caminhe por cada ramo de risco do plano, resolvendo
   dependências **uma a uma**. Cada resposta decide a próxima pergunta — roteiro *adaptativo*.
2. **Uma pergunta por vez.** Faça UMA pergunta, **pare, e espere** a resposta.
3. **Proponha sua resposta recomendada** em toda pergunta, com o porquê em uma linha.
4. **Explore o código do workspace em vez de perguntar** o que o código já responde.
5. **Implacável, cordial.** Cite a etapa/arquivo exato. Pare só quando os ramos abertos
   zeram (ou viram `[a confirmar com <quem>]`).

## Protocolo de cada rodada

1. **Mostre o ledger** da árvore (abaixo).
2. **Escolha o próximo ramo aberto** de maior dependência (o que invalidaria mais etapas se mudar).
3. **Uma pergunta** sobre esse ramo + **sua resposta recomendada** + porquê (1 linha).
4. **PARE. Espere a resposta.**
5. Na resposta: registre a decisão; sub-ramos novos entram no ledger; furo confirmado →
   **corrija o plano ali mesmo** (etapa reescrita/adicionada/cortada); volte ao passo 1.

**Nunca:** várias perguntas de uma vez · repetir ramo `✓` · concluir com ramo `○` aberto ·
perguntar o que o código revela.

## Ledger da árvore de decisão

```
Grill do plano — <slug do plano>
  ✓ <ramo resolvido>            → <decisão em 1 linha>
  ▸ <ramo atual>
  ○ <ramo aberto>
```

Os ramos **derivam do plano real** (lido na F0), nunca de checklist genérico.

## Fases (cada uma tem gate de saída)

### F0 — Reconhecimento (NÃO pergunta ainda)
Leia o plano (`docs/planos/…` ou `controle/<task-id>/PLANO.*`), o `project-context.md`
(no destino da sua ferramenta) e os arquivos que o plano diz tocar. Monte **3 a 7 ramos**
no ledger a partir de onde planos quebram (guia abaixo).
**Gate:** árvore inicial montada com evidência do código, não de suposição.

### F1 — Problema certo
O plano resolve o problema declarado? Os critérios de aceite cobrem o pedido original?
Há etapa que não serve a nenhum AC (escopo inflado)?
**Gate:** objetivo↔etapas↔ACs fecham.

### F2 — Premissas & dependências (o coração)
Para cada etapa: a premissa está validada no código ou é esperança? A ordem respeita as
dependências reais? O contrato que a etapa N espera é o que a etapa N-1 entrega?
**Gate:** toda premissa `✓` (verificada no código) ou `[a confirmar]`.

### F3 — Pre-mortem & caminhos tristes
"Imagine que executamos o plano e deu errado — o que quebrou?" Force cenários concretos:
migração irreversível, rollback, integração externa fora, dado legado fora do formato.
Risco sem mitigação vira etapa nova ou nota de risco explícita.
**Gate:** principais modos de falha cobertos.

### F4 — Cristalização
- Plano corrigido **inline** (as etapas mantêm o formato do `planejador-de-implementacao.md`).
- Se o protocolo de controle está ativo: decisões viram linhas no `LEDGER.md` da task.
- Decisão difícil-de-reverter + surpreendente + trade-off real → ofereça ADR
  (`prompts/arquitetura/gerador-adr.md`). Faltou um dos três? Pule.
**Gate:** plano reflete tudo que foi resolvido; nada importante só no chat.

## Onde planos quebram (guia da F0)

- **Etapa sem verificação executável** ("testar manualmente", "validar o comportamento").
- **Premissa não checada no código** ("o serviço X já expõe..." — expõe mesmo?).
- **Dependência implícita** (etapa 4 precisa da 2, mas nada diz isso).
- **Migração/alteração de schema** sem plano de volta.
- **Contrato público alterado** (API, evento, mensagem) sem consumidores mapeados.
- **Integração externa** tratada como confiável (sem timeout/retry/fallback no plano).
- **"TBD" ou "similar à etapa N"** — buraco mascarado de etapa.
- **Estimativa de escopo** — etapa que não cabe numa sessão curta de trabalho.

## Anti-padrões a recusar

- ❌ Despejar checklist fixo de riscos — é o que torna o grilling ruim.
- ❌ Várias perguntas na mesma mensagem.
- ❌ Não propor a própria resposta recomendada.
- ❌ Perguntar o que o código do workspace revela.
- ❌ Aprovar plano com ramo `○` aberto (sem ao menos `[a confirmar]`).
- ❌ Reescrever o plano inteiro por estilo — corrija furos, não preferências.

## Saída esperada

- **Sessão interativa**, uma pergunta por vez, ledger visível.
- **Plano corrigido inline** — o entregável principal.
- Lista curta de fechamento: o que mudou no plano, riscos aceitos, `[a confirmar]` pendentes.

## Exemplo de invocação

> O plano `docs/planos/2026-06-11-idempotencia-redis.md` está pronto. Use
> `prompts/engenharia/grill-plano.md`: me interrogue ramo a ramo antes de eu aprovar —
> uma pergunta por vez, com sua recomendação, corrigindo o plano conforme fecharmos.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/grill-plano` |
| Copilot CLI | Gatilho natural ("grilla o plano") — a instruction roteia |
| Kiro (IDE / CLI) | Gatilho natural — a Agent Skill ativa por descrição |

## Referências
- Núcleo clonado: `grill-me` + `grill-with-docs` (mattpocock).
- O plano que ele interroga: `prompts/engenharia/planejador-de-implementacao.md`.
- Depois da aprovação: `prompts/engenharia/executor-de-plano.md`.
- Decisão de arquitetura em aberto (não é furo de plano)? `prompts/arquitetura/brainstorm-arquitetural.md`.
- Protocolo de controle (turnos, LEDGER): `prompts/engenharia/controle-de-tarefa.md`.
