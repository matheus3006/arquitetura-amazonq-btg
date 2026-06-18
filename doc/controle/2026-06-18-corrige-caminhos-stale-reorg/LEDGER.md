# LEDGER — 2026-06-18-corrige-caminhos-stale-reorg

## Decisoes
- Caminho do CSS no PLANO.html: `../../../ia/design-system/` (3 niveis), porque PLANO.html vive em
  `doc/controle/<task-id>/` e o design-system em `ia/design-system/` (task -> controle -> doc -> raiz).
  O valor antigo `../../docs/arquitetura/design-system/` estava errado em pasta E profundidade.
- README: alinhar a URL de exemplo a prosa (que ja dizia `ia/templates/`).

## Working-model respeitado
- Editado so o canonico `ia/prompts/engenharia/controle-de-tarefa.md` (linhas 129-130). O caminho
  stale nao existia em nenhum mirror (`git grep -F '../../docs/arquitetura/design-system'` fora de
  ia/prompts/ = vazio), entao nao houve regeneracao de mirror.
- README.md e standalone (raiz) — sem mirror.
- Nenhum mirror tocado; os 3 `--check` seguem OK (confirmado).

## Evidencias (2026-06-18)
- AC1 `grep -rn 'docs/arquitetura' ia/prompts/ README.md` -> ">>> OK: zero residuo".
- AC2 controle-de-tarefa.md:129-130 -> `../../../ia/design-system/tokens.css` + `components.css`.
- AC3 README.md:245 -> `file:///caminho/para/arquitetura/ia/templates/index.html`.
- AC4 `bash ia/tools/sync-copilot.sh --check`   -> OK ... exit=0
      `bash ia/tools/sync-kiro.sh --check`      -> OK ... exit=0
      `bash ia/tools/sync-como-usar.sh --check` -> OK ... exit=0

## Arquivos tocados
- Canonicos (editados): ia/prompts/engenharia/controle-de-tarefa.md, README.md.
- Controle: doc/controle/2026-06-18-corrige-caminhos-stale-reorg/ (TASK + LEDGER).

## Fora de escopo (confirmado, NAO tocado)
- Mencoes a `docs/...` que sao INTENCIONAIS (descricao de migracao do layout antigo):
  ia/INSTALAR.md:55,126,132 · install.sh:146-149 · install.ps1:153-157,222-243.
- Registros HISTORICOS que citam o layout antigo como fato passado:
  doc/adr/0001:15 · doc/adr/0004:41 · doc/specs/2026-06-10-...:172,174. Ficam como historico.
- Commit: nao solicitado nesta task — nao commitado.
