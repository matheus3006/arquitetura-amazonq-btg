# Plano — escopar-regra-classdef-c4

**Objetivo:** a regra C4 (4 classDef) só vale pro diagrama de contexto; libera os demais
flowcharts e religa o check estrutural dos templates no CI.
**Maior risco:** rename de `ext` pegar ocorrência errada (extAsync/external/context) ou o 01
(C4 real) deixar de ser validado. Mitigação: edits pontuais + re-rodar validar-doc.

## Etapa 1 — regra: de "exige 4" para "nomes reservados"
- **Arquivos:** `ia/tools/validar-doc.sh` (`_rule_mermaid_classdefs`, ~176-232).
- **Mudança:** remover o bloco que emite `falta classDef` (o `need[]`/`found[]`). Manter o
  hex-check: classDef nomeado person/sys/ext/extAsync DEVE bater com o SoT. Atualizar comentário.
- **Verificação:** `validar-doc ia/tools/tests/fixtures/mermaid/missing-classdef.html --mermaid`
  → exit 0; `bad-classdef-hex.html` → exit 1.
- **Pronto quando:** missing-classdef PASSA e hex-errado FALHA.

## Etapa 2 — exemplos: ext → external (colisão de nome reservado)
- **Arquivos:** `ia/templates/02-padroes.html` (387 classDef, 425/429 class), `ia/templates/06-infraestrutura.html` (267 classDef, 312 class).
- **Mudança:** `ext` → `external` (mantém as cores cinza; sai do nome reservado). NÃO tocar 01.
- **Verificação:** `grep -n 'classDef ext\b\|\bext\b' nesses arquivos` → só `external`/`extAsync`.
- **Pronto quando:** nenhum `classDef ext` não-C4 nos dois arquivos.

## Etapa 3 — testes
- **Arquivos:** `ia/tools/tests/run-tests.sh`.
- **Mudança:** caso "mermaid: falta classDef = FAIL" → "mermaid: reservado parcial c/ hex certo
  = PASS" (mesma fixture missing-classdef.html, agora exit 0). Manter "classDef hex errado = FAIL".
- **Verificação:** `bash ia/tools/tests/run-tests.sh`.
- **Pronto quando:** suite verde.

## Etapa 4 — doc
- **Arquivos:** `ia/tools/README-validar-doc.md`.
- **Mudança:** "4 classDef com hex exatos" → "nomes reservados (person/sys/ext/extAsync) usam o
  hex do SoT (não obrigatórios; exigidos só no diagrama de contexto, por convenção)".
- **Verificação:** leitura.
- **Pronto quando:** descrição condiz com a regra nova.

## Etapa 5 — religar no CI
- **Arquivos:** `.github/workflows/ci.yml` (job Linux).
- **Mudança:** substituir o comentário "não rodamos validar-doc ia/templates" por um step
  `bash ia/tools/validar-doc.sh ia/templates --mermaid`. Nota: `--front` fica fora (forbidden-terms).
- **Verificação:** `python3 -c yaml.safe_load`; `validar-doc ia/templates --mermaid` → exit 0.
- **Pronto quando:** YAML válido e o check passa localmente.
