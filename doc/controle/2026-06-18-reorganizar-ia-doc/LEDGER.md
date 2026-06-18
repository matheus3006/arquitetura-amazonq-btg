# LEDGER — 2026-06-18-reorganizar-ia-doc

## Decisoes
- Split conceitual: `ia/` = a maquina do pack (prompts, skills, tools, templates, design-system,
  COMO-USAR, INSTALAR); `doc/` = os outputs (arquitetura real, controle, adr, specs, planos).
  Os 3 tool dirs (.amazonq/.github/.kiro) ficam na raiz — auto-load das IDEs.
- Dois tipos de path tratados separadamente: prosa "root-relative" (prompts/ -> ia/prompts/) via
  Python com lookbehind (?<![\w./]) que protege .github/skills, .kiro/skills, ia/, doc/; e links
  HTML "file-relative" do COMO-USAR (movido pra ia/) -> design-system/, templates/ (irmaos).
- Runtime JS (sidebar/diagram-viewer/prefs) NAO consolidado em design-system (YAGNI): ficou em
  ia/templates onde estava, pra os links same-dir dos templates nao quebrarem.
- Sync scripts: PACK_DIR passou a subir 2 niveis (../..  = raiz) e as origens ganharam prefixo ia/;
  os destinos mirror (.github/.kiro) e as rules (.amazonq/rules) seguem na raiz.
- Migracao de installs antigos INCLUIDA (escolha do usuario): install.sh/.ps1 secao 7d + INSTALAR
  Passo 4 — move docs/* -> doc/* (preservando dados; arquitetura/ menos templates+design-system) e
  remove copias antigas do pack na raiz (ja reinstaladas em ia/).

## Bug pego e corrigido na execucao
- A substituicao literal ` 'prompts'`/` 'skills'` no install.ps1 vazou pros destinos MIRROR
  (.github/.kiro), virando 'ia/prompts'/'ia/skills' errados. Corrigido: linhas 74/75/89 voltaram a
  'prompts'/'skills' (mirror tool-fixed). install.sh nao foi afetado (usa $TARGET/.github/prompts,
  que nao casa com $TARGET/prompts) — confirmado pelo dry-run.

## Evidencias (2026-06-18)
- Fase 1: git status = 246 renames; docs/ removido; doc/ = adr controle planos specs (+arquitetura placeholder).
- Fase 2: Python transform = 40 arquivos / 273 subs nos canonicos; sync scripts + COMO-USAR a parte.
- Fase 3: sync-copilot/kiro/como-usar geram e --check = OK (30 prompts, 32 skills importadas, 71 cards).
- Fase 5: resolve-check = 279 refs reais resolvem (1 era path-exemplo idempotencia-redis, ok);
  3 --checks OK; 2 dry-runs de install (alvo limpo) exit 0 -> alvo recebe so ia/ + tool dirs,
  .github/skills 62, .github/prompts 30, nada vazou pra raiz.

## Arquivos tocados
- Movidos (git mv, 246 renames): prompts->ia/prompts, skills->ia/skills, tools->ia/tools,
  docs/arquitetura/{templates,design-system}->ia/, COMO-USAR.*+INSTALAR.md->ia/,
  docs/controle->doc/controle, docs/adr->doc/adr, docs/superpowers/*->doc/{specs,planos}.
- Editados canonicos: .amazonq/rules/*, ia/prompts/**, ia/COMO-USAR.html, ia/INSTALAR.md,
  ia/tools/sync-*.sh, .amazonq/hooks/*, .kiro/hooks/*, .amazonq/cli-agents/*, ia/skills/README.md,
  README.md, install.sh, install.ps1.
- Mirrors regenerados pelos syncs: .github/**, .kiro/**, ia/COMO-USAR.md.
- Novo: doc/arquitetura/README.md (placeholder).
- Controle: doc/controle/2026-06-18-reorganizar-ia-doc/ (TASK, PLANO, LEDGER).

## Fora de escopo (confirmado)
- Tool dirs e project-context: imoveis (auto-load).
- ia/skills/**/SKILL.md (importadas verbatim) e doc/controle/** (historico): nao reescritos.

## Pendencia
- install.ps1 nao pode ser dry-run no macOS (sem pwsh) — espelhado da logica verificada do install.sh.
  Recomendado um teste real no Windows antes de confiar 100% na camada PowerShell.
