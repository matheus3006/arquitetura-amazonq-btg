# TASK — 2026-06-18-instalar-prosa-doc-stale

- **fase:** concluida
- **tipo:** trivial (1 arquivo, doc-only; baixo risco)
- **pedido:** corrigir a prosa stale em INSTALAR.md:85-87, que afirma que os assets do pack
  (css, 2 .js, paginas de exemplo) sao copiados de `doc/arquitetura/` — pos-reorg eles vivem
  em `ia/design-system/` + `ia/templates/`. `doc/arquitetura/` hoje so tem README.md.

## Achado (da pergunta do usuario)
- INSTALAR.md:85-87 contradiz a propria tabela do Passo 2 (linhas 49-51, que poem css/js/html
  em `ia/`). Passou batido na validacao anterior por usar o prefixo NOVO `doc/` (nao `docs/`).
- Evidencia: `find doc/arquitetura` -> so `doc/arquitetura/README.md`; nenhum css/js/templates
  em doc/.

## Working-model
- INSTALAR.md e canonico standalone: nao e espelhado por sync e NAO e copiado pro alvo
  (o proprio arquivo lista "INSTALAR.md" em "nao copie"). Sem re-sync de conteudo.

## Criterios de aceite
- [x] AC1: INSTALAR.md nao afirma mais que assets vivem/sao copiados de `doc/arquitetura/`;
  aponta `ia/design-system/` + `ia/templates/` + `ia/`, coerente com a tabela.
- [x] AC2: a regra "nao copie a doc/ do pack" continua clara.
- [x] AC3: zero `doc/arquitetura/ (css...` residual; os 3 sync --check seguem exit 0.

## Checklist de execucao
- [x] reescrever INSTALAR.md:85-87
- [x] grep de residuo + 3 --check
- [x] LEDGER + fechar
