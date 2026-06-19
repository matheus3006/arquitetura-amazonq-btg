# Ledger — arquitetura-v2-0-1

## Decisões
- 2026-06-19 — task aberta para os 3 findings MÉDIA da validação adversarial v2
  (workflow wf_fa475c35-067; 6 média/alta sobreviveram à refutação, 1 refutado).
- 2026-06-19 — Fork #3 (QA.md): ESTENDER validar-doc.sh p/ comparar fill/stroke/color do
  classDef contra ia/tools/lib/mermaid-classdefs.txt (não baixar a promessa). Regra nova
  `mermaid-classdef-hex`; degrada p/ só-presença se o SoT faltar (fallback gracioso).
- 2026-06-19 — Fork #1 (QA.md): investigação revelou gap maior — docs gerados em
  doc/arquitetura/ referenciam ../templates/ + ../design-system/ que nada criava. Decisão:
  SEMEAR doc/templates/ + doc/design-system/ de ia/ (artefato de build). Helper
  ia/tools/seed-doc-assets.sh (idempotente), instalado e chamado pelos 2 instaladores.
- 2026-06-19 — Como o script passou a enforce o hex, a promessa "hex exatos" do
  checklist-validador.md:22 e README-validar-doc.md:31 ficou verdadeira sem editar doc.
- 2026-06-19 — #4 (baixa) foldado: arquiteto-de-sistema.md:103 reescrito p/ Decisão #11.

## Verificação
- AC1 (prefs.js + CSS resolvem): install.sh dry-run em mktemp → EXIT=0; alvo tem
  ia/templates/prefs.js, doc/templates/{prefs,sidebar,diagram-viewer}.js e
  doc/design-system/{tokens,components}.css; sem vazamento (doc/specs|controle|.git ausentes). passed
- AC2 (install.ps1 idempotente): revisão estática — linha 96 agora usa glob `ia/prompts/$t/*`
  num dir criado, igual às outras 4 cópias recursivas (sem aninhar). pwsh indisponível no
  ambiente → validação em Windows real fica como pendência. passed (estático)
- AC3 (promessa hex == enforcement): validar-doc.sh bad-classdef-hex.html --mermaid →
  "person fill #ff0000 diverge do SoT (esperado #1c4e93)" EXIT=1; ok-pair.html → EXIT=0. passed
- AC4 (suite + sync): run-tests.sh → PASS=18 FAIL=0; 3× sync --check → EXIT=0. passed
- Working-model: git status com ZERO mudança em .github/ e .kiro/ (sync regenerou mirrors
  idênticos — wrappers são stubs-ponteiro); edições só em canônicos + ia/tools + install.* + task.

## Pendências
- Validar install.ps1 em Windows/PowerShell real (2 runs consecutivos): confirmar ausência de
  ia/prompts/<t>/<t>/ e presença de doc/templates + doc/design-system. Não testável aqui (sem pwsh).
- 11 findings BAIXA de cobertura do linter opcional (só-prompt) seguem para outra task.
