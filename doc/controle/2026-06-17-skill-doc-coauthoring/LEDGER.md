# LEDGER — 2026-06-17-skill-doc-coauthoring

## Decisoes
- Fonte: a skill nao estava nos caches de plugin (superpowers/claude-code-skills/etc.);
  achei em ~/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin/.../
  skills/doc-coauthoring (SKILL.md unico, 16K, sem arquivos de apoio). Copiada verbatim.
- Categoria nova `documentacao` (a skill e sobre co-autoria de doc em geral, nao so arquitetura).
- Proveniencia registrada como `anthropic-skills` no catalogo skills/README.md.

## Evidencias (2026-06-17)
- skills/documentacao/doc-coauthoring/SKILL.md criado (verbatim). skills/ agora: 31 skills, 14 categorias.
- Regen: espelhada em .github/skills e .kiro/skills (57 subpastas cada = 26 wrappers + 31 importadas).
- sync-copilot/sync-kiro/sync-como-usar --check: todos OK.
- grep: nenhuma contagem velha (30/13/56) restante em README/INSTALAR/installers/skills-README.

## Pendencias
- (nenhuma) — fica disponivel para o stack de skills das 3 etapas de doc de arquitetura (em desenho).
