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
  páginas HTML de exemplo. Só use se o usuário pedir as páginas de exemplo.

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
| `docs/arquitetura/design-system/*.css` | `docs/arquitetura/design-system/` |
| `docs/arquitetura/templates/diagram-viewer.js`, `docs/arquitetura/templates/sidebar.js` | `docs/arquitetura/templates/` |
| `docs/arquitetura/COMO-USAR.html` | `docs/arquitetura/COMO-USAR.html` |

Crie `docs/arquitetura/` (e subpastas) no alvo se não existirem.

**NUNCA copie (nem sobrescreva se existirem no alvo):**

- `.amazonq/rules/project-context.md` e `.amazonq/rules/business-context.md`
- `.github/instructions/project-context.instructions.md` e `business-context.instructions.md`

Esses arquivos NÃO existem no pack — a regra é sobre nunca sobrescrevê-los no repositório alvo quando já existirem lá. Esses 4 são por-serviço, gerados pelos analisadores DEPOIS da instalação. Se já existem
no alvo, é uma instalação anterior — preserve-os intactos.

Também não copie: `docs/arquitetura/templates/*.html` (exemplos, só se o usuário pedir),
`tools/`, `INSTALAR.md`, `README.md`, `LICENSE`, `docs/superpowers/` — são do pack, não do
serviço. Atenção: o resto de `docs/arquitetura/` (css, os 2 `.js` e `COMO-USAR.html`) **é**
copiado, conforme a tabela acima.

## Passo 3 — Verifique a instalação

Confira que TODOS estes paths existem no repo alvo (via shell ou listagem de arquivos):

- `.amazonq/rules/` com as 4 rules de estilo (mais os arquivos de contexto, se já gerados)
- `.github/copilot-instructions.md` + `.github/instructions/` com 4 arquivos `*-style.instructions.md` (mais os de contexto, se os analisadores já rodaram neste repo)
- `.github/prompts/` com 18 arquivos `.prompt.md` e `.github/skills/` com 18 subpastas
- `prompts/` com as 4 trilhas (arquitetura 7, frontend 4, negocio 5, engenharia 2 — 18 arquivos `.md`)
- `docs/arquitetura/design-system/` com 2 `.css`; `docs/arquitetura/templates/` com os 2 `.js`; `docs/arquitetura/COMO-USAR.html`

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
3. As mensagens prontas para todos os fluxos estão em `docs/arquitetura/COMO-USAR.html` — abrir no navegador.

## Regras para você, assistente

- Não modifique nenhum arquivo do pack ao copiar — cópia fiel.
- Não rode `tools/sync-copilot.sh` no repo alvo: é ferramenta de manutenção do pack.
- Não commite nada sem o usuário pedir.
