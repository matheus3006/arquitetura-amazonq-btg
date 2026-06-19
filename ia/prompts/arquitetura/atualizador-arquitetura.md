# Atualizador de Arquitetura (complementar — doc já existente)

**STATUS — leia ANTES de responder:**
- Este prompt é **complementar** (fora da trilha numerada 1→7). Use-o em **doc já existente** que precisa ser conformada às novas regras (v2).
- Roda em **sessão própria** (regra master).
- Abre **1 task de controle por execução** cobrindo toda a pasta `doc/arquitetura/` analisada (decisão #10 do spec).
- Diferente dos validadores #6/#7: o atualizador **pode editar** (é quem aplica correções de drift de front in-place).

## Pré-requisito (uma vez por execução)

Abra a task de controle ANTES de editar qualquer artefato. Derive um slug kebab-case (ex.: `atualizar-doc-arquitetura`), monte o task-id `AAAA-MM-DD-<slug>` e crie:
- `doc/controle/<task-id>/TASK.md` (escopo + ACs + checklist).
- `doc/controle/<task-id>/QA.md` (vazio com o cabeçalho do template — preenchido na hora em cada pergunta respondida).
- `doc/controle/<task-id>/LEDGER.md` (decisões + evidências, ao final).

## O que você faz

Ordem proposta (coerente com a ramificação aprovada em QA.md verbatim):

1. **Diagnóstico geral** — varra `doc/arquitetura/` e classifique cada problema encontrado por tipo:
   - **Drift de FRONT (UI/UX / template / classes / Mermaid / NAV / resíduo do exemplo).**
   - **Drift LÓGICO (arquitetural — incertezas, garantias não resolvidas, lacuna de conteúdo).**

2. **Compara com template** — `ia/templates/01-visao-geral.html` (página de conteúdo) e `index.html` (landing) são o gabarito de FORMA.

3. **Roda validadores embutidos** — execute internamente as regras de §5.1 (front) e §5.2 (mermaid). Tente:
   - `bash ia/tools/validar-doc.sh doc/arquitetura/ --all`
   - exit 0 → nenhum drift de front; exit 1 → use o stdout como lista de correções; exit 2 ou indisponível → fallback (leia direto).

4. **Ramifica por tipo** (verbatim QA.md):
   - **Drift de FRONT** → escreva um **plano de ajuste** como seção `## Plano de ajuste de front` no `TASK.md` da task, depois **CONFORME in-place** (você está autorizado a editar). Após cada correção, marque `[x]` no checklist do TASK.md.
   - **Drift LÓGICO** → abra um **grill** (use o protocolo de `grill-arquitetura.md`): pergunta-uma-por-vez ao usuário. Para CADA pergunta, **apenda no QA.md no mesmo turno** em que a resposta chega (status vivo). Verbatim quando houver decisão; normalizada caso contrário (formato em `controle-de-tarefa.md`).

5. **Verificação final** — re-rode `validar-doc.sh --all`; só feche a task com exit 0 (ou checklist textual sem FAILs).

## Saídas

- Edições in-place em `doc/arquitetura/*.html` (drift de front).
- `doc/controle/<task-id>/TASK.md` com fase=concluida e checklist marcado.
- `doc/controle/<task-id>/QA.md` com todo o grilling.
- `doc/controle/<task-id>/LEDGER.md` com decisões + evidências.

## NÃO faz

- Não gera páginas novas do zero (isso é a trilha 1→7).
- Não move arquivos entre pastas sem grilling.
- Não pergunta o slug — derive do pedido.
