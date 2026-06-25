# TASK — 2026-06-25-instalar-granular-split

- **fase:** concluida
- **tipo:** estrutural (multi-arquivo, doc-only; baixo risco — INSTALAR.md nao e copiado pro alvo nem espelhado por sync)
- **pedido:** deixar o `ia/INSTALAR.md` mais granular. Hoje 211 linhas; um agente le tudo
  (fallback manual + migracao + diagnostico v2) mesmo numa instalacao trivial, o que torna a
  execucao lenta. Reduzir o que o agente carrega no caminho-feliz.
- **desenho aprovado (pergunta de design):** split — dispatcher fino + sub-arquivos por caso.

## Decisao de arquitetura
- INSTALAR.md continua sendo o entry point (README aponta pra ele) e fica so com o
  caminho-feliz: Passo 0, 1, 3 (verificacao), 5 + stubs com caminho EXATO pras sub-paginas.
- Passos condicionais viram `ia/INSTALAR/{manual,migracao,doc-v2}.md`, abertos so sob gatilho.
- Passo 3 (verificacao) FICA no INSTALAR.md -> os 4 greps do `check-counts.sh` seguem validos.

## Criterios de aceite
- [ ] AC1: INSTALAR.md cai de 211 p/ ~75-90 linhas; caminho-feliz auto-contido (Passo 0/1/3/5).
- [ ] AC2: 3 sub-paginas em `ia/INSTALAR/` com o conteudo movido verbatim + breadcrumb de volta.
- [ ] AC3: stubs apontam caminho exato (`INSTALAR/<arq>.md`) e o gatilho ("so se ...").
- [ ] AC4: `check-counts.sh` exit 0 (4 padroes do Passo 3 preservados) e `run-tests.sh` verde.
- [ ] AC5: 3 `sync --check` seguem exit 0 (nenhum mirror tocado); `manual.md` lista `ia/INSTALAR/` em "nao copie".

## Checklist de execucao
- [x] criar `ia/INSTALAR/manual.md` (Passo 2)
- [x] criar `ia/INSTALAR/migracao.md` (Passo 4)
- [x] criar `ia/INSTALAR/doc-v2.md` (Passo 4b)
- [x] reescrever `ia/INSTALAR.md` (slim + stubs)
- [x] verificacao: check-counts OK, run-tests PASS=21, 3 sync --check exit 0, wc 211->106
- [x] LEDGER + fechar
