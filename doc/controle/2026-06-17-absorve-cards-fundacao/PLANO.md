# PLANO — 2026-06-17-absorve-cards-fundacao

Um arquivo canonico: `COMO-USAR.html` (o `.md` e gerado dele). 4 edicoes cirurgicas + sync.

## Edicao 1 — remover a secao "Antes de tudo" (linhas ~103-134)
Deletar o bloco `<section class="trilha">` ... `</section>` cujo titulo e
"Antes de tudo: preparar o repositorio" (intro + os 2 cards). Confirmado por grep que NENHUMA
referencia a essa secao existe fora dela.

## Edicao 2 — mover "Mapear o dominio" para "Documentar o negocio"
Inserir o `<article class="msg-card">` do "Mapear o dominio" (verbatim, slug
/analisador-de-dominio) como PRIMEIRO card da secao "Documentar o negocio" (apos
`<div class="cards">`, antes do card "Grill do negocio"). Conteudo da mensagem identico —
so muda o lugar.

## Edicao 3 — intro da trilha "Documentar o negocio"
Atual: "O que o codigo nao conta: regras nao-escritas... sem jargao tecnico."
Acrescentar uma frase no fim: comecar pelo "Mapear o dominio", que gera o business-context
que todos os outros cards desta trilha consomem.

## Edicao 4 — nota de refresh no "Quando" da Etapa 1/3
Atual: "Repo sem doc — gera contexto + dominio + a arquitetura (espinha) num fluxo so."
Acrescentar: tambem serve de refresh do contexto tecnico — parar no gate apos a Fase A
(absorve o antigo "Preparar o repositorio").

## Sync + verificacao
- `bash tools/sync-como-usar.sh` e `--check`.
- Esperado: COMO-USAR.md regenerado, contagem 71 -> 70 cards (1 card removido; o outro so mudou
  de secao). `--check` exit 0.
- grep negativo: "Antes de tudo", "estes dois cards", `>Preparar o reposit` = 0 ocorrencias.
- grep positivo: "Mapear o dominio" aparece 1x, dentro da secao de negocio.

## Fora de escopo
- prompts/arquitetura/analisador-de-projeto.md e prompts/negocio/analisador-de-dominio.md
  (arquivos de prompt intactos — so o card visual muda/sai).
- Combos que citam esses prompts por caminho (continuam validos).
- Hero e demais trilhas (sem mencao a "Antes de tudo").
