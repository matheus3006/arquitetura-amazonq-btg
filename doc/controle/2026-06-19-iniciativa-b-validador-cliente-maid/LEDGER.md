# Ledger — iniciativa-b-validador-cliente-maid

## Decisões
- 2026-06-19 — Desenho aprovado via grilling (ver QA.md). Fork1=só destravar 6/7;
  Fork2=guarda funcional; Fork3=script versionado pack-only (`check-mermaid.sh`).
- 2026-06-19 — Brinde `checkout` v4→v5 incluído (remove warning de Node 20 no CI).
- 2026-06-19 — Aprovação pré-execução pela sessão de grill → task aberta direto em `execucao`
  (sem turno extra de plano), conforme grill-before-implementing.
- 2026-06-19 — [B2 BLOQUEIO] Spike do parser: `@probelabs/maid` é MAIS ESTRITO que o renderer.
  maid REJEITA 6/10 diagramas (FL-EDGE-LABEL-QUOTE-IN-PIPES, FL-LABEL-QUOTE-IN-UNQUOTED em
  cilindro `[("x")]`, dotted `-.label.->`, `alt ... as ...`) que `mermaid@10.9.6` (o que o
  `diagram-viewer.js:19` carrega da CDN) ACEITA — todos os 10 passam no `mermaid.parse`.
  → maid = falso-positivo pro dialeto do pack. Recomendo trocar o parser do gate por
  mermaid@10 (autoritativo). Decisão do usuário pendente antes de wirar B2.
- 2026-06-19 — [B2 RESOLVIDO] DROPADO (decisão do usuário). Reframe: gate de CI não ajuda o
  dev do serviço (sem acesso ao CI) — e não precisa: o `diagram-viewer.js:184-190` mostra
  caixa de erro quando o mermaid não renderiza, e o `validar-doc --mermaid` estrutural já vai
  pro cliente (B1). O gate só guardaria os 10 diagramas de EXEMPLO (já verdes, mudam pouco) →
  node no CI não compensa. maid descartado de vez (mais estrito que o renderer). Nenhum
  artefato de B2 foi criado (spike só em /tmp). Reviver = guarda do exemplo com mermaid@10.

## Verificação
- Spike maid: `npx -y @probelabs/maid <tmp>` → EXIT=1 (6 erros).
- Spike mermaid@10: `mermaid.parse` (mermaid@10.9.6 + jsdom) nos 10 blocos → 10/10 PASS.
- AC1+AC3: `bash ia/tools/tests/run-tests.sh` → PASS=21 FAIL=0 (inclui install-validador) — passed.
- AC5: `python3 -c yaml.safe_load` → YAML OK; checkout refs = {actions/checkout@v5} — passed.
- Guard adversarial: removi cada SoT da install seedada e rodei a fixture "ruim" →
  classes/forbidden/mermaid todas 1→0 ("exit 1" prova mesmo que o SoT chegou) — passed.
- AC2: assertivo no job Windows (Test-Path dos 4) — verifica no push (pwsh n/a local).

## Pendências
- Nenhuma na task. Iniciativa B fechada com B1 (validador no cliente) + bump checkout@v5.
- Working tree NÃO commitado (aguarda "pode commitar" do usuário).
- Roadmap: falta a iniciativa D (kit outbound). Chip `task_d8458acd` (templates vs
  validar-doc estrutural) segue aberto e ortogonal.
