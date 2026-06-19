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
- As páginas HTML de exemplo são instaladas **por padrão** (os prompts usam-nas como
  referência de FORMA ao gerar documentação) e **nunca sobrescrevem** arquivos já
  existentes no alvo. Para excluí-las: `--no-examples` (sh) ou `-NoExamples` (ps1) —
  só use se o usuário pedir explicitamente.

O script é idempotente e termina com a lista do que copiou. Se der erro, a mensagem é
autoexplicativa (alvo inexistente, opção desconhecida, alvo = próprio pack) — corrija e
rode de novo. Se o script funcionou, pule para o Passo 3.

## Passo 2 — Fallback: cópia manual (se você não pode rodar shell)

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

**Hooks de início de interação (substituem o antigo pre-commit — não há mais trava no
`git commit`):**

- **Amazon Q:** rode com o agente do pack — `q chat --agent arquitetura` — para o hook
  `userPromptSubmit` (`.amazonq/hooks/controle-hook.sh`) disparar a cada mensagem e
  lembrar de abrir/atualizar a task em `doc/controle/`.
- **Kiro:** `.kiro/hooks/controle-prompt.kiro.hook` aparece no painel de hooks; o trigger
  `promptSubmit` dispara sozinho. (A ação `askAgent` consome crédito — desligável no painel.)
- **Copilot:** sem hook de início de interação — segue só na instruction sempre-on.
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
`INSTALAR.md`, `README.md`, `LICENSE`,
nem a `doc/` do pack — são do pack, não do serviço. Os assets reutilizáveis do pack
(css, os 2 `.js`, as páginas de exemplo e o `ia/COMO-USAR.html`) **são** copiados, mas
vivem em `ia/design-system/`, `ia/templates/` e `ia/`, conforme a tabela acima — não há
mais nenhum asset do pack dentro de `doc/`.

## Passo 3 — Verifique a instalação

Confira que TODOS estes paths existem no repo alvo (via shell ou listagem de arquivos):

- `.amazonq/rules/` com as 5 rules de estilo (mais os arquivos de contexto, se já gerados)
- `.amazonq/cli-agents/arquitetura.json` + `.amazonq/hooks/controle-hook.sh` + `.kiro/hooks/controle-prompt.kiro.hook` (hooks de início de interação do controle; **sem** git hook — o commit não é mais bloqueado)
- `.github/copilot-instructions.md` + `.github/instructions/` com 5 arquivos `*-style.instructions.md` (mais os de contexto, se os analisadores já rodaram neste repo)
- `.github/prompts/` com 32 arquivos `.prompt.md` e `.github/skills/` com 64 subpastas (32 wrappers + 32 importadas)
- `.kiro/steering/` com as 5 rules de estilo e `.kiro/skills/` com 64 subpastas
- `ia/prompts/` com as 4 trilhas (arquitetura 13, frontend 4, negocio 5, engenharia 10 — 32 arquivos `.md`)
- `ia/skills/` com 14 categorias e 32 subpastas com `SKILL.md` (biblioteca importada)
- `ia/design-system/` com 2 `.css`; `ia/templates/` com os 2 `.js`; `ia/COMO-USAR.html` e `ia/COMO-USAR.md` em ia/, no repo
- `ia/templates/` com as páginas de exemplo (`01-visao-geral.html`, `index.html`, etc.) — exceto se a instalação usou `--no-examples`

Se algo faltar, volte ao passo que o copia. Não declare a instalação concluída sem
esta verificação (evidência antes de afirmação).

## Passo 4 — Re-instalação / atualização (inclui MIGRAÇÃO de versão antiga)

Rodar de novo é seguro: os scripts (e a regra do Passo 2) preservam os arquivos de
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
| Faltam `.amazonq/cli-agents/arquitetura.json`, `.amazonq/hooks/controle-hook.sh` ou `.kiro/hooks/controle-prompt.kiro.hook` | **Copie-os** do pack (tabela do Passo 2) e dê `+x` no `controle-hook.sh`. |
| Existe `controle/` na **raiz** do repo (com tasks dentro) | **Mova** cada pasta de task para `doc/controle/` (crie se não existir). Preserve tudo — são dados do usuário; **não apague**. Se uma task de mesmo nome já existir em `doc/controle/`, faça merge sem sobrescrever. Remova o `controle/` só depois de vazio. |
| `ia/skills/` sem as categorias `fluxo-dev`, `orquestracao` ou `documentacao` (ou com menos de 32 skills) | **Recopie** `ia/skills/`, `.github/` e `.kiro/` inteiras do pack — trazem as skills novas (5 do lote dev/debug + `doc-coauthoring`) e os 3 prompts novos. |
| Rules/prompts ainda citam `controle/` (raiz) ou o "pre-commit" como trava | São sobrescritos ao recopiar `.amazonq/rules/`, `ia/prompts/`, `.github/` e `.kiro/` do pack — refaça a cópia (Passo 1 ou 2). |
| **Layout pré-`ia/`+`doc/`**: existem `prompts/`, `skills/` ou `tools/` na **raiz**, ou uma pasta `docs/` (em vez de `doc/`) | **Migre o layout.** Mova os DADOS do usuário pra `doc/`: `docs/controle`→`doc/controle`, `docs/adr`→`doc/adr`, `docs/specs`/`docs/planos`→`doc/`, e a doc real em `docs/arquitetura/` (tudo **menos** `templates/` e `design-system/`, que são do pack) → `doc/arquitetura/`. **Remova** as cópias antigas do pack na raiz (`prompts/`, `skills/`, `tools/`, `COMO-USAR.html`, `COMO-USAR.md`) — já reinstaladas em `ia/`. Preserve os dados do usuário; nunca sobrescreva. |

Depois de corrigir, **rode o Passo 3 de novo** e confirme também que a versão antiga sumiu:

- NÃO existe mais `.git/hooks/pre-commit` do pack nem `.amazonq/hooks/pre-commit-controle.sh`;
- NÃO existe mais `controle/` na raiz — só `doc/controle/`;
- NÃO existem mais `prompts/`, `skills/`, `tools/` na raiz nem a pasta `docs/` — o pack vive em `ia/` e os outputs em `doc/`;
- os 3 arquivos de hook novos existem (`.amazonq/cli-agents/arquitetura.json`, `.amazonq/hooks/controle-hook.sh`, `.kiro/hooks/controle-prompt.kiro.hook`).

Os scripts `install.sh` / `install.ps1` já fazem TODAS essas correções sozinhos (removem o
pre-commit, instalam os hooks novos, movem `controle/` → `doc/controle/` e migram o layout antigo
para `ia/` + `doc/`); esta tabela é para quando você instala/migra na mão.

## Passo 4b — Prepare a documentação existente para o novo fluxo (diagnóstico, não-destrutivo)

A re-instalação **preserva** a documentação que o usuário já gerou (os `project-context` /
`business-context` nos três destinos e as páginas em `doc/arquitetura/`). Se essa doc foi gerada
por uma versão **anterior ao fluxo canônico de 3 etapas** (`documentar-servico` →
`completar-documentacao` → `grill-arquitetura`), ela pode estar incompleta. Este passo é **só
diagnóstico**: você **NÃO edita nem gera nada** — entrega ao usuário um plano do que falta e qual
card rodar. Diferente do Passo 4, os scripts **não** fazem isto (exige ler a doc e julgar); é
tarefa sua, assistente.

**Primeiro, há doc real a migrar?** Se o `project-context` (nos três destinos) ainda é o exemplo
fictício **"Liquidação Transacional"**, então **não há doc gerada** — siga para o Passo 5 (primeiro
uso normal). Só continue aqui se a doc descreve o **serviço real** do usuário.

| Sinal na doc existente | O que falta | Card para completar (no `COMO-USAR`) |
|---|---|---|
| `project-context` real existe, mas faltam os `business-context.md` (`.amazonq/rules/`, `.github/instructions/business-context.instructions.md`, `.kiro/steering/`) | a fundação de negócio | **"Mapear o domínio"** — trilha _Documentar o negócio_ (`/analisador-de-dominio`) |
| Há páginas em `doc/arquitetura/`, mas **sem runbook nem fluxos críticos** | operação + runtime | **"Completar a documentação (Etapa 2/3)"** (`/completar-documentacao`) |
| Doc com `⚠ a confirmar`, números redondos ou garantias não resolvidas | auditoria das incertezas | **"Grill intenso de arquitetura (Etapa 3/3)"** (`/grill-arquitetura`, em sessão nova) |

Regras deste passo:

- **Não** rode os cards você mesmo nem edite a doc — apenas monte o diagnóstico.
- **Não** re-rode a Etapa 1 "do zero" sobre uma doc que já existe (duplicaria/sobrescreveria). Quem
  já tem doc completa **só os blocos que faltam** — é exatamente por isso que eles existem como
  cards isolados (ex.: o `business-context` é preenchido só pelo "Mapear o domínio", sem refazer a
  arquitetura).
- A geração roda **depois**, disparada pelo usuário, sob o protocolo de controle (task de 2 turnos:
  plano → aprovação → execução).

**Saída:** no fechamento (Passo 5), apresente algo como _"sua doc tem X, falta Y e Z; para alinhar
ao fluxo de 3 etapas, rode estes cards nesta ordem: …"_ — ou, se a doc já cobre as três etapas,
_"nada a migrar"_.

## Passo 5 — Oriente o usuário (primeiro uso)

Ao terminar, diga ao usuário, nas suas palavras:

1. A instalação está completa e verificada (mostre a lista do Passo 3). Se o **Passo 4b** detectou
   doc anterior ao fluxo de 3 etapas, apresente aqui o **plano de migração** (o que já existe, o que
   falta e a ordem dos cards a rodar) — sem executá-lo; quem dispara é o usuário.
2. O primeiro passo de uso é gerar o contexto do projeto: mensagem "analisa o projeto"
   (Amazon Q e Kiro — no Kiro a skill `analisador-de-projeto` ativa por descrição) ou
   `/analisador-de-projeto` (Copilot IDE). Sem isso, o pack bloqueia gerações de
   documentação de propósito. O contexto é gravado em TRÊS destinos (Q, Copilot e Kiro).
3. Para mudanças de código com controle de contexto: basta descrever o pedido como
   mensagem normal — o assistente deriva o slug e abre a task sozinho (protocolo de 2
   turnos: plano → aprovação → execução com ledger). `nova tarefa: <slug> — …` é override
   opcional para nomear na mão.
4. As mensagens prontas para todos os fluxos estão em `ia/COMO-USAR.html`, em ia/, no repo — abrir no navegador.

## Regras para você, assistente

- Não modifique nenhum arquivo do pack ao copiar — cópia fiel.
- Não rode `ia/tools/sync-copilot.sh` nem `ia/tools/sync-kiro.sh` no repo alvo: são ferramentas de manutenção do pack.
- Não commite nada sem o usuário pedir.
