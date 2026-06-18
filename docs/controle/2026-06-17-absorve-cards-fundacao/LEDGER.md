# LEDGER — 2026-06-17-absorve-cards-fundacao

## Decisoes
- Confirmado no codigo (nao de memoria): documentar-servico.md (Etapa 1/3) orquestra Fase A =
  analisador-de-projeto e Fase B = analisador-de-dominio. A linha 18 do prompt diz que "substitui
  a necessidade de rodar analisador-de-projeto ... na mao". Logo a secao "Antes de tudo" era
  redundante com a Etapa 1/3.
- Assimetria que guiou a solucao: "Preparar o repositorio" so alimenta arquitetura -> absorvido.
  "Mapear o dominio" e a fundacao da trilha de NEGOCIO inteira (glossario/catalogo/fluxo consomem
  o business-context) -> nao podia sumir; foi MOVIDO para o 1o card de "Documentar o negocio".
  Decisao do usuario no grill: "some 1, o outro so troca de lugar".
- Capacidade de refresh do contexto tecnico (caso de uso do card removido) preservada como nota
  no "Quando" da Etapa 1/3: parar no gate apos a Fase A quando so o codigo mudou.
- Card movido foi colado VERBATIM (mesma <pre class="msg"> e slug /analisador-de-dominio) — zero
  perda de conteudo, so reposicionamento.
- Prompts .md (analisador-de-projeto / analisador-de-dominio) intactos. Combos os citam por
  caminho, nao pelo card -> nada quebrou.

## Evidencias (2026-06-17)
- sync-como-usar.sh: "Gerado: COMO-USAR.md (70 cards)". --check: "OK ... em sincronia" (exit 0).
- Contagem: HTML <article class="msg-card"> = 70; MD ^###  = 70 (batem). Era 71, -1 (card removido).
- Referencias orfas: "Antes de tudo"=0, "estes dois cards"=0, "<h3>Preparar o reposit"=0.
- "analisador-de-projeto" sobra 1x: linha 115, "Fase A contexto (analisador-de-projeto...)" no
  corpo da mensagem da Etapa 1/3 — mencao legitima (descreve o que o fluxo roda), nao card.
- "Mapear o dominio": 1 <h3>, na secao "Documentar o negocio" (linha 684, apos eyebrow linha 676);
  a secao "Arquitetura" (linha 104) vem direto apos "Como invocar", sem a antiga "Antes de tudo".

## Arquivos tocados
- Canonico: COMO-USAR.html (remove secao "Antes de tudo"; insere card em "Documentar o negocio";
  ajusta intro de negocio; nota de refresh na Etapa 1/3).
- Gerado: COMO-USAR.md regenerado pelo sync (70 cards).
- Controle: docs/controle/2026-06-17-absorve-cards-fundacao/ (TASK, PLANO, LEDGER).

## Fora de escopo (confirmado)
- prompts/arquitetura/analisador-de-projeto.md e prompts/negocio/analisador-de-dominio.md (intactos).
- Combos que citam os prompts por caminho. Hero e demais trilhas (nao mencionavam "Antes de tudo").
