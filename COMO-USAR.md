# Como usar o pack no Amazon Q

O Amazon Q lê `.amazonq/rules/` **sozinho** neste repo. Você não configura nada nele — só **fala em linguagem natural** com o `@workspace` aberto no serviço, e o Q identifica a intenção e carrega o prompt certo.

> Funciona igual no Q do IDE (VS Code / Visual Studio / JetBrains) e no `q chat` (CLI). No CLI, garanta que a pasta do repo está no contexto.

## Começando — mensagens prontas (copiar e colar)

Com `@workspace` aberto no repo do serviço, cole uma destas e troque os `[CAMPOS]`:

- **Arquitetura técnica (do zero):**
  > Quero fazer a criação de um desenho de arquitetura técnico (fluxo técnico). Analise a aplicação: **[NOME_DA_APLICAÇÃO]**. Você deve seguir todo o processo descrito em `prompts/arquitetura/analisador-de-projeto.md`: detecte a stack e os padrões, me mostre o que encontrou e pergunte o que o código não revela. Ao final, gere o `project-context.md`.

- **Visão de negócio (do zero):**
  > Quero fazer o mapeamento da arquitetura de negócio (fluxo de negócio). Analise a aplicação: **[NOME_DA_APLICAÇÃO]**. Você deve seguir todo o processo descrito em `prompts/negocio/analisador-de-dominio.md`: detecte as regras candidatas no código (validações, enums, autorização), os atores e os eventos, me grile por fases pra confirmar o que o código não revela, e gere o `business-context.md`.

- **Interrogatório (grill) de uma área:**
  > Quero aprofundar as regras de negócio de **[PROCESSO_OU_ÁREA]** na aplicação **[NOME_DA_APLICAÇÃO]**. Você deve seguir todo o processo descrito em `prompts/negocio/grill-negocio.md`: me interrogue por fases, uma pergunta por vez, propondo sua resposta recomendada, mostrando o ledger a cada rodada, e atualize o `business-context.md` conforme fechamos.

- **Fluxo de negócio (visual feliz/triste):**
  > Quero o desenho do fluxo de negócio de **[PROCESSO]** na aplicação **[NOME_DA_APLICAÇÃO]**. Você deve seguir todo o processo descrito em `prompts/negocio/mapeador-de-fluxo-de-negocio.md`: caminho feliz e caminhos tristes, com o diagrama no padrão da casa.

- **Não sei por onde começar:**
  > ajuda de negócio

> 💡 As mensagens nomeiam o prompt (`prompts/.../arquivo.md`) e mandam **"seguir todo o processo descrito"** de propósito: é isso que faz o Q rodar o fluxo inteiro de forma consistente, em vez de responder por cima.

## Guia por partes do fluxo

### Parte 1 — Preparar o terreno (uma vez por repositório)
**Objetivo:** criar as fontes de verdade que todo o resto consome.

1. **Técnico** (se ainda não rodou no repo):
   > Quero fazer a criação de um desenho de arquitetura técnico (fluxo técnico). Analise a aplicação: **[NOME_DA_APLICAÇÃO]**. Você deve seguir todo o processo descrito em `prompts/arquitetura/analisador-de-projeto.md`, me mostrar o que detectou e perguntar o que o código não revela. Ao final, gere o `project-context.md`.
2. **Negócio:**
   > Agora quero o mapeamento da arquitetura de negócio (fluxo de negócio). Analise a aplicação: **[NOME_DA_APLICAÇÃO]**. Você deve seguir todo o processo descrito em `prompts/negocio/analisador-de-dominio.md`: detecte regras candidatas, atores e eventos, me grile pra confirmar, e gere o `business-context.md`.

**O que esperar:** o Q lê o código, mostra os candidatos e faz perguntas **uma de cada vez**. No fim, dois arquivos em `.amazonq/rules/`.
**Antes de avançar:** revise os dois arquivos — eles mandam em tudo daqui pra frente. Corrija o que estiver errado.

### Parte 2 — Aprofundar o negócio (o grill)
**Objetivo:** tirar do código o que ele não conta — regra não-escrita, dono da decisão, exceções.

> Quero aprofundar as regras de negócio de **[PROCESSO_OU_ÁREA]** na aplicação **[NOME_DA_APLICAÇÃO]**. Você deve seguir todo o processo descrito em `prompts/negocio/grill-negocio.md`: me interrogue por fases, uma pergunta por vez, propondo sua resposta, mostrando o ledger `✓/▸/○`, e atualize o `business-context.md` a cada decisão.

**O que esperar:** interrogatório por fases (reconhecimento → espinha → regras → caminhos tristes → cristalização), sempre **uma pergunta por vez**, com o placar `✓ resolvido · ▸ atual · ○ aberto` no topo. Respondeu "não sei"? Ele marca `[a confirmar]` e segue.
**Quando parar:** quando o placar zerar os ramos abertos (`○`).

### Parte 3 — Gerar os documentos
**Objetivo:** transformar o `business-context.md` em páginas navegáveis. Ordem sugerida:

1. **Fluxo visual:**
   > Quero o desenho do fluxo de negócio de **[PROCESSO]** na aplicação **[NOME_DA_APLICAÇÃO]**. Você deve seguir `prompts/negocio/mapeador-de-fluxo-de-negocio.md`: caminho feliz + caminhos tristes, com diagrama.
2. **Catálogo de regras:**
   > Quero o catálogo de regras de negócio da aplicação **[NOME_DA_APLICAÇÃO]**, agrupado por capacidade. Você deve seguir `prompts/negocio/catalogo-de-regras.md`.
3. **Glossário:**
   > Quero a página de glossário do domínio da aplicação **[NOME_DA_APLICAÇÃO]**. Você deve seguir `prompts/negocio/glossario-de-negocio.md`.

**O que esperar:** páginas HTML (em `templates/`), abríveis direto no navegador (`file://`). O fluxo **recusa** se você não der pelo menos um caminho triste.

### Parte 4 — Manter vivo
- **Código mudou muito?** → *Atualize a visão de negócio da aplicação **[NOME_DA_APLICAÇÃO]** seguindo `prompts/negocio/analisador-de-dominio.md`.*
- **Revisão periódica / dúvida nova?** → *Quero estressar as regras de **[ÁREA]** — siga `prompts/negocio/grill-negocio.md`.*
- **Auditar uma doc existente?** → *Revise a doc de negócio de **[X]** procurando furos e incoerências com o código.*

## Trilha de NEGÓCIO

| Pra... | Diga algo como |
|---|---|
| Mapear o domínio (1ª vez) | `analisa o domínio` · `mapeia o negócio` |
| **Fluxo visual feliz/triste** | `documenta o fluxo de negócio do estorno` · `caminho feliz e triste de <X>` |
| Catálogo de regras | `catálogo de regras` · `lista as regras de negócio` |
| Glossário do domínio | `glossário de negócio` · `termos do domínio` |
| **Grill (interrogatório por fases)** | `grilla o negócio` · `que regras não estão escritas?` · `estressa o domínio` |
| Ajuda | `ajuda de negócio` · `o que dá pra documentar de negócio?` |

## Trilha TÉCNICA

| Pra... | Diga algo como |
|---|---|
| Visão geral / arquitetura | `documenta esse serviço` · `visão geral` |
| ADR (decisão) | `cria uma ADR sobre <X>` |
| Runbook operacional | `gera o runbook` |
| Fluxo transacional | `documenta o fluxo de autorização` |
| Revisar doc (grill técnico) | `revisa essa doc procurando furos` |

## Dicas

- **Ambíguo?** "documenta o fluxo X" → o Q pergunta se é **técnico** (runtime, chamadas) ou **de negócio** (regras, atores, caminho feliz/triste). Responda e ele segue.
- **Ver o HTML gerado:** abra o arquivo no navegador (`file://`). Os scripts são classic — funciona sem servidor. `Cmd/Ctrl+P` → "Salvar como PDF" (marque "Gráficos de fundo").
- **Faltou regra ou dono?** Rode `grilla o negócio` — ele interroga por fases e atualiza o `business-context.md` na hora.
- **A doc deve refletir o código real**, não o exemplo "Liquidação Transacional". Se algo do exemplo vazar, diga "use o domínio real deste serviço".
