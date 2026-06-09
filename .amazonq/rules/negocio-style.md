# Business Documentation Style Guide — trilha `negocio`

> Lido automaticamente pelo Amazon Q em todo workspace que contenha esta pasta.
> Governa a **trilha de negócio** do pack. **Complementa** `architecture-style.md` (trilha técnica) — não a substitui.
> Ambas são carregadas juntas. Use a **§1 (roteamento)** pra decidir a trilha de cada pedido.
> Doc técnica (runtime, sequence, ADR, runbook) → `architecture-style.md`. Doc de negócio (regras, atores, decisões, processo) → esta rule.

---

## GATE OBRIGATÓRIO — `business-context.md`

Antes de gerar **qualquer doc de negócio** (exceto os dois prompts que o criam — ver abaixo):

```
Pedido de doc de negócio chega
        ↓
business-context.md existe em .amazonq/rules/ ?
        │
        ├── NÃO → carregue prompts/negocio/analisador-de-dominio.md PRIMEIRO.
        │        Pare a geração. Conclua a análise de domínio. Peça confirmação.
        │        Depois o usuário reinvoca o pedido original.
        │
        └── SIM → leia-o COMPLETO. É a fonte de verdade de NEGÓCIO:
                 • glossário do domínio (linguagem ubíqua)
                 • regras de negócio confirmadas + dono + consequência
                 • atores/papéis e desfechos de negócio
                 Prossiga com o prompt indicado pelo gatilho (§2).
```

**Exceções ao gate** (rodam JUSTAMENTE pra popular o `business-context.md`):
- `analisador-de-dominio.md` — cria/atualiza o arquivo.
- `grill-negocio.md` — refina o arquivo inline durante a sessão.

**Pré-requisito recomendado:** `project-context.md` (trilha técnica) deve existir — o analisador de domínio o consome. Se faltar, sugira rodar `analisador-de-projeto.md` antes; mas é possível seguir a partir do código.

`business-context.md` tem **peso de regra**, igual a esta. Quando define um termo ou regra, **sobrescreve** qualquer exemplo em `templates/`.

---

## 0. STATUS DESTA TRILHA

| Pasta / arquivo | Status | Como usar |
|---|---|---|
| `.amazonq/rules/negocio-style.md` (esta) | **REGRA** | Convenções + gate + hooks de negócio. |
| `.amazonq/rules/business-context.md` | **REGRA por projeto** (gerada pelo analisador de domínio) | Fonte de verdade de negócio. Sobrescreve exemplos. |
| `.amazonq/rules/project-context.md` | **REGRA por projeto** (trilha técnica, reusada) | Contexto de código que o negócio consome. |
| `prompts/negocio/*.md` | **REGRA** (metodologia) | Carregue conforme a tabela de hooks § 2. |
| `design-system/*.css`, `templates/diagram-viewer.js`, `sidebar.js` | **REGRA** (reuso) | Mesmos do pack técnico. Não duplicar, não substituir. |
| `templates/negocio/*` (exemplos de negócio) | **EXEMPLO** | Forma, não substância. Adapte ao domínio real. |

A doc de negócio **mora junto** da técnica, no mesmo repo do serviço, e **compartilha** o `project-context.md`.

---

## 1. Roteamento — trilha técnica vs. trilha de negócio

Antes de carregar qualquer prompt, decida a trilha:

- **NEGÓCIO (esta rule)** quando o pedido fala de: "negócio", "regra de negócio", "visão de negócio", "processo de negócio", "fluxo de negócio", "caminho feliz/triste", "quem decide", "glossário de negócio", "linguagem do domínio", "grilla o negócio".
- **TÉCNICA (`architecture-style.md`)** quando fala de: "transacional", "sequence diagram", "container", "ADR", "runbook", "SLO", "saga", "idempotência", "fluxo de autorização/estorno técnico".
- **AMBÍGUO** ("documenta o fluxo X", "explica como funciona Y") → **pergunte**: *"Você quer a visão **técnica** (runtime, chamadas, estados) ou de **negócio** (regras, atores, decisões, caminho feliz/triste)?"* Não chute.

Nunca misture as duas numa mesma página. Um mesmo fluxo pode ter as duas docs — arquivos separados, em trilhas separadas.

---

## 2. Hooks — gatilho → prompt (negocio)

| Quando o usuário pedir / mencionar | Carregue |
|---|---|
| **Primeira doc de negócio** OU "analisa o domínio", "mapeia o negócio", `business-context.md` ausente | `prompts/negocio/analisador-de-dominio.md` (antes de qualquer outro) |
| "documentar fluxo de negócio", "caminho feliz", "caminho triste", "processo de negócio", "como o negócio funciona" | `prompts/negocio/mapeador-de-fluxo-de-negocio.md` |
| "catálogo de regras", "regras de negócio", "que regras existem", "lista as regras" | `prompts/negocio/catalogo-de-regras.md` |
| "glossário de negócio", "linguagem ubíqua", "termos do domínio", "dicionário de negócio" | `prompts/negocio/glossario-de-negocio.md` |
| "grilla o negócio", "me interroga sobre as regras", "que regras não estão escritas", "estressa o domínio", "valida o entendimento de negócio" | `prompts/negocio/grill-negocio.md` |

Ao gerar HTML final, aplique também `.amazonq/rules/frontend-style.md` (mesmo esqueleto, design-system e viewer da trilha técnica).

**Ajuda / descoberta:** se o usuário pedir "ajuda de negócio", "o que dá pra fazer aqui", "que comandos de negócio existem" → **liste os 5 prompts acima e seus gatilhos** (resumo), **sem gerar nada**.

---

## 3. A regra rígida de diagrama de NEGÓCIO

**Mecanismo: idêntico ao da trilha técnica** — `architecture-style.md` § 1 (Mermaid via `diagram-viewer.js`; fonte em `<script type="text/mermaid" data-id="...">` no fim do `<body>`; `<figure class="diagram-figure">` + `<figcaption>` numerada; **nunca** `C4Context`; **nunca** `<script type="module">`).

**O que muda é o vocabulário visual.** Diagrama de negócio usa **classDefs próprios** (não os `person/sys/ext/extAsync` técnicos). Use `flowchart TB`/`LR` pra processo; `sequenceDiagram` com atores de negócio pra caminho feliz/triste com ordem temporal.

```mermaid
classDef papel          fill:#5b4b8a,stroke:#0a0c12,color:#ffffff,stroke-width:2px
classDef atividade      fill:#2f3a4a,stroke:#0a0c12,color:#ffffff,stroke-width:2px
classDef decisao        fill:#e6a946,stroke:#0a0c12,color:#0a0c12,stroke-width:2px
classDef externo        fill:#ffffff,stroke:#5d6677,color:#0a0c12,stroke-width:1.5px
classDef desfechoOk     fill:#2bb673,stroke:#0a0c12,color:#ffffff,stroke-width:2px
classDef desfechoTriste fill:#e85a5a,stroke:#0a0c12,color:#ffffff,stroke-width:2px
```

| Classe | Cor | Quando usar |
|---|---|---|
| `papel` | roxo | Ator/decisor de negócio — quem inicia ou decide um passo |
| `atividade` | ardósia | Passo do processo de negócio (a ação) |
| `decisao` | âmbar | Ponto onde uma **regra ramifica** o fluxo (gateway) |
| `externo` | branco c/ borda | Parte externa: cliente, órgão regulador, parceiro |
| `desfechoOk` | verde | Desfecho do **caminho feliz** (resultado de negócio positivo) |
| `desfechoTriste` | vermelho | Desfecho do **caminho triste** (exceção/recusa de negócio) |

**Caminho feliz e triste no mesmo diagrama:** ramifique a partir de um nó `decisao`; o ramo positivo termina em `desfechoOk`, o(s) negativo(s) em `desfechoTriste`. Aplicar via `class NomeDoNo classe` ao fim do bloco. Cores **não** são adaptáveis — convenção da casa. Vêm de `tokens.css` (success/warning/danger) + roxo/ardósia introduzidos pra papel/atividade.

---

## 4. Esqueleto de página HTML

Idêntico ao da trilha técnica: siga `.amazonq/rules/frontend-style.md` § 1 e o esqueleto de `architecture-style.md` § 3 (mesmo `shell`, `sidebar.js`, `tokens.css` + `components.css`, `diagram-viewer.js`). **O que muda são as seções de conteúdo**, definidas por cada prompt — não a estrutura.

---

## 5. Convenções de redação (negocio)

Herdam as da trilha técnica (PT-BR, voz ativa, sem qualificadores vagos, números concretos), com **duas diferenças**:

1. **Linguagem de NEGÓCIO, não jargão técnico.** Não vaze `idempotency`, `outbox`, `retry`, `circuit breaker` pra doc de negócio — isso é da trilha técnica. Use os termos do `business-context.md` (glossário do domínio).
2. **Toda regra cita origem + dono + consequência.** Origem no código (`arquivo:símbolo`) ou `[regra de processo, fora do código]`; dono (papel responsável); o que acontece de **negócio** se violada.

---

## 6. Comportamento de geração (negocio)

- **Fluxo de negócio SEM caminho triste → recuse.** Peça pelo menos um desfecho de exceção/recusa.
- **Não inventar regra.** Se não está no código nem foi confirmada, marque `[a confirmar com <quem>]`.
- **Glossário (`business-context.md`) é glossário** — sem detalhe de implementação, sem virar spec.
- **Regra documentada = regra rastreável.** Sem origem nem dono, não entra no catálogo — vira ponto aberto.

---

## 7. O que NÃO documentar (trilha negocio)

- Detalhe de implementação técnica (vai pra trilha técnica).
- Conceito genérico de tecnologia.
- Regra trivial/óbvia sem dono nem consequência de negócio.
- "Como o código faz" — a trilha de negócio responde **o quê** e **por quê** de negócio, não o **como** técnico.

---

## 8. Auto-checklist antes de entregar (negocio)

- [ ] Carreguei `business-context.md` (e o `project-context.md`)?
- [ ] Roteei certo (§ 1) — isso é mesmo trilha de negócio, não técnica?
- [ ] Linguagem de negócio, sem jargão técnico vazando?
- [ ] Toda regra tem **origem + dono + consequência**?
- [ ] Fluxo tem **caminho feliz E pelo menos um caminho triste**?
- [ ] Diagrama segue § 3 (viewer + classDefs `papel/atividade/decisao/externo/desfecho*`)?
- [ ] Substituí o conteúdo de exemplo pelo domínio real do serviço?
