# PLANO — 2026-06-25-instalar-granular-split

> Aprovado via pergunta de design (opcao "split: dispatcher fino + sub-arquivos").
> INSTALAR.md e canonico standalone: nao e espelhado por sync nem copiado pro alvo.

## Mapa do split (o que vai pra onde)

| Secao atual (INSTALAR.md) | Destino |
|---|---|
| Passo 0 — confirme o alvo | fica (slim) |
| Passo 1 — rode o script | fica (slim; nota de copia manual do .gitignore vai pra manual.md) |
| Passo 2 — copia manual | -> `ia/INSTALAR/manual.md` (stub no slim) |
| Passo 3 — verifique | fica (slim) — **contem os 4 padroes do check-counts** |
| Passo 4 — migracao antiga | -> `ia/INSTALAR/migracao.md` (stub; reassurance "rodar de novo e seguro" fica) |
| Passo 4b — diagnostico doc v2 | -> `ia/INSTALAR/doc-v2.md` (stub no slim) |
| Passo 5 — oriente o usuario | fica (slim) |
| Regras p/ assistente | fica (slim) |

## Forma dos stubs
Cada Passo movido vira 3-4 linhas no slim: titulo + gatilho ("so se ...") + link de caminho
EXATO pra sub-pagina. Cada sub-pagina abre com breadcrumb de volta ao INSTALAR.md.

## Invariantes a manter
- Numeracao dos passos inalterada (0,1,2,3,4,4b,5) — evita quebrar cross-refs.
- Passo 3 verbatim (4 strings do check-counts: "arquitetura 13...32 arquivos", "14 categorias
  e 32 subpastas", "com 64 subpastas (32 wrappers", "com 64 subpastas").
- Mirrors intocados (3 sync --check exit 0).
- `manual.md` adiciona `ia/INSTALAR/` a lista "nao copie".

## Verificacao (evidencia antes de afirmacao)
`bash ia/tools/check-counts.sh` · `bash ia/tools/tests/run-tests.sh` ·
`bash ia/tools/sync-{copilot,kiro,como-usar}.sh --check` · `wc -l ia/INSTALAR.md` · links resolvem.

## Fora de escopo
- Junie (espera a pesquisa). Mudanca em installers/CI (nao necessaria: nao copiam INSTALAR*).
- Commit/push (nao pedido).
