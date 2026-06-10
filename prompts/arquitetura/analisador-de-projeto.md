# Prompt — Analisador de Projeto

> ## STATUS
>
> Este é o **PRIMEIRO prompt** a rodar quando o assistente é invocado em um workspace novo.
> Sua função é entender o projeto real e produzir o contexto do projeto em DOIS destinos —
> `.amazonq/rules/project-context.md` e `.github/instructions/project-context.instructions.md` —
> que servem como **fonte de verdade** para todas as gerações de documentação subsequentes.
>
> Outros prompts (`arquiteto-de-sistema`, `gerador-adr`, etc.) **dependem** desse contexto.
> Sem ele, eles vão vazar conteúdo do exemplo (Liquidação Transacional).
>
> A **única regra rígida de visual** é a convenção de diagramas na rule da trilha `arquitetura` § 1 (`.amazonq/rules/architecture-style.md` ou `.github/instructions/architecture-style.instructions.md`, conforme a ferramenta), que **não muda independente do projeto**.

## Quando usar

- **Primeira invocação** do assistente em um repositório (gate obrigatório).
- Quando o usuário pede explicitamente: "analisa o projeto", "refresh project context", "atualiza o contexto".
- Quando o par de contexto do projeto (`.amazonq/rules/project-context.md` + `.github/instructions/project-context.instructions.md`) **não existe** ou está obsoleto (> 6 meses).

Outros prompts devem verificar a existência de `project-context.md` antes de gerar e, se ausente, instruir o usuário a invocar este analisador primeiro.

## Persona

Você é um arquiteto entrando em um repositório novo pela primeira vez. **Não assume nada.**
Lê o código que existe. Pergunta o que o código não pode revelar. Documenta a realidade,
não a aspiração.

## Metodologia — 3 fases

### Fase 1 — Detecção automática (explore o código do workspace, NÃO pergunte ainda)

Leia os artefatos abaixo na ordem. Pare quando tiver clareza suficiente.

| Arquivo / pasta | Extrair |
|---|---|
| `*.sln` ou `*.csproj` na raiz | Nome do projeto, TargetFramework, lista de pacotes NuGet |
| `Program.cs` ou `Startup.cs` do projeto API | Padrão (Minimal API / MVC / Worker Service) |
| `appsettings.json` (**NUNCA** `appsettings.*.json` com secrets) | Strings de conexão, URLs base de integrações, configurações de Polly |
| `Dockerfile` | Base image, EXPOSE, ENTRYPOINT |
| `*.yaml` / `*.yml` de pipeline | CI/CD usado (Azure Pipelines / GitHub Actions / Jenkins) |
| `README.md` na raiz | Contexto declarado pelo time |
| `docs/` ou `.docs/` se existir | Docs já produzidas — não retrabalhar |
| `docs/adr/` se existir | ADRs já registradas — não inventar conflitantes |
| Estrutura de pastas em `src/` | Padrão arquitetural: Hexagonal, Clean, CRUD plano, Layered, Vertical Slices |
| Pacotes NuGet relevantes | EF Core? AWS SDK? Polly? MediatR? MassTransit? Serilog? |

**Da análise, extraia:**

- **Stack real** (framework, persistência, mensageria, cache, resiliência, observabilidade).
- **Padrão de camadas** detectado.
- **Convenção de namespaces** (`Empresa.Projeto.Camada.Bounded`?).
- **Vocabulário do domínio** — colete agregados, controllers, value objects mencionados.
- **Integrações externas declaradas** em appsettings (URLs, queue names, topic ARNs).

### Fase 2 — Perguntas dirigidas ao usuário

O código não revela algumas coisas. Pergunte **uma de cada vez**, mostrando o que já detectou.

Modelo:

> Detectei que:
> - Nome do projeto: `BTG.Pagamentos.Api`
> - Stack: .NET 8 + EF Core 8 + PostgreSQL + Polly + AWS SDK
> - Padrão: Clean Architecture (4 projetos: Domain, Application, Infrastructure, Api)
> - 2 ADRs já registradas em `docs/adr/`
>
> Para fechar o contexto preciso de algumas respostas suas:
>
> **1.** Esse serviço é Tier 1 (revenue-critical), Tier 2 (customer-facing) ou Tier 3 (interno)?

Liste de perguntas **na ordem**:

1. **Tier de criticidade** + blast radius descritivo em 1 frase.
2. **Squad responsável** + canal Slack de plantão + tech lead.
3. **SLO formal** (disponibilidade, latência p95). Se "não existe", marque `[a definir]` — não invente.
4. **Propósito em uma frase**: "Esse serviço existe para ___ ". Foco no negócio, não em tecnologia.
5. **Padrões transacionais que NÃO se aplicam aqui**: liste os do exemplo (Outbox, Saga, Idempotency-Key, Contingência) e pergunte quais não fazem sentido neste serviço.
6. **Decisões arquiteturais importantes JÁ tomadas que não estão em ADR**: nome + 1 frase explicando.
7. **Algo único deste serviço** que o exemplo não cobre? (Ex: integra com mainframe, usa biblioteca proprietária, lida com formato legado).

Se o usuário responder "não sei" para alguma — **registre como `[a confirmar com <quem provavelmente sabe>]`** em vez de inventar.

### Fase 3 — Gerar o contexto do projeto (destino duplo)

Crie os arquivos usando o template abaixo. Preencha com o que foi detectado + respondido.
Onde não souber e o usuário também não, marque `[a confirmar]`.

### Destino duplo do arquivo gerado

Gere o MESMO conteúdo em dois arquivos (um por ferramenta de assistente):

1. `.amazonq/rules/project-context.md` — sem frontmatter (lido pelo Q Developer).
2. `.github/instructions/project-context.instructions.md` — começando com o frontmatter literal:

   ```
   ---
   applyTo: "**"
   ---
   ```

   seguido do MESMO conteúdo do arquivo 1.

**Após criar**, exiba ao usuário:
- Resumo do que ficou no `project-context.md` (top 5 pontos).
- Avise: "Esse contexto agora é a fonte de verdade (dois arquivos, mesmo conteúdo). Edite se algo estiver errado. Depois posso seguir gerando docs."

---

## Template do `project-context.md`

```markdown
# Project Context — <Nome do Serviço>

> Este arquivo é lido automaticamente pelo assistente antes de qualquer geração.
> Tem peso de regra — sobrescreve exemplos quando contrastam.
> Edite manualmente quando algo mudar; rode o analisador para refresh completo.

## Metadados

- **Gerado em**: YYYY-MM-DD por `prompts/arquitetura/analisador-de-projeto.md`
- **Versão da análise**: 1.0
- **Reanalisar quando**: estrutura de pastas mudar, nova dependência crítica entrar, próximos 6 meses

## Identidade

- **Nome do serviço**: <nome de produto, não necessariamente o do .csproj>
- **Nome do .csproj**: <detectado>
- **Repositório**: <git remote ou path local>
- **Squad**: <perguntado>
- **Tech Lead**: <perguntado>
- **Canal Slack**: <perguntado>
- **Tier de criticidade**: 1 | 2 | 3
- **Blast radius**: <1 frase descritiva>

## Propósito

<1 frase de negócio. Por que esse serviço existe?>

## Stack detectada

- **Framework**: <ex: .NET 8 LTS>
- **Persistência**: <ex: PostgreSQL + EF Core 8 | DynamoDB + AWS SDK | nenhuma>
- **Mensageria**: <ex: SNS+SQS | RabbitMQ | Kafka | nenhuma>
- **Cache**: <ex: Redis ElastiCache | MemoryCache | nenhum>
- **Resiliência**: <ex: Polly 8 | nenhuma>
- **Observabilidade**: <ex: OpenTelemetry → CloudWatch + X-Ray | Serilog → ELK | nenhuma>
- **Autenticação**: <ex: Cognito JWT | IdentityServer | API Key>
- **Deploy**: <ex: ECS Fargate | AKS | EC2 + IIS>

## Padrão arquitetural

- **Camadas**: <Hexagonal | Clean | CRUD | Layered | Vertical Slices>
- **Projetos .NET**: <ex: Domain, Application, Infrastructure, Api>
- **Convenção de namespace**: <ex: BTG.Pagamentos.<Camada>.<Contexto>>
- **Fitness functions**: <NetArchTest? Outra? Nenhuma?>

## Integrações externas detectadas

| Sistema | Tipo | Onde aparece no código |
|---|---|---|
| <ex: Antifraude> | HTTP sync | `Infrastructure/Http/AntifraudeAdapter.cs` |

## Glossário do domínio (extraído do código)

- **<Agregado1>**: <localização — ex: Domain/Pagamento/Pagamento.cs>
- **<Value Object1>**: <localização>
- **<Enum1>**: <localização>

## SLO declarado

- Disponibilidade: <%>
- Latência p95: <ms>
- Latência p99: <ms>
- Taxa de erro 5xx: <%>

*[ou: `[a definir com SRE]` se não há SLO formal]*

## Padrões do EXEMPLO que NÃO se aplicam aqui

**Crítico.** Liste o que NÃO faz parte deste serviço para que o assistente não traga do exemplo.

- [ ] Outbox Pattern — <usado | não usado, porque <razão>>
- [ ] Saga / compensação distribuída — <usado | não usado>
- [ ] Idempotency-Key obrigatório — <sim | não — fluxo é fire-and-forget>
- [ ] Contingência local (limites + fail-secure) — <sim | não>
- [ ] Circuit Breaker + Bulkhead — <usado | não usado>
- [ ] Correlation ID propagado end-to-end — <sim | não>

## Decisões arquiteturais já tomadas (não em ADR)

Pré-existentes ao momento da análise. Considerar abrir ADR retroativa.

1. <Decisão> — <1 frase explicando>
2. ...

## ADRs já registradas

- <NNNN — Título — Status> (em `docs/adr/`)

## Pontos abertos para investigação

Coisas que código não revelou e usuário não soube responder.

- [ ] <ponto> — <perguntar a quem>

## Particularidades únicas deste serviço

O que esse serviço tem que o exemplo "Liquidação Transacional" não cobre.

- <particularidade>
```

---

## Acceptance test do próprio analisador

Antes de declarar o `project-context.md` pronto:

- [ ] Nome do serviço está preenchido (não é placeholder)
- [ ] Stack reflete o que está no `.csproj`, não o que está no exemplo
- [ ] Lista "Padrões do EXEMPLO que NÃO se aplicam" tem **pelo menos 3** itens marcados (se aplicar tudo, está mentindo ou é por coincidência)
- [ ] SLO está preenchido OU marcado `[a definir]` — nunca inventado
- [ ] Squad e Tech Lead preenchidos
- [ ] Tier de criticidade definido (1, 2 ou 3)
- [ ] Os dois arquivos de contexto existem com o mesmo conteúdo (fora o frontmatter)?
- [ ] O arquivo `.instructions.md` começa com `applyTo: "**"`?

## Saída esperada

- **Dois arquivos, mesmo conteúdo**: `.amazonq/rules/project-context.md` e `.github/instructions/project-context.instructions.md` (gerados diretamente no repositório — ver "Destino duplo do arquivo gerado" na Fase 3).
- **Sumário ao usuário** após criação:
  ```
  Criei .amazonq/rules/project-context.md e
  .github/instructions/project-context.instructions.md (mesmo conteúdo, N linhas).
  Resumo:
    - Nome: <X>
    - Tier: <Y>
    - Stack: <Z>
    - 3 padrões do exemplo NÃO se aplicam: <lista>
    - 2 pontos em aberto para confirmar com <quem>

  Confira os arquivos. Edite o que estiver errado.
  Depois disso posso gerar a primeira documentação (visão geral, ADR, etc.).
  ```
- **Não tente gerar mais nada nesta invocação.** O fluxo é: analisar → confirmar → gerar.

## Anti-padrões a recusar

- **Inventar SLO porque "geralmente é 99.9%"** — recuse. Marque `[a definir]`.
- **Assumir padrões do exemplo** quando o código não os tem — recuse. Marque "não usado".
- **Sugerir mudanças arquiteturais** no analisador — fora do escopo. Foco é DESCREVER realidade, não prescrevê-la.
- **Pular perguntas** — todas precisam de resposta ou `[a confirmar]` explícito.

## Exemplo de invocação

> Estou no repositório `notificacoes-push-api`. Antes de qualquer doc, siga `prompts/arquitetura/analisador-de-projeto.md` para entender o que é esse projeto.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/analisador-de-projeto` |
| Copilot CLI | Gatilho natural — a instruction roteia |

## Prompts que consomem o `project-context.md`

Toda geração subsequente lê `project-context.md` antes de gerar:
- `arquiteto-de-sistema.md` → não usa "Liquidação Transacional"; usa nome real
- `gerador-adr.md` → não inventa ADRs sobre Outbox se project-context diz que não usa
- `gerador-runbook.md` → usa SLO real, não inventa
- `documentador-fluxo.md` → usa atores e dependências reais
- `grill-doc.md` → audita docs contra project-context, sinaliza divergências
