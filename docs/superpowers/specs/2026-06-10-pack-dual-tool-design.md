# Design — Pack dual-tool (Amazon Q + GitHub Copilot) com trilha de engenharia

- **Data:** 2026-06-10
- **Status:** aprovado para planejamento
- **Autor:** Matheus + Claude

## 1. Objetivo

Evoluir o pack `arquitetura` (hoje AmazonQ-only) para funcionar por completo no Amazon Q **e** no GitHub Copilot, corrigindo no caminho os bugs confirmados pela auditoria dos installers e adicionando uma trilha de disciplinas de engenharia portadas do superpowers. O modelo-alvo predominante é Claude Sonnet 4.6 (nos dois assistentes), então os andaimes anti-achatamento existentes são mantidos integralmente.

## 2. Decisões e justificativas

| Decisão | Escolha | Por quê |
|---|---|---|
| Superfícies Copilot | VS Code, Visual Studio/JetBrains, Copilot CLI (sem cloud agent) | Resposta do time. Prompt files cobrem as IDEs; o CLI usa instructions + leitura de arquivo + Agent Skills. |
| Sincronia das rules | `.amazonq/rules/` canônico; `.github/` gerado por script e commitado | Zero drift por construção; fluxo de edição atual não muda; installers continuam cópia burra. |
| Prompts | Árvore `prompts/` única, neutralizada | Os dois assistentes leem os mesmos arquivos; wrappers finos evitam duplicar ~2.200 linhas. |
| Wrappers | `.prompt.md` (IDEs) **e** `SKILL.md` (CLI + Claude Code) para cada prompt | Cobertura completa das superfícies escolhidas; gerados do mesmo manifest. |
| Skills superpowers | systematic-debugging, writing-plans (trilha nova); verification-before-completion (seção de rule); brainstorming (enriquece prompt existente). TDD fora. | Resposta do time. Orquestração (subagentes, worktrees) não porta — depende do harness do Claude Code. |
| Identidade | README/COMO-USAR dual-tool; repo NÃO é renomeado no GitHub | Só texto nesta rodada. |
| Formato do guia de uso | `COMO-USAR.html` (substitui o .md): página no design system do pack, focada em **mensagens prontas para copiar** por trilha/prompt | Decisão do usuário: o guia é para humanos copiarem mensagens que extraem o máximo dos prompts; HTML permite cards + botão copiar e dogfooda o design system. |
| Guia de instalação | `INSTALAR.md` novo: guia escrito **para o assistente de IA do usuário executar** (passos, fallback manual, verificação) | Decisão do usuário: quem instala aponta a própria IA (Q/Copilot/Claude) para o arquivo e diz "instala". |

## 3. Estrutura final do repo

```
arquitetura/
├── .amazonq/rules/                  ← CANÔNICO (editado à mão)
│   ├── architecture-style.md
│   ├── frontend-style.md
│   ├── negocio-style.md
│   └── engenharia-style.md          ← NOVO
├── .github/                         ← GERADO (commitado; nunca editado à mão)
│   ├── copilot-instructions.md      ← entry point curto: identidade do pack + gate + ponteiro pro roteamento
│   ├── instructions/
│   │   ├── architecture-style.instructions.md
│   │   ├── frontend-style.instructions.md
│   │   ├── negocio-style.instructions.md
│   │   └── engenharia-style.instructions.md
│   ├── prompts/<slug>.prompt.md     ← 18 wrappers (um por prompt canônico)
│   └── skills/<slug>/SKILL.md       ← 18 wrappers
├── prompts/                         ← NEUTRO (única fonte da metodologia)
│   ├── arquitetura/  (7 arquivos — brainstorm-arquitetural.md enriquecido)
│   ├── frontend/     (4 arquivos)
│   ├── negocio/      (5 arquivos)
│   └── engenharia/                  ← NOVO
│       ├── depurador-sistematico.md
│       └── planejador-de-implementacao.md
├── tools/
│   ├── sync-copilot.sh              ← gera .github/ a partir do canônico; --check para drift
│   └── manifest.tsv                 ← slug → trilha → descrição (18 entradas)
├── design-system/                   ← inalterado
├── templates/                       ← inalterado
├── install.sh / install.ps1         ← corrigidos + copiam camada nova
├── README.md                        ← dual-tool
├── COMO-USAR.html                   ← guia de uso: mensagens prontas por trilha (substitui COMO-USAR.md)
├── INSTALAR.md                      ← guia de instalação PARA O ASSISTENTE DE IA executar
└── docs/superpowers/specs/          ← este documento
```

## 4. Camada Copilot gerada

**Instructions.** Cada rule canônica vira `<nome>.instructions.md` com frontmatter:

```yaml
---
applyTo: "**"
excludeAgent: "code-review"
---
```

`applyTo: "**"` nas quatro espelha o comportamento do Q (todas as rules sempre carregadas) — escopar `frontend-style` por glob fica para depois. `excludeAgent: "code-review"` evita os arquivos entrarem truncados em reviews (limite de 4.000 chars do code review).

**Transformações do sync por rule (determinísticas):**
1. Injetar o frontmatter acima.
2. Trocar a frase de auto-load ("lido automaticamente pelo Amazon Q…") pela equivalente Copilot.
3. Reescrever paths por tabela fixa: `.amazonq/rules/X.md` → `.github/instructions/X.instructions.md` (cross-references entre rules e linhas da tabela de status §0).

**`copilot-instructions.md`** (gerado de template fixo, < 40 linhas): o que o pack é, onde está o roteamento por gatilhos, o gate de contexto. Existe porque é o único arquivo lido por todas as superfícies sem exceção.

**Wrappers.** Para cada linha do `manifest.tsv`:

- `.github/prompts/<slug>.prompt.md` — frontmatter `description: <descrição>`; corpo de ~8 linhas: "Siga TODO o processo descrito em `prompts/<trilha>/<slug>.md`, fase por fase. Não achate fases interativas em checklist nem em despejo de perguntas."
- `.github/skills/<slug>/SKILL.md` — frontmatter `name` + `description`; mesmo corpo. (Padrão Agent Skills — funciona no Copilot CLI, no VS Code agent mode e no Claude Code.)

O manifest é mantido à mão (18 entradas estáveis); parsing de descrição a partir da prosa foi descartado por fragilidade.

**Modo `--check`:** regenera em diretório temporário e compara com o commitado; exit ≠ 0 em divergência. Preparado para CI futura; nesta rodada é disciplina manual do mantenedor.

## 5. Gate duplo de contexto

Os analisadores (`analisador-de-projeto.md`, `analisador-de-dominio.md`) passam a gravar em dois destinos:

| Conteúdo | Amazon Q | Copilot |
|---|---|---|
| Contexto técnico | `.amazonq/rules/project-context.md` (sem frontmatter) | `.github/instructions/project-context.instructions.md` (com `applyTo: "**"`) |
| Contexto de negócio | `.amazonq/rules/business-context.md` | `.github/instructions/business-context.instructions.md` (idem) |

Texto canônico do gate (igual nos dois lados, citando ambos os paths — assim o sync não precisa reescrever esta parte):

> Nenhum dos dois existe → rodar o analisador primeiro e parar. Só um existe (repo da era Q-only) → espelhar o conteúdo no outro destino (com/sem frontmatter conforme o lado) antes de prosseguir.

Risco conhecido: arquivo Copilot gravado **sem** frontmatter existe mas nunca auto-carrega (quebra silenciosa). Mitigação: o template de saída nos analisadores traz o frontmatter literal no esqueleto do arquivo Copilot, e o checklist de aceitação dos analisadores ganha o item "o arquivo `.instructions.md` começa com `applyTo`?".

## 6. Neutralização de `prompts/`

As ~113 referências específicas de ferramenta nos prompts existentes viram linguagem neutra:

| Antes | Depois |
|---|---|
| "Amazon Q", "o Q" | "o assistente" |
| `@workspace` | "explore o código do workspace" |
| "modo write" | "gere o arquivo" |
| "Exemplo de invocação no Amazon Q" | "Exemplo de invocação" + tabela: Q (mensagem com path) · Copilot IDE (`/comando`) · Copilot CLI (gatilho em linguagem natural) |
| "O Amazon Q tende a achatar…" (grill-negocio) | "Assistentes tendem a achatar…" — **andaime preservado na íntegra** |

Paths de saída dos analisadores ganham o destino duplo da seção 5. As menções a `.amazonq/rules/architecture-style.md § 1/§ 2` nos STATUS dos prompts viram referência neutra ("a rule de estilo da trilha técnica — `.amazonq/rules/` ou `.github/instructions/` conforme a ferramenta").

## 7. Trilha engenharia (nova)

**Rule canônica `engenharia-style.md`** — sem gate de contexto (as disciplinas funcionam em qualquer repo). Contém:

1. Tabela de gatilhos: "debugga", "investiga esse bug", "não funciona", "causa raiz" → `prompts/engenharia/depurador-sistematico.md`; "planeja a implementação", "plano de implementação", "quebra em etapas" → `prompts/engenharia/planejador-de-implementacao.md`.
2. Seção sempre-ativa **"Disciplina de conclusão"** (porte destilado de `verification-before-completion`, ~12 linhas): nunca afirmar "pronto/corrigido/passando" sem rodar o comando de verificação na mesma resposta e mostrar o output; teste falhando é reportado como falhando; passo pulado é declarado.

**`depurador-sistematico.md`** (porte de `systematic-debugging`): 4 fases com gates — (1) reproduzir e ler a mensagem de erro inteira, (2) investigar causa raiz com evidência do código/logs, (3) formular UMA hipótese testável por vez, (4) fix mínimo + verificação. Gate central: **proibido propor correção antes de evidência de causa raiz**. Elementos do harness Claude (TodoWrite, subagentes) ficam de fora do porte.

**`planejador-de-implementacao.md`** (porte de `writing-plans`): a partir de um spec/requisito, produzir plano em etapas pequenas e independentemente verificáveis (cada etapa: o que muda, como verificar, critério de pronto), salvo em `docs/planos/<data>-<slug>.md`. Pressupõe design já discutido; aponta para o `brainstorm-arquitetural` quando não há.

**Enriquecimento do `brainstorm-arquitetural.md`** (porte da disciplina de `brainstorming`): uma pergunta por vez com preferência por múltipla escolha; 2-3 abordagens com trade-offs e recomendação antes de fechar; design apresentado por seções com aprovação; saída final alimenta `gerador-adr.md` (terminal state mantido — pré-ADR). Visual companion e Skill tool não portam.

Método de porte (já validado no pack): preservar fases, gates e árvore de decisão; nunca achatar em checklist; atribuição da skill de origem no bloco STATUS.

## 8. Fixes da auditoria (incorporados)

**Os dois installers:**
- Copiar `prompts/frontend/` e `prompts/engenharia/` (bug grave: rules roteiam para arquivos não instalados).
- Copiar a camada `.github/` inteira (copilot-instructions.md, instructions/, prompts/, skills/), protegendo os 4 arquivos de contexto gerados (`*-context*` nos dois lados — nunca sobrescrever).
- Copiar a 4ª rule (`engenharia-style.md`).
- `✓` impresso só quando a cópia de fato ocorreu; falha de item opcional vira `⚠`, falha de item obrigatório aborta com mensagem clara.
- Hints pós-install cobrem as 4 trilhas.
- Exclusão de `.DS_Store` após as cópias recursivas.

**Só `install.sh`:**
- Flag desconhecida (`--*` não reconhecida) vira erro com usage, em vez de virar TARGET silenciosamente.
- `--help` imprime apenas o cabeçalho de uso (sem shebang nem comentários internos de seção).

**Só `install.ps1`:**
- Em-dashes (U+2014) → `--` (arquivo 100% ASCII; resolve mojibake no Windows PowerShell 5.1 sem depender de BOM).
- Guard de auto-instalação: `TrimEnd` de separadores nos dois lados da comparação.
- Alvo inexistente → mensagem amigável + exit 1 (paridade com o .sh), em vez de exceção crua do `Resolve-Path`.
- `Write-Error` + `exit` morto → `Write-Host` + `exit 1`; path da sugestão montado com `Join-Path`.
- Cópias opcionais com tratamento por item (paridade de comportamento com o .sh corrigido).

**Rules canônicas:**
- Remover a linha `templates/negocio/*` da tabela de `negocio-style.md` (diretório nunca existiu).
- Condicionar a âncora `templates/01-visao-geral.html` em `architecture-style.md` ao install com `--with-examples` ("caso contrário, siga o esqueleto abaixo").

## 9. README, COMO-USAR.html e INSTALAR.md

- README: posicionamento "pack para Amazon Q e GitHub Copilot"; instalação aponta para `INSTALAR.md` (via IA) e para os scripts (via humano); árvore de estrutura atualizada; "Como funciona" com os dois caminhos; nota sobre `tools/sync-copilot.sh` para mantenedores.
- **COMO-USAR.html** (substitui COMO-USAR.md): página no design system do pack (tokens + components, scripts clássicos, funciona em `file://`), com um card por prompt (18), agrupados por trilha, cada um com a **mensagem pronta** ("siga todo o processo descrito em ...") com `[CAMPOS]` para trocar, botão copiar, e a alternativa `/slug` para Copilot IDE. É o arquivo que os installers copiam para o repo do serviço.
- **INSTALAR.md**: guia imperativo escrito para o assistente de IA do usuário executar de ponta a ponta: obter o pack, rodar o script da plataforma (ou fallback de cópia manual com lista exata), NUNCA copiar arquivos de contexto, verificar a instalação (comandos + esperado) e orientar o usuário ao primeiro passo (analisador). Não é copiado para o repo alvo — vive no pack.

## 10. Validação

1. **Installers:** re-executar em sandbox (mktemp) os cenários da auditoria: instalação limpa (conferir que TODOS os paths citados pelas rules/instructions existem no alvo), re-run com contextos pré-existentes nos dois lados (devem sobreviver), `--with-examples`, guard com e sem trailing slash, `--help`, flag inválida, alvo inexistente, path com espaços. `install.ps1` sem execução local (sem pwsh): validação estática + paridade linha a linha; teste real no Windows do trabalho fica como passo do usuário.
2. **Sync:** rodar 2× → idempotente (diff vazio); `--check` limpo após commit; mutação proposital em rule canônica → `--check` acusa.
3. **Conteúdo:** grep de varredura pós-neutralização (`amazon q|amazonq|@workspace|modo write`) deve retornar zero em `prompts/` (exceto menções legítimas em tabelas de invocação por ferramenta); grep de paths pendurados (`templates/negocio`, refs a arquivos inexistentes) deve retornar zero no repo inteiro.
4. **Smoke manual (usuário, no trabalho):** VS Code `/gerador-adr`; CLI com gatilho natural; Amazon Q com fluxo atual (regressão).

## 11. Fora de escopo desta rodada

- TDD como prompt (decisão do time).
- Cloud agent / `AGENTS.md` / `copilot-setup-steps.yml`.
- Renomear o repo no GitHub.
- CI executando `sync-copilot.sh --check` (script já nasce pronto para isso).
- Escopar `frontend-style` por glob (`applyTo: "**/*.html,**/*.css"`).
- Páginas de exemplo da trilha negócio (`templates/negocio/`) — a referência pendurada é removida; criar exemplos reais fica para depois.
