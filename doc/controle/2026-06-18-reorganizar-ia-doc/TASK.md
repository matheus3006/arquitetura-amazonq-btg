# TASK — 2026-06-18-reorganizar-ia-doc

- **fase:** concluida
- **tipo:** refactor estrutural grande do pack (maior mudanca da sessao)
- **pedido:** separar a estrutura em duas pastas — `ia/` (a maquina do pack: prompts,
  templates, exemplos, skills, tools, COMO-USAR, INSTALAR) e `doc/` (os outputs: documentacao
  real gerada, controle, adr). Modelo conceitual: a FERRAMENTA que voce instala vs os OUTPUTS
  que voce gera.

## Design fechado no brainstorming (4 forks)
1. Alcance: SPLIT COMPLETO `ia/` + `doc/` (nao o split parcial). Os 3 tool dirs
   (`.amazonq/.github/.kiro`) ficam na RAIZ — as IDEs leem desses caminhos fixos.
2. `doc/` = `arquitetura/` (doc real gerada) + `controle/` + `adr/` (+ `specs/` `planos/`).
   O `project-context`/`business-context` (a "analise do codigo") FICA nos tool dirs — e config
   que a IA le sozinha; mover quebraria o auto-load.
3. (decidido na engenharia) Assets de render (CSS + sidebar.js/diagram-viewer.js/prefs.js) ficam
   juntos em `ia/design-system/`; `ia/templates/` fica so com os .html de exemplo. Templates e
   design-system irmaos sob `ia/` => os links internos dos templates (`../design-system/`) NAO
   quebram. A doc gerada em `doc/` referencia os assets por caminho relativo calculado pela IA.
4. Migracao de quem ja instalou o layout antigo: INCLUIR AGORA (Passo 4 do INSTALAR), preservando
   o trabalho do usuario.

## Criterios de aceite
- [ ] Layout final: raiz tem `.amazonq/ .github/ .kiro/ ia/ doc/ README.md LICENSE install.sh install.ps1`.
- [ ] `ia/` = prompts/ skills/ tools/ templates/ design-system/ COMO-USAR.html COMO-USAR.md INSTALAR.md.
- [ ] `doc/` = arquitetura/ controle/ adr/ specs/ planos/ (arquitetura/ com placeholder no repo do pack).
- [ ] Mover com `git mv` (historico preservado).
- [ ] Referencias reescritas nos CANONICOS (nao nos mirrors): .amazonq/rules/, ia/prompts/,
      ia/COMO-USAR.html, ia/INSTALAR.md, ia/tools/sync-*.sh, hooks, cli-agents, install.sh/.ps1, README.
- [ ] skills importadas (ia/skills/**/SKILL.md) NAO editadas (verbatim). Registros historicos em
      doc/controle/ NAO reescritos (sao historico).
- [ ] 3 syncs (copilot/kiro/como-usar) rodam de ia/tools/ e --check = OK nos tres.
- [ ] INSTALAR Passo 4 migra layout antigo -> ia/+doc/ (preserva tudo); install.sh/.ps1 idem.
- [ ] Verificacao: todo caminho `ia/...`/`doc/...` citado em prompts/rules/COMO-USAR resolve pra
      arquivo existente; nenhuma ref orfa ao layout antigo fora de historico.

## Checklist de execucao (fases com gate)
- [x] Fase 1 — git mv das pastas (ia/ e doc/) — 246 renames, historico preservado
- [x] Fase 2 — reescrita de referencias (Python lookbehind: 40 arq/273 subs + sync scripts + COMO-USAR Type A/B)
- [x] Fase 3 — re-sync dos 3 + --check verde (30 prompts, 32 skills, 71 cards)
- [x] Fase 4 — INSTALAR + install.sh/.ps1 (paths + Passo 4 migracao de layout + Passo 4b)
- [x] Fase 5 — resolve-check (279 refs ok), 3 --checks, 2 dry-runs de install (exit 0, layout correto)

## Nota de execucao
Recomendado rodar numa BRANCH/WORKTREE (nao direto na main) pela dimensao (200+ refs); pode
exigir mais de um turno. Cada fase fecha com seu gate de verificacao antes da seguinte.
