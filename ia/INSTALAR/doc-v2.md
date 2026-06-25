# INSTALAR · Passo 4b — Prepare a documentação existente para a trilha v2 (diagnóstico)

> Sub-página de [`../INSTALAR.md`](../INSTALAR.md). **Só siga isto se já existe doc REAL do
> serviço** (não o exemplo fictício "Liquidação Transacional"). É **só diagnóstico**: você
> NÃO edita nem gera nada — entrega ao usuário um plano do que falta, que apresenta no
> **Passo 5** do INSTALAR.md.

A re-instalação **preserva** a documentação que o usuário já gerou (os `project-context` /
`business-context` nos três destinos e as páginas em `doc/arquitetura/`). A v2 (2026-06-19)
substituiu o fluxo antigo de 3 etapas (`documentar-servico` → `completar-documentacao` →
`grill-arquitetura`) pela **trilha de 7 etapas / 8 sessões** (cada prompt em sessão própria);
`completar-documentacao` foi **aposentado sem stub**. Doc gerada antes da v2 pode estar
incompleta ou divergir do padrão visual. Este passo é **só diagnóstico**: você **NÃO edita nem
gera nada** — entrega ao usuário um plano do que falta e qual ação rodar. Diferente da migração
(`migracao.md`), os scripts **não** fazem isto (exige ler a doc e julgar); é tarefa sua, assistente.

**Primeiro, há doc real a migrar?** Se o `project-context` (nos três destinos) ainda é o exemplo
fictício **"Liquidação Transacional"**, então **não há doc gerada** — siga para o Passo 5 (primeiro
uso normal). Só continue aqui se a doc descreve o **serviço real** do usuário.

| Sinal na doc existente | O que falta | Ação recomendada na v2 |
|---|---|---|
| `project-context` real existe, mas faltam os `business-context.md` (`.amazonq/rules/`, `.github/instructions/business-context.instructions.md`, `.kiro/steering/`) | a fundação de negócio (sessão 1b da Etapa 1/7) | rodar `analisador-de-dominio` (em sessão própria) — apenda Q&A no `QA.md` no mesmo turno |
| Há páginas em `doc/arquitetura/`, mas **sem fluxos críticos** | runtime (Etapa 3/7) | rodar `documentador-fluxo` em sessão nova; apenda entry no NAV de `sidebar.js` no mesmo passo |
| Há páginas, mas **sem runbook** | operação (Etapa 4/7) | rodar `gerador-runbook` em sessão nova; apenda entry no NAV |
| Doc com `⚠ a confirmar`, números redondos ou garantias não resolvidas | auditoria lógica (Etapa 5/7) | rodar `grill-arquitetura` em sessão nova; Q&A no `QA.md` no mesmo turno |
| Doc visualmente fora do padrão (classes fora do design-system, cor hex hardcoded, página órfã do NAV, resíduo do exemplo fictício, Mermaid quebrado, esqueleto HTML errado) | conformidade com a v2 (drift de front/template/Mermaid) | rodar `atualizador-arquitetura` (complementar — fora da trilha; **1 task de controle por execução**; conforma in-place o que é front, abre grill para o que é lógico) |

Regras deste passo:

- **Não** rode as ações você mesmo nem edite a doc — apenas monte o diagnóstico.
- **Não** re-rode a Etapa 1 "do zero" sobre uma doc que já existe (duplicaria/sobrescreveria). Quem
  já tem doc completa **só os blocos que faltam** — é exatamente por isso que cada etapa é um prompt
  isolado (ex.: o `business-context` é preenchido só por `analisador-de-dominio`, sem refazer a
  arquitetura).
- Para **drift de front/template/Mermaid** em doc existente, prefira o `atualizador-arquitetura`:
  ele abre 1 task de controle por execução, conforma in-place o que é visual e abre grill (com
  Q&A no QA.md) para o que é arquitetural.
- A geração roda **depois**, disparada pelo usuário, sob o protocolo de controle (task com TASK.md +
  QA.md + LEDGER.md — abertos ANTES da edição; status vivo).

**Saída:** no fechamento (Passo 5), apresente algo como _"sua doc tem X, falta Y e Z; para alinhar à
trilha v2 de 7 etapas / 8 sessões, rode estas ações nesta ordem: …"_ — ou, se a doc já cobre o
fluxo v2, _"nada a migrar; rode `validador-visual` + `validador-sintaxe-mermaid` para confirmar
conformidade"_.
