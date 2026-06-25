# INSTALAR · Passo 2 — Fallback: cópia manual

> Sub-página de [`../INSTALAR.md`](../INSTALAR.md). **Só siga isto se você NÃO pode rodar o
> script** (Passo 1). Se rodou o `install.sh`/`install.ps1` com sucesso, **ignore esta
> página** e volte ao **Passo 3** do INSTALAR.md para verificar.

Copie do pack para a raiz do repo alvo, preservando a estrutura de pastas:

| Origem (pack) | Destino (repo alvo) |
|---|---|
| `.amazonq/rules/architecture-style.md`, `frontend-style.md`, `negocio-style.md`, `engenharia-style.md`, `controle-style.md` | `.amazonq/rules/` |
| `.amazonq/cli-agents/arquitetura.json` | `.amazonq/cli-agents/` |
| `.amazonq/hooks/controle-hook.sh` | `.amazonq/hooks/` (dê permissão de execução) |
| `.kiro/hooks/controle-prompt.kiro.hook` | `.kiro/hooks/` |
| `.github/copilot-instructions.md` | `.github/` |
| `.github/instructions/*.instructions.md` (as 5 de estilo) | `.github/instructions/` |
| `.github/prompts/` (inteira) | `.github/prompts/` |
| `.github/skills/` (inteira) | `.github/skills/` |
| `.kiro/steering/*.md` (as 5 de estilo) | `.kiro/steering/` |
| `.kiro/skills/` (inteira) | `.kiro/skills/` |
| `.junie/guidelines.md` | `.junie/` |
| `ia/prompts/arquitetura/`, `ia/prompts/frontend/`, `ia/prompts/negocio/`, `ia/prompts/engenharia/` (inteiras) | `ia/prompts/` |
| `ia/skills/` (inteira — biblioteca de 32 skills importadas) | `ia/skills/` |
| `ia/design-system/*.css` | `ia/design-system/` |
| `ia/templates/diagram-viewer.js`, `ia/templates/sidebar.js` | `ia/templates/` |
| `ia/templates/*.html` (exemplos de FORMA — copie **só os que não existem** no alvo; nunca sobrescreva) | `ia/templates/` |
| `ia/COMO-USAR.html` | `ia/COMO-USAR.html` (em ia/, no alvo) |
| `ia/COMO-USAR.md` | `ia/COMO-USAR.md` (em ia/ — versão markdown gerada) |

Crie `ia/` (com `prompts/`, `skills/`, `design-system/`, `templates/`) e `doc/` no alvo se não
existirem. A doc REAL gerada do serviço vai em `doc/arquitetura/`; os exemplos de forma ficam em
`ia/templates/`.

**`.gitignore` do produto (na cópia manual):** replique o bloco de
`ia/tools/lib/gitignore-pack-block.txt` no `.gitignore` do alvo — ele **ignora** as réplicas
pesadas (`.github/skills/`, `.github/prompts/`, `.kiro/skills/`, `ia/skills/`) e **mantém
versionada** a config + o contexto por-serviço + `doc/`.

**Hooks de início de interação (substituem o antigo pre-commit — não há mais trava no
`git commit`):**

- **Amazon Q:** rode com o agente do pack — `q chat --agent arquitetura` — para o hook
  `userPromptSubmit` (`.amazonq/hooks/controle-hook.sh`) disparar a cada mensagem e
  lembrar de abrir/atualizar a task em `doc/controle/`.
- **Kiro:** `.kiro/hooks/controle-prompt.kiro.hook` aparece no painel de hooks; o trigger
  `promptSubmit` dispara sozinho. (A ação `askAgent` consome crédito — desligável no painel.)
- **Copilot:** sem hook de início de interação — segue só na instruction sempre-on.
- **Junie:** sem hook de início de interação — segue só no `.junie/guidelines.md` sempre-on.
- **Migração de instalação antiga:** se o alvo tem `.git/hooks/pre-commit` contendo
  `pre-commit-controle`, **apague-o** para destravar o commit; remova também
  `.amazonq/hooks/pre-commit-controle.sh` se existir. (Os instaladores fazem isso sozinhos.)

**NUNCA copie (nem sobrescreva se existirem no alvo):**

- `.amazonq/rules/project-context.md` e `.amazonq/rules/business-context.md`
- `.github/instructions/project-context.instructions.md` e `business-context.instructions.md`
- `.kiro/steering/project-context.md` e `.kiro/steering/business-context.md`
- `.kiro/steering/product.md`, `.kiro/steering/tech.md` e `.kiro/steering/structure.md`
  (foundation files gerados pelo próprio Kiro)

Esses arquivos NÃO existem no pack — a regra é sobre nunca sobrescrevê-los no repositório alvo quando já existirem lá. São por-serviço: os contextos são gerados pelos analisadores DEPOIS da instalação, e os foundation files pelo próprio Kiro. Se já existem
no alvo, é uma instalação anterior — preserve-os intactos.

Também não copie: `ia/tools/` inteira (são scripts de manutenção do pack de origem),
`INSTALAR.md`, `ia/INSTALAR/` (esta pasta de runbook), `README.md`, `LICENSE`,
nem a `doc/` do pack — são do pack, não do serviço. Os assets reutilizáveis do pack
(css, os 2 `.js`, as páginas de exemplo e o `ia/COMO-USAR.html`) **são** copiados, mas
vivem em `ia/design-system/`, `ia/templates/` e `ia/`, conforme a tabela acima — não há
mais nenhum asset do pack dentro de `doc/`.

Ao terminar a cópia, volte ao **Passo 3** do [`../INSTALAR.md`](../INSTALAR.md) para verificar.
