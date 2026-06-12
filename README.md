# arquitetura — pack de documentação para Amazon Q, GitHub Copilot e Kiro

Starter pack de documentação arquitetural para serviços **.NET transacionais**, usando
**Amazon Q Developer**, **GitHub Copilot** (VS Code, Visual Studio, JetBrains, CLI) ou
**Kiro** (IDE/CLI) como assistente.

Transforma o assistente em um especialista que entende seu projeto antes de gerar documentação,
produz HTML semântico com pan/zoom em diagramas, e segue convenções verificáveis.

## O que esse repositório é

Um pacote pronto para clonar dentro de cada serviço .NET do seu time. Inclui:

- **Rules** lidas automaticamente pelo Amazon Q (`.amazonq/rules/`)
- **Camada Copilot gerada** (`.github/`): instructions auto-aplicadas, slash commands (`/gerador-adr`, ...) e Agent Skills — gerada de `.amazonq/rules/` por `tools/sync-copilot.sh`, nunca editada à mão
- **Camada Kiro gerada** (`.kiro/`): steering auto-carregado (`inclusion: always`) + Agent Skills com ativação por descrição — gerada de `.amazonq/rules/` por `tools/sync-kiro.sh`, nunca editada à mão
- **Prompts** que clonam comportamento de skills especializadas — 4 trilhas (arquitetura, frontend, negocio, engenharia)
- **Trilha de engenharia**: debugging sistemático, planejamento de implementação e disciplina de verificação (portes do superpowers)
- **Protocolo de controle de contexto** (`controle-style`): toda edição nasce de uma task em `controle/<task-id>/` — ciclo de 2 turnos otimizado para cota de requests, com watchdog determinístico via pre-commit git
- **Biblioteca de skills importadas** (`skills/`): 25 Agent Skills copiadas verbatim das melhores fontes (superpowers, product/pm/c-level skills, mattpocock, bencium) em 11 categorias — espelhadas pelas camadas Copilot e Kiro; catálogo em `skills/README.md`
- **Design system** dark com paleta institucional + animações sutis
- **Template viewer** para diagramas Mermaid com pan/zoom estilo Figma, fundo claro com traços escuros
- **12 páginas HTML de exemplo** documentando um serviço fictício ("Liquidação Transacional") como referência de forma e qualidade

## Protocolo de controle — toda task com entregável nasce de uma task de controle

Depois de instalado num serviço, este pack muda o **fluxo de trabalho diário**: todo pedido
que **crie ou modifique um artefato** — código, documento, spec, design, diagrama, plano,
config, pesquisa escrita (**não é só código**) — começa com uma task, antes de qualquer
edição. Você **não escreve comando nem slug** — manda o pedido como mensagem normal e o
assistente deriva o slug do próprio pedido. Só pergunta de leitura pura (que não gera nem
altera artefato) fica de fora.

```
você:        <descreve o que quer fazer — uma mensagem normal, como esta>
assistente:  deriva um slug do pedido, anuncia o task-id (AAAA-MM-DD-<slug>),
             cria controle/<task-id>/ (TASK.md com escopo + ACs + PLANO) e PEDE sua aprovação
você:        "aprovado"
assistente:  executa o checklist marcando cada passo [x] na hora (status vivo),
             registra evidências no LEDGER.md e fecha — tudo num turno
```

(Quer nomear a task na mão? Comece a mensagem com `nova tarefa: <slug> — …` — override opcional.)

Dois mecanismos garantem isso (ver [ADR-0001](docs/adr/0001-protocolo-de-controle-de-contexto.md) e a rule `controle-style`):

1. **A rule sempre-on** instrui o assistente: *edição fora de `controle/` exige task ativa*.
   O ciclo é de **2 turnos** (trivial: 1), desenhado para gastar o mínimo da sua cota de requests.
2. **O watchdog `pre-commit`** (instalado pelos installers em `.git/hooks/`) **bloqueia** qualquer
   commit que altere código sem os arquivos da task no mesmo commit. Bypass consciente: `git commit --no-verify`.

**Não se aplica a:** geração de documentação (trilhas técnica/negócio/frontend) e tarefas
triviais que você declarar. O detalhe do protocolo e os templates estão em
[`prompts/engenharia/controle-de-tarefa.md`](prompts/engenharia/controle-de-tarefa.md); as mensagens prontas, no card "Abrir uma task" do [`COMO-USAR.md`](COMO-USAR.md).

## Instalação rápida

"Instalar" = colocar os arquivos do pack na **raiz** do repo do serviço. O Amazon Q lê `.amazonq/rules/` automaticamente; o Copilot lê `.github/instructions/`; o Kiro lê `.kiro/steering/`. Escolha a via:

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
- `.amazonq/rules/` → as 5 rules (`architecture-style`, `frontend-style`, `negocio-style`, `engenharia-style`, `controle-style`)
- `tools/pre-commit-controle.sh` → `.amazonq/hooks/pre-commit-controle.sh` no alvo (e, em repo git, um gancho `.git/hooks/pre-commit` que o chama)
- `.github/` → `copilot-instructions.md`, `instructions/` (as 5), `prompts/` e `skills/` inteiras
- `.kiro/` → `steering/` (as 5 rules) e `skills/` inteira
- `skills/` → inteira (biblioteca de skills importadas)
- `prompts/` → as 4 trilhas inteiras (`arquitetura`, `frontend`, `negocio`, `engenharia`)
- `docs/arquitetura/design-system/*.css`
- `docs/arquitetura/templates/diagram-viewer.js` e `docs/arquitetura/templates/sidebar.js`
- `docs/arquitetura/templates/*.html` — páginas de exemplo, usadas pelos prompts como referência de FORMA (copie só as que não existirem no alvo; não sobrescreva páginas já geradas)
- `COMO-USAR.html` → raiz do repo alvo

**Não** copie os arquivos de contexto por-projeto: `project-context.md` e `business-context.md` (em `.amazonq/rules/` e em `.kiro/steering/`) nem `project-context.instructions.md` e `business-context.instructions.md` (em `.github/instructions/`) — são gerados por-serviço pelos analisadores, nos três destinos. Também não toque nos foundation files do Kiro (`.kiro/steering/product.md`, `tech.md`, `structure.md`), gerados pelo próprio Kiro.

Mensagens prontas para cada gatilho: [COMO-USAR.html](COMO-USAR.html) (raiz do repo).

> O pack tem **quatro trilhas: técnica, negócio, frontend e engenharia** — mais o **protocolo de controle de contexto** (rule `controle-style` + prompt `controle-de-tarefa` + pre-commit). Os instaladores entregam tudo.

## Filosofia

Uma única regra rígida: **a convenção de diagramas** (Mermaid + viewer + 4 classDefs com cores fixas).

Tudo o mais — paleta, nomes, padrões, glossário — é **convenção adaptável**. O conteúdo das páginas em `docs/arquitetura/templates/` é **exemplo, não blueprint**. O analisador de projeto (rodado na primeira invocação em cada repo) lê o código real e produz o par de contexto do projeto (`.amazonq/rules/` + `.github/instructions/`) para evitar drift do exemplo.

## Como funciona

> O fluxo abaixo descreve o Amazon Q. No Copilot é o mesmo desenho com outros nomes:
> `.github/instructions/` no lugar de `.amazonq/rules/` (auto-aplicadas), `/analisador-de-projeto`
> como atalho. No Kiro, idem: `.kiro/steering/` (auto-carregado) e os prompts como Agent Skills
> (`.kiro/skills/`, ativadas por descrição). O contexto é gerado nos TRÊS lados
> (`project-context.md` + `project-context.instructions.md` + `.kiro/steering/project-context.md`).

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
Q gera HTML em docs/arquitetura/templates/ usando dados do projeto REAL (não do exemplo)
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
│       ├── controle-style.md                    ← regra universal — protocolo de controle de tarefas (2 turnos + cota)
│       ├── project-context.md                   ← (gerado por-projeto — não versionar)
│       └── business-context.md                  ← (gerado por-projeto — não versionar)
├── .github/                                     ← gerado por tools/sync-copilot.sh — não editar
│   ├── copilot-instructions.md
│   ├── instructions/                            ← 5 rules (.instructions.md); contexto por-projeto é gerado aqui pelos analisadores
│   ├── prompts/                                 ← slash commands (23 arquivos .prompt.md)
│   └── skills/                                  ← Agent Skills (48: 23 wrappers + 25 importadas)
├── .kiro/                                       ← gerado por tools/sync-kiro.sh — não editar
│   ├── steering/                                ← 5 rules (inclusion: always); contexto por-projeto e foundation files são gerados aqui por-serviço
│   └── skills/                                  ← Agent Skills (48: 23 wrappers + 25 importadas)
├── skills/                                      ← biblioteca importada (FONTE das cópias verbatim — 11 categorias, 25 skills; ver skills/README.md)
├── prompts/
│   ├── arquitetura/                             ← 7 prompts (analisador, arquiteto, ADR, runbook, fluxo, grill, brainstorm)
│   ├── frontend/                                ← 4 prompts (ux-controlado, ui-pro-max, design-system, polidor)
│   ├── negocio/                                 ← 5 prompts (analisador-dominio, catalogo, glossario, grill, mapeador)
│   └── engenharia/                              ← 7 prompts (especificador, planejador, grill-plano, executor, tdd, depurador, controle-de-tarefa)
├── tools/
│   ├── manifest.tsv                             ← slug → trilha → descrição (gera os 69 wrappers)
│   ├── pre-commit-controle.sh                   ← watchdog do protocolo de controle (copiado pros alvos pelos instaladores)
│   ├── sync-copilot.sh                          ← gera/valida a camada .github/
│   ├── sync-kiro.sh                             ← gera/valida a camada .kiro/
│   └── sync-como-usar.sh                        ← gera/valida o COMO-USAR.md a partir do .html
├── COMO-USAR.html                               ← mensagens prontas para cada gatilho (raiz, no pack e nos alvos)
├── COMO-USAR.md                                 ← versão markdown — GERADA por tools/sync-como-usar.sh, não editar
└── docs/
    ├── arquitetura/                             ← espelha o layout do repo alvo
    │   ├── design-system/
    │   │   ├── tokens.css                       ← cores, espaço, tipografia, raios, sombras, motion
    │   │   └── components.css                   ← componentes prontos (callouts, badges, cards, tables, etc.)
    │   └── templates/                           ← runtime + exemplos + páginas geradas
    │       ├── index.html                       ← portal de exemplo
    │       ├── 01-visao-geral.html … 14-enums.html ← 11 páginas de exemplo (serviço fictício)
    │       ├── sidebar.js                       ← navegação compartilhada
    │       └── diagram-viewer.js                ← leitor Mermaid + pan/zoom
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

4. **O assistente vai detectar o código, perguntar o necessário, criar `project-context.md`** (sempre nos TRÊS destinos: `.amazonq/rules/`, `.github/instructions/` e `.kiro/steering/`). Revise.

5. **Daí em diante**, todas as gerações de documentação respeitam o contexto do projeto. Exemplos:
   - "Gera a visão geral do serviço"
   - "Cria uma ADR sobre a decisão de usar DynamoDB em vez de PostgreSQL"
   - "Documenta o fluxo de notificação push"
   - "Revisa essa página procurando inconsistências"

## Visualizar o exemplo localmente

Abra qualquer página em `docs/arquitetura/templates/` direto no navegador (Chrome ou Firefox):

```
file:///caminho/para/arquitetura/docs/arquitetura/templates/index.html
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

`.amazonq/rules/` é a fonte canônica (e `COMO-USAR.html` é o canônico do guia). As camadas
`.github/`, `.kiro/` e o `COMO-USAR.md` são GERADOS — não edite à mão.
Depois de editar qualquer rule, o `tools/manifest.tsv` ou o `COMO-USAR.html`:

    bash tools/sync-copilot.sh && bash tools/sync-kiro.sh && bash tools/sync-como-usar.sh     # regenera tudo
    bash tools/sync-copilot.sh --check && bash tools/sync-kiro.sh --check && bash tools/sync-como-usar.sh --check   # antes de commitar

Commite o gerado junto com a mudança canônica.

## Contribuindo

Estrutura genérica universal? PR.
Conteúdo do exemplo "Liquidação Transacional"? Não substitua — é exemplo de forma; cada projeto adapta com `project-context.md`.

## Licença

MIT — veja [LICENSE](LICENSE).

Conteúdo de exemplo em `docs/arquitetura/templates/` é fictício, não representa nenhum sistema real.
