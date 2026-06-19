# QA — 2026-06-19-pipeline-arquitetura-v2

> Registro vivo do input do usuário no brainstorming do redesign. (Demonstra a própria feature
> "QA-ledger" que este design cria: par pergunta→resposta+data, apendado na hora.)

## Perguntas & Respostas

- [2026-06-19] P (seed, pedido inicial): o que mudar no pipeline de arquitetura?
  R: doc não seguiu o template; quer mais rigidez e clareza do padrão. Quebrar os 3 prompts iniciais
  em mais granular + validação visual + validação de texto/Mermaid; ao iniciar doc, abrir task de
  controle com ledger registrando o input; melhorar o ia/COMO-USAR.html.

- [2026-06-19] P: o split é 3→5 ou 3→6? Orquestradores aposentados ou viram atalhos?
  R: São **7 etapas** contando os 2 validadores (validador de arquivos/Mermaid/sintaxe + validação do
  projeto final com foco front-end). TODOS no começo da trilha, com texto explícito "rode as 7 na
  sequência". Regra nova: **cada prompt roda em sessão própria**. + criar um **atualizador** que aplica
  as novas regras a doc já existente.
  verbatim: "cada prompt deve rodar em uma sessao propria"; "DEVE HAVER UM TEXTO EXPLICITO DIZENDO QUE
  SE DEVE RODAR TODOS OS 7 SEGUINDO A SEQUENCIA"; "CRIE MAIS UM CHAMADO ATUALIZADOR".

- [2026-06-19] P: como os validadores enforçam? (script vs checklist; portabilidade Q/Copilot/Kiro)
  R: **Híbrido** — checklist obrigatório com evidência (portável) + ia/tools/validar-doc.sh opcional.

- [2026-06-19] P: onde/como registrar as perguntas+respostas?
  R: **Arquivo próprio QA.md** por task (status vivo, todas as perguntas, normalizado + verbatim quando importa).

- [2026-06-19] P: qual a fronteira do imutável no template? (vocabulário fechado de classes?)
  R: Pode haver **mais seções** que hoje (quebrar para não gerar HTML extenso é bom); MAS elas DEVEM
  ficar na sidebar e ser navegáveis, DEVEM seguir o estilo visual e DEVEM obedecer as regras de UI/UX
  do template. Cada arquitetura é única.
  verbatim: "elas DEVEM ficar na sidebar e ser navegavel, DEVE seguir o estilo visual, DEVE OBECEDER AS
  REGRAS DE UI E UX ja existentes no template".

- [2026-06-19] P: unificar o destino de gravação?
  R: **doc/arquitetura/ (páginas) + doc/adr/ (ADRs).**

- [2026-06-19] P: o que o atualizador faz ao achar desvio?
  R: **Diagnostica**; se for drift de frontend (UI/UX) já faz um plano de ajuste; se for algo técnico de
  arquitetura, gera um grill que segue a regra de salvar no QA.md.
  verbatim: "se for drift de frontend ( visao - UI e UX ) ele ja faz um plano de ajuste, se for algo
  tecnico de arquitetura ele gera um grill no qual deve seguir a regra de salvar no QA.md".

- [2026-06-19] P: 3 detalhes finais — (1) Etapa 1 = 2 sessões reusando os analisadores? (2) repropósito de
  documentar-servico como índice + aposentar completar-documentacao? (3) slugs validador-visual /
  validador-sintaxe-mermaid / atualizador-arquitetura?
  R: (1) recomendado (2 sessões reusando os analisadores); (2) recomendado (repropósito + aposentar); (3) ok.

- [2026-06-19] P: granularidade do atualizador — 1 task por execução (cobrindo toda doc/arquitetura/) ou 1 task por página com drift?
  R: **somente uma task** (1 task por execução).
  verbatim: "deva ser somente uma task".
