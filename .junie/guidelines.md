# Guidelines do projeto — pack `arquitetura` (para o Junie)

> GERADO por `ia/tools/sync-junie.sh` (ferramenta de manutencao do pack de origem — nao
> existe nos repos instalados) a partir de `.amazonq/rules/` + `ia/tools/manifest.tsv` —
> NAO edite a mao. O Junie injeta este arquivo como contexto em toda task.

Voce e o Junie num repo que usa o pack `arquitetura` (documentacao arquitetural +
disciplinas de engenharia), o mesmo pack usado por Amazon Q, Copilot e Kiro.

## Estrutura do repositorio (use o caminho exato; nao varra pastas)

- `.amazonq/rules/*.md` — os 5 padroes SEMPRE-ON do pack (fonte canonica; todos os agentes
  derivam dela). Trate-os como sempre validos; leia o arquivo relevante quando precisar do detalhe.
- `ia/prompts/<trilha>/<nome>.md` — a metodologia de cada tarefa (arquitetura, frontend,
  negocio, engenharia). E o que voce ABRE quando um gatilho casa (tabela abaixo).
- `doc/arquitetura/` — a documentacao HTML gerada do servico (saida real).
- `doc/controle/` — as tasks do protocolo de controle (TASK.md / PLANO.md / LEDGER.md).
- `doc/adr/`, `doc/specs/`, `doc/planos/` — decisoes (ADR), specs e planos.
- `ia/skills/`, `ia/design-system/`, `ia/templates/` — biblioteca de skills, CSS e templates de FORMA.

## Padroes sempre-on (leia sob demanda em `.amazonq/rules/`)

- `architecture-style.md` — trilha tecnica + a UNICA regra rigida de visual (convencao Mermaid:
  diagram-viewer + classDefs com cores fixas). Releia antes de gerar/editar diagrama.
- `frontend-style.md` — HTML/CSS e o design-system (vocabulario fechado de classes, cores via `var()`).
- `negocio-style.md` — trilha de negocio (regras, atores, eventos, linguagem ubiqua).
- `engenharia-style.md` — disciplinas de engenharia (debug sistematico, plano, TDD, revisao).
- `controle-style.md` — protocolo de controle de tarefas (resumo na secao final).

## Gatilhos -> metodologia (quando a intencao casar, LEIA o arquivo e siga TODO o processo, fase por fase)

| Quando o pedido for | Abra e siga |
|---|---|
| Etapa 1/7 (sessao 1a): analisa o repositorio e gera project-context.md em 3 destinos de rules (Amazon Q/Copilot/Kiro). Pre-requisito de toda a trilha; cada prompt em sessao propria | `ia/prompts/arquitetura/analisador-de-projeto.md` |
| Etapa 2/7: arquitetura/espinha (5 perguntas-ancora + grill + paginas-nucleo). Cada pagina criada em doc/arquitetura/ + entry no NAV de sidebar.js no mesmo passo | `ia/prompts/arquitetura/arquiteto-de-sistema.md` |
| Complementar (fora da trilha 1-7): gera ADRs em formato MADR com trade-offs explicitos e metrica de validacao (destino: doc/adr/) | `ia/prompts/arquitetura/gerador-adr.md` |
| Etapa 4/7: doc/arquitetura/runbook.html (4 campos obrigatorios por failure mode, nada inventado). Apenda entry no NAV de sidebar.js | `ia/prompts/arquitetura/gerador-runbook.md` |
| Etapa 3/7: pagina(s) de fluxo critico em doc/arquitetura/ (sequenceDiagram com autonumber). Apenda entry no NAV de sidebar.js | `ia/prompts/arquitetura/documentador-fluxo.md` |
| Complementar (fora da trilha 1-7): revisor cetico de UMA pagina por 7 lentes (diferente da Etapa 5/7 grill-arquitetura, que cobre TODA a doc). Procura furos, inconsistencias e garantias nao implementadas | `ia/prompts/arquitetura/grill-doc.md` |
| Complementar (fora da trilha 1-7): parceiro de pensamento pre-ADR. Reformula o problema, gera opcoes e converge com trade-offs | `ia/prompts/arquitetura/brainstorm-arquitetural.md` |
| Decisoes visuais propostas antes de aplicadas, uma por vez | `ia/prompts/frontend/designer-ux-controlado.md` |
| Catalogo de estilos, paletas e padroes visuais para escolher direcao | `ia/prompts/frontend/designer-ui-pro-max.md` |
| Extensao e auditoria do design system do pack | `ia/prompts/frontend/design-system-arquitetura.md` |
| Polimento de UI: microinteracoes, easing e acabamento (estilo Emil Kowalski) | `ia/prompts/frontend/polidor-ui.md` |
| Etapa 1/7 (sessao 1b, reusado pela trilha arquitetura): analisa o dominio e gera business-context.md em 3 destinos de rules (regras, atores, eventos). Apenda Q&A no QA.md no mesmo turno | `ia/prompts/negocio/analisador-de-dominio.md` |
| Mapeia fluxo de negocio com caminho feliz e caminhos tristes em diagrama | `ia/prompts/negocio/mapeador-de-fluxo-de-negocio.md` |
| Cataloga regras de negocio com origem, dono e consequencia | `ia/prompts/negocio/catalogo-de-regras.md` |
| Gera o glossario do dominio (linguagem ubiqua) | `ia/prompts/negocio/glossario-de-negocio.md` |
| Interrogatorio por fases com ledger para extrair regras nao escritas do dominio | `ia/prompts/negocio/grill-negocio.md` |
| Depuracao sistematica em 4 fases: causa raiz com evidencia antes de qualquer correcao | `ia/prompts/engenharia/depurador-sistematico.md` |
| Transforma spec/decisao em plano de etapas pequenas e independentemente verificaveis | `ia/prompts/engenharia/planejador-de-implementacao.md` |
| Protocolo de controle para QUALQUER task que crie ou modifique um artefato (codigo, doc, spec, design, diagrama, plano) — nao so codigo. 2 turnos: escopo+plano aprovados viram checklist (status vivo, marcado a cada passo), execucao com ledger de evidencias. Tasks de doc/grill geram tambem QA.md (status vivo, mesmo turno) | `ia/prompts/engenharia/controle-de-tarefa.md` |
| Interrogatorio socratico do plano de implementacao: anda a arvore de decisoes e acha furos, premissas e riscos antes da aprovacao | `ia/prompts/engenharia/grill-plano.md` |
| Executa o plano aprovado etapa por etapa com verificacao por etapa, regra de desvio e parada em bloqueio | `ia/prompts/engenharia/executor-de-plano.md` |
| Disciplina test-first por etapa: nenhum codigo de producao sem teste falhando antes (red-green-refactor) | `ia/prompts/engenharia/tdd-disciplinado.md` |
| Transforma pedido vago em spec minima com criterios de aceite verificaveis, antes do plano | `ia/prompts/engenharia/especificador.md` |
| Refatoracao sob rede de testes: caracteriza o comportamento, anda em passos pequenos (Mikado) e verifica a cada passo — comportamento identico no fim | `ia/prompts/engenharia/refatorador-incremental.md` |
| Desenha a estrategia de testes alem do TDD unitario: niveis (unit/integracao/contrato/e2e), regressao dos bugs ja vistos e prioridade por risco x custo | `ia/prompts/engenharia/estrategista-de-testes.md` |
| Conduz a revisao de codigo por dimensoes (correcao, seguranca, simplicidade/reuso, testes) com achados por severidade e evidencia arquivo:linha | `ia/prompts/engenharia/revisor-de-codigo.md` |
| Indice da trilha de 7 etapas (8 sessoes — Etapa 1 = 2 sessoes). Aponta as etapas 1-7 em sequencia; cada prompt em sessao propria; NAO orquestra (deprecado o atalho anterior) | `ia/prompts/arquitetura/documentar-servico.md` |
| Etapa 5/7: grill intenso codigo-primeiro sobre a doc gerada — cada incerteza resolvida pelo codigo (com nivel de certeza) ou perguntada ao humano; respostas apendadas no QA.md no mesmo turno | `ia/prompts/arquitetura/grill-arquitetura.md` |
| Complementar (fora da trilha 1-7, gatilho 'mudanca de codigo'): atualiza a doc a partir do diff da branch. Analisa o codigo, grilla o porque (grill-me + human-architect-mindset) e registra ADR quando a mudanca nao partiu de uma ADR existente (destino: doc/arquitetura/, ADRs em doc/adr/) | `ia/prompts/arquitetura/sincronizar-doc-codigo.md` |
| Etapa 6/7: validador visual/template (so reporta; checklist canonico + ia/tools/validar-doc.sh --front opcional). Verifica navegabilidade, esqueleto, vocabulario fechado de classes, cores via var(--color-*), forbidden-terms | `ia/prompts/arquitetura/validador-visual.md` |
| Etapa 7/7: validador sintaxe + Mermaid (so reporta; checklist canonico + ia/tools/validar-doc.sh --mermaid opcional). Pareamento data-id, tipo valido, 4 classDef, autonumber sempre em sequence | `ia/prompts/arquitetura/validador-sintaxe-mermaid.md` |
| Complementar (fora da trilha 1-7): conforma doc ja existente em doc/arquitetura/ as regras v2. Diagnostica, ramifica (front->plano+aplica; logico->grill+QA.md), 1 task de controle por execucao | `ia/prompts/arquitetura/atualizador-arquitetura.md` |

Regras de execucao dos prompts:
- NAO achate fases interativas em checklist nem em despejo de perguntas — quando o prompt
  pedir uma pergunta por vez, faca UMA pergunta e espere a resposta.
- Respeite os gates: nao avance de fase sem cumprir o criterio de saida da anterior.
- Use apenas comandos reais do projeto; nao invente scripts de build/teste.

## Shell (Windows) — leia antes de rodar comandos

O Junie roda mal com terminal no Windows (spawna o proprio shell). Para reduzir erro e
desperdicio de token:

- **Plugin do IDE:** deixe o shell padrao em **PowerShell 7+ (`pwsh.exe`)** —
  Settings -> Tools -> Terminal -> Shell path. NAO use Git Bash como padrao do IDE: o Junie
  exige PowerShell e reverte o terminal (limitacao conhecida da JetBrains). O `pwsh` 7 tem
  `&&` e `||`, entao comandos encadeados estilo Unix funcionam.
- **Evite `cmd.exe`** — trava o Junie ao executar comandos.
- **CLI / quem usa Git Bash:** garanta um `.bashrc`/`.bash_profile` limpo para uso
  nao-interativo — `[ -z "$PS1" ] && return` no topo e, no terminal da JetBrains,
  `unset PROMPT_COMMAND` (sem `ls` colorido). Sequencias de escape do prompt poluem a
  saida capturada e fazem `ls`/`find` voltarem VAZIOS.

## Protocolo de controle (resumo — detalhe em `.amazonq/rules/controle-style.md`)

Todo pedido que cria ou altera um artefato (codigo, doc, spec, diagrama, plano) exige uma
task ativa em `doc/controle/<AAAA-MM-DD-slug>/` ANTES de editar: TASK.md (escopo + ACs) +
PLANO.md; depois a execucao marca o checklist e registra evidencias no LEDGER.md. Derive o
slug do proprio pedido — nao peca o nome ao usuario. Pergunta de leitura pura nao abre task.
