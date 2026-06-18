# LEDGER — 2026-06-17-prompt-sincronizar-doc-codigo

## Decisoes (design fechado via brainstorming, 4 forks)
- Input: SEMPRE `git diff main...HEAD` (escolha do usuario). Pos-merge tratado como nota no prompt
  (rodar de um checkout do ponto anterior), sem ramificar o fluxo.
- Motor do grill: IMPORTAR grill-me da superpowers (escolha do usuario, ciente do +1 dependencia)
  em vez de reusar o andaime nativo. grill-me = como perguntar; human-architect-mindset = QUAIS
  dimensoes (invariante/falha/ordem/escala). O pack ja usava esse padrao HAM-controla-grill no
  grill-arquitetura; aqui o grill-me e o motor explicito.
- Alcance: atualiza paginas afetadas inline + project-context (se stack mudou) + ADR. Fluxo
  codigo -> grill -> doc -> ADR.
- Deteccao de ADR: hibrida (busca docs/<servico>/adr/, mostra candidatas, confirma) — fiel a
  "evidencia antes de perguntar".
- Posicionamento: standalone (nao e etapa do fluxo de 3); e o "manter em dia" apos o "criar do
  zero". Card colocado logo apos a Etapa 3/3 no COMO-USAR; gatilho na rule apos o grill-arquitetura.

## Working-model respeitado
- Canonicos editados a mao: prompts/arquitetura/sincronizar-doc-codigo.md (novo),
  skills/arquitetura/grill-me/ (novo, verbatim), skills/README.md, tools/manifest.tsv,
  .amazonq/rules/architecture-style.md, COMO-USAR.html.
- Mirrors GERADOS pelo sync (nunca a mao): .github/{instructions,prompts,skills},
  .kiro/{steering,skills}, COMO-USAR.md. grill-me espelhado por cp -R (mecanismo de skills
  importadas do sync, linhas 151-161 do sync-copilot.sh).

## Evidencias (2026-06-18)
- sync-copilot: "30 prompt files + 30 skills wrappers + 32 skills importadas"; --check OK.
- sync-kiro: "30 skills wrappers + 32 skills importadas"; --check OK.
- sync-como-usar: "COMO-USAR.md (71 cards)" (era 70, +1); --check OK.
- Prompt nos 3 caminhos: .github/prompts/sincronizar-doc-codigo.prompt.md,
  .github/skills/sincronizar-doc-codigo/SKILL.md, .kiro/skills/sincronizar-doc-codigo/SKILL.md.
- grill-me: skills/arquitetura/grill-me + .github/skills/grill-me + .kiro/skills/grill-me, todos
  635 bytes, diff vazio (identicos). Sem colisao de slug (registramos sincronizar-doc-codigo).
- manifest: slug 1x (30 slugs no total). Card no COMO-USAR.md 1x.

## Arquivos tocados
- Canonicos (novos): prompts/arquitetura/sincronizar-doc-codigo.md, skills/arquitetura/grill-me/SKILL.md.
- Canonicos (editados): skills/README.md, tools/manifest.tsv, .amazonq/rules/architecture-style.md, COMO-USAR.html.
- Mirrors (gerados): .github/* e .kiro/* (instructions/steering/prompts/skills), COMO-USAR.md.
- Controle: docs/controle/2026-06-17-prompt-sincronizar-doc-codigo/ (TASK, PLANO, LEDGER).

## Fora de escopo (confirmado)
- Sem script de diff (o prompt instrui o assistente a rodar git diff; nao e automacao).
- grill-me importado verbatim (nao editado).
- Outras trilhas/rules alem de arquitetura.

## Pendencia
- Comentario "23 wrappers" no sync-copilot.sh (cabecalho) esta desatualizado vs o real (30). Nao
  tocado nesta task (fora de escopo; e so comentario interno do script). Candidato a limpeza futura.
