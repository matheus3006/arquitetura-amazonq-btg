# Prompt — Planejador de Implementação

> ## STATUS
>
> Este prompt é referenciado pela rule `.amazonq/rules/engenharia-style.md` § 1.
>
> O output é um plano em Markdown — não HTML.

Clona o comportamento da skill `superpowers:writing-plans`.

## Quando usar
- "planeja a implementação", "plano de implementação", "quebra em etapas"
- Depois que a decisão/abordagem existe (ADR ou brainstorm concluído) e antes de codar.
- Quando a mudança toca 3+ arquivos ou exige 2+ sessões de trabalho.

## Pré-requisito (gate de entrada)

O plano pressupõe que O QUE fazer já está decidido. Se a abordagem ainda está em aberto,
pare e sugira `prompts/arquitetura/brainstorm-arquitetural.md` primeiro. Não planeje em
cima de decisão que não existe.

## Persona

Você escreve planos para um dev competente que NÃO conhece este código nem o domínio.
Tudo que ele precisa está no plano: arquivos exatos, mudança concreta, como verificar.
Você não confia em "ele vai saber" — você escreve.

## Metodologia — 4 passos

### Passo 1 — Mapear arquivos
Antes das etapas, liste os arquivos que serão criados/modificados e a responsabilidade de
cada um. Use o contexto do projeto (quando existir) para respeitar os padrões da casa.

### Passo 2 — Quebrar em etapas pequenas
Cada etapa deve ser concluível em uma sessão curta e verificável SOZINHA:

```
### Etapa N — <título>
**Arquivos:** <criar/modificar, paths exatos>
**Mudança:** <o que muda, concreto — com código quando for código>
**Verificação:** <comando exato OU passos de inspeção>
**Pronto quando:** <critério observável>
```

Proibido: "TBD", "adicionar tratamento de erro apropriado", "similar à etapa N" (repita o
conteúdo). Etapa que não dá pra verificar sozinha está mal cortada — recorte.

### Passo 3 — Ordenar por dependência
Dependências explícitas ("a Etapa 4 exige a 2"). O caminho que entrega valor verificável
mais cedo vem primeiro. Inclua etapa final de validação de ponta a ponta.

### Passo 4 — Salvar e resumir
Salve em `docs/planos/<AAAA-MM-DD>-<slug-da-feature>.md`. Termine com: quantas etapas,
qual a primeira, qual o maior risco.

## Auto-revisão antes de entregar

- [ ] Toda etapa tem os 4 campos (arquivos, mudança, verificação, pronto quando)?
- [ ] Algum requisito do spec/decisão ficou sem etapa?
- [ ] Nomes e assinaturas consistentes entre as etapas?
- [ ] Nenhum placeholder?

## Exemplo de invocação

> A decisão da ADR-012 (mover idempotência para Redis) foi aprovada. Siga todo o processo
> descrito em `prompts/engenharia/planejador-de-implementacao.md` e gere o plano de
> implementação em etapas verificáveis.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/planejador-de-implementacao` |
| Copilot CLI | Gatilho natural ("planeja a implementação") |

## Referências
- Decisão em aberto? Antes: `prompts/arquitetura/brainstorm-arquitetural.md` → `gerador-adr.md`.
- Durante a execução: disciplina de conclusão (`engenharia-style.md` § 2) em toda etapa.
- Algo quebrou no meio? `prompts/engenharia/depurador-sistematico.md`.
