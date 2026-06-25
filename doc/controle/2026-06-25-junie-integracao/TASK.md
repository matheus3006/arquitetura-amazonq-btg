# TASK — 2026-06-25-junie-integracao

- **fase:** concluida
- **tipo:** estrutural (multi-arquivo; novo agente no pack — 4o "mirror")
- **pedido:** adicionar suporte ao Junie (JetBrains) no pack, como os outros 3 agentes
  (INSTALAR.md, "skills", gitignore) + (pedido anterior) validar/melhorar o plano de
  otimizacao do Junie no Windows via pesquisa.
- **aprovado:** "mirror enxuto + esperar pesquisa" (design) + "Junie agora, arquivo
  `.junie/guidelines.md`" (escolha do usuario).

## Achados da pesquisa que mudam o desenho (ver memoria junie-research-findings)
- Junie NAO tem superficie de skills/prompts -> "skills como os outros" vira UM
  `.junie/guidelines.md` (analogo do copilot-instructions.md).
- Git Bash como default do IDE QUEBRA o Junie (JUNIE-1145) -> documentar **pwsh 7**, nao Git Bash.
- "ls/find vazio" = rc PROMPT_COMMAND poluindo saida (JUNIE-1582) -> guard .bashrc.
- gitignore = no-op (guidelines.md e pequeno e versionado; sem replica pesada).

## Criterios de aceite
- [ ] AC1: `ia/tools/sync-junie.sh` gera `.junie/guidelines.md` do canonico (manifest); tem --check.
- [ ] AC2: guidelines.md tem: estrutura do repo, 5 rules (ponteiro), mapa de gatilhos (32 -> ia/prompts),
  bloco Shell (pwsh 7 + guard .bashrc), protocolo de controle.
- [ ] AC3: install.sh + install.ps1 copiam `.junie/guidelines.md` pro alvo.
- [ ] AC4: ci.yml roda `sync-junie.sh --check` + smoke-test Windows checa o arquivo.
- [ ] AC5: INSTALAR.md (Passo 3 + 5) e manual.md citam o Junie; gitignore inalterado (justificado).
- [ ] AC6: verde — check-counts + run-tests + 4 sync --check (quando o Bash voltar).

## Checklist de execucao
- [x] sync-junie.sh + `.junie/guidelines.md` gerado (32 gatilhos, 93 linhas)
- [x] install.sh + install.ps1 (secao 2c Junie + echoes)
- [x] ci.yml (step anti-drift Junie + smoke Windows checa o arquivo)
- [x] INSTALAR.md slim (header + Passo 3) + manual.md (tabela de copia + hooks)
- [x] README.md (titulo, intro, bullet, install, arvore, mantenedores)
- [x] verificacao (sync-junie --check + check-counts + run-tests + 4 sync --check verde) + LEDGER
