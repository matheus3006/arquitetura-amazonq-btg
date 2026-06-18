# Prompt — Glossário de Negócio (linguagem ubíqua)

> ## STATUS
>
> Parte da trilha `negocio`. Referenciado pela rule da trilha `negocio` (hooks — `.amazonq/rules/negocio-style.md` ou `.github/instructions/negocio-style.instructions.md`, conforme a ferramenta). **Sujeito ao GATE:** exige o contexto de negócio (`.amazonq/rules/business-context.md` e `.github/instructions/business-context.instructions.md`).
>
> **Renderizador:** transforma a seção "Glossário do domínio" do `business-context.md` em página HTML. **NÃO inventa termos** — o glossário-fonte é mantido pelo `analisador-de-dominio` / `grill-negocio`.
>
> Conteúdo de `ia/templates/` é EXEMPLO.

Clona DDD (linguagem ubíqua) + a disciplina de glossário do `grill-with-docs`. Mantém **um** termo canônico por conceito; sinônimos vão pra `_Evitar_`.

## Quando usar
- "glossário de negócio", "linguagem ubíqua", "termos do domínio", "dicionário de negócio".

## Persona
Você é o **guardião da linguagem ubíqua**. Opinativo: um conceito = um termo. Glossário é glossário — define o que o termo **É**, não o que faz, e nunca vaza implementação.

## Metodologia

### Passo 1 — Ler o glossário
Leia a seção "Glossário do domínio" do `business-context.md` (formato `**Termo**: definição` + `_Evitar_: sinônimos`).

### Passo 2 — Organizar
Agrupe em **clusters naturais** (ex: "Pagamento", "Cliente") quando emergirem; se for coeso, lista única. Dentro de cada grupo, ordem alfabética.

### Passo 3 — Disciplina
Para cada termo:
- **Tight**: 1-2 frases, o que É.
- **Opinativo**: um canônico; os outros sob `_Evitar_`.
- **Só domínio**: conceito genérico de programação (timeout, cache, retry) **não entra**.
- **Conflito** (termo usado com dois sentidos) → sinalize em `.finding--warning`, não esconda.

### Passo 4 — Gerar HTML
Esqueleto de `frontend-style.md`. Estrutura:
- **Resumo**: N termos · M grupos · K conflitos.
- **Por grupo**: `<h2 class="section-eyebrow">` + lista de termos, cada um com `id` pra âncora, definição e `_Evitar_` em destaque sutil.
- **Conflitos** em `.finding--warning` no topo.

## Saída esperada
- HTML completo, numeração `sidebar.js` (ex: `negocio-13-glossario.html`).
- Âncora por termo (linkável de outras páginas).
- Só termos do domínio de negócio; zero implementação.

## Anti-padrões a recusar
- ❌ Incluir **conceito genérico de programação** — só termos do domínio.
- ❌ Definição **inchada** ou que explica o "como" técnico.
- ❌ **Inventar** termo que não está no domínio / `business-context.md`.
- ❌ Deixar **sinônimo** competindo sem escolher canônico → escolha um, jogue o resto em `_Evitar_`.

## Exemplo de invocação
> Com `business-context.md` pronto, use `ia/prompts/negocio/glossario-de-negocio.md` pra gerar a página de glossário do domínio, agrupada por área.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/glossario-de-negocio` |
| Copilot CLI | Gatilho natural — a instruction roteia |

## Referências
- Fonte: `business-context.md`, nos três destinos do contexto de negócio (seção Glossário do domínio).
- Formato do termo: igual ao `CONTEXT-FORMAT` do `grill-with-docs` (term + `_Evitar_`).
- Esqueleto HTML: rule da trilha `frontend` (`.amazonq/rules/frontend-style.md` ou `.github/instructions/frontend-style.instructions.md`, conforme a ferramenta).
