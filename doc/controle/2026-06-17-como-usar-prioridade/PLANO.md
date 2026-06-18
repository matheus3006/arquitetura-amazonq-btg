# PLANO — reorganizacao do COMO-USAR por prioridade de trilha

## Nova ordem de secoes (topo -> base)

**Topo (meta/onboarding, mantem posicao):**
0. ⚠ Banner: regra do protocolo de controle
1. Como invocar, por ferramenta
2. Antes de tudo: preparar o repositorio (Preparar repo + Mapear dominio) — gate

**Trilhas por prioridade:**

### 1. Arquitetura
Visao geral · Fluxo tecnico · Runbook · Registrar ADR · Revisar doc (grill-doc) ·
Brainstorm arquitetural · Mentalidade de arquiteto · Conselheiro CTO · Stress-test ·
Review de arquitetura do codigo · **[novo] Co-autoria de doc (doc-coauthoring)**

### 2. Debugging
Investigar bug (causa raiz) · Debugging sistematico

### 3. Escrita de codigo
Spec · Plano de implementacao · Criar plano executavel · Plano vira issues ·
Grill do plano · Julgar plano · Abrir task (controle) · Executar plano · Executar com
checkpoints · TDD · TDD integral · Code review (requesting) · Verificacao antes de concluir ·
**[novos] Refatorador incremental · Estrategista de testes · Revisor de codigo (executor) ·
Receber code review · Worktrees git · Fechar a branch · Dev orientada a subagentes ·
Agentes em paralelo**

### 4. UI/UX
Direcao visual · Inteligencia de design · Melhorar visual · UX controlado · Design system ·
Auditoria de design · Polir · Polish a Emil · Tipografia · Interface de alto impacto

**Demais:**
### 5. Documentar o negocio
Grill do negocio · Fluxo de negocio · Catalogo de regras · Glossario

### 6. Produto e gestao
PM senior · Toolkit · Discovery · Estrategista de produto · Teardown · Scrum master

### 7. Combos — pipelines de skills (os 11, inalterados)

## Cards novos (9) — formato igual aos demais (Quando + <pre class="msg"> + footer)
- Escrita de codigo (8): refatorador-incremental, estrategista-de-testes, revisor-de-codigo
  (prompts) + receiving-code-review, using-git-worktrees, finishing-a-development-branch,
  subagent-driven-development, dispatching-parallel-agents (skills).
- Arquitetura (1): doc-coauthoring (skill).

## Execucao
1. Ler COMO-USAR.html inteiro (formato exato dos cards).
2. Reescrever o body na nova ordem, realocando cada card e inserindo os 9 novos.
3. Preservar head/CSS/rodape e o conteudo exato de cada card existente.
4. sync-como-usar.sh -> regenera COMO-USAR.md; --check.
5. Conferir: nenhum card perdido (>= atual+9), ordem correta, ferramentas/skill footers.

## Maior risco
Rewrite de 70KB: perder um card ou quebrar o HTML. Mitigacao: inventario de cards antes/depois
(contagem por <h3>/<pre class="msg">), e --check do sync.
