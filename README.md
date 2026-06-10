# arquitetura — pack de documentação para Amazon Q e GitHub Copilot

Starter pack de documentação arquitetural para serviços **.NET transacionais**, usando
**Amazon Q Developer** ou **GitHub Copilot** (VS Code, Visual Studio, JetBrains, CLI) como assistente.

Transforma o assistente em um especialista que entende seu projeto antes de gerar documentação,
produz HTML semântico com pan/zoom em diagramas, e segue convenções verificáveis.

## O que esse repositório é

Um pacote pronto para clonar dentro de cada serviço .NET do seu time. Inclui:

- **Rules** lidas automaticamente pelo Amazon Q (`.amazonq/rules/`)
- **Camada Copilot gerada** (`.github/`): instructions auto-aplicadas, slash commands (`/gerador-adr`, ...) e Agent Skills — gerada de `.amazonq/rules/` por `tools/sync-copilot.sh`, nunca editada à mão
- **Prompts** que clonam comportamento de skills especializadas — 4 trilhas (arquitetura, frontend, negocio, engenharia)
- **Trilha de engenharia**: debugging sistemático, planejamento de implementação e disciplina de verificação (portes do superpowers)
- **Design system** dark com paleta institucional + animações sutis
- **Template viewer** para diagramas Mermaid com pan/zoom estilo Figma, fundo claro com traços escuros
- **12 páginas HTML de exemplo** documentando um serviço fictício ("Liquidação Transacional") como referência de forma e qualidade

## Instalação rápida

"Instalar" = colocar os arquivos do pack na **raiz** do repo do serviço. O Amazon Q lê `.amazonq/rules/` automaticamente; o Copilot lê `.github/instructions/` automaticamente. Escolha a via:

**Via assistente de IA (qualquer plataforma):** aponte o seu assistente (Amazon Q, Copilot,
Claude...) para o arquivo [`INSTALAR.md`](INSTALAR.md) do pack e diga:
> Siga o INSTALAR.md deste pack e instale no repositório `<caminho-do-meu-servico>`.

**macOS / Linux (bash):**
```bash
git clone https://github.com/matheus3006/arquitetura-amazonq-btg.git
bash arquitetura-amazonq-btg/install.sh /caminho/do/seu/servico
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/matheus3006/arquitetura-amazonq-btg.git
pwsh arquitetura-amazonq-btg\install.ps1 -Target C:\repos\seu-servico
# Windows PowerShell 5.x: powershell -ExecutionPolicy Bypass -File arquitetura-amazonq-btg\install.ps1 -Target C:\repos\seu-servico
```

**Manual (qualquer OS, sem script):** copie do pack pro repo do serviço, mantendo a estrutura:
- `.amazonq/rules/` → as 4 rules (`architecture-style`, `frontend-style`, `negocio-style`, `engenharia-style`)
- `.github/` → `copilot-instructions.md`, `instructions/` (as 4), `prompts/` e `skills/` inteiras
- `prompts/` → as 4 trilhas inteiras (`arquitetura`, `frontend`, `negocio`, `engenharia`)
- `design-system/*.css`
- `templates/diagram-viewer.js` e `templates/sidebar.js`
- `COMO-USAR.html`

**Não** copie os arquivos de contexto por-projeto: `project-context.md` e `business-context.md` (em `.amazonq/rules/`) nem `project-context.instructions.md` e `business-context.instructions.md` (em `.github/instructions/`) — são gerados por-serviço pelos analisadores.

Mensagens prontas para cada gatilho: [COMO-USAR.html](COMO-USAR.html).

> O pack tem **quatro trilhas: técnica, negócio, frontend e engenharia**. Os instaladores entregam as quatro.

## Filosofia

Uma única regra rígida: **a convenção de diagramas** (Mermaid + viewer + 4 classDefs com cores fixas).

Tudo o mais — paleta, nomes, padrões, glossário — é **convenção adaptável**. O conteúdo das páginas em `templates/` é **exemplo, não blueprint**. O analisador de projeto (rodado na primeira invocação em cada repo) lê o código real e produz `.amazonq/rules/project-context.md` para evitar drift do exemplo.

## Como funciona

> O fluxo abaixo descreve o Amazon Q. No Copilot é o mesmo desenho com outros nomes:
> `.github/instructions/` no lugar de `.amazonq/rules/` (auto-aplicadas), `/analisador-de-projeto`
> como atalho, e o contexto gerado nos DOIS lados (`project-context.md` + `project-context.instructions.md`).

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
arquitetura/
├── README.md                                    ← este arquivo
├── INSTALAR.md                                  ← guia de instalação (leitura pelo assistente)
├── COMO-USAR.html                               ← mensagens prontas para cada gatilho
├── LICENSE                                      ← MIT
├── .gitignore
├── install.sh                                   ← instalador macOS/Linux
├── install.ps1                                  ← instalador Windows PowerShell
├── .amazonq/
│   └── rules/                                   ← FONTE CANÔNICA — edite aqui
│       ├── architecture-style.md                ← regra universal — princípios + hooks + diagrama
│       ├── frontend-style.md                    ← regra universal — HTML/CSS/typography
│       ├── negocio-style.md                     ← regra universal — domínio, regras, glossário
│       ├── engenharia-style.md                  ← regra universal — debugging + implementação
│       ├── project-context.md                   ← (gerado por-projeto — não versionar)
│       └── business-context.md                  ← (gerado por-projeto — não versionar)
├── .github/                                     ← gerado por tools/sync-copilot.sh — não editar
│   ├── copilot-instructions.md
│   ├── instructions/                            ← 4 rules + 2 context placeholders (.instructions.md)
│   ├── prompts/                                 ← slash commands (18 arquivos .prompt.md)
│   └── skills/                                  ← Agent Skills (18 subpastas com SKILL.md)
├── prompts/
│   ├── arquitetura/                             ← 7 prompts (analisador, arquiteto, ADR, runbook, fluxo, grill, brainstorm)
│   ├── frontend/                                ← 4 prompts (ux-controlado, ui-pro-max, design-system, polidor)
│   ├── negocio/                                 ← 5 prompts (analisador-dominio, catalogo, glossario, grill, mapeador)
│   └── engenharia/                              ← 2 prompts (depurador-sistematico, planejador-de-implementacao)
├── tools/
│   ├── manifest.tsv                             ← mapeamento rules → .github/ (fonte do sync)
│   └── sync-copilot.sh                          ← gera/valida a camada .github/
├── design-system/
│   ├── tokens.css                               ← cores, espaço, tipografia, raios, sombras, motion
│   └── components.css                           ← componentes prontos (callouts, badges, cards, tables, etc.)
├── templates/
│   ├── index.html                               ← portal de exemplo
│   ├── 01-visao-geral.html … 14-enums.html      ← 11 páginas de exemplo (serviço fictício)
│   ├── sidebar.js                               ← navegação compartilhada
│   └── diagram-viewer.js                        ← leitor Mermaid + pan/zoom
└── docs/
    └── superpowers/                             ← specs e planos de desenvolvimento do pack
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

1. **Instale o pack no seu projeto** (seção _Instalação rápida_ acima):
   ```bash
   bash /caminho/arquitetura/install.sh   # de dentro do repo do serviço
   ```

2. **Abra o seu assistente** (Amazon Q, Copilot, ou outro) no projeto.

3. **Diga**: "Analisa esse projeto antes de começar a documentar."

4. **O assistente vai detectar o código, perguntar o necessário, criar `project-context.md`** (em `.amazonq/rules/` e/ou `.github/instructions/` dependendo da ferramenta). Revise.

5. **Daí em diante**, todas as gerações de documentação respeitam o contexto do projeto. Exemplos:
   - "Gera a visão geral do serviço"
   - "Cria uma ADR sobre a decisão de usar DynamoDB em vez de PostgreSQL"
   - "Documenta o fluxo de notificação push"
   - "Revisa essa página procurando inconsistências"

## Visualizar o exemplo localmente

Abra qualquer página em `templates/` direto no navegador (Chrome ou Firefox):

```
file:///caminho/para/arquitetura/templates/index.html
```

Os scripts são classic (não module) — funciona em `file://` sem servidor.

Para gerar PDF, `Cmd+P` → Salvar como PDF → marcar "Gráficos de fundo". Print styles otimizam o layout automaticamente.

## Princípios das regras

1. **Decisão antes de implementação.** Documentação responde *por quê*; código responde *como*.
2. **Trade-off explícito.** Toda decisão tem ônus. Listar o que perdemos é parte da decisão.
3. **Auditável.** Cada documento traz autor, data, versão, status.
4. **Não confiar em disciplina** quando há alternativa verificável (fitness function, lint, alarme).
5. **Linguagem direta.** Frases curtas. Sem "robusto", "escalável", "moderno". Números concretos.

## Para mantenedores do pack

`.amazonq/rules/` é a fonte canônica. A camada `.github/` é GERADA — não edite à mão.
Depois de editar qualquer rule ou o `tools/manifest.tsv`:

    bash tools/sync-copilot.sh           # regenera .github/
    bash tools/sync-copilot.sh --check   # confirma que esta em sincronia (use antes de commitar)

Commite o `.github/` regenerado junto com a mudança canônica.

## Contribuindo

Estrutura genérica universal? PR.
Conteúdo do exemplo "Liquidação Transacional"? Não substitua — é exemplo de forma; cada projeto adapta com `project-context.md`.

## Licença

MIT — veja [LICENSE](LICENSE).

Conteúdo de exemplo em `templates/` é fictício, não representa nenhum sistema real.
