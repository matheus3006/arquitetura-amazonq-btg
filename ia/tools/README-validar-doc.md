# validar-doc.sh — lint estrutural da doc gerada

Camada determinística opcional dos validadores #6 (front/template) e #7 (sintaxe/Mermaid)
da trilha de arquitetura (spec: [doc/specs/2026-06-19-pipeline-arquitetura-v2-design.md](../../doc/specs/2026-06-19-pipeline-arquitetura-v2-design.md)).

## Uso

    bash ia/tools/validar-doc.sh <pasta> [--front | --mermaid | --all]

`<pasta>` é tipicamente `doc/arquitetura/`. Aceita também caminho de arquivo único.

| Flag       | O que verifica |
|------------|---------------|
| `--front`   | Vocabulário fechado de classes, ordem do `<head>`, cor hex hardcoded, NAV órfão, resíduo do exemplo |
| `--mermaid` | Pareamento `data-diagram`↔`data-id`, tipo válido na 1ª linha, 4 `classDef`, `autonumber` em sequence |
| `--all`     | Roda os dois |

## Exit codes

- `0` clean
- `1` violações (lista no stdout, formato `arquivo:linha:regra: descrição`)
- `2` erro de uso ou ambiente sem dep opcional (fallback gracioso)

## Fontes (Source of Truth)

Editáveis em `ia/tools/lib/`:

| Arquivo | Conteúdo | Lido por |
|---|---|---|
| `design-system-classes.txt` | Vocabulário fechado de classes | `--front` |
| `mermaid-classdefs.txt` | 4 classDef com hex exatos | `--mermaid` |
| `forbidden-terms.txt` | Termos proibidos (resíduo do exemplo) | `--front` |

Adicionar/remover regra ou item = editar **um** arquivo. Nada hardcoded no script.

## Testes

    bash ia/tools/tests/run-tests.sh

Suite com 17 casos cobrindo:

- 3 casos de CLI/exit codes (sem args, flag inválida, pasta inexistente).
- 5 casos de `--front`: head-order, class-unknown, hex-hardcoded, forbidden-terms, nav-órfã.
- 5 casos de `--mermaid`: pair-OK, pair-FAIL, type-invalid, classdef-faltando, autonumber-FAIL, autonumber-OK.
- 1 caso de `--all` (pasta com mistura → FAIL).

Fixtures em `ia/tools/tests/fixtures/{front,mermaid}/`.

## Limitações conhecidas (futuras melhorias)

- Não roda `mermaid-cli` para parse real — só lint estrutural por regex.
  Upgrade opcional quando `mermaid-cli` estiver disponível no ambiente.
- Tipografia Butterick (aspas tipográficas, em/en dash, `≥`/`≤`, número PT-BR) ainda
  não é checada pelo script; fica como N-A no checklist e o validador faz fallback textual.
