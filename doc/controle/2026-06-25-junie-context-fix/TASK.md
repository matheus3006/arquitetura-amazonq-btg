# TASK — 2026-06-25-junie-context-fix

- **fase:** concluida
- **tipo:** trivial (follow-up da integracao Junie; 2 canonicos + regeneracao)
- **pedido:** fechar 2 lacunas de completude do Junie no pack: (1) o guidelines.md nao
  mandava o Junie ler o project/business-context do servico (gate-critico; os outros 3
  agentes carregam automatico); (2) Passo 5 do INSTALAR.md nao citava o Junie.

## Criterios de aceite
- [x] AC1: sync-junie.sh injeta no guidelines.md um bloco "Contexto do servico" mandando ler
  `.amazonq/rules/{project,business}-context.md` (com o gate "sem project-context, nao gere doc").
- [x] AC2: INSTALAR.md Passo 5 cita o Junie (gatilho via guidelines) + nota "Junie le o do .amazonq/rules/".
- [x] AC3: regenerar .junie/guidelines.md; sync-junie --check + check-counts + run-tests verde.

## Checklist
- [x] editar sync-junie.sh (bloco contexto) + INSTALAR.md (Passo 5)
- [x] regenerar guidelines.md + verificar (32 gatilhos; 93->101 ln; tudo exit 0)
- [x] LEDGER + commit + push
