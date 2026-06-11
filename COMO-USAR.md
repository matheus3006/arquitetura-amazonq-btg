# Como usar — pack arquitetura (Amazon Q + Copilot + Kiro)

> GERADO de `COMO-USAR.html` por `tools/sync-como-usar.sh` — NAO edite a mao.
> Prefere botao de copiar? Abra `COMO-USAR.html` (mesma raiz) no navegador.

## Como invocar, por ferramenta

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE / q chat) | Cole a mensagem do card |
| Copilot IDE (VS Code / Visual Studio / JetBrains) | Cole a mensagem OU use o atalho /slug indicado no card |
| Copilot CLI | Cole a mensagem (os prompts também existem como skills) |
| Kiro (IDE / CLI) | Cole a mensagem — a Agent Skill de mesmo slug ativa por descrição (.kiro/skills/); o steering carrega as regras automaticamente |

Primeira vez no repositório? Rode o card nº 1 antes de qualquer outro — todo o resto depende do contexto que ele gera. Para docs de negócio, rode também o nº 8.

## Trilha técnica

### 1 · Preparar o repositório

**Quando:** Primeira invocação em repo novo, ou quando o código mudou muito.

```text
Objetivo: gerar a fonte de verdade técnica deste repositório (project-context) — é ela que destrava todas as outras gerações e impede que a doc herde conteúdo do exemplo fictício.

Analise a aplicação [NOME_DA_APLICACAO] seguindo todo o processo de prompts/arquitetura/analisador-de-projeto.md: detecte a stack e os padrões do código, me mostre o que encontrou, pergunte o que o código não revela (uma pergunta por vez), inclua a lista negativa (padrões que NÃO usamos) e grave o contexto nos TRÊS destinos (Amazon Q, Copilot e Kiro).

Pronto quando: os três arquivos de contexto existem com o mesmo conteúdo e eu revisei o resumo.
```

_Copilot IDE: /analisador-de-projeto_

### 2 · Visão geral de arquitetura

**Quando:** Documentar o serviço do zero ou atualizar a visão geral.

```text
Objetivo: a página de visão geral de arquitetura da aplicação [NOME_DA_APLICACAO] — propósito, contexto, integrações, fluxo principal, stack e quality goals — fiel ao código real, não aspiracional.

Siga todo o processo de prompts/arquitetura/arquiteto-de-sistema.md: faça as 5 perguntas-âncora e depois me grile ramo a ramo no estilo grill-with-docs — uma pergunta por vez, ledger visível, sua resposta recomendada, documentando inline conforme fecharmos — até o ledger zerar. As âncoras são o piso, não o teto.

Pronto quando: HTML no padrão da casa com os diagramas na convenção rígida, e nenhum ⚠ aberto que eu não tenha aceitado explicitamente.
```

_Copilot IDE: /arquiteto-de-sistema_

### 3 · Registrar uma decisão (ADR)

**Quando:** Decisão tomada (ou madura o suficiente) que precisa virar registro.

```text
Objetivo: registrar a decisão [DECISAO] como ADR auditável — por que escolhemos, o que perdemos com isso, e como saberemos que deu certo.

Siga todo o processo de prompts/arquitetura/gerador-adr.md: formato MADR, mínimo 3 decision drivers e 2 opções consideradas, trade-offs explícitos (toda decisão tem ônus — liste o que perdemos) e métrica de validação. Não invente contexto que você não tem — pergunte o que faltar num bloco único.

Pronto quando: ADR numerada salva no padrão da casa, linkando as docs e ADRs relacionadas.
```

_Copilot IDE: /gerador-adr_

### 4 · Runbook operacional

**Quando:** Documentação de operação: failure modes, on-call, SLO.

```text
Objetivo: o runbook operacional de [SERVICO_OU_FLUXO] — o documento que alguém de on-call usa às 3h da manhã sem conhecer o serviço.

Siga todo o processo de prompts/arquitetura/gerador-runbook.md: cada failure mode com sintoma observável, query de log/métrica para confirmar, ação imediata e mitigação permanente. Não invente SLO, threshold nem nome de dashboard — me pergunte num bloco único o que o código e a config não revelam.

Pronto quando: todo failure mode tem os 4 campos preenchidos e nenhum valor foi inventado.
```

_Copilot IDE: /gerador-runbook_

### 5 · Fluxo transacional (técnico)

**Quando:** Sequência de chamadas, payloads, estados — visão de runtime.

```text
Objetivo: a documentação de runtime do fluxo [FLUXO] na aplicação [NOME_DA_APLICACAO] — quem chama quem, em que ordem, com que payload, e o que acontece quando falha.

Siga todo o processo de prompts/arquitetura/documentador-fluxo.md: sequence diagram com autonumber (e BEGIN/COMMIT onde houver transação), payloads relevantes, e os estados de erro, retry e timeout. Confirme cada chamada no código antes de desenhar — nada de fluxo aspiracional.

Pronto quando: caminho feliz + caminhos de falha desenhados, batendo com o código real.
```

_Copilot IDE: /documentador-fluxo_

### 6 · Revisar documentação (grill técnico)

**Quando:** Auditar uma página/ADR existente procurando furos.

```text
Objetivo: auditar [PAGINA_OU_ADR] como revisor cético — achar furos, garantias não implementadas e decisões disfarçadas de premissa ANTES que alguém confie nessa doc.

Siga todo o processo de prompts/arquitetura/grill-doc.md: aplique as 7 lentes na ordem (terminologia, decisões disfarçadas de premissa, garantias vs implementação, janelas sem número...), e para cada achado traga a evidência — trecho citado + o que o código realmente mostra — com severidade e correção proposta.

Pronto quando: relatório estruturado com achados acionáveis, ou a declaração explícita de que a doc sobreviveu às 7 lentes.
```

_Copilot IDE: /grill-doc_

### 7 · Brainstorm (antes de decidir)

**Quando:** Ainda não decidiu? Sempre antes de uma ADR.

```text
Objetivo: explorar [IDEIA_OU_PROBLEMA] antes de decidir — sair com opções reais comparadas e uma recomendação, não com a minha primeira ideia validada por educação.

Siga todo o processo de prompts/arquitetura/brainstorm-arquitetural.md: reformule o problema antes de discutir qualquer solução, uma pergunta por vez, mínimo 4 opções de naturezas diferentes com trade-offs de cada uma, e feche com aprovação por seções.

Pronto quando: problema acordado + opções comparadas + recomendação pronta pra virar ADR (card 3).
```

_Copilot IDE: /brainstorm-arquitetural_

## Trilha de negócio

### 8 · Mapear o domínio

**Quando:** Primeira doc de negócio do repo, ou refresh após mudanças grandes.

```text
Objetivo: gerar a fonte de verdade de NEGÓCIO deste repositório (business-context) — as regras, atores, eventos e termos que o código sozinho não conta, e que todas as docs de negócio consomem.

Analise a aplicação [NOME_DA_APLICACAO] seguindo todo o processo de prompts/negocio/analisador-de-dominio.md: detecte as regras candidatas no código (validações, enums, autorização, limites em config), os atores e os eventos, me grile por fases pra confirmar o que o código não revela (uma pergunta por vez), e grave o contexto de negócio nos TRÊS destinos (Amazon Q, Copilot e Kiro).

Pronto quando: os três arquivos de contexto de negócio existem, idênticos, e eu revisei o resumo.
```

_Copilot IDE: /analisador-de-dominio_

### 9 · Grill do negócio (interrogatório)

**Quando:** Tirar do código o que ele não conta: regra não-escrita, dono, exceções.

```text
Objetivo: extrair de [PROCESSO_OU_AREA] na aplicação [NOME_DA_APLICACAO] as regras que NÃO estão escritas — quem decide, exceções, invariantes — e cristalizá-las no contexto de negócio.

Siga todo o processo de prompts/negocio/grill-negocio.md: me interrogue por fases, uma pergunta por vez com sua resposta recomendada, mostrando o ledger ✓/▸/○ a cada rodada, explorando o código antes de perguntar, e atualize o contexto de negócio (nos TRÊS destinos) conforme fechamos cada ramo.

Pronto quando: ledger zerado (todo ramo ✓ ou [a confirmar com quem]) e a tabela de regras resolvidas pronta pro catálogo (card 11).
```

_Copilot IDE: /grill-negocio_

### 10 · Fluxo de negócio (feliz/triste)

**Quando:** Desenho visual do processo com desfechos positivos e de exceção.

```text
Objetivo: o desenho do processo [PROCESSO] da aplicação [NOME_DA_APLICACAO] que uma pessoa de NEGÓCIO entende — quem faz o quê, onde se decide, como termina bem e como termina mal.

Siga todo o processo de prompts/negocio/mapeador-de-fluxo-de-negocio.md: caminho feliz e pelo menos um caminho triste, diagrama no padrão da casa (classes papel/atividade/decisao/desfecho), linguagem do glossário do domínio — zero jargão técnico (nada de HTTP, fila, retry).

Pronto quando: página com o diagrama validado por mim e todos os desfechos nomeados em termos de negócio.
```

_Copilot IDE: /mapeador-de-fluxo-de-negocio_

### 11 · Catálogo de regras

**Quando:** Inventário das regras de negócio com origem, dono e consequência.

```text
Objetivo: o inventário auditável das regras de negócio da aplicação [NOME_DA_APLICACAO] — pra responder "por que o sistema recusou isso?" sem precisar ler código.

Siga todo o processo de prompts/negocio/catalogo-de-regras.md: regras agrupadas por capacidade, toda regra com origem no código (arquivo:símbolo) ou marcada como regra de processo, dono e consequência de negócio. Regra sem dono identificável → marque [a confirmar com quem] em vez de inventar.

Pronto quando: nenhuma regra sem origem rastreável e o catálogo batendo com o contexto de negócio.
```

_Copilot IDE: /catalogo-de-regras_

### 12 · Glossário do domínio

**Quando:** Linguagem ubíqua: os termos do negócio, sem detalhe de implementação.

```text
Objetivo: a página de linguagem ubíqua da aplicação [NOME_DA_APLICACAO] — negócio e dev chamando as coisas pelo mesmo nome, com os sinônimos proibidos explícitos.

Siga todo o processo de prompts/negocio/glossario-de-negocio.md: termos vindos do contexto de negócio, definição operacional curta (o que o termo É, não como funciona por dentro), sinônimos a evitar listados por termo, zero detalhe de implementação.

Pronto quando: página gerada com os termos batendo 1:1 com o contexto de negócio — divergência encontrada é apontada, não silenciada.
```

_Copilot IDE: /glossario-de-negocio_

## Trilha frontend

### 13 · Melhorar o visual (controlado)

**Quando:** Decisões visuais propostas uma a uma, com seu OK antes de aplicar.

```text
Objetivo: melhorar o visual de [PAGINA] sem surpresas — cada mudança existe só depois do meu OK.

Siga todo o processo de prompts/frontend/designer-ux-controlado.md: proponha UMA decisão visual por vez (o que muda, por que, e o efeito esperado), espere minha aprovação antes de aplicar, e use sempre os tokens do design system — nada hardcoded.

Pronto quando: todas as decisões aprovadas estão aplicadas e NADA além delas mudou.
```

_Copilot IDE: /designer-ux-controlado_

### 14 · Escolher direção visual

**Quando:** Antes de criar algo novo: estilo, paleta, referências.

```text
Objetivo: escolher a direção visual de [PROJETO_OU_PAGINA] ANTES de produzir qualquer tela — decisão de estilo tomada uma vez, não rediscutida a cada página.

Siga todo o processo de prompts/frontend/designer-ui-pro-max.md: apresente opções do catálogo (estilo + paleta + tipografia) adequadas ao contexto e ao público, com prós, contras e onde cada uma costuma falhar, e me deixe escolher ou combinar.

Pronto quando: direção escolhida e registrada — ela passa a guiar os cards 13, 15 e 16.
```

_Copilot IDE: /designer-ui-pro-max_

### 15 · Design system (estender/auditar)

**Quando:** Padronizar componentes, auditar tokens, evitar drift visual.

```text
Objetivo: [ESTENDER_OU_AUDITAR] o design system deste repositório sem criar drift — tudo via tokens, nada hardcoded, nada quebrando quem já consome.

Siga todo o processo de prompts/frontend/design-system-arquitetura.md: audite tokens e componentes existentes, aponte cada inconsistência com evidência (arquivo e linha do hex/px mágico), e proponha a mudança compatível com o que existe ANTES de aplicar.

Pronto quando: mudanças aplicadas sem quebrar consumidores + relatório do que foi normalizado e do que ficou como dívida.
```

_Copilot IDE: /design-system-arquitetura_

### 16 · Polir (acabamento)

**Quando:** A página funciona mas falta o acabamento fino.

```text
Objetivo: dar o acabamento fino em [PAGINA] — ela já funciona; falta a sensação de produto profissional (microinterações, ritmo, estados).

Siga todo o processo de prompts/frontend/polidor-ui.md: aplique o checklist de polimento na ordem (microespaçamento, easing, estados, press feedback), sempre com tokens do design system — nada hardcoded — e justifique cada ajuste em 1 linha (antes → depois).

Pronto quando: checklist percorrido inteiro, com a lista dos ajustes feitos e dos itens que não se aplicavam.
```

_Copilot IDE: /polidor-ui_

## Trilha engenharia

### 17 · Investigar bug (causa raiz)

**Quando:** Comportamento inesperado — antes de qualquer tentativa de correção.

```text
[SINTOMA — cole o erro/stack trace real]

Objetivo: achar a CAUSA RAIZ disso — não silenciar o sintoma com o primeiro palpite.

Siga todo o processo de prompts/engenharia/depurador-sistematico.md: as 4 fases na ordem, causa raiz demonstrada com evidência (arquivo:linha) ANTES de qualquer proposta de correção, fix mínimo, e a verificação rodada ao final com o output mostrado.

Pronto quando: causa demonstrada + fix mínimo aplicado + teste/comando de verificação passando, com o output real na resposta.
```

_Copilot IDE: /depurador-sistematico_

### 18 · Plano de implementação

**Quando:** Decisão aprovada que vira código — antes de codar.

```text
Objetivo: transformar a decisão [DECISAO_OU_ADR] num plano que um dev que NÃO conhece este código executa sem me perguntar nada.

Siga todo o processo de prompts/engenharia/planejador-de-implementacao.md: mapeie os arquivos afetados, quebre em etapas pequenas e independentemente verificáveis — cada uma com arquivos exatos, mudança concreta, comando de verificação e critério de pronto — ordenadas por dependência. Proibido "TBD" e "similar à etapa N".

Pronto quando: plano salvo em docs/planos/ + resumo (nº de etapas, primeira etapa, maior risco). Próximo passo natural: grill do plano (card 21).
```

_Copilot IDE: /planejador-de-implementacao_

### 19 · Nova tarefa (controle de contexto)

**Quando:** Qualquer mudança no repositório — abre o protocolo de 2 turnos (plano → aprovação → execução).

```text
nova tarefa: [SLUG] — [DESCRICAO_BREVE]

Objetivo: abrir esta task sob o protocolo de controle — escopo e plano aprovados ANTES de qualquer código, evidências registradas no fechamento, e o mínimo de turnos da minha cota.

Siga o protocolo de prompts/engenharia/controle-de-tarefa.md: neste turno crie SOMENTE controle/<task-id>/ (TASK.md com escopo+ACs e o PLANO — me pergunte o formato .md ou .html junto com as demais dúvidas, num bloco único) e termine pedindo aprovação. Execução apenas depois do meu "aprovado" — e aí tudo num turno: checklist, código, LEDGER com evidências e fechamento.

Pronto quando (turno 1): TASK.md + PLANO criados, aprovação pedida, e NADA fora de controle/ foi tocado.
```

_Copilot IDE: /controle-de-tarefa_

### 20 · Spec antes do plano

**Quando:** Pedido vago, sem comportamento nem critérios de aceite definidos.

```text
Objetivo: transformar [PEDIDO_VAGO — ex: melhorar o fluxo de estorno] numa spec com critérios de aceite verificáveis — decidir O QUE o software deve fazer antes de qualquer plano de COMO.

Siga todo o processo de prompts/engenharia/especificador.md: explore o código e os contextos primeiro, me pergunte o que faltar num bloco único, confirme comigo as costuras de teste (prefira as que já existem, na camada mais alta), e nada inventado — o que ninguém respondeu vira [a confirmar].

Pronto quando: docs/specs/<data>-<slug>.md salvo, todo AC verificável, fora-de-escopo preenchido. Próximo passo natural: plano (card 18).
```

_Copilot IDE: /especificador_

### 21 · Grill do plano (pre-mortem)

**Quando:** Plano pronto, ANTES de aprovar — ache os furos enquanto é barato.

```text
Objetivo: achar os furos do plano [PATH_DO_PLANO] enquanto é barato — antes da aprovação, não em produção.

Siga todo o processo de prompts/engenharia/grill-plano.md: me interrogue ramo a ramo — uma pergunta por vez, ledger ✓/▸/○ visível, sua resposta recomendada em cada uma — explorando o código antes de perguntar, corrigindo o plano inline conforme fecharmos, e incluindo o pre-mortem ("executamos e deu errado: o que quebrou?").

Pronto quando: ledger zerado e plano corrigido, com a lista do que mudou, dos riscos aceitos e dos [a confirmar] pendentes.
```

_Copilot IDE: /grill-plano_

### 22 · Executar o plano aprovado

**Quando:** Plano aprovado vira código — etapa por etapa, com evidência.

```text
Objetivo: transformar o plano aprovado [PATH_DO_PLANO] em código — sem improviso, sem etapa não verificada, sem "melhorias" que ninguém pediu.

Siga todo o processo de prompts/engenharia/executor-de-plano.md: revise o plano criticamente primeiro (preocupações num bloco único, antes de tocar em arquivo), execute etapa por etapa com verificação e output real por etapa, registre desvios mecânicos e siga, e PARE se algo divergir de decisão do plano — sem adivinhar.

Pronto quando: relatório de fechamento em 3 blocos — o que passou (com evidência), o que falhou (com output, sem maquiar) e o que foi adaptado (com motivo).
```

_Copilot IDE: /executor-de-plano_

### 23 · TDD (test-first)

**Quando:** Qualquer etapa que produz código de produção — feature, bugfix, refactor.

```text
Objetivo: implementar [ETAPA_OU_COMPORTAMENTO] com prova de que funciona — nenhum código de produção sem teste falhando antes (lei de ferro).

Siga todo o processo de prompts/engenharia/tdd-disciplinado.md: RED (me mostre o teste falhando pelo motivo certo), GREEN (código mínimo pra passar, suíte inteira verde), REFACTOR (sem comportamento novo). Escreveu código antes do teste? Delete e recomece pelo teste.

Pronto quando: checklist do prompt completo e a suíte verde, com o output de cada fase mostrado na resposta.
```

_Copilot IDE: /tdd-disciplinado_

## Biblioteca de skills importadas

Cópias verbatim das melhores Agent Skills disponíveis (conteúdo em inglês — peça resposta em PT-BR). No Kiro e no Copilot CLI elas ativam sozinhas quando seu pedido casa com a descrição; no Amazon Q e Copilot IDE, cole a mensagem do card. Catálogo completo: skills/README.md.

### 24 · Arquitetura — mentalidade de arquiteto

**Quando:** Decisão de sistema, decomposição de problema, navegação de restrições.

```text
Objetivo: pensar como arquiteto em [DECISAO_OU_SISTEMA] — modelo de domínio, restrições e decomposição antes de tecnologia.

Siga TODO o processo descrito em skills/arquitetura/human-architect-mindset/SKILL.md (conteúdo em inglês; responda em PT-BR), aplicando-o ao meu contexto real.

Pronto quando: análise estruturada com restrições explícitas e a decomposição recomendada.
```

_Skill: human-architect-mindset_

### 25 · Arquitetura — conselheiro técnico (CTO)

**Quando:** Dívida técnica, build-vs-buy, estratégia de stack, escala do time.

```text
Objetivo: orientação técnico-estratégica sobre [TEMA — ex: dívida técnica do serviço X].

Siga TODO o processo descrito em skills/arquitetura/cto-advisor/SKILL.md (em inglês; responda em PT-BR), com trade-offs e recomendação fundamentada — não lista neutra de opções.

Pronto quando: recomendação clara + riscos + o que monitorar depois da decisão.
```

_Skill: cto-advisor_

### 26 · Arquitetura — brainstorm pré-construção

**Quando:** Antes de QUALQUER trabalho criativo: feature, componente, mudança de comportamento.

```text
Objetivo: explorar intenção, requisitos e design de [FEATURE_OU_MUDANCA] antes de construir qualquer coisa.

Siga TODO o processo descrito em skills/arquitetura/brainstorming/SKILL.md (em inglês; responda em PT-BR): perguntas uma a uma até o design estar acordado.

Pronto quando: entendimento compartilhado registrado — só então partimos pra spec/plano.
```

_Skill: brainstorming_

### 27 · PM — PM sênior

**Quando:** Portfólio, stakeholders, riscos e decisões de projeto enterprise.

```text
Objetivo: atuar como PM sênior em [PROJETO_OU_DECISAO] — priorização, stakeholders, risco.

Siga TODO o processo descrito em skills/pm/senior-pm/SKILL.md (em inglês; responda em PT-BR), aplicado ao meu contexto.

Pronto quando: análise + plano de ação com donos e próximos passos concretos.
```

_Skill: senior-pm_

### 28 · PM — toolkit de produto

**Quando:** RICE, PRD, análise de entrevistas, frameworks de discovery.

```text
Objetivo: aplicar o framework certo de PM a [PROBLEMA — ex: priorizar o backlog do Q3].

Siga TODO o processo descrito em skills/pm/product-manager-toolkit/SKILL.md (em inglês; responda em PT-BR), escolhendo o framework adequado e justificando a escolha.

Pronto quando: artefato gerado (priorização/PRD/análise) com o racional explícito.
```

_Skill: product-manager-toolkit_

### 29 · PM — discovery de produto

**Quando:** Validar oportunidade ANTES de comprometer roadmap.

```text
Objetivo: validar a oportunidade [OPORTUNIDADE_OU_HIPOTESE] — mapear premissas e testar problem-solution fit antes de construir.

Siga TODO o processo descrito em skills/pm/product-discovery/SKILL.md (em inglês; responda em PT-BR).

Pronto quando: premissas mapeadas por risco + plano de validação com método e critério de kill.
```

_Skill: product-discovery_

### 30 · Business — estrategista de produto

**Quando:** OKRs, planejamento trimestral, posicionamento, apostas estratégicas.

```text
Objetivo: trabalhar a estratégia de [PRODUTO_OU_AREA] — cascata de OKRs, posicionamento ou plano trimestral.

Siga TODO o processo descrito em skills/business/product-strategist/SKILL.md (em inglês; responda em PT-BR).

Pronto quando: estratégia articulada com apostas explícitas e métricas de sucesso.
```

_Skill: product-strategist_

### 31 · Business — teardown de concorrente

**Quando:** Análise competitiva estruturada: pricing, reviews, vagas, sinais públicos.

```text
Objetivo: o teardown estruturado do concorrente [CONCORRENTE] — forças, fraquezas, pricing e posicionamento, a partir de sinais públicos.

Siga TODO o processo descrito em skills/business/competitive-teardown/SKILL.md (em inglês; responda em PT-BR).

Pronto quando: matriz comparativa + SWOT + ações recomendadas pro nosso contexto.
```

_Skill: competitive-teardown_

### 32 · Business — stress-test de premissas

**Quando:** Antes de apostar em algo: quais premissas, se falsas, derrubam tudo?

```text
Objetivo: estressar as premissas de negócio por trás de [PLANO_OU_APOSTA] antes de comprometer recursos.

Siga TODO o processo descrito em skills/business/stress-test/SKILL.md (em inglês; responda em PT-BR): identifique as premissas, ataque cada uma, e diga qual derruba o plano se for falsa.

Pronto quando: premissas ranqueadas por fragilidade × impacto, com teste barato pra cada uma crítica.
```

_Skill: stress-test_

### 33 · Planejamento — executar plano com checkpoints

**Quando:** Plano escrito pronto pra virar realidade em outra sessão.

```text
Objetivo: executar o plano [PATH_DO_PLANO] com disciplina — revisão crítica, execução tarefa a tarefa, parada em bloqueio.

Siga TODO o processo descrito em skills/planejamento/executing-plans/SKILL.md (em inglês; responda em PT-BR).

Pronto quando: todas as tarefas executadas e verificadas, ou bloqueio reportado com contexto — nunca adivinhado.
```

_Skill: executing-plans_

### 34 · Planejamento — scrum master

**Quando:** Sprint planning, velocity, retro, impedimentos — com dados.

```text
Objetivo: [CERIMONIA_OU_PROBLEMA — ex: planejar a sprint / analisar a queda de velocity] com abordagem data-driven.

Siga TODO o processo descrito em skills/planejamento/scrum-master/SKILL.md (em inglês; responda em PT-BR).

Pronto quando: análise/plano da cerimônia com números e ações de coaching concretas.
```

_Skill: scrum-master_

### 35 · Planejamento — plano vira issues

**Quando:** Quebrar plano/spec/PRD em issues independentes e pegáveis.

```text
Objetivo: quebrar [PLANO_OU_SPEC] em issues independentes, em fatias verticais (tracer bullet) — cada uma entregável sozinha.

Siga TODO o processo descrito em skills/planejamento/to-issues/SKILL.md (em inglês; responda em PT-BR), adaptando o destino pro nosso tracker.

Pronto quando: lista de issues com escopo, dependências e ordem de ataque.
```

_Skill: to-issues_

### 36 · Backend — TDD integral

**Quando:** Feature ou bugfix de backend — a versão completa da disciplina test-first.

```text
Objetivo: implementar [FEATURE_OU_FIX] sob TDD integral — nenhum código de produção sem teste falhando antes.

Siga TODO o processo descrito em skills/backend/test-driven-development/SKILL.md (em inglês; responda em PT-BR), mostrando RED, GREEN e REFACTOR com output real.

Pronto quando: checklist de verificação da skill completo e suíte verde.
```

_Skill: test-driven-development_

### 37 · Backend — debugging sistemático

**Quando:** Bug, teste falhando, comportamento inesperado — antes de propor fix.

```text
[SINTOMA — cole o erro real]

Objetivo: causa raiz com evidência, não palpite.

Siga TODO o processo descrito em skills/backend/systematic-debugging/SKILL.md (em inglês; responda em PT-BR): as 4 fases na ordem, sem pular pra solução.

Pronto quando: causa demonstrada + fix mínimo + verificação passando com output.
```

_Skill: systematic-debugging_

### 38 · Backend — verificação antes de concluir

**Quando:** Antes de declarar qualquer coisa "pronta" ou abrir PR.

```text
Objetivo: verificar de verdade que [TRABALHO] está completo antes de qualquer afirmação de sucesso.

Siga TODO o processo descrito em skills/backend/verification-before-completion/SKILL.md (em inglês; responda em PT-BR): rode os comandos de verificação e mostre o output ANTES de afirmar.

Pronto quando: evidência real na resposta — ou a lista honesta do que ainda falha.
```

_Skill: verification-before-completion_

### 39 · Frontend — polish à Emil Kowalski

**Quando:** Componente funciona mas falta o toque: animação, timing, detalhes invisíveis.

```text
Objetivo: aplicar a filosofia de polish de UI (Emil Kowalski) em [COMPONENTE_OU_PAGINA] — animação com propósito, detalhes invisíveis que fazem software parecer bom.

Siga TODO o processo descrito em skills/frontend/emil-design-eng/SKILL.md (em inglês; responda em PT-BR).

Pronto quando: ajustes aplicados com o porquê de cada um (e o que NÃO animar).
```

_Skill: emil-design-eng_

### 40 · Frontend — tipografia profissional

**Quando:** Qualquer UI com texto visível: aspas, traços, hierarquia, espaçamento.

```text
Objetivo: tipografia correta em [PAGINA_OU_COMPONENTE] — as regras atemporais que costumam ser ignoradas (aspas curvas, en/em-dash, hierarquia, line-height).

Siga TODO o processo descrito em skills/frontend/ui-typography/SKILL.md (em inglês; responda em PT-BR), em modo auditoria: aponte violações e corrija.

Pronto quando: violações listadas e corrigidas, sem mudar o design além da tipografia.
```

_Skill: ui-typography_

### 41 · Frontend — interface de alto impacto

**Quando:** Criar página/componente novo que NÃO pareça feito por IA.

```text
Objetivo: construir [PAGINA_OU_COMPONENTE] com qualidade visual de produção e identidade própria — anti-estética-genérica.

Siga TODO o processo descrito em skills/frontend/bencium-impact-designer/SKILL.md (em inglês; responda em PT-BR), respeitando o design system do projeto quando existir.

Pronto quando: implementação entregue com as decisões visuais justificadas.
```

_Skill: bencium-impact-designer_

### 42 · UI/UX — inteligência de design

**Quando:** Escolher estilo, paleta, fonte e padrões com base em catálogo grande.

```text
Objetivo: decidir a direção de design de [PROJETO] usando o catálogo da skill (50+ estilos, 161 paletas, 57 pares de fontes, 99 guidelines de UX).

Siga TODO o processo descrito em skills/ui-ux/ui-ux-pro-max/SKILL.md (em inglês; responda em PT-BR), consultando os dados da pasta da skill.

Pronto quando: direção proposta com paleta/tipografia/estilo nomeados e guidelines aplicáveis listadas.
```

_Skill: ui-ux-pro-max_

### 43 · UI/UX — auditoria de design

**Quando:** App existente que precisa parecer mais premium/consistente.

```text
Objetivo: auditoria visual sistemática de [APP_OU_PAGINA] — hierarquia, espaçamento, consistência — com plano de refinamento em fases.

Siga TODO o processo descrito em skills/ui-ux/design-audit/SKILL.md (em inglês; responda em PT-BR). Só visual: não toque em lógica nem features.

Pronto quando: relatório de achados + plano faseado pronto pra implementar.
```

_Skill: design-audit_

### 44 · UI/UX — designer controlado

**Quando:** Decisões de UX uma a uma, com aprovação antes de aplicar.

```text
Objetivo: evoluir o UX de [PAGINA] sem decisão unilateral — acessibilidade e identidade únicas, mas cada escolha passa por mim.

Siga TODO o processo descrito em skills/ui-ux/bencium-controlled-ux-designer/SKILL.md (em inglês; responda em PT-BR): proponha, espere o OK, aplique.

Pronto quando: decisões aprovadas aplicadas — e nada além delas.
```

_Skill: bencium-controlled-ux-designer_

### 45 · Code review

**Quando:** Antes de merge, ao fechar feature grande, ou pra revisar trabalho pronto.

```text
Objetivo: code review rigoroso de [BRANCH_DIFF_OU_ARQUIVOS] contra os requisitos — não um "LGTM" educado.

Siga TODO o processo descrito em skills/code-review/requesting-code-review/SKILL.md (em inglês; responda em PT-BR), atuando você mesmo como o revisor cético do template.

Pronto quando: achados classificados por severidade, cada um com arquivo:linha e correção proposta.
```

_Skill: requesting-code-review_

### 46 · Review de arquitetura do código

**Quando:** O código funciona, mas a estrutura precisa de revisão: acoplamento, costuras, módulos.

```text
Objetivo: revisar a ARQUITETURA do código em [AREA_OU_MODULO] — oportunidades de aprofundamento guiadas pelo domínio (CONTEXT/contextos) e pelas ADRs existentes.

Siga TODO o processo descrito em skills/arquitetura-review/improve-codebase-architecture/SKILL.md (em inglês; responda em PT-BR).

Pronto quando: oportunidades ranqueadas com custo/benefício e a primeira mudança segura proposta.
```

_Skill: improve-codebase-architecture_

### 47 · Julgar um plano (pre-mortem)

**Quando:** Plano pronto demais pra ser verdade? Ataque-o antes de executar.

```text
Objetivo: julgar o plano [PLANO] com pre-mortem — assumir que falhou e descobrir por quê, antes de gastar um real.

Siga TODO o processo descrito em skills/julgar-planos/challenge/SKILL.md (em inglês; responda em PT-BR).

Pronto quando: modos de falha ranqueados por probabilidade × impacto, com mitigação ou veto pra cada um.
```

_Skill: challenge_

### 48 · Criar um plano executável

**Quando:** Spec/decisão pronta que precisa virar plano que outro contexto executa.

```text
Objetivo: transformar [SPEC_OU_DECISAO] num plano executável por quem NÃO conhece este código — a versão integral da disciplina de planos.

Siga TODO o processo descrito em skills/criar-planos/writing-plans/SKILL.md (em inglês; responda em PT-BR).

Pronto quando: plano salvo com tarefas bite-sized, cada uma com verificação própria — pronto pro card 33 (executar) ou 47 (julgar antes).
```

_Skill: writing-plans_
