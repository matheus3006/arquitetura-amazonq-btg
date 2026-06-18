# TASK — 2026-06-17-preparar-doc-existente

- **fase:** concluida
- **tipo:** normal
- **pedido:** quem ja gerou doc com versao anterior ao fluxo de 3 etapas atualiza o pack pedindo
  ao agente pra seguir INSTALAR.md. Hoje o INSTALAR.md migra a INSTALACAO (Passo 4) mas nao
  PREPARA a doc gerada existente. Adicionar um passo de diagnostico (nao-destrutivo) que detecta
  a doc anterior e entrega um plano de migracao.

## Distincao que guia a solucao
- INSTALACAO do pack (prompts/skills/hooks/templates): Passo 4 ja migra via "sinais -> correcao".
- DOC GERADA do servico (project-context, business-context, docs/arquitetura/): o pack PRESERVA
  e nunca sobrescreve => por isso nunca e "preparada". E o gap.

## Decisao do usuario (grill)
- Profundidade: DIAGNOSTICAR o gap (plano). O agente detecta e entrega "tem X, falta Y, rode o
  card Z" — NAO toca na doc. A geracao roda depois, disparada pelo usuario, sob o protocolo de
  controle. (Rejeitado: "so avisar" = pouco acionavel; "completar automatico" = mexe na doc sem
  controle de tarefa, contra o protocolo.)

## Deteccao (sinais -> o que falta -> card que completa)
- project-context preenchido (servico REAL, sem "Liquidacao Transacional") mas SEM business-context
  nos 3 destinos -> falta a fundacao de negocio -> card "Mapear o dominio" (/analisador-de-dominio).
- paginas de arquitetura existem mas sem runbook nem fluxos criticos -> falta operacao+runtime ->
  card "Completar a documentacao (Etapa 2/3)" (/completar-documentacao).
- doc com "⚠ a confirmar"/numeros redondos nao resolvidos -> falta auditoria -> card
  "Grill intenso de arquitetura (Etapa 3/3)" (/grill-arquitetura, sessao nova).

## Criterios de aceite
- [x] INSTALAR.md ganha "Passo 4b — Prepare a documentacao existente para o novo fluxo
      (diagnostico, nao-destrutivo)", entre o Passo 4 e o Passo 5 (linha 135).
- [x] Explicito: SO diagnostico (NAO edita/gera nada); NAO re-roda a Etapa 1 do zero; migracao
      roda depois, pelo usuario, sob controle. (3 travas presentes no grep)
- [x] Tabela sinais -> falta -> card (3 linhas), com os caminhos dos 3 destinos do business-context.
- [x] Gatilho "doc real vs ainda-exemplo": "Liquidacao Transacional" => segue pro Passo 5. (1x)
- [x] Diz que, diferente do Passo 4, os scripts NAO fazem isto (exige julgamento do agente).
- [x] Passo 5 (item 1) referencia o 4b (apresentar o plano de migracao no fechamento). (linha 173)
- [x] INSTALAR.md canonico (sem mirror) — nenhum sync; COMO-USAR so citado pelos nomes dos cards.

## Checklist de execucao
- [x] INSTALAR.md: inserir Passo 4b (texto + tabela sinais->card + regras nao-destrutivas)
- [x] INSTALAR.md: amarrar no Passo 5 (item 1 aponta o diagnostico do 4b)
- [x] verificacao: passos 0..4b..5 sem renumeracao, refs Passo 2/3 intactas, caminhos conferem (72-74)
