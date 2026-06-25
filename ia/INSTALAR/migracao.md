# INSTALAR · Passo 4 — Re-instalação / atualização (inclui MIGRAÇÃO de versão antiga)

> Sub-página de [`../INSTALAR.md`](../INSTALAR.md). **Só siga isto se o alvo já tem uma
> instalação ANTIGA do pack.** Os scripts `install.sh`/`install.ps1` já fazem TODAS estas
> correções sozinhos — esta página é para quando você instala/migra **na mão**. Ao corrigir,
> rode o **Passo 3** do INSTALAR.md de novo.

Rodar de novo é seguro: os scripts (e a regra da cópia manual) preservam os arquivos de
contexto por-serviço (nos três lados) e os foundation files do Kiro. O resto é
sobrescrito com a versão nova do pack — é o esperado.

**Se o alvo já tem uma instalação ANTIGA do pack, você DEVE detectá-la e corrigi-la** até
ficar idêntica ao estado novo. A versão antiga usava um **pre-commit que bloqueava o
`git commit`** e guardava as tasks em **`controle/` na raiz**; a versão nova usa **hooks de
início de interação** e guarda as tasks em **`doc/controle/`**. Verifique cada sinal abaixo
e aplique a correção:

| Sinal de versão antiga | Correção (deixar igual ao estado novo) |
|---|---|
| `.git/hooks/pre-commit` contém `pre-commit-controle` | Se o arquivo **só** chama o pre-commit-controle, **apague-o**. Se tiver outras linhas, remova **apenas** a linha `bash .amazonq/hooks/pre-commit-controle.sh \|\| exit 1`. Isso destrava o `git commit`. |
| Existe `.amazonq/hooks/pre-commit-controle.sh` | **Apague** — foi substituído pelos hooks de início de interação. |
| Faltam `.amazonq/cli-agents/arquitetura.json`, `.amazonq/hooks/controle-hook.sh` ou `.kiro/hooks/controle-prompt.kiro.hook` | **Copie-os** do pack (tabela de cópia em [`manual.md`](manual.md)) e dê `+x` no `controle-hook.sh`. |
| Existe `controle/` na **raiz** do repo (com tasks dentro) | **Mova** cada pasta de task para `doc/controle/` (crie se não existir). Preserve tudo — são dados do usuário; **não apague**. Se uma task de mesmo nome já existir em `doc/controle/`, faça merge sem sobrescrever. Remova o `controle/` só depois de vazio. |
| `ia/skills/` sem as categorias `fluxo-dev`, `orquestracao` ou `documentacao` (ou com menos de 32 skills) | **Recopie** `ia/skills/`, `.github/` e `.kiro/` inteiras do pack — trazem as skills novas (5 do lote dev/debug + `doc-coauthoring`) e os 3 prompts novos da v2 (`validador-visual`, `validador-sintaxe-mermaid`, `atualizador-arquitetura`). |
| Rules/prompts ainda citam `controle/` (raiz) ou o "pre-commit" como trava | São sobrescritos ao recopiar `.amazonq/rules/`, `ia/prompts/`, `.github/` e `.kiro/` do pack — refaça a cópia (Passo 1 ou cópia manual). |
| **Layout pré-`ia/`+`doc/`**: existem `prompts/`, `skills/` ou `tools/` na **raiz**, ou uma pasta `docs/` (em vez de `doc/`) | **Migre o layout.** Mova os DADOS do usuário pra `doc/`: `docs/controle`→`doc/controle`, `docs/adr`→`doc/adr`, `docs/specs`/`docs/planos`→`doc/`, e a doc real em `docs/arquitetura/` (tudo **menos** `templates/` e `design-system/`, que são do pack) → `doc/arquitetura/`. **Remova** as cópias antigas do pack na raiz (`prompts/`, `skills/`, `tools/`, `COMO-USAR.html`, `COMO-USAR.md`) — já reinstaladas em `ia/`. Preserve os dados do usuário; nunca sobrescreva. |

Depois de corrigir, **rode o Passo 3 do INSTALAR.md de novo** e confirme também que a versão antiga sumiu:

- NÃO existe mais `.git/hooks/pre-commit` do pack nem `.amazonq/hooks/pre-commit-controle.sh`;
- NÃO existe mais `controle/` na raiz — só `doc/controle/`;
- NÃO existem mais `prompts/`, `skills/`, `tools/` na raiz nem a pasta `docs/` — o pack vive em `ia/` e os outputs em `doc/`;
- os 3 arquivos de hook novos existem (`.amazonq/cli-agents/arquitetura.json`, `.amazonq/hooks/controle-hook.sh`, `.kiro/hooks/controle-prompt.kiro.hook`).

Os scripts `install.sh` / `install.ps1` já fazem TODAS essas correções sozinhos (removem o
pre-commit, instalam os hooks novos, movem `controle/` → `doc/controle/` e migram o layout antigo
para `ia/` + `doc/`); esta tabela é para quando você instala/migra na mão.
