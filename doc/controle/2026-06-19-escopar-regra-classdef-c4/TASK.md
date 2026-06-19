---
fase: concluida
tipo: normal
task_id: 2026-06-19-escopar-regra-classdef-c4
---

## Objetivo
Corrigir a regra `mermaid-classdef` do validar-doc, que exige os 4 classDef C4
(person/sys/ext/extAsync) em TODO flowchart — só faz sentido no diagrama de contexto. Escopar
por "nomes reservados" e religar `validar-doc ia/templates --mermaid` como gate no CI.
Resolve o chip `task_d8458acd`.

## Escopo
- Regra: para de EXIGIR os 4; mantém "classDef nomeado person/sys/ext/extAsync usa hex do SoT".
- Exemplos: renomear `classDef ext` (não-C4) → `external` em 02-padroes e 06-infraestrutura.
- Testes/fixtures + README ajustados ao novo comportamento.
- CI: religar `validar-doc ia/templates --mermaid` no job Linux.

## Fora de escopo
- Não tocar em prompts (mecanismo "nomes reservados" não precisa).
- Não governar cor de classDef não-reservado.
- `--front` sobre templates (forbidden-terms dispara por design — fica fora do CI).

## Acceptance Criteria
- [x] AC1: `validar-doc ia/templates --mermaid` → exit 0.
- [x] AC2: `run-tests.sh` verde (caso repurposado p/ PASS; hex errado segue FAIL). PASS=21.
- [x] AC3: CI Linux roda `validar-doc ia/templates --mermaid`; YAML válido (full CI no push).
- [x] AC4: 01 (C4) validado — adversarial: corromper hex do person → FAIL confirmado.

## Checklist (STATUS VIVO — marque [x] na hora)
- [x] 1. validar-doc.sh: remover "exige 4"; manter hex-check dos nomes reservados (+ comentário)
- [x] 2. renomear classDef ext→external em 02-padroes (387/425/429) e 06-infra (267/312)
- [x] 3. run-tests.sh: caso "falta classDef"→PASS; manter caso hex-FAIL
- [x] 4. README-validar-doc.md: descrição da regra
- [x] 5. ci.yml: step `validar-doc ia/templates --mermaid` (substitui o comentário)
- [x] 6. verificar: templates --mermaid exit0 + run-tests verde + YAML (ACs)
- [x] 7. dismiss chip task_d8458acd
