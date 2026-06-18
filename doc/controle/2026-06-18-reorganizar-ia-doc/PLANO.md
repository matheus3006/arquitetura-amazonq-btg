# PLANO — 2026-06-18-reorganizar-ia-doc

Refactor estrutural. Working-model: canonico -> mirror via sync (nunca editar mirror a mao).
Execucao em 5 fases, cada uma com gate de verificacao. Recomendado em branch/worktree.

## Layout final
```
raiz/
  .amazonq/  .github/  .kiro/      (tool-fixed: rules, instructions, steering, wrappers,
                                    hooks, project-context/business-context)
  ia/
    prompts/ {arquitetura,engenharia,negocio,frontend}
    skills/  {categorias importadas — verbatim}
    tools/   {sync-copilot.sh, sync-kiro.sh, sync-como-usar.sh, manifest.tsv}
    templates/      {*.html exemplo}
    design-system/  {tokens.css, components.css, sidebar.js, diagram-viewer.js, prefs.js}
    COMO-USAR.html  COMO-USAR.md  INSTALAR.md
  doc/
    arquitetura/  (doc real gerada; no repo do pack: README.md placeholder)
    controle/  adr/  specs/  planos/
  README.md  LICENSE  install.sh  install.ps1   (bootstrap fica na raiz)
```

## Fase 1 — git mv (preserva historico)
- `git mv prompts ia/prompts` · `git mv skills ia/skills` · `git mv tools ia/tools`
- `git mv docs/arquitetura/templates ia/templates`
- `git mv docs/arquitetura/design-system ia/design-system`
- mover sidebar.js/diagram-viewer.js/prefs.js de ia/templates -> ia/design-system (consolidar render)
- `git mv COMO-USAR.html COMO-USAR.md INSTALAR.md ia/`
- `git mv docs/controle doc/controle` · `git mv docs/adr doc/adr`
- docs/superpowers/specs -> doc/specs ; docs/superpowers/plans -> doc/planos (estao vazios)
- criar doc/arquitetura/README.md (placeholder: "doc de arquitetura REAL gerada vai aqui")
- remover docs/ vazio.
- **Gate:** `git status` mostra renames; nada perdido; `ls ia/ doc/` confere com o layout.

## Fase 2 — reescrita de referencias (canonicos apenas)
Script sed aplicando, EM ORDEM, nos arquivos canonicos:
- `prompts/`            -> `ia/prompts/`
- `skills/`             -> `ia/skills/`
- `tools/`              -> `ia/tools/`
- `docs/arquitetura/templates`     -> `ia/templates`
- `docs/arquitetura/design-system` -> `ia/design-system`
- `docs/controle`       -> `doc/controle`
- `docs/adr`            -> `doc/adr`
- `docs/specs`          -> `doc/specs`
- `docs/planos`         -> `doc/planos`
- `docs/arquitetura`    -> `doc/arquitetura`   (aplicar por ULTIMO; as duas subpastas ja foram tratadas acima)

Arquivos canonicos no escopo do sed:
- `.amazonq/rules/*.md` (rules canonicas — referenciam prompts/skills/docs)
- `ia/prompts/**/*.md`
- `ia/COMO-USAR.html` (70 cards) + `ia/INSTALAR.md`
- `ia/tools/sync-copilot.sh`, `sync-kiro.sh`, `sync-como-usar.sh` (paths de origem e SRC/DST)
- `.amazonq/hooks/*.sh`, `.kiro/hooks/*`, `.amazonq/cli-agents/*.json` (prosa docs/controle)
- `install.sh`, `install.ps1`, `README.md`

FORA do sed (nao tocar):
- `ia/skills/**/SKILL.md` (importadas verbatim — nao referenciam paths do pack)
- mirrors `.github/**` e `.kiro/**` (regenerados na Fase 3)
- `doc/controle/**` (registros historicos — descrevem o que era verdade na epoca)
- COMO-USAR.md (regenerado pelo sync na Fase 3)

Cuidados:
- Ordem importa: tratar `docs/arquitetura/<sub>` ANTES de `docs/arquitetura` generico.
- A doc gerada referencia os assets por caminho relativo CALCULADO pela IA (a rule frontend-style
  passa a apontar `ia/design-system/`); os templates de exemplo mantem `../design-system/` (irmaos).
- **Gate:** grep por refs orfas (`(^|[^a-z])prompts/`, `docs/controle`, etc.) fora de ia//doc/historico = 0.

## Fase 3 — re-sync
- `bash ia/tools/sync-copilot.sh && bash ia/tools/sync-copilot.sh --check`
- `bash ia/tools/sync-kiro.sh && bash ia/tools/sync-kiro.sh --check`
- `bash ia/tools/sync-como-usar.sh && bash ia/tools/sync-como-usar.sh --check`
- **Gate:** 3 --check = OK; mirrors regenerados apontando pros caminhos ia/.

## Fase 4 — instaladores + migracao
- `ia/INSTALAR.md`: tabela de copia (origem ia/* e doc/*), gate de contexto, Passo 4b (paths novos).
- `ia/INSTALAR.md` Passo 4 (MIGRACAO de layout antigo): nova regra —
  `prompts/ skills/ tools/` na raiz -> `ia/`; `docs/controle -> doc/controle`,
  `docs/adr -> doc/adr`, `docs/<servico>` (doc real) -> `doc/<servico>`,
  `docs/arquitetura/{templates,design-system} -> ia/`. Preserva tudo; nada apagado; se ja existir
  no destino, faz merge sem sobrescrever.
- `install.sh` / `install.ps1`: atualizar os mapas de copia e a logica de migracao automatica.
- **Gate:** INSTALAR auto-consistente; install.sh --help/dry-run sem erro.

## Fase 5 — verificacao final
- Resolve-check: extrair todo `ia/prompts/...`, `ia/skills/...`, `ia/tools/...`, `doc/...` citado
  em ia/prompts, .amazonq/rules, ia/COMO-USAR e afirmar que o arquivo/dir existe.
- 3 syncs --check = OK (repetir).
- Dry-run de install num diretorio temporario: confirmar que ia/ e doc/ sao criados certos.
- **Gate:** zero path quebrado; relatorio de fechamento em 3 blocos.

## Fora de escopo
- Mudar conteudo de prompts/skills/docs alem dos caminhos.
- Mover os tool dirs (.amazonq/.github/.kiro) — impossivel (auto-load das IDEs).
- Tirar o project-context dos tool dirs (idem).

## Riscos
- 200+ referencias; uma perdida quebra um path/sync/install. Mitigacao: sed deterministico +
  resolve-check + 3 --checks + dry-run, em branch/worktree, fase a fase.
- COMO-USAR.md e mirrors regenerados (nao editados) — divergencia impossivel se o sync passar.
