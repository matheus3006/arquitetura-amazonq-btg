# LEDGER — 2026-06-17-pipeline-arquitetura

## Decisoes
- Estrutura: ORQUESTRADOR (escolha do usuario) — Etapas 1 e 2 referenciam os prompts-base e
  rodam os processos deles em fases com checkpoint; nao duplicam metodologia. Base preservada
  (gate de ADR/runbook intacto).
- Pipeline de 3 etapas obrigatorias, cada uma terminando com handoff pra proxima:
  documentar-servico (1) -> completar-documentacao (2) -> grill-arquitetura (3, sessao nova).
- Escopo da Etapa 1 = "espinha" (contexto + dominio + visao geral + paginas-nucleo). Fluxo
  critico + runbook foram pra Etapa 2 (proposta do usuario). Grill exaustivo virou Etapa 3.
- Etapa 3 (grill-arquitetura): loop CODIGO-PRIMEIRO por incerteza, com NIVEL DE CERTEZA
  (alta/media/baixa + arquivo:linha) ou pergunta ao humano so quando o codigo nao fecha.
  Distinto do grill-doc (revisao geral por 7 lentes, pagina a pagina).
- Stack de skills nas 3: human-architect-mindset, improve-codebase-architecture,
  verification-before-completion, doc-coauthoring (+ andaime de grilling).
- Rule: estreitei a linha do arquiteto-de-sistema para "pagina unica/refresh"; o fluxo do zero
  agora roteia pra documentar-servico.

## Evidencias (2026-06-17)
- 3 prompts criados em prompts/arquitetura/ (estilo do pack). Cobertura: 29 prompts == 29 manifest;
  arquitetura 10.
- Regen: sync-copilot/sync-kiro -> 29 wrappers + 31 importadas = 60 por camada; as 3 etapas com
  prompt + wrapper .github + wrapper .kiro + card COMO-USAR (pgkc nos 3).
- architecture-style § 2 roteia as 3 etapas + nota do fluxo canonico — propagado pros 2 mirrors
  (instructions + steering): etapas=6, fluxo-canonico=1 nos tres.
- COMO-USAR.html: 71 cards (68 + 3 etapas), combo "documentar do zero" reescrito pro pipeline;
  COMO-USAR.md regenerado (71 cards).
- sync-copilot/sync-kiro/sync-como-usar --check: todos OK. Nenhuma contagem velha (26/57/78/arquitetura 7).

## Pendencias
- Contraste/UI do template (adiado pelo usuario) — proximo candidato.
