# Checklist canonico dos validadores

> Embutido pelos prompts `validador-visual` e `validador-sintaxe-mermaid` no INICIO da
> resposta. Sem este bloco preenchido, a etapa NAO conta como concluida.

## Checklist do validador

| Regra | Status | Evidencia |
|---|---|---|
| 5.1.1 NAV: cada .html tem entry em sidebar.js | PASS / FAIL / N-A | `arquivo:linha` |
| 5.1.1 NAV: href resolve para arquivo existente | PASS / FAIL / N-A | `arquivo:linha` |
| 5.1.2 Ordem fixa do <head> | PASS / FAIL / N-A | `arquivo:linha` |
| 5.1.2 Body em shell > sidebar + main | PASS / FAIL / N-A | `arquivo:linha` |
| 5.1.2 Toda classe em design-system-classes.txt | PASS / FAIL / N-A | trecho |
| 5.1.2 Zero hex hardcoded fora dos classDef | PASS / FAIL / N-A | trecho |
| 5.1.3 Cabecalho h2.section-eyebrow / texto p.prose | PASS / FAIL / N-A | trecho |
| 5.1.3 Pagina de conteudo abre com breadcrumb + hero | PASS / FAIL / N-A | trecho |
| 5.1.3 Diagrama: figure.diagram-figure + script[data-id] pareados | PASS / FAIL / N-A | trecho |
| 5.1.3 Sem residuo (forbidden-terms.txt) | PASS / FAIL / N-A | grep |
| 5.2 Pareamento data-diagram <-> data-id 1:1 | PASS / FAIL / N-A | trecho |
| 5.2 1a linha do bloco = tipo valido | PASS / FAIL / N-A | trecho |
| 5.2 4 classDef com hex exatos (mermaid-classdefs.txt) | PASS / FAIL / N-A | trecho |
| 5.2 Labels entre aspas, sem `<`/`>` crus, sem `\n` | PASS / FAIL / N-A | trecho |
| 5.2 sequenceDiagram tem `autonumber` (sempre) | PASS / FAIL / N-A | trecho |
| 5.2 Tipografia Butterick onde aplicavel | PASS / FAIL / N-A | trecho |

**Modo:** lint (validar-doc.sh exit 0|1) | fallback (checklist textual) | misto

**Veredito:** PASS (zero FAIL) | FAIL (N violacoes listadas abaixo)

## Violacoes (somente se FAIL)
- `<arquivo>:<linha>:<regra>: <descricao curta>`
- ...
