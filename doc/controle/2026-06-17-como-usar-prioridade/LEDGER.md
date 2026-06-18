# LEDGER — 2026-06-17-como-usar-prioridade

## Decisoes
- Estrutura: reagrupar por trilha (escolha do usuario), nao so reordenar. Banner de controle +
  "Como invocar" + "Preparar o repositorio" mantidos no topo (gate/onboarding).
- Ordem das trilhas: Arquitetura > Debugging > Escrita de codigo > UI/UX > Negocio > Produto > Combos.
- Realocacoes principais: "Explorar e decidir" (brainstorm, mentalidade, CTO, stress-test, ADR) e
  "Documentar arquitetura" -> **Arquitetura**; "Especificar/Planejar/Atacar/Executar" + code-review +
  verificacao -> **Escrita de codigo**; "Design e frontend" -> **UI/UX**.
- Os dois cards de brainstorm ficaram juntos em Arquitetura (explorar-antes-de-decidir).
- doc-coauthoring entrou em Arquitetura; os 8 cards de dev em Escrita de codigo.
- Cards renomeados pra evitar ambiguidade na nova trilha: "Code review" -> "Code review (template
  cetico)" (skill) ao lado de "Revisar codigo (conduzir a review)" (prompt revisor-de-codigo).

## Evidencias (2026-06-17)
- COMO-USAR.html: 68 <article class="msg-card"> (abre/fecha 68/68), 68 <h3>, 68 <pre class="msg">,
  10 <section> (abre/fecha 10/10 = 1 banner + 9 trilha).
- Ordem das section-eyebrow conferida = ordem alvo.
- Os 9 slugs novos presentes (grep).
- sync-como-usar.sh: COMO-USAR.md regenerado com 68 cards; --check OK (md == html).

## Pendencias
- Fora de escopo (segue pendente): pipeline de 3 etapas de arquitetura (em desenho, aguardando
  aprovacao) e o ajuste de contraste/UI do template (adiado pelo usuario).
