# INSTALAR.md — guia de instalação (para o seu assistente de IA executar)

> **Você, assistente** (Amazon Q, GitHub Copilot, Claude ou outro agente com acesso a
> arquivos): este arquivo é um runbook para VOCÊ executar, não um texto para resumir ao
> usuário. Siga os passos na ordem. O objetivo é instalar o pack `arquitetura` no
> repositório do serviço do usuário.

## Passo 0 — Confirme o alvo

Identifique a RAIZ do repositório do serviço onde o pack será instalado. Se não estiver
claro pelo contexto, pergunte ao usuário. Duas regras:

- NUNCA instale dentro do próprio pack (o diretório que contém este INSTALAR.md).
- O alvo deve ser a raiz do repo (onde fica o `.git/`), não uma subpasta.

## Passo 1 — Caminho preferido: rode o script

Se você pode executar comandos de shell:

- **macOS / Linux:** `bash <caminho-do-pack>/install.sh <raiz-do-repo-alvo>`
- **Windows:** `powershell -ExecutionPolicy Bypass -File <caminho-do-pack>\install.ps1 -Target <raiz-do-repo-alvo>`
- Opcional: acrescente `--with-examples` (sh) ou `-WithExamples` (ps1) para incluir as
  páginas HTML de exemplo.

O script é idempotente e termina com a lista do que copiou. Se der erro, a mensagem é
autoexplicativa (alvo inexistente, opção desconhecida, alvo = próprio pack) — corrija e
rode de novo. Se o script funcionou, pule para o Passo 3.

## Passo 2 — Fallback: cópia manual (se você não pode rodar shell)

Copie do pack para a raiz do repo alvo, preservando a estrutura de pastas:

| Origem (pack) | Destino (repo alvo) |
|---|---|
| `.amazonq/rules/architecture-style.md`, `frontend-style.md`, `negocio-style.md`, `engenharia-style.md` | `.amazonq/rules/` |
| `.github/copilot-instructions.md` | `.github/` |
| `.github/instructions/*.instructions.md` (as 4 de estilo) | `.github/instructions/` |
| `.github/prompts/` (inteira) | `.github/prompts/` |
| `.github/skills/` (inteira) | `.github/skills/` |
| `prompts/arquitetura/`, `prompts/frontend/`, `prompts/negocio/`, `prompts/engenharia/` (inteiras) | `prompts/` |
| `design-system/*.css` | `design-system/` |
| `templates/diagram-viewer.js`, `templates/sidebar.js` | `templates/` |
| `COMO-USAR.html` | raiz do repo |

**NUNCA copie (nem sobrescreva se existirem no alvo):**

- `.amazonq/rules/project-context.md` e `.amazonq/rules/business-context.md`
- `.github/instructions/project-context.instructions.md` e `business-context.instructions.md`

Esses 4 são por-serviço, gerados pelos analisadores DEPOIS da instalação. Se já existem
no alvo, é uma instalação anterior — preserve-os intactos.

Também não copie: `templates/*.html` (exemplos, só se o usuário pedir), `tools/`,
`INSTALAR.md`, `README.md`, `LICENSE`, `docs/` — são do pack, não do serviço.

## Passo 3 — Verifique a instalação

Confira que TODOS estes paths existem no repo alvo (via shell ou listagem de arquivos):

- `.amazonq/rules/` com as 4 rules de estilo
- `.github/copilot-instructions.md` + `.github/instructions/` com 4 arquivos `.instructions.md`
- `.github/prompts/` com 18 arquivos `.prompt.md` e `.github/skills/` com 18 subpastas
- `prompts/` com as 4 trilhas (7 + 4 + 5 + 2 = 18 arquivos `.md`)
- `design-system/` com 2 `.css`; `templates/` com os 2 `.js`; `COMO-USAR.html` na raiz

Se algo faltar, volte ao passo que o copia. Não declare a instalação concluída sem
esta verificação (evidência antes de afirmação).

## Passo 4 — Re-instalação / atualização

Rodar de novo é seguro: os scripts (e a regra do Passo 2) preservam os 4 arquivos de
contexto por-serviço. O resto é sobrescrito com a versão nova do pack — é o esperado.

## Passo 5 — Oriente o usuário (primeiro uso)

Ao terminar, diga ao usuário, nas suas palavras:

1. A instalação está completa e verificada (mostre a lista do Passo 3).
2. O primeiro passo de uso é gerar o contexto do projeto: mensagem "analisa o projeto"
   (Amazon Q) ou `/analisador-de-projeto` (Copilot IDE). Sem isso, o pack bloqueia
   gerações de documentação de propósito.
3. As mensagens prontas para todos os fluxos estão em `COMO-USAR.html` — abrir no navegador.

## Regras para você, assistente

- Não modifique nenhum arquivo do pack ao copiar — cópia fiel.
- Não rode `tools/sync-copilot.sh` no repo alvo: é ferramenta de manutenção do pack.
- Não commite nada sem o usuário pedir.
