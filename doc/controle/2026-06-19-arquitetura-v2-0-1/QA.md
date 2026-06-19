# QA — 2026-06-19-arquitetura-v2-0-1

> **Status vivo:** apendado NO MESMO TURNO em que a resposta chega.
> **Regra binária:** **verbatim** sempre que houver decisão (escolha entre opções, nome de
> tecnologia, restrição numérica/temporal); **normalizada** (1 linha) caso contrário.

## Perguntas & Respostas

- [2026-06-19] P: Finding #3 — fechar o descompasso promessa↔enforcement do classDef hex
  (validar-doc.sh só confere presença dos nomes, não o hex): estender o script (hex completo),
  só o fill, ou ajustar a promessa (sem código)?
  R: verbatim: "Estender o script (hex completo)" — validar-doc.sh passa a ler
  `lib/mermaid-classdefs.txt` e comparar fill+stroke+color de cada classDef; emite
  `mermaid-classdef-hex` no divergente; + caso TDD (`run-tests.sh` → PASS=18).

- [2026-06-19] P: Finding #1 — investigando, descobri que docs gerados em `doc/arquitetura/`
  referenciam `../templates/` + `../design-system/` (= `doc/templates/`, `doc/design-system/`)
  que NADA cria → página gerada renderiza sem estilo no repo de terceiro. v2.0.1 deve só copiar
  prefs.js (#1 estrito), semear assets em `doc/`, ou repath para `ia/`?
  R: verbatim: "Semear assets em doc/ (artefatos)" — geradores/setup semeiam
  `doc/templates/{prefs,sidebar,diagram-viewer}.js` + `doc/design-system/*.css` a partir de `ia/`,
  idempotente, tratados como artefato de build (re-copiados de `ia/`, nunca editados à mão, como
  os mirrors); paths do spec ficam idênticos; validador e fixtures intactos; + copiar `prefs.js`
  nos instaladores (#1 original).
