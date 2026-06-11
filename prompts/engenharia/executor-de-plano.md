# Prompt — Executor de Plano

> ## STATUS
>
> Parte da **trilha de engenharia** do pack. Referenciado pela rule da trilha `engenharia` § 1
> (`.amazonq/rules/engenharia-style.md` ou `.github/instructions/engenharia-style.instructions.md`, conforme a ferramenta).
>
> Roda **depois** do plano aprovado (`planejador-de-implementacao.md`, idealmente grillado
> pelo `grill-plano.md`). No protocolo de controle, é a disciplina do **turno 2**.

Clona o comportamento da skill `superpowers:executing-plans`, sem orquestração de
subagentes/worktrees (fora do alcance destas ferramentas).

## Quando usar
- "executa o plano", "implementa o plano aprovado", "segue o plano".
- Turno 2 do protocolo de controle (após o "aprovado" do usuário).

## Pré-requisito (gate de entrada)

Existe um plano escrito e aprovado, com etapas no formato do planejador (arquivos, mudança,
verificação, pronto-quando). Não existe → pare e sugira `planejador-de-implementacao.md`.
Plano existe mas nunca foi desafiado → sugira 1x o `grill-plano.md`; se o usuário declinar, siga.

## Metodologia — 3 passos

### Passo 1 — Carregar e revisar criticamente
Leia o plano inteiro UMA vez antes de tocar em qualquer arquivo. Procure: etapa sem
verificação, premissa que o código atual contradiz, dependência fora de ordem.
- **Achou problema crítico** (impede começar) → reporte TODAS as preocupações num bloco
  único e espere — não comece com furo conhecido.
- **Sem problemas** → liste as etapas como checklist (no protocolo de controle: o checklist
  do `TASK.md`) e comece.

### Passo 2 — Executar etapa por etapa
Para cada etapa, nesta ordem, sem pular:
1. Marque a etapa como em andamento no checklist.
2. Siga a etapa **exatamente como escrita**. O plano decide; você executa.
3. Rode a verificação da etapa e **mostre o output real** (disciplina de conclusão,
   `engenharia-style.md` § 2). Verificação falhou → conserte antes de avançar.
4. Marque concluída. Próxima.

**Regra de desvio** (a realidade divergiu do plano):
- Desvio **mecânico** (arquivo renomeado, assinatura ligeiramente diferente, import a mais):
  adapte, registre 1 linha (no protocolo de controle: `LEDGER.md` § Decisões) e siga.
- Desvio que **muda uma decisão do plano** (abordagem não funciona, contrato é outro,
  efeito colateral não previsto): **PARE**. Não force, não adivinhe.

### Passo 3 — Fechamento
Após a última etapa: rode a validação de ponta a ponta do plano (a etapa final do
planejador). Relate em 3 blocos: **o que passou** (com evidência) · **o que falhou**
(com output, sem maquiar) · **o que foi pulado/adaptado** (com motivo). No protocolo de
controle: evidências no `LEDGER.md`, ACs marcados, `fase: concluida`.

## Quando PARAR e perguntar

Pare imediatamente quando: bloqueio externo (dependência ausente, acesso negado) ·
instrução do plano incompreensível · verificação falhando após 2 tentativas honestas ·
desvio de decisão (regra acima). Ao parar: junte **TODAS** as dúvidas num bloco único
(cada ida-e-volta custa cota) e proponha sua recomendação para cada uma.

**Plano atualizado pelo usuário no meio?** Volte ao Passo 1 — revise o plano novo inteiro
antes de continuar.

## Anti-padrões a recusar

- ❌ "Melhorar" o plano durante a execução (refactor extra, feature a mais) — execute o aprovado.
- ❌ Pular a verificação de uma etapa "porque é simples".
- ❌ Declarar etapa concluída sem output de verificação na mesma resposta.
- ❌ Forçar através de bloqueio com suposição.
- ❌ Parar a cada etapa pra pedir confirmação que o plano aprovado já deu.

## Saída esperada

Código implementado etapa por etapa, checklist atualizado em tempo real, e o relatório de
fechamento em 3 blocos (passou / falhou / adaptado) com evidências.

## Exemplo de invocação

> O plano `docs/planos/2026-06-11-idempotencia-redis.md` foi aprovado. Use
> `prompts/engenharia/executor-de-plano.md`: execute etapa por etapa, verificação por
> etapa, e pare se algo divergir de decisão do plano.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/executor-de-plano` |
| Copilot CLI | Gatilho natural ("executa o plano") — a instruction roteia |
| Kiro (IDE / CLI) | Gatilho natural — a Agent Skill ativa por descrição |

## Referências
- O plano que ele executa: `prompts/engenharia/planejador-de-implementacao.md`.
- Antes de aprovar: `prompts/engenharia/grill-plano.md`.
- Etapas de código test-first: `prompts/engenharia/tdd-disciplinado.md`.
- Quebrou no meio: `prompts/engenharia/depurador-sistematico.md`.
- Turnos, checklist e LEDGER: `prompts/engenharia/controle-de-tarefa.md`.
