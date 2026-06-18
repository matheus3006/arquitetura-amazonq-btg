# TASK — 2026-06-17-prompt-sincronizar-doc-codigo

- **fase:** concluida
- **tipo:** feature do pack (novo prompt + skill importada + wrappers + card)
- **pedido:** prompt que, numa branch a mergear, ANALISA o codigo novo, faz um GRILL
  (grill-me + human-architect-mindset, com o HAM controlando as dimensoes) pra entender o
  PORQUE das mudancas, ATUALIZA a doc afetada e pergunta sobre ADR (encadeando o gerador-adr
  quando a mudanca nao partiu de uma ADR existente).

## Design fechado no brainstorming (4 forks)
1. Nome/slug: `sincronizar-doc-codigo`, trilha `arquitetura`.
2. Input: SEMPRE `git diff main...HEAD` (branch vs main; pos-merge = rodar de um checkout
   do ponto anterior — nota no prompt, sem complicar).
3. Motor do grill: IMPORTAR `grill-me` da superpowers (verbatim) + `human-architect-mindset`
   controlando as dimensoes (invariante, modo de falha, ordem temporal, escala).
4. Alcance da doc: ATUALIZA inline as paginas afetadas + project-context (se stack/padroes
   mudaram) + ADR. Fluxo: codigo -> grill -> doc atualizada -> ADR.
5. Deteccao de ADR: hibrida — busca em docs/<servico>/adr/, mostra candidatas, confirma.

## Fluxo do prompt (5 fases com gate)
- Fase 0 Escopo: `git diff main...HEAD` -> lista arquivos/modulos, mostra e confirma.
- Fase A Codigo: le o diff de verdade -> mapeia "mudanca no codigo -> o que muda na
  arquitetura -> pagina de doc afetada -> a incerteza (o porque)".
- Fase B Grill: grill-me + HAM, ja com o contexto do codigo. Uma pergunta por vez, ledger,
  codigo-antes-de-perguntar. Captura o PORQUE. Gate: ledger zerado.
- Fase C Doc: atualiza inline as paginas afetadas + project-context (3 destinos) se aplicavel,
  fiel ao codigo + ao porque; ⚠ onde o grill deixou pendencia.
- Fase D ADR: le docs/<servico>/adr/, cruza com os temas do grill. Ja existe ADR -> linka.
  Nao existe -> pergunta; se sim, encadeia prompts/arquitetura/gerador-adr.md com o contexto.

## Criterios de aceite
- [x] prompts/arquitetura/sincronizar-doc-codigo.md no esqueleto do pack (as 5 fases com gate).
- [x] skills/arquitetura/grill-me/SKILL.md = copia verbatim (635 bytes), idem nos 2 mirrors.
- [x] skills/README.md lista o grill-me (catalogo 31->32; wrappers 29->30; data 2026-06-18).
- [x] tools/manifest.tsv com a linha `sincronizar-doc-codigo` (1x; total 30 slugs).
- [x] .amazonq/rules/architecture-style.md § 2 com o gatilho -> prompt novo.
- [x] sync-copilot + sync-kiro rodados: 30 prompt files + 30 wrappers + 32 skills importadas;
      grill-me espelhado identico nos 2; architecture-style mirror atualizado. --check OK (ambos).
- [x] COMO-USAR.html: card apos a Etapa 3/3 + COMO-USAR.md regenerado (70->71 cards). --check OK.
- [x] Verificacao: prompt nos 3 caminhos (.github/prompts, .github/skills, .kiro/skills);
      grill-me sem colisao; 3 sync --check = OK.

## Checklist de execucao
- [x] skills/arquitetura/grill-me/SKILL.md (copia verbatim) + skills/README.md
- [x] prompts/arquitetura/sincronizar-doc-codigo.md (novo)
- [x] tools/manifest.tsv (linha nova) + .amazonq/rules/architecture-style.md (gatilho)
- [x] sync-copilot.sh + sync-kiro.sh + --check de ambos
- [x] COMO-USAR.html (card) + sync-como-usar.sh + --check
- [x] verificacao final (3 caminhos do prompt, grill-me espelhado, contagens)
