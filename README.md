# arquitetura-amazonq-btg

Starter pack de documentação arquitetural para serviços **.NET transacionais** usando **Amazon Q Developer** como assistente.

Transforma o Q em um especialista que entende seu projeto antes de gerar documentação,
produz HTML semântico com pan/zoom em diagramas, e segue convenções verificáveis.

## O que esse repositório é

Um pacote pronto para clonar dentro de cada serviço .NET do seu time. Inclui:

- **Rules** lidas automaticamente pelo Amazon Q
- **Prompts** que clonam comportamento de skills especializadas (arquitetura, frontend, polish)
- **Design system** dark com paleta institucional + animações sutis
- **Template viewer** para diagramas Mermaid com pan/zoom estilo Figma, fundo claro com traços escuros
- **12 páginas HTML de exemplo** documentando um serviço fictício ("Liquidação Transacional") como referência de forma e qualidade

## Filosofia

Uma única regra rígida: **a convenção de diagramas** (Mermaid + viewer + 4 classDefs com cores fixas).

Tudo o mais — paleta, nomes, padrões, glossário — é **convenção adaptável**. O conteúdo das páginas em `templates/` é **exemplo, não blueprint**. O analisador de projeto (rodado na primeira invocação em cada repo) lê o código real e produz `.amazonq/rules/project-context.md` para evitar drift do exemplo.

## Como funciona

```
Dev clona esse repo para dentro do projeto .NET dele
       ↓
Dev abre o Amazon Q e escreve: "documenta esse serviço"
       ↓
Q lê .amazonq/rules/architecture-style.md (auto)
       ↓
Gate detecta: .amazonq/rules/project-context.md NÃO EXISTE
       ↓
Q carrega prompts/arquitetura/analisador-de-projeto.md
       ↓
═══ FASE 1 — DETECÇÃO ═══
  Q lê .csproj, Program.cs, appsettings.json, Dockerfile,
  estrutura de pastas, pacotes NuGet, README, /docs/adr/
       ↓
═══ FASE 2 — PERGUNTAS ═══
  Q mostra o que detectou e pergunta o que código não revela:
  tier de criticidade, SLO, squad, padrões que NÃO se aplicam
       ↓
═══ FASE 3 — project-context.md ═══
  Q gera o arquivo com nome real, stack real, lista negativa
  ("não usamos Outbox", "não há contingência")
       ↓
Dev revisa, ajusta se necessário
       ↓
Dev: "ok, agora gera a visão geral"
       ↓
Q lê architecture-style.md + project-context.md + arquiteto-de-sistema.md
       ↓
Q gera HTML usando dados do projeto REAL (não do exemplo)
  • Sidebar via sidebar.js
  • Hero com nome real do serviço
  • Diagramas seguindo a convenção rígida (cores fixas)
  • Tabelas, callouts, code blocks consistentes
```

## Estrutura

```
arquitetura-amazonq-btg/
├── README.md                                    ← este arquivo
├── LICENSE                                      ← MIT
├── .gitignore
├── .amazonq/
│   └── rules/
│       ├── architecture-style.md                ← regra universal — princípios + hooks + diagrama
│       ├── frontend-style.md                    ← regra universal — HTML/CSS/typography
│       └── project-context.md                   ← (não existe ainda — analisador cria por projeto)
├── prompts/
│   ├── arquitetura/
│   │   ├── analisador-de-projeto.md             ← roda PRIMEIRO em todo repo novo
│   │   ├── arquiteto-de-sistema.md              ← persona de arquiteto sênior
│   │   ├── gerador-adr.md                       ← ADRs em formato MADR
│   │   ├── gerador-runbook.md                   ← runbooks operacionais
│   │   ├── documentador-fluxo.md                ← fluxos transacionais com sequence diagrams
│   │   ├── grill-doc.md                         ← revisor cético de documentação
│   │   └── brainstorm-arquitetural.md           ← parceiro de pensamento pré-ADR
│   └── frontend/
│       ├── designer-ux-controlado.md            ← decisões visuais propostas antes de aplicadas
│       ├── designer-ui-pro-max.md               ← catálogo de estilos e paletas
│       ├── design-system-arquitetura.md         ← extensão e auditoria do design system
│       └── polidor-ui.md                        ← polimento estilo Emil Kowalski
├── design-system/
│   ├── tokens.css                               ← cores, espaço, tipografia, raios, sombras, motion
│   └── components.css                           ← componentes prontos (callouts, badges, cards, tables, etc.)
└── templates/
    ├── index.html                               ← portal de exemplo
    ├── 01-visao-geral.html                      ← visão geral arquitetural
    ├── 02-padroes.html                          ← camadas, Hexagonal, fitness functions
    ├── 03-dados.html                            ← payload, transformações, eventos
    ├── 04-configuracoes.html                    ← env vars, feature flags, limites
    ├── 05-nova-funcionalidade.html              ← guia end-to-end de adição de feature
    ├── 06-infraestrutura.html                   ← topologia AWS, pipeline, observabilidade, DR
    ├── 07-fluxo-autorizacao.html                ← fluxo principal com diagramas e payloads
    ├── 08-fluxo-estorno.html                    ← fluxo de reversão
    ├── 09-fluxo-contingencia.html               ← modo degradado
    ├── 13-dicionario.html                       ← dicionário canonical dos campos
    ├── 14-enums.html                            ← enums e códigos
    ├── sidebar.js                               ← navegação compartilhada
    └── diagram-viewer.js                        ← leitor Mermaid + pan/zoom
```

## A convenção de diagrama — única regra rígida de visual

Detalhada em `.amazonq/rules/architecture-style.md` § 1. Resumo:

- **Mermaid** via `diagram-viewer.js` (não `<script type="module">` — quebra em `file://`).
- **Sintaxe `flowchart`** para relações; `sequenceDiagram` para fluxos temporais. **Não usar `C4Context`** (renderização instável).
- **4 classes obrigatórias** com cores fixas:
  - `person` (azul escuro) — quem inicia o fluxo
  - `sys` (azul accent) — o serviço documentado
  - `ext` (branco com borda escura) — dependência externa síncrona
  - `extAsync` (cinza com borda tracejada) — dependência externa assíncrona
- **Wrapper** `<figure class="diagram-figure">` com `<figcaption>` numerada.
- **Fonte do diagrama** em `<script type="text/mermaid" data-id="...">` no fim do `<body>`.
- **Viewer** com `<div class="diagram-viewer" data-diagram="...">` no conteúdo.

Essa convenção **não muda** quando o resto do visual (paleta, tipografia, etc.) é adaptado à identidade da empresa.

## Quick start em um projeto novo

1. **Clone esse repo para a raiz do seu projeto .NET**:
   ```bash
   cd seu-projeto-dotnet
   git clone https://github.com/matheus3006/arquitetura-amazonq-btg.git
   # ou subarvore:
   # git subtree add --prefix=docs/arquitetura https://github.com/matheus3006/arquitetura-amazonq-btg.git main --squash
   ```

2. **Abra o Amazon Q** com `@workspace` no projeto.

3. **Diga**: "Analisa esse projeto antes de começar a documentar."

4. **Q vai detectar o código, perguntar o necessário, criar `.amazonq/rules/project-context.md`.** Revise.

5. **Daí em diante**, todas as gerações de documentação respeitam o `project-context.md`. Exemplos:
   - "Gera a visão geral do serviço"
   - "Cria uma ADR sobre a decisão de usar DynamoDB em vez de PostgreSQL"
   - "Documenta o fluxo de notificação push"
   - "Revisa essa página procurando inconsistências"

## Visualizar o exemplo localmente

Abra qualquer página em `templates/` direto no navegador (Chrome ou Firefox):

```
file:///caminho/para/arquitetura-amazonq-btg/templates/index.html
```

Os scripts são classic (não module) — funciona em `file://` sem servidor.

Para gerar PDF, `Cmd+P` → Salvar como PDF → marcar "Gráficos de fundo". Print styles otimizam o layout automaticamente.

## Princípios das regras

1. **Decisão antes de implementação.** Documentação responde *por quê*; código responde *como*.
2. **Trade-off explícito.** Toda decisão tem ônus. Listar o que perdemos é parte da decisão.
3. **Auditável.** Cada documento traz autor, data, versão, status.
4. **Não confiar em disciplina** quando há alternativa verificável (fitness function, lint, alarme).
5. **Linguagem direta.** Frases curtas. Sem "robusto", "escalável", "moderno". Números concretos.

## Contribuindo

Estrutura genérica universal? PR.
Conteúdo do exemplo "Liquidação Transacional"? Não substitua — é exemplo de forma; cada projeto adapta com `project-context.md`.

## Licença

MIT — veja [LICENSE](LICENSE).

Conteúdo de exemplo em `templates/` é fictício, não representa nenhum sistema real.
