# Pack de documentacao arquitetural — instrucoes para o GitHub Copilot

> GERADO por `tools/sync-copilot.sh` a partir de `.amazonq/rules/` — NAO edite a mao.
> Este repositorio usa o pack `arquitetura` com Amazon Q **e** GitHub Copilot.

## Como este repo esta organizado para o Copilot

- As regras completas estao em `.github/instructions/*.instructions.md` (aplicadas
  automaticamente): `architecture-style` (trilha tecnica), `negocio-style` (negocio),
  `frontend-style` (HTML/CSS), `engenharia-style` (disciplinas de engenharia).
- A metodologia de cada tarefa mora em `prompts/<trilha>/<nome>.md`. As tabelas de
  gatilhos nas instructions mapeiam a intencao do usuario para o prompt certo. Quando
  um gatilho casar, LEIA o arquivo do prompt e siga TODO o processo descrito, fase por
  fase — nunca achate fases interativas em checklist ou despejo de perguntas.
- Atalhos: cada prompt existe como slash command (`.github/prompts/`, use `/<slug>` no
  chat das IDEs) e como Agent Skill (`.github/skills/`, Copilot CLI).

## Gate de contexto (resumo)

Antes de gerar documentacao, o contexto do projeto precisa existir em DOIS arquivos de
mesmo conteudo: `.github/instructions/project-context.instructions.md` (Copilot) e
`.amazonq/rules/project-context.md` (Amazon Q). Se nenhum existir, rode primeiro
`prompts/arquitetura/analisador-de-projeto.md` (`/analisador-de-projeto`). Se so um
existir, espelhe no outro. Doc de NEGOCIO exige tambem o par `business-context`
(criado por `prompts/negocio/analisador-de-dominio.md`).

## Regra inegociavel

Todo diagrama segue a convencao Mermaid da instruction `architecture-style` secao 1
(diagram-viewer + classDefs com cores fixas). E a unica regra rigida de visual.
