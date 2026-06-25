# INSTALAR.md — guia de instalação (para o seu assistente de IA executar)

> **Você, assistente** (Amazon Q, GitHub Copilot, Junie, Claude ou outro agente com acesso a
> arquivos): este arquivo é um runbook para VOCÊ executar, não um texto para resumir ao
> usuário. Siga os passos na ordem. O objetivo é instalar o pack `arquitetura` no
> repositório do serviço do usuário.
>
> **Caminho rápido (instalação nova):** Passo 0 → Passo 1 → Passo 3 → Passo 5. Os Passos
> **2, 4 e 4b são condicionais** — cada um virou uma sub-página em `INSTALAR/` que você só
> abre **se o gatilho descrito bater**. Não leia o que não se aplica.

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

**`.gitignore` do produto:** o script também semeia (idempotente) um bloco marcado no
`.gitignore` do alvo — **ignora** as réplicas pesadas (`.github/skills/`, `.github/prompts/`,
`.kiro/skills/`, `ia/skills/`) e **mantém versionada** a config + o **contexto por-serviço**
(`project-context.md` / `business-context.md`, que devem ser versionados — é a análise revisada do
produto) + `doc/`. **Regra "clonou → instala 1×":** quem clona o repo deve rodar o instalador uma
vez para materializar as skills/prompts do seu assistente.

## Passo 2 — Fallback: cópia manual  ·  *só se você NÃO pode rodar shell*

Se você **pode** rodar o script (Passo 1), **ignore este passo** e vá para o Passo 3. Se
**não pode** executar shell, o passo a passo completo — tabela de cópia exata, hooks de
início de interação, o `.gitignore` na mão e a lista do que **nunca** copiar — está em
[`INSTALAR/manual.md`](INSTALAR/manual.md).

## Passo 3 — Verifique a instalação

Confira que TODOS estes paths existem no repo alvo (via shell ou listagem de arquivos):

- `.amazonq/rules/` com as 5 rules de estilo (mais os arquivos de contexto, se já gerados)
- `.amazonq/cli-agents/arquitetura.json` + `.amazonq/hooks/controle-hook.sh` + `.kiro/hooks/controle-prompt.kiro.hook` (hooks de início de interação do controle; **sem** git hook — o commit não é mais bloqueado)
- `.github/copilot-instructions.md` + `.github/instructions/` com 5 arquivos `*-style.instructions.md` (mais os de contexto, se os analisadores já rodaram neste repo)
- `.github/prompts/` com 32 arquivos `.prompt.md` e `.github/skills/` com 64 subpastas (32 wrappers + 32 importadas)
- `.kiro/steering/` com as 5 rules de estilo e `.kiro/skills/` com 64 subpastas
- `.junie/guidelines.md` (camada Junie — arquivo único que o Junie lê e injeta em toda task)
- `ia/prompts/` com as 4 trilhas (arquitetura 13, frontend 4, negocio 5, engenharia 10 — 32 arquivos `.md`)
- `ia/skills/` com 14 categorias e 32 subpastas com `SKILL.md` (biblioteca importada)
- `ia/design-system/` com 2 `.css`; `ia/templates/` com os 2 `.js`; `ia/COMO-USAR.html` e `ia/COMO-USAR.md` em ia/, no repo
- `ia/templates/` com as páginas de exemplo (`01-visao-geral.html`, `index.html`, etc.) — exceto se a instalação usou `--no-examples`

Se algo faltar, volte ao passo que o copia. Não declare a instalação concluída sem
esta verificação (evidência antes de afirmação).

## Passo 4 — Re-instalação / atualização  ·  *migração de versão antiga só se aplicável*

Rodar o instalador de novo é **seguro**: ele preserva os arquivos de contexto por-serviço
(nos três lados) e os foundation files do Kiro; o resto é sobrescrito com a versão nova.

**Se o alvo já tem uma instalação ANTIGA** (pre-commit que travava o `git commit`, `controle/`
na raiz, ou layout pré-`ia/`+`doc/`), a tabela completa de **sinais → correção** está em
[`INSTALAR/migracao.md`](INSTALAR/migracao.md). Os scripts `install.sh`/`install.ps1` já
aplicam todas essas correções sozinhos — a sub-página é para quando você migra na mão.

## Passo 4b — Doc existente para a trilha v2 (diagnóstico)  ·  *só se já há doc real*

Se o serviço **já tem documentação real** (o `project-context` descreve o serviço real, não
o exemplo fictício "Liquidação Transacional"), rode o **diagnóstico não-destrutivo** de
[`INSTALAR/doc-v2.md`](INSTALAR/doc-v2.md) — ele monta um plano do que falta para alinhar à
trilha v2 (7 etapas / 8 sessões), que você apresenta no Passo 5. **Você não edita nem gera
nada** aqui. Se a doc ainda é o exemplo fictício, não há nada a migrar — siga para o Passo 5.

## Passo 5 — Oriente o usuário (primeiro uso)

Ao terminar, diga ao usuário, nas suas palavras:

1. A instalação está completa e verificada (mostre a lista do Passo 3). Se o **Passo 4b** detectou
   doc anterior à trilha v2 (7 etapas / 8 sessões), apresente aqui o **plano de migração** (o que já
   existe, o que falta e a ordem das ações a rodar) — sem executá-lo; quem dispara é o usuário.
2. O primeiro passo de uso é gerar o contexto do projeto: mensagem "analisa o projeto"
   (Amazon Q, Kiro e Junie — no Kiro a skill `analisador-de-projeto` ativa por descrição;
   no Junie, o gatilho no `.junie/guidelines.md` aponta o prompt) ou `/analisador-de-projeto`
   (Copilot IDE). Sem isso, o pack bloqueia gerações de documentação de propósito. O contexto
   é gravado em TRÊS destinos (Q, Copilot e Kiro); o Junie lê o do `.amazonq/rules/`.
3. Para mudanças de código com controle de contexto: basta descrever o pedido como
   mensagem normal — o assistente deriva o slug e abre a task sozinho (protocolo de 2
   turnos: plano → aprovação → execução com ledger). `nova tarefa: <slug> — …` é override
   opcional para nomear na mão.
4. As mensagens prontas para todos os fluxos estão em `ia/COMO-USAR.html`, em ia/, no repo — abrir no navegador.

## Regras para você, assistente

- Não modifique nenhum arquivo do pack ao copiar — cópia fiel.
- Não rode `ia/tools/sync-copilot.sh` nem `ia/tools/sync-kiro.sh` no repo alvo: são ferramentas de manutenção do pack.
- Não commite nada sem o usuário pedir.
