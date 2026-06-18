# PLANO — 2026-06-17-preparar-doc-existente

Um arquivo canonico: `INSTALAR.md` (sem mirror/sync). 2 edicoes.

## Edicao 1 — inserir "Passo 4b" entre o Passo 4 (linha ~133) e o Passo 5 (linha 135)
Novo passo, espelhando o estilo do Passo 4 (tabela de sinais). Esqueleto do conteudo:

> ## Passo 4b — Preparar a documentacao existente para o novo fluxo (diagnostico, nao-destrutivo)
>
> A re-instalacao PRESERVA a doc gerada do servico (project-context, business-context,
> docs/arquitetura/). Se ela foi gerada por uma versao anterior ao fluxo de 3 etapas, pode estar
> incompleta. Este passo e SO diagnostico: voce NAO edita nem gera nada — entrega ao usuario um
> plano do que falta e qual card rodar. Diferente do Passo 4, os scripts NAO fazem isto (exige
> ler a doc e julgar); e tarefa sua, agente.
>
> Primeiro, ha doc real a migrar? Se o project-context (3 destinos) ainda e o exemplo
> "Liquidacao Transacional", NAO ha doc gerada — siga para o Passo 5 (primeiro uso normal).
> So siga aqui se a doc descreve o servico REAL.
>
> | Sinal na doc existente | O que falta | Card para completar (COMO-USAR) |
> |---|---|---|
> | project-context real existe, mas faltam os `business-context.md` (`.amazonq/rules/`, `.github/instructions/`, `.kiro/steering/`) | fundacao de negocio | "Mapear o dominio" — trilha Documentar o negocio (`/analisador-de-dominio`) |
> | paginas em docs/arquitetura/ existem, mas sem runbook nem fluxos criticos | operacao + runtime | "Completar a documentacao (Etapa 2/3)" (`/completar-documentacao`) |
> | doc com `⚠ a confirmar` / numeros redondos nao resolvidos | auditoria de incertezas | "Grill intenso de arquitetura (Etapa 3/3)" (`/grill-arquitetura`, sessao nova) |
>
> Regras:
> - NAO rode os cards voce mesmo nem edite a doc — so monte o diagnostico.
> - NAO re-rode a Etapa 1 "do zero" sobre doc que ja existe (duplicaria/sobrescreveria). Quem ja
>   tem doc completa SO os blocos que faltam — e por isso que eles existem como cards isolados.
> - A geracao roda depois, disparada pelo usuario, sob o protocolo de controle (task de 2 turnos).
>
> Saida: no fechamento (Passo 5), apresente "sua doc tem X, falta Y e Z; pra alinhar ao fluxo de
> 3 etapas, rode [cards] nesta ordem" — ou "a doc ja cobre as 3 etapas, nada a migrar".

## Edicao 2 — amarrar no Passo 5
No Passo 5 (orientacao ao usuario), acrescentar um item: se o Passo 4b detectou doc anterior ao
fluxo de 3 etapas, apresente o plano de migracao (o que falta + ordem dos cards) junto da
orientacao de primeiro uso.

## Verificacao
- Titulos: existe "Passo 4b"; Passo 5 segue logo depois; nenhum numero de passo renumerado.
- Refs cruzadas intactas: "Passo 2", "Passo 3" continuam validas (grep).
- Caminhos dos 3 destinos do business-context conferem com as linhas 72-74 do INSTALAR.md.

## Fora de escopo
- COMO-USAR (so referenciado pelos nomes dos cards, nao editado).
- Scripts install.sh/ps1 (o 4b e diagnostico do agente, nao automatizavel por shell).
- Os prompts do fluxo de 3 etapas (intactos).
