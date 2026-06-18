# TASK — 2026-06-17-skills-dev-debug

- **fase:** concluida
- **tipo:** normal
- **pedido:** ampliar o pack com mais "scripts" de desenvolvimento e debug — importar um
  range maior de skills + criar prompts autorais pras lacunas. (Desenho aprovado pelo usuario.)

## Criterios de aceite
- [x] 5 skills importadas verbatim em skills/<cat>/ (2 categorias novas: fluxo-dev, orquestracao).
- [x] 3 prompts autorais no estilo do pack (fases + gate + refs + tabela de invocacao).
- [x] engenharia-style § 1 roteia os 3; § 3 nao contradiz mais as skills importadas.
- [x] manifest com 26 linhas; sync coverage OK (prompts == manifest == 26).
- [x] Contagens atualizadas (25->30 skills, 11->13 cat, 23->26 wrappers, 48->56, 69->78) em README/INSTALAR/installers.
- [x] sync --check (copilot/kiro/como-usar) todos OK.

## Checklist de execucao
- [x] importar as 5 skills (cp -R verbatim)
- [x] escrever refatorador-incremental.md
- [x] escrever estrategista-de-testes.md
- [x] escrever revisor-de-codigo.md
- [x] manifest.tsv: +3 linhas (engenharia)
- [x] engenharia-style.md: +3 rows no § 1, reescrever § 3
- [x] sync-copilot + sync-kiro
- [x] skills/README.md: catalogo (+5 skills, +2 cat, proveniencia, contagens)
- [x] contagens em README.md, INSTALAR.md, install.sh, install.ps1
- [x] verificacao final (--check x3, coverage, contagens, ls dos novos dirs)

## Pendencia (fora do escopo aprovado — opcional)
- COMO-USAR.html nao ganhou cards para os 8 novos itens (3 prompts + 5 skills). Eles ja
  funcionam por linguagem natural e slash command; os cards sao so conveniencia.
