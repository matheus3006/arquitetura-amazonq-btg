# ADR-0003 — Biblioteca de skills importadas (cópias verbatim)

- **Status:** aceita
- **Data:** 2026-06-11
- **Autor:** Matheus (com Claude Code)
- **Contexto de origem:** além dos 23 prompts autorais (portes adaptados), o usuário quer
  as melhores Agent Skills disponíveis utilizáveis no BTG, como cópias fiéis — sem
  reescrita, sem achatamento.

## Contexto e problema

Os prompts do pack são PORTES (adaptados a Q/Copilot/Kiro, em PT-BR). Skills originais
completas (superpowers, product/pm/c-level, mattpocock, bencium) têm profundidade que um
porte resume. Faltava um caminho para usá-las inteiras nas três ferramentas, sem que os
syncs (que fazem `rm -rf` das pastas geradas) as apagassem.

## Decisões

1. **Fonte canônica:** `skills/<categoria>/<slug>/` no pack — cópias verbatim
   (`cp -RL`, symlinks resolvidos), nunca editadas; atualizar = recopiar da fonte.
   25 skills em 11 categorias (3 arquitetura, 3 PM, 3 business, 3 planejamento,
   3 backend, 3 frontend, 3 UI/UX, 1 code review, 1 review de arquitetura,
   1 julgar planos, 1 criar planos). Catálogo: `skills/README.md`.
2. **Espelhamento nos geradores:** `sync-copilot.sh` e `sync-kiro.sh` ganham uma passada
   pós-wrappers que copia `skills/*/*/` verbatim para `.github/skills/<slug>/` e
   `.kiro/skills/<slug>/` (achatando a categoria), com guarda de colisão de slug contra
   o manifest. Camadas passam de 23 → 48 skills.
3. **Seleção limitada ao copiável:** plugins "cowork" (engineering:, design:,
   operations:) não têm arquivos no disco (geridos pelo claude.ai) — ficaram de fora.
4. **Invocação:** Kiro e Copilot CLI ativam por descrição (frontmatter validado nas 25);
   Amazon Q e Copilot IDE via mensagem citando `skills/<cat>/<slug>/SKILL.md`
   (cards 24–48 do COMO-USAR). Conteúdo em inglês preservado; cards pedem resposta PT-BR.
5. **Instaladores** copiam `skills/` inteira para os alvos (fonte canônica disponível
   para o Amazon Q referenciar por arquivo).

## Consequências

- (+) Profundidade integral das skills originais nas três ferramentas, sem manutenção
  de conteúdo (só recopiar para atualizar).
- (+) Convivem com os portes: o porte é o fluxo padronizado da casa; a skill importada
  é a versão integral quando se quer o processo completo.
- (−) +3 MB no pack (maior: ui-ux-pro-max, 1.7 MB de catálogos de dados).
- (−) Conteúdo em inglês e com referências a tooling do Claude Code (TodoWrite,
  subagents) que Q/Kiro ignoram — aceito: as instruções de processo dominam o valor.
- (−) Duplicidade conceitual em 4 pares (ex: tdd-disciplinado × test-driven-development,
  grill-plano × challenge) — mitigada pelos cards, que indicam quando usar cada um.

## Validação

Uso real no BTG: se as skills importadas em inglês confundirem o Q (misturar idioma na
resposta, tentar usar ferramentas inexistentes), promover as mais usadas a portes PT-BR
na trilha correspondente e rebaixar a cópia a referência.
