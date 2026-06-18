# TASK — 2026-06-17-absorve-cards-fundacao

- **fase:** concluida
- **tipo:** normal
- **pedido:** os cards "Preparar o repositorio" e "Mapear o dominio" (secao "Antes de tudo")
  sao redundantes agora que a Etapa 1/3 (documentar-servico) ja roda os dois nas Fases A/B.
  Usuario quer absorve-los — confirmado no prompt: documentar-servico.md Fase A = analisador-de-projeto,
  Fase B = analisador-de-dominio.

## Decisao do usuario (grill, opcao "some 1, o outro so troca de lugar")
- "Preparar o repositorio" (analisador-de-projeto): so alimenta arquitetura => ABSORVIDO pela
  Etapa 1/3. Card removido.
- "Mapear o dominio" (analisador-de-dominio): e a FUNDACAO da trilha de negocio inteira
  (glossario/catalogo/fluxo consomem o business-context) => MOVIDO para o 1o card de
  "Documentar o negocio". Card preservado, so reposicionado — nenhuma capacidade perdida.
- Secao "Antes de tudo: preparar o repositorio" deixa de existir.

## Cuidados (decorrencia da mudanca)
- Refresh do contexto tecnico (caso de uso do card removido: "quando o codigo mudou muito")
  preservado via nota no "Quando" da Etapa 1/3 (parar no gate apos a Fase A).
- Intro da trilha "Documentar o negocio" ajustada p/ apontar "Mapear o dominio" como passo 0.
- PROMPTS (.md) NAO sao tocados: analisador-de-projeto.md e analisador-de-dominio.md seguem
  existindo no repo; combos os referenciam por caminho, nao pelo card — nada quebra.

## Criterios de aceite
- [x] Secao "Antes de tudo: preparar o repositorio" removida do COMO-USAR.html. (grep = 0)
- [x] Card "Preparar o repositorio" nao aparece mais como card. (<h3>Preparar = 0)
- [x] Card "Mapear o dominio" (slug /analisador-de-dominio) e o 1o card de "Documentar o negocio"
      (linha 684), conteudo da <pre class="msg"> identico ao original (movido verbatim).
- [x] "Quando" da Etapa 1/3 ganha a nota de refresh do contexto tecnico.
- [x] Intro de "Documentar o negocio" aponta "Mapear o dominio" como fundacao.
- [x] Nenhuma referencia orfa: "Antes de tudo"=0, "estes dois cards"=0, "<h3>Preparar"=0.
      Unica ocorrencia de "analisador-de-projeto" e a Fase A no corpo da Etapa 1/3 (legitima).
- [x] sync-como-usar.sh regenera; --check OK; cards = 70 (HTML e MD batem; era 71, -1).

## Checklist de execucao
- [x] COMO-USAR.html: remover a <section> "Antes de tudo" inteira
- [x] COMO-USAR.html: inserir card "Mapear o dominio" como 1o de "Documentar o negocio"
- [x] COMO-USAR.html: nota de refresh no "Quando" da Etapa 1/3
- [x] COMO-USAR.html: ajustar intro da trilha de negocio
- [x] sync-como-usar.sh + --check OK
- [x] verificacao: grep orfas=0, cards 70/70, card movido verbatim, Fase A legitima confirmada
