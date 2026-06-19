# Plano — instalador-gitignore-contexto

**Objetivo:** instalador semeia bloco `.gitignore` idempotente no produto + docs orientam versionar o contexto.
**Maior risco:** drift entre `install.sh` e `install.ps1` no conteúdo do bloco → mitigado por SoT única lida pelos dois.

## Etapa 1 — SoT do bloco + helper bash
- **Arquivos:** `ia/tools/lib/gitignore-pack-block.txt` (novo), `ia/tools/seed-gitignore.sh` (novo).
- **Mudança:** a SoT contém só o CORPO do bloco (comentários + paths a ignorar:
  `.github/skills/`, `.github/prompts/`, `.kiro/skills/`, `ia/skills/`). O helper recebe `<target>`,
  e injeta entre marcadores `# >>> arquitetura-pack (gerado pelo instalador) >>>` … `# <<< arquitetura-pack <<<`:
  cria `.gitignore` se ausente; se já tem os marcadores, substitui só o miolo; senão, apenda o bloco.
- **Verificação:** `bash ia/tools/seed-gitignore.sh /tmp/t1` 2× → 1 bloco; `diff` do miolo vs SoT.
- **Pronto quando:** helper idempotente e miolo == SoT em dir novo e em dir com `.gitignore` preexistente.

## Etapa 2 — install.sh chama o helper
- **Arquivos:** `install.sh` (nova seção `# 9) .gitignore` antes do echo final).
- **Mudança:** `cp` do `seed-gitignore.sh` pra `$TARGET/ia/tools/` (re-seed) + `bash seed-gitignore.sh "$TARGET"`,
  com linha de log `✓ .gitignore (bloco do pack)`.
- **Verificação:** `bash install.sh /tmp/alvo` (dry em dir temp) → `.gitignore` com o bloco; re-run → 1 bloco.
- **Pronto quando:** instalação cria/atualiza o `.gitignore` sem duplicar e sem tocar linhas do usuário.

## Etapa 3 — install.ps1 paridade
- **Arquivos:** `install.ps1` (nova seção `# 9) .gitignore`).
- **Mudança:** função PS que lê `ia/tools/lib/gitignore-pack-block.txt` (mesma SoT) e injeta entre os
  mesmos marcadores (cria/replace/append), copiando também o `.txt` e o `.sh` pro alvo.
- **Verificação:** se `pwsh` disponível → roda 2× e compara; senão revisão estática lado a lado com Etapa 1/2.
- **Pronto quando:** lógica e marcadores idênticos ao bash; bloco gerado == SoT.

## Etapa 4 — Teste
- **Arquivos:** `ia/tools/tests/run-tests.sh` (+ caso) ou novo `tests/test-seed-gitignore.sh`.
- **Mudança:** caso que roda `seed-gitignore.sh` em temp 2×, assert 1 par de marcadores e miolo == SoT,
  e assert que linha preexistente (`node_modules/`) é preservada.
- **Verificação:** `bash ia/tools/tests/run-tests.sh` → PASS inclui o novo caso, FAIL=0.
- **Pronto quando:** suite verde com o caso novo.

## Etapa 5 — Docs
- **Arquivos:** `README.md` (linhas 163-164 + nota nova), `ia/INSTALAR.md`.
- **Mudança:** 163-164 `(gerado por-projeto — não versionar)` → `(gerado por-projeto — versione: análise do produto)`;
  nota curta da política do `.gitignore` (o que ignora/mantém) + regra "clonou → roda o instalador 1×" em ambos.
- **Verificação:** `grep -n 'não versionar' README.md` → vazio; nota presente nos dois docs.
- **Pronto quando:** docs coerentes com o comportamento novo do instalador.
