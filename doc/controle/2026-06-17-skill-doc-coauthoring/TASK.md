# TASK — 2026-06-17-skill-doc-coauthoring

- **fase:** concluida
- **tipo:** trivial
- **pedido:** adicionar a skill `doc-coauthoring` (anthropic-skills) ao pacote de copias
  (skills/), pra poder invoca-la — em especial no stack de qualidade dos prompts de doc.

## Criterios de aceite
- [x] skills/documentacao/doc-coauthoring/SKILL.md (verbatim da fonte) existe.
- [x] catalogo skills/README.md atualizado (+1 skill, categoria nova `documentacao`, proveniencia).
- [x] contagens (30->31 skills, 13->14 cat, 56->57) em README/INSTALAR/installers.
- [x] sync-copilot/kiro --check OK; skill espelhada em .github/.kiro (57 cada).

## Checklist
- [x] cp -R verbatim -> skills/documentacao/doc-coauthoring
- [x] skills/README.md (catalogo + contagens + proveniencia)
- [x] contagens em README.md, INSTALAR.md, install.sh, install.ps1
- [x] sync-copilot + sync-kiro
- [x] verificacao (--check x3, espelhada, sem contagem velha)
