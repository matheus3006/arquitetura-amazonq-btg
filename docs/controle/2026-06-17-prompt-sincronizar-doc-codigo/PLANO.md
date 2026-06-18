# PLANO — 2026-06-17-prompt-sincronizar-doc-codigo

Working-model do pack: canonico -> mirror via tools/sync-*.sh (nunca editar mirror a mao).
Ordem das tarefas pensada p/ o sync rodar UMA vez no fim e cobrir tudo.

## Tarefa 1 — importar a skill grill-me (canonico)
- `cp -R ~/.claude/skills/productivity/grill-me/  skills/arquitetura/grill-me/`
  (so SKILL.md, 635 bytes). Verbatim, sem editar (skill importada, conteudo em ingles).
- skills/README.md: adicionar grill-me na lista de skills importadas (categoria arquitetura).
- Slug "grill-me" nao colide com o manifest (vamos registrar "sincronizar-doc-codigo", outro slug).

## Tarefa 2 — o prompt canonico
`prompts/arquitetura/sincronizar-doc-codigo.md`, no esqueleto do pack (modelo: grill-arquitetura.md):
- `# Prompt — Sincronizar Documentacao com o Codigo`
- `> ## STATUS` — referenciado pela rule arquitetura § 2; standalone (nao e etapa do fluxo de 3);
  diferenca vs grill-arquitetura (gatilho = mudanca de codigo; termina em ADR).
- `## Quando usar` — branch a mergear (ou codigo recem-mergeado) que muda comportamento/estrutura.
- `## Persona` — arquiteto que so confia no diff real; nao documenta o aspiracional.
- `## Stack de skills` — skills/arquitetura/grill-me (motor), human-architect-mindset (dimensoes),
  prompts/arquitetura/gerador-adr.md (Fase D), skills/backend/verification-before-completion
  (codigo/evidencia antes de afirmar).
- `## Metodologia — fases com gate`:
  - Fase 0 Escopo: `git diff main...HEAD` -> lista arquivos/modulos; MOSTRA e confirma. Nota:
    pos-merge = rodar de um checkout do ponto anterior.
  - Fase A Codigo (primeiro o codigo): le o diff -> inventario "mudanca -> efeito arquitetural ->
    pagina de doc afetada -> a incerteza/o porque". Gate: inventario montado.
  - Fase B Grill (grill-me + HAM): uma pergunta por vez, ledger ✓/▸/○, resposta recomendada,
    codigo-antes-de-perguntar; HAM escolhe as dimensoes. Gate: ledger zerado (porque de cada
    mudanca ✓ ou [a confirmar]).
  - Fase C Doc: atualiza inline as paginas afetadas + project-context (3 destinos) se stack/padroes
    mudaram; fiel ao codigo + porque; ⚠ nas pendencias. Gate: doc batendo com o diff.
  - Fase D ADR: le docs/<servico>/adr/ -> candidatas; existe -> linka na doc; nao existe ->
    pergunta; se sim, encadeia gerador-adr.md com o contexto ja capturado. Gate: decisao registrada
    ou referenciada.
- `## Regras` — codigo antes de pergunta; nada aspiracional; execucao sob protocolo de controle.
- `## Anti-padroes` — documentar intencao em vez do diff; pular o grill; criar ADR duplicada.
- `## Saida esperada` — paginas atualizadas + project-context (se aplicavel) + ADR nova/linkada,
  com o porque registrado.
- `## Exemplo de invocacao` + `## Referencias` (gerador-adr, grill-arquitetura, human-architect-mindset).

## Tarefa 3 — registro nos canonicos de roteamento
- `tools/manifest.tsv`: linha (TAB-separada) na regiao de arquitetura:
  `sincronizar-doc-codigo<TAB>arquitetura<TAB>Atualiza a doc a partir do diff da branch: analisa o codigo, grilla o porque (grill-me + human-architect-mindset) e registra ADR quando a mudanca nao partiu de uma ADR existente`
- `.amazonq/rules/architecture-style.md` § 2 (mapa gatilho -> prompt): nova linha
  `| "sincronizar a doc com o codigo", "atualizar doc apos mudanca/merge", "documentar o que mudou na branch" | prompts/arquitetura/sincronizar-doc-codigo.md |`

## Tarefa 4 — sync (gera todos os mirrors)
- `bash tools/sync-copilot.sh` e `bash tools/sync-kiro.sh` -> wrappers do prompt (.github/prompts,
  .github/skills, .kiro/skills), grill-me espelhado (cp -R verbatim), architecture-style mirror.
- `--check` de ambos = exit 0.

## Tarefa 5 — COMO-USAR
- `COMO-USAR.html`: card novo na trilha Arquitetura, inserido APOS "Grill intenso de arquitetura
  (Etapa 3/3)" (as 3 etapas sao "criar do zero"; este e "manter em dia quando o codigo muda").
  h3 "Sincronizar doc com o codigo"; quando "Branch a mergear (ou codigo recem-mergeado)..."; msg
  no padrao (Objetivo / Siga todo o processo de prompts/arquitetura/sincronizar-doc-codigo.md: ... /
  Pronto quando); slug `Copilot IDE: /sincronizar-doc-codigo`.
- `bash tools/sync-como-usar.sh` + `--check`.

## Verificacao (fechamento)
- Prompt referenciavel pelos 3 caminhos: .github/prompts/sincronizar-doc-codigo.prompt.md,
  .github/skills/sincronizar-doc-codigo/SKILL.md, .kiro/skills/sincronizar-doc-codigo/ existem.
- grill-me espelhado em .github/skills/grill-me e .kiro/skills/grill-me (verbatim, sem colisao).
- sync-copilot --check, sync-kiro --check, sync-como-usar --check = OK.
- COMO-USAR.md: contagem de cards = atual+1; manifest tem o slug 1x.

## Fora de escopo
- Implementar a deteccao de diff em codigo/script (o prompt instrui o assistente a rodar git diff;
  nao e um script).
- Editar o conteudo do grill-me (importado verbatim).
- Outras trilhas/rules alem de arquitetura.
