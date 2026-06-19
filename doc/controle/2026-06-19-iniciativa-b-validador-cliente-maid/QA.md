# QA — 2026-06-19-iniciativa-b-validador-cliente-maid

## Perguntas & Respostas
- [2026-06-19] P: Dado que as etapas 6/7 já chamam validar-doc (só faltava o instalador levar o
  arquivo), o que "prompts rodam validar-doc no done da geração" deve significar?
  R: verbatim: "Só destravar 6/7"
- [2026-06-19] P: Nível de guarda verificável em volta do shipping do validador?
  R: verbatim: "Guarda funcional"
- [2026-06-19] P: Onde mora a lógica de extração + parser do gate Mermaid?
  R: verbatim: "Qual seria a melhor forma de fazermos e por que ?"
  (delegou → recomendei e segui opção 1: script versionado `ia/tools/check-mermaid.sh`, pack-only)
- [2026-06-19] P: Aprovação do desenho consolidado da iniciativa B?
  R: verbatim: "aprovado"
- [2026-06-19] P: [B2] Parser do gate — manter `maid` (falso-positivo vs renderer) ou `mermaid@10`?
  R: verbatim: "mas do que adiantaria se ele quebrasse quando o usuario que nao tem acesso ao
  CI tiver problema com o mermaid ?" (reframe → gate de CI não ajuda o cliente)
- [2026-06-19] P: Dado que o cliente já vê erro no browser + validar-doc estrutural (B1), e o
  gate só protegeria os exemplos do pack — manter, virar guarda-do-exemplo, ou dropar B2?
  R: verbatim: "Dropar B2"
