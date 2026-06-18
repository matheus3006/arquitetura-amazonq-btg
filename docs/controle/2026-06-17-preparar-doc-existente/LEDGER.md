# LEDGER — 2026-06-17-preparar-doc-existente

## Decisoes
- A chave foi separar duas "atualizacoes": (1) INSTALACAO do pack, ja migrada pelo Passo 4
  (sinais->correcao) e pelos scripts; (2) DOC GERADA do servico, que o pack PRESERVA e nunca
  sobrescreve — e por isso nunca era preparada. O 4b cobre so o (2).
- Profundidade escolhida pelo usuario no grill: DIAGNOSTICAR o gap (nao-destrutivo). Rejeitados
  "so avisar" (pouco acionavel) e "completar automatico" (mexe na doc sem o controle de 2 turnos).
- Migracao incremental, NAO re-geracao do zero: quem ja tem doc roda so os blocos que faltam. Isso
  so e possivel porque os blocos atomicos existem como cards isolados — conecta direto com a task
  anterior (absorve-cards-fundacao), que preservou o "Mapear o dominio" justamente como bloco. A
  peca nº1 que falta numa doc antiga e o business-context, preenchido so por esse card.
- Sinal primario de deteccao = business-context ausente (conceito que nem existia antes do fluxo de
  3 etapas; detectavel por arquivo nos 3 destinos). Secundarios (runbook/fluxos ausentes; ⚠ nao
  resolvidos) sao qualitativos, julgados pelo agente.
- Gatilho de "ha doc real?": se project-context ainda e o exemplo "Liquidacao Transacional", nao ha
  doc gerada -> Passo 5 normal (primeiro uso), nao migracao.
- O 4b e tarefa do AGENTE, nao dos scripts install.sh/ps1 (exige ler a doc e julgar) — dito explicito.

## Evidencias (2026-06-17)
- Estrutura de passos: 0,1,2,3,4,4b,5 — nenhuma renumeracao (grep '^## Passo').
- Refs cruzadas intactas: "pule para o Passo 3", "regra do Passo 2", "tabela do Passo 2",
  "rode o Passo 3", "Passo 1 ou 2", "lista do Passo 3" (todas continuam validas).
- Tabela do 4b: 3 cards (Mapear o dominio / Completar 2-3 / Grill 3-3); "Mapear o dominio" 2x
  (tabela + trava sobre blocos atomicos) => grep contou 4, esperado.
- Travas: "NAO edita nem gera" 1x; "re-rode a Etapa 1" 1x; "Liquidacao Transacional" 1x.
- Caminhos do business-context no 4b (linha 151) batem com as linhas 72-74 do INSTALAR.md.
- Amarracao: Passo 5 item 1 (linha 173) referencia o Passo 4b.

## Arquivos tocados
- Canonico: INSTALAR.md (insere Passo 4b; acrescenta a referencia no item 1 do Passo 5).
- Controle: docs/controle/2026-06-17-preparar-doc-existente/ (TASK, PLANO, LEDGER).

## Fora de escopo (confirmado)
- COMO-USAR (so citado pelos nomes dos cards; nao editado; sem sync).
- Scripts install.sh/install.ps1 (4b e diagnostico do agente, nao automatizavel por shell).
- Prompts do fluxo de 3 etapas (intactos).

## Pendencia
- INSTALAR.md e canonico e nao e copiado pro repo alvo (e o guia que o agente segue) — confirmado
  que nao ha mirror nem gerador (grep em tools/). Nenhuma propagacao necessaria.
