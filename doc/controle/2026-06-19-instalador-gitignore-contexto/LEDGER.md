# Ledger — instalador-gitignore-contexto

## Decisões
- 2026-06-19 — Iniciativa E do roadmap de melhorias A/B/D/E (aprovado nesta sessão).
- 2026-06-19 — Instalador edita o `.gitignore` por padrão (bloco marcado idempotente) — escolha do usuário, não flag/print.
- 2026-06-19 — Política: IGNORA réplicas pesadas (`.github/skills`, `.github/prompts`, `.kiro/skills`, `ia/skills` ~9,5 MB);
  MANTÉM versionada a config minúscula (rules/instructions/steering/hooks ~200 KB) + contexto por-produto + `doc/`.
- 2026-06-19 — Contexto por-produto (`project-context`/`business-context`) passa a ser VERSIONADO (fluxo multi-autor + custo de regerar); corrige README que dizia "não versionar".
- 2026-06-19 — Instalação seletiva por assistente DESCARTADA: na mesma equipe cada pessoa usa um assistente diferente → precisa das 3 camadas.
- 2026-06-19 — Conteúdo do bloco numa SoT única (`ia/tools/lib/gitignore-pack-block.txt`) lida por sh e ps1, para evitar drift entre os dois instaladores. (Pendente confirmação na aprovação.)

## Verificação
- AC1/AC2: `seed-gitignore.sh` em temp 2× → 1 bloco; miolo `diff` == SoT; `node_modules/` preservado — passed
- AC2 (install): `install.sh <temp>` 2× → 1 bloco no `.gitignore`; helper+SoT entregues em `ia/tools/` — passed
- AC3: `install.ps1` §9 revisão estática (pwsh indisponível) — lógica/marcadores idênticos ao bash, lê a mesma SoT — passed
- AC4: `grep 'não versionar' README.md` → vazio; nota "clonou → instala 1×" em README e ia/INSTALAR.md — passed
- AC5: `run-tests.sh` → PASS=19 FAIL=0; `sync-{copilot,kiro,como-usar}.sh --check` → OK (sem drift) — passed

## Pendências
- Commit: aguardando "pode commitar" do usuário (não commito sem pedido explícito).
- AC3 não exercitado em runtime Windows (pwsh ausente no ambiente) — só revisão estática.
- Bloco no install.ps1 grava com `Set-Content -Encoding utf8` (BOM no Windows PowerShell 5.1) — inócuo p/ git; validar quando houver pwsh.
