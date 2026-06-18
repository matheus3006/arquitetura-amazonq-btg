# TASK — 2026-06-17-pipeline-arquitetura

- **fase:** concluida
- **tipo:** normal
- **pedido:** pipeline de 3 etapas obrigatorias pra documentar arquitetura do zero
  (desenho aprovado): Etapa 1 funde analisador-de-projeto + analisador-de-dominio +
  arquiteto-de-sistema; Etapa 2 completa (fluxo + runbook); Etapa 3 grill intenso
  codigo-primeiro com niveis de certeza. Base preservada; stack de skills nas 3.

## Criterios de aceite
- [x] 3 prompts novos em prompts/arquitetura/: documentar-servico, completar-documentacao,
      grill-arquitetura — estilo do pack (STATUS, Quando usar, fases+gate, stack de skills, refs).
- [x] Etapa 1 orquestra (referencia, nao duplica) os 3 base; termina apontando Etapa 2.
      Etapa 2 orquestra fluxo+runbook; termina apontando Etapa 3 (outra sessao).
      Etapa 3: loop codigo-primeiro (re-analisa -> achou=corrige+nivel de certeza /
      nao achou=pergunta humano), atualiza doc inline.
- [x] architecture-style § 2 roteia as 3 etapas (+ nota do fluxo canonico); manifest 29 linhas.
- [x] COMO-USAR: 3 cards novos na trilha Arquitetura (71 cards) + combo "documentar do zero" aponta o pipeline.
- [x] Contagens (26->29 prompts/wrappers, arquitetura 7->10, 57->60, 78->87) atualizadas.
- [x] sync-copilot/kiro/como-usar --check OK.

## Checklist de execucao
- [x] escrever documentar-servico.md (Etapa 1)
- [x] escrever completar-documentacao.md (Etapa 2)
- [x] escrever grill-arquitetura.md (Etapa 3)
- [x] manifest.tsv: +3 linhas (arquitetura) -> 29
- [x] architecture-style.md § 2: rotear as 3 etapas + nota do fluxo canonico (estreitou arquiteto p/ pagina unica)
- [x] sync-copilot + sync-kiro (60 por camada)
- [x] COMO-USAR.html: 3 cards (Arquitetura) + combo reescrito -> regen .md (71 cards)
- [x] contagens em README.md, INSTALAR.md, install.sh, install.ps1, skills/README.md
- [x] verificacao (--check x3, coverage 29/29/10, pgkc das 3 etapas, sem contagem velha, roteamento nos 3)
