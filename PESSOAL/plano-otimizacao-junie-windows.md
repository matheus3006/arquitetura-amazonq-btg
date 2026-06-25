# Plano de Otimização — Junie (JetBrains) no Windows

> **Objetivo:** parar o desperdício de tokens e os erros de comando do Junie no Windows
> (descasamento de shell → erro → retry loop → queima de contexto) e melhorar a busca de arquivos.
> **Revisado em 2026-06-25** com pesquisa em fontes primárias (docs JetBrains + YouTrack;
> 18 claims confirmados / 7 derrubados). Mudanças vs. a 1ª versão: 🔄 (corrigido), ➕ (novo).
> Tickets `JUNIE-####` são a evidência.

---

## ⏱️ TL;DR — o que fazer amanhã de manhã (10 min)

1. **Shell do IDE → PowerShell 7 (`pwsh.exe`)**, não Git Bash, não cmd.exe. (Sem PS7: `winget install Microsoft.PowerShell`.) — 🔄 *mudou: era Git Bash; ver A1.*
2. Crie **`.junie/guidelines.md`** na raiz do projeto com: **mapa da estrutura do repo** + **comandos reais** (install/test/lint/build) + regra de shell. (Parte B.)
3. **Settings → Tools → Junie → Project Settings → Guidelines Path** → aponte pra esse arquivo **na mão** (o auto-detect falha — JUNIE-618). ➕
4. Modelo e *effort* no **default**. Pergunta simples → **Ask mode**, não o agente.
5. Comando seguro e recorrente pediu aprovação → **"Always allow"**.

Isso resolve o grosso. O resto é o porquê + casos especiais (CLI, Git Bash, file-search).

---

## 0. Decisões (confirme antes de começar)

- [ ] Uso o Junie como: **( ) plugin no IDE**  •  **( ) CLI no terminal**
- [ ] Acesso ao Junie: plugin standalone **ou** pelo **"agente do Junie" dentro do AI Assistant** — é o **mesmo motor**; tudo aqui (pwsh 7, Guidelines Path, `guidelines.md`) se aplica igual. (Só o chat "puro" do AI Assistant, não-agente, é outro caminho.)
- [ ] Shell alvo: **(x) PowerShell 7 (`pwsh.exe`) — recomendado**  •  **( ) Git Bash — só no CLI, ou no IDE se testar que funciona (A1)**
- [ ] Tenho/posso instalar **PowerShell 7**? (`winget install Microsoft.PowerShell` — por usuário, sem admin)

> 🔄 **Por que PowerShell 7 e não Git Bash (correção principal):** no **plugin do IDE**, pôr Git Bash como
> shell padrão **quebra o Junie** — aparece *"Junie can not work without PowerShell"* e ele reverte o
> terminal pra PowerShell (JUNIE-1145; JetBrains confirma como limitação não-intencional). Mesmo override
> com WSL (JUNIE-956). O **PowerShell 7 (`pwsh`)** satisfaz essa exigência **e** tem `&&` e `||` (o Windows
> PowerShell 5.1 não tem) — comandos encadeados estilo Unix funcionam. **No CLI**, o Git Bash roda ok; a
> restrição é só do plugin.

---

## Parte A — Passos manuais no IDE (você faz; o agente NÃO consegue)

### A1. Alinhar o shell para PowerShell 7 ⭐ *maior impacto* — 🔄 corrigido
1. (Se preciso) instale o PS7: `winget install Microsoft.PowerShell` → `C:\Program Files\PowerShell\7\pwsh.exe`.
2. `Ctrl+Alt+S` → **Tools → Terminal** → **Shell path**:
   ```
   C:\Program Files\PowerShell\7\pwsh.exe
   ```
3. **OK** → feche e reabra o terminal do IDE.
4. ✅ **Verificação:** `pwsh -v` (deve dizer 7.x) + `Get-ChildItem`; teste `echo a && echo b` (o `&&` confirma o 7).
5. **NÃO use `cmd.exe`**: o Junie **trava** ao executar comandos nele (`AssertionError: shellIntegration=null`,
   JUNIE-2275, aberto). O workaround oficial da JetBrains é justamente trocar o shell pra PowerShell.

> ⚠️ **Version-sensitive:** o conserto do JUNIE-1145 (Git Bash) está "em andamento" pela JetBrains. Se
> você **precisa** de Git Bash no IDE, teste na sua build: se aparecer o erro "requires PowerShell", fique no `pwsh` 7.

### A2. Manter modelo e effort no DEFAULT — confirmado
- Não troque o modelo nem suba o *effort*. O default é o mais barato **e** o melhor nos benchmarks da
  JetBrains; effort alto raramente melhora e custa muito mais token.

### A3. Usar Ask mode para perguntas — confirmado
- Pergunta simples ("onde está X?", entender código) → **Ask mode / AI Chat**, não o agente. Mais barato e
  não altera código. Reserve o agente pra tarefas que exigem edição/iteração.

### A4. Construir o Allowlist de forma incremental — confirmado
- Comando seguro e recorrente pediu aprovação (`git status`, `pnpm test`…) → **"Always allow"**. Persiste
  sozinho. *(IDE: Settings → Tools → Junie → Action Allowlist, regex Java. CLI: `%USERPROFILE%\.junie\allowlist.json`, GLOB — Anexo 2.)*

### A5. ➕ Apontar o Guidelines Path na mão — novo (crítico)
- **Settings → Tools → Junie → Project Settings → Guidelines Path** → aponte pro arquivo da Parte B.
- **Por quê:** o Junie **não** carrega o `AGENTS.md` automaticamente de forma confiável no IDE (JUNIE-618
  reaberto; builds recentes mantinham o campo no legado `.junie/guidelines.md`). Setar o path na mão
  garante o arquivo certo. JUNIE-1085 também aberto — área em fluxo; **confirme na sua versão**.

---

## Parte B — Dar contexto ao Junie (cole este prompt no agente)

> 🔄 Além dos comandos reais, o arquivo agora traz um **mapa da estrutura do repo** — ataca direto a dor de
> "busca por pasta": o Junie lê o caminho exato em vez de tatear. ➕

**Qual arquivo?** Use **`.junie/guidelines.md`** (o Junie carrega esse caminho de forma confiável em
builds antigas e novas). O nome novo "oficial" é `AGENTS.md`/`.junie/AGENTS.md` (precedência:
`.junie/AGENTS.md` > `AGENTS.md` raiz > `.junie/guidelines.md`), mas como o auto-detect do AGENTS.md falha
no IDE (A5), `guidelines.md` + Guidelines Path setado é o caminho seguro. *(O Junie injeta esse arquivo em
TODA task — mantenha enxuto: 30-50 linhas.)*

```
Goal: Create .junie/guidelines.md to give you persistent project context.
Scope: Only CREATE the file .junie/guidelines.md at the repo root. Do NOT modify any source code. Do NOT run build/test commands.

Steps:
1. Inspect the project to find the REAL commands and the folder layout: read package.json / pom.xml / build.gradle / Makefile / pyproject.toml, and list the top-level directories.
2. Create .junie/guidelines.md with this exact skeleton, filling in the project's actual values (omit a row if it doesn't exist):

# Project Guidelines

## Repo structure (read the exact path; do not scan folders)
- <dir> — <what lives here>
- <dir> — <what lives here>

## Commands
| Install | <fill> |
| Test    | <fill> |
| Lint    | <fill> |
| Build   | <fill> |

## Shell
- Shell is PowerShell 7 (pwsh) on Windows. `&&` and `||` work. Do NOT use Unix-only tools.
- Use ONLY the commands in the table above; do not invent build/test commands.

## Forbidden behavior
- Do NOT refactor or clean up code unless I explicitly say "refactor".
- Do NOT rename files without a valid technical reason.
- Ask before changing more than 3 files in one task.

3. Show me the final file and stop. Do not do anything else.
```

> Se inflar: *"Trim .junie/guidelines.md to rules, structure and commands only, under 50 lines."*

---

## Parte C — Verificação (como saber que funcionou)

- [ ] Comando certo **de primeira** (não erra `npm` vs `pnpm`, não inventa script de teste).
- [ ] **Zero** travas/erros no terminal (sem `cmd.exe`; `&&` funciona no `pwsh` 7).
- [ ] Acha arquivos pelo **caminho** do guidelines, sem varrer pastas.
- [ ] **Menos** pop-ups de aprovação ("Always allow").
- [ ] Prompt curto: `Goal: …` / `Scope: only file A and B`.

---

## ➕ Busca de arquivo / `ls`/`find` voltando vazio (sua dor nº2)

Causa concreta e **não-óbvia**: quando o Junie roda em **bash** (Git Bash, WSL, CLI), o `.bashrc` costuma
emitir sequências de escape (via `PROMPT_COMMAND`, título de janela, `ls` colorido) que **poluem a saída
capturada** → `ls`/`find` voltam **vazios** (JUNIE-1582, confirmado por usuário + JetBrains). Trocar de
shell só mascara; o conserto é sanitizar o rc:

```bash
# no topo do ~/.bashrc
[ -z "$PS1" ] && return                                   # sai cedo em shell nao-interativo
if [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]]; then
  unset PROMPT_COMMAND                                     # nada de escape de titulo
fi
# e evite: alias ls='ls --color=always'
```

> Em **PowerShell 7** essa falha específica não se aplica (é problema de rc do bash). A pesquisa **não**
> achou evidência sobre indexação interna do Junie, Scopes/Project View ou `.aiignore` — então, no IDE, o
> melhor pela busca é o **mapa de estrutura no guidelines** (Parte B): caminho pronto em vez da busca dele.

---

## Plano B — Se ficar no Windows PowerShell 5.1 (sem instalar o 7)

O 5.1 satisfaz a exigência de PowerShell do Junie, mas **não tem `&&`**. No prompt da Parte B, troque o
bloco `## Shell` por:

```
## Shell (CRITICAL)
- Shell is Windows PowerShell 5.1. Chain commands with `;`, NEVER `&&` (it doesn't exist in 5.1).
- Use Get-ChildItem / Remove-Item / Get-Content, not ls -la / rm -rf / cat.
- Use `curl.exe`, not `curl` (which is an alias for Invoke-WebRequest).
```

> Sempre que puder, instale o **PowerShell 7 (`pwsh`)** — `&&`/`||` passam a funcionar e some essa
> ressalva. **Evite `cmd.exe`** (trava — JUNIE-2275).

---

## Anexo 1 — Higiene contínua (economia de token)

- Tarefas pequenas e concretas gastam menos token (menos exploração, menos requests).
- Prompt estruturado: `Goal: …` / `Scope: Only file A and file B. Don't touch other modules.`
- Revise o `guidelines.md` a cada poucas semanas: comando que mudou = comando errado de novo.

## Anexo 2 — Só para Junie CLI — 🔄 ampliado

Config commitável e por-usuário (Windows: `~` = `%USERPROFILE%`):

```
<projeto>\.junie\config.json        # projeto (compartilhavel com o time): model, provider, mcp-locations, guidelines-location
%USERPROFILE%\.junie\config.json    # usuario
%USERPROFILE%\.junie\settings.json  # usuario (ATENCAO: precede o config.json do projeto)
<projeto>\.junie\allowlist.json     # regras de comando do projeto (GLOB)
```

➕ **Precedência (maior → menor):** flags → `~/.junie/settings.json` → `<projeto>/.junie/config.json` →
`~/.junie/config.json`. *(Quirk: o `settings.json` do usuário supera o `config.json` do projeto.)*

➕ Campos do `config.json`: `guidelines-location` (aponta o guidelines — ex.: `./.junie/guidelines.md`) e
`mcp-locations` (pastas com configs de MCP). Dá pra **commitar** o `config.json` do projeto + o
`guidelines.md` e versionar o setup do Junie com o repo.

`allowlist.json` usa **GLOB** (não regex), de cima pra baixo, **1º match vence** → específico antes do geral:

```json
{ "rules": { "executables": { "rules": [
  { "pattern": "pnpm install*", "action": "ask"   },
  { "prefix":  "git",           "action": "allow" },
  { "pattern": "pnpm *",        "action": "allow" },
  { "pattern": "node *",        "action": "allow" }
] } } }
```

---

### Fontes (primárias)
- Shell/terminal quebrado no Windows: JUNIE-2552, JUNIE-2389, JUNIE-3102
- Trava no cmd.exe: JUNIE-2275 · Git Bash força PowerShell: JUNIE-1145 · idem WSL: JUNIE-956
- `ls`/`find` vazio (rc do bash): JUNIE-1582
- AGENTS.md vs guidelines.md (precedência + auto-detect falho): JUNIE-618 (reaberto), JUNIE-1085
- Guidelines & memory: https://junie.jetbrains.com/docs/guidelines-and-memory.html
- Customize guidelines (Guidelines Path): https://www.jetbrains.com/help/junie/customize-guidelines.html
- Config do CLI: https://junie.jetbrains.com/docs/junie-cli-configuration.html
- Action Allowlist: https://junie.jetbrains.com/docs/action-allowlist-junie-cli.html · https://junie.jetbrains.com/docs/action-allowlist.html
- PowerShell 5.1 vs 7: https://learn.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell
- Quota/tokens: https://youtrack.jetbrains.com/articles/SUPPORT-A-1981
