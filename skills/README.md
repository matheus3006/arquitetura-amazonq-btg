# skills/ — biblioteca de skills importadas (cópias verbatim)

Cópias fiéis de Agent Skills (padrão aberto `SKILL.md`) selecionadas como as melhores
disponíveis por categoria. **Nunca edite estes arquivos** — são espelhos das fontes;
atualização = recopiar da fonte. O conteúdo é em inglês (original preservado).

## Como usar

| Ferramenta | Como invocar |
|---|---|
| Kiro (IDE/CLI) | Automático — a skill ativa quando seu pedido casa com a `description` (espelhadas em `.kiro/skills/`) |
| Copilot CLI | Automático — espelhadas em `.github/skills/` |
| Copilot IDE / Amazon Q | Mensagem citando o arquivo: "Siga TODO o processo descrito em `skills/<categoria>/<slug>/SKILL.md`" |

Mensagens prontas para cada uma: `COMO-USAR.html` (raiz do repo, seção "Biblioteca de skills").

`.github/skills/` e `.kiro/skills/` são GERADOS por `tools/sync-copilot.sh` /
`tools/sync-kiro.sh` — que copiam esta pasta verbatim além dos 23 wrappers do pack.
Editar aqui + rodar os dois syncs = camadas atualizadas.

## Catálogo (25)

| Categoria | Skill | Fonte | O que entrega |
|---|---|---|---|
| arquitetura | `human-architect-mindset` | local (.agents) | pensamento arquitetural sistêmico: domínio, restrições, decomposição |
| arquitetura | `cto-advisor` | c-level-skills | conselheiro técnico-estratégico: stack, dívida, build-vs-buy |
| arquitetura | `brainstorming` | superpowers | exploração de intenção/requisitos/design ANTES de construir |
| pm | `senior-pm` | pm-skills | ofício de PM sênior: priorização, stakeholders, discovery→delivery |
| pm | `product-manager-toolkit` | product-skills | caixa de ferramentas de PM: frameworks, métricas, rituais |
| pm | `product-discovery` | product-skills | descoberta de produto: hipóteses, entrevistas, validação |
| business | `product-strategist` | product-skills | estratégia de produto: posicionamento, mercado, apostas |
| business | `competitive-teardown` | product-skills | análise estruturada de concorrente (12 dimensões, SWOT, pricing) |
| business | `stress-test` | executive-mentor | stress-test de premissas de negócio |
| planejamento | `executing-plans` | superpowers | execução disciplinada de plano escrito, com checkpoints |
| planejamento | `scrum-master` | pm-skills | cerimônias e fluxo ágil: sprint, retro, impedimentos |
| planejamento | `to-issues` | local (mattpocock) | quebra plano/PRD em issues rastreáveis |
| backend | `test-driven-development` | superpowers | TDD integral: lei de ferro, red-green-refactor |
| backend | `systematic-debugging` | superpowers | debugging em 4 fases: causa raiz com evidência antes do fix |
| backend | `verification-before-completion` | superpowers | evidência antes de afirmar "pronto" — sempre |
| frontend | `emil-design-eng` | local | polish de UI à Emil Kowalski: animação, detalhes invisíveis |
| frontend | `ui-typography` | local (.agents) | tipografia profissional pra UI: regras que LLMs erram |
| frontend | `bencium-impact-designer` | local (.agents) | frontend de alto impacto visual, anti-estética-genérica-de-IA |
| ui-ux | `ui-ux-pro-max` | local | inteligência UI/UX: 50+ estilos, 161 paletas, 99 guidelines |
| ui-ux | `design-audit` | local (.agents) | auditoria visual sistemática + plano de refinamento em fases |
| ui-ux | `bencium-controlled-ux-designer` | local (.agents) | decisões de UX propostas uma a uma, com aprovação |
| code-review | `requesting-code-review` | superpowers | revisão de código rigorosa via template de revisor cético |
| arquitetura-review | `improve-codebase-architecture` | local (mattpocock) | review da ARQUITETURA do código: acoplamento, costuras, módulos |
| julgar-planos | `challenge` | executive-mentor | pre-mortem de plano: ataca o plano antes de executar |
| criar-planos | `writing-plans` | superpowers | escrita de planos executáveis por quem não conhece o código |

## Licenças e origem

Superpowers (obra/Jesse Vincent, MIT) · claude-code-skills marketplace (pm/product/c-level/executive-mentor) ·
skills locais (mattpocock, bencium, comunidade). Uso interno. Versões congeladas na data da cópia
(2026-06-11); ver histórico git para atualizações.
