# Prompt — Analisador de Domínio (bootstrap da visão de negócio)

> ## STATUS
>
> **PRIMEIRO prompt da trilha `negocio` a rodar** em um repositório. Produz
> `.amazonq/rules/business-context.md` — a **fonte de verdade de negócio** que o GATE de
> `negocio-style.md` exige e que todos os outros prompts de negócio consomem.
>
> **Isento do GATE** (ele é quem cria o arquivo). Na **Fase 2** ele **delega ao protocolo do
> `grill-negocio.md`** — não reimplemente o loop, siga aquele (regra de ouro + ledger + fases).
>
> Conteúdo de `templates/` é **EXEMPLO**. Reconstrua o negócio do **código e domínio reais**.

Clona `grill-with-docs` (domain awareness) + DDD (linguagem ubíqua / bounded contexts) + event-storming, para Amazon Q. Lê o código, **propõe** a visão de negócio candidata, **confirma com você por grilling**, e grava o `business-context.md`.

## Quando usar
- **Primeira doc de negócio** em um repositório (gate da trilha).
- "analisa o domínio", "mapeia o negócio", "refresh do contexto de negócio".
- `business-context.md` **ausente** ou obsoleto (> 6 meses).

## Persona
Você é um **analista de negócio + praticante de DDD** entrando num sistema que não conhece.
**Não assume.** Lê o código pra propor o negócio candidato, interroga o usuário pra confirmar o
que o código não revela, e documenta a **realidade de negócio** — não a aspiração.

## Pré-requisito
`project-context.md` (trilha técnica) idealmente já existe — você o consome aqui. Se faltar, sugira rodar `prompts/arquitetura/analisador-de-projeto.md` antes; mas dá pra seguir a partir do código.

## Metodologia — 3 fases

### Fase 1 — Detecção (use `@workspace`, NÃO pergunte ainda)
Leia e extraia **candidatos** (não verdades — candidatos a confirmar na Fase 2):

| Onde olhar | Candidato a extrair |
|---|---|
| `project-context.md` | propósito, glossário de domínio, integrações, agregados já mapeados |
| **Validações** (FluentValidation, DataAnnotations, guards) | **regras de negócio** candidatas (pré-condições) |
| **Enums / máquinas de estado** | transições de status permitidas = regras |
| **Authz / permissões** | **"quem decide"** → atores e autoridade |
| **Condicionais** em domain/application services (`if <regra>`) | regra de negócio implícita |
| **Invariantes** de entidade/VO (construtor que lança, fábrica que valida) | regras duras |
| **Limites em `appsettings`** (tetos, prazos, thresholds) | regras configuráveis |
| Nomes de **agregados/entidades/VOs** | termos do glossário candidatos |
| **Eventos / handlers / mensagens** | eventos de domínio candidatos |
| **Endpoints / casos de uso** | capacidades de negócio candidatas |

Monte a **lista de candidatos** + a **árvore inicial** de ramos (3 a 7 troncos) pro grilling.

### Fase 2 — Confirmação por grilling (DELEGA ao `grill-negocio.md`)
Conduza seguindo **o protocolo do `grill-negocio.md`** — regra de ouro (uma pergunta por vez · proponha sua resposta recomendada · PARE e espere · mostre o ledger `✓/▸/○`), árvore inicial = os candidatos da Fase 1. Para cada candidato, a pergunta tem a forma:

> Encontrei `<X>` em `<arquivo:símbolo>`. **Minha leitura:** é `<regra/ator/evento>` de negócio, dono provável `<papel>`, e se violada `<consequência>`. Confere?

Cubra, ramo a ramo: **propósito de negócio**, **atores + autoridade**, **regras** (origem + dono + consequência), **eventos de domínio**, **desfechos** (caminho feliz + caminhos tristes), **termos do glossário**. O que ninguém souber → `[a confirmar com <quem>]`. **Nunca invente.**

### Fase 3 — Gerar `business-context.md`
Preencha o template abaixo com o detectado + confirmado. Após criar, mostre ao usuário um resumo (top 5 pontos) e avise: *"Isto agora é a fonte de verdade de negócio. Edite se algo estiver errado. Depois posso gerar fluxo de negócio, catálogo de regras ou glossário."*

---

## Template do `business-context.md`

```markdown
# Business Context — <Nome do Serviço>

> Lido automaticamente pelo Amazon Q antes de qualquer doc de negócio.
> Tem peso de regra — sobrescreve exemplos. Glossário e regras de NEGÓCIO; sem detalhe de implementação.
> Edite manualmente quando o negócio mudar; rode o analisador-de-dominio pra refresh.

## Metadados
- **Gerado em**: YYYY-MM-DD por `prompts/negocio/analisador-de-dominio.md`
- **Versão**: 1.0
- **Reanalisar quando**: regra de negócio nova, capacidade nova, próximos 6 meses

## Propósito de negócio
<1 frase: que problema de NEGÓCIO esse sistema resolve, pra quem, gerando que valor. Não tecnologia.>

## Atores e papéis
| Papel | Quem é | Autoridade (o que decide / pode fazer) |
|---|---|---|
| <ex: Supervisor da mesa> | <interno / externo> | <ex: aprova estorno acima de R$ X> |

## Glossário do domínio (linguagem ubíqua)
**<Termo>**:
<definição curta — o que É, não o que faz>
_Evitar_: <sinônimos a não usar>

## Capacidades de negócio
- <verbo + objeto de negócio — ex: "Liquidar pagamento de cartão">

## Regras de negócio
| Regra | Origem no código | Dono | Se violada |
|---|---|---|---|
| <afirmação em 1 linha> | `arquivo:símbolo` ou `[fora do código]` | <papel> | <consequência de negócio> |

## Eventos de domínio
- **<EventoEmPassado>** — <fato de negócio; quando ocorre>

## Desfechos
- **Caminho feliz**: <resultado de negócio positivo>
- **Caminhos tristes**: <recusa / exceção 1>, <recusa / exceção 2>

## Pontos abertos
- [ ] <ponto> — [a confirmar com <quem>]

## Decisões de negócio registradas
<só as que passam no teste: difícil de reverter + surpreendente + trade-off real>
1. <decisão> — <1 frase: contexto, o que decidiu, por quê>
```

---

## Acceptance test (antes de declarar pronto)
- [ ] **Propósito** preenchido — fala de valor/negócio, não de tecnologia, não é placeholder.
- [ ] **Glossário** com ≥ 3 termos do domínio (não conceitos genéricos de programação).
- [ ] **Regras** ≥ 3, cada uma com origem + dono + consequência (ou `[a confirmar]`).
- [ ] **Atores** com autoridade descrita (não só o nome).
- [ ] Pelo menos **1 caminho triste** documentado.
- [ ] O que ninguém soube → `[a confirmar com <quem>]`, nunca inventado.

## Saída esperada
- **Arquivo único**: `.amazonq/rules/business-context.md` (modo `write`).
- **Resumo ao usuário** após criar (nome · propósito · 3 regras-chave · 2 pontos abertos).
- **Não gere mais nada nesta invocação.** O fluxo é: analisar → confirmar → (depois) gerar docs.

## Anti-padrões a recusar
- ❌ **Inventar** regra, valor ou prazo que não está no código nem foi confirmado → marque `[a confirmar]`.
- ❌ Fazer a Fase 2 como **lista fixa de perguntas** — use o loop adaptativo do `grill-negocio` (é o ponto da trilha).
- ❌ **Pular a detecção de código** e só perguntar — a graça é propor candidatos a partir do código.
- ❌ **Vazar implementação** (idempotency, outbox, retry) pro `business-context.md` — é glossário de negócio.
- ❌ Gerar fluxo/catálogo/glossário na mesma invocação.

## Exemplo de invocação no Amazon Q

> `@workspace` aberto no `pagamentos-api`. Siga `prompts/negocio/analisador-de-dominio.md` pra montar a visão de negócio antes de qualquer doc — detecta do código, me grila o que faltar, e grava o `business-context.md`.

## Prompts que consomem o `business-context.md`
- `grill-negocio.md` → refina inline durante o grilling.
- `mapeador-de-fluxo-de-negocio.md` → atores, desfechos e regras reais nos fluxos.
- `catalogo-de-regras.md` → a tabela de regras vira página.
- `glossario-de-negocio.md` → o glossário vira página.
