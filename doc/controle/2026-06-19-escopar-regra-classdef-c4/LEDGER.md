# Ledger — escopar-regra-classdef-c4

## Decisões
- 2026-06-19 — Achado: a regra `mermaid-classdef` exige os 4 classDef C4 em TODO flowchart,
  mas só `01-visao-geral` é diagrama de contexto (usa person/sys/ext/extAsync e passa). Os
  outros (02/03/06/07) usam taxonomias próprias e renderizam ok no mermaid@10 → regra
  over-generalizada, exemplos certos.
- 2026-06-19 — Fork direção: "Corrigir a REGRA" (não conformar exemplos). Ver QA.
- 2026-06-19 — Fork mecanismo: "Nomes reservados" — não exige os 4; classDef chamado
  person/sys/ext/extAsync deve usar hex do SoT. Mantém governança da paleta no pack E no
  cliente, sem marcador/prompt. Custo: renomear `ext` não-C4 → `external` em 02 e 06.
- 2026-06-19 — Desenho aprovado ("aprovado") → task aberta em execucao.

## Verificação
- AC1: `validar-doc ia/templates --mermaid` → EXIT=0 (era 22 violações classdef) — passed.
- AC2: `run-tests.sh` → PASS=21 FAIL=0 (caso "reservado parcial c/ hex certo = PASS";
  "classDef hex errado = FAIL" mantido) — passed.
- AC3: `yaml.safe_load(ci.yml)` OK; step "Lint Mermaid das páginas de exemplo" no job Linux — passed.
- AC4 (adversarial): copiei 01-visao-geral, corrompi `classDef person fill` → validar-doc
  acusou `mermaid-classdef-hex ... person ... diverge do SoT` (EXIT=1) → paleta C4 segue
  enforçada, não passou por acaso — passed.

## Pendências
- Chip `task_d8458acd`: resolvido pelo conteúdo, mas NÃO foi possível dispensar via tool
  (id de sessão anterior a um restart — não persiste). Usuário dispensa manualmente se aparecer.
- Working tree NÃO commitado (aguarda pedido explícito).
