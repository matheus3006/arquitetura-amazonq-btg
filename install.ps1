#requires -Version 5
<#
  install.ps1 - instala o pack arquitetura (Amazon Q + GitHub Copilot) num repositorio de servico.

  Uso (PowerShell / pwsh - Windows, macOS ou Linux):
    pwsh install.ps1                          # instala no diretorio atual
    pwsh install.ps1 -Target C:\repos\servico
    pwsh install.ps1 -NoExamples              # NAO inclui as paginas HTML de exemplo

  Copia: .amazonq/rules/ (5 rules) + .github/ (camada Copilot) + .kiro/ (camada Kiro:
           steering + Agent Skills) + prompts/ (4 trilhas) + skills/ (biblioteca de
           31 skills importadas)
         + COMO-USAR.html (raiz) + docs/arquitetura/ (css do design system, js dos
           templates e paginas HTML de exemplo — referencia de FORMA pros prompts;
           nunca sobrescreve arquivo ja existente no alvo)
         + hooks de inicio de interacao do protocolo de controle (.amazonq/cli-agents/
           + .amazonq/hooks/ + .kiro/hooks/) — orientam o agente a abrir a task; NAO bloqueiam commit
  NAO copia: arquivos de contexto por-servico (project/business-context nos tres lados)
         nem os foundation files do Kiro (product/tech/structure.md).
#>
param(
  [string]$Target = (Get-Location).Path,
  [switch]$NoExamples,
  [switch]$WithExamples  # aceito por compatibilidade - exemplos ja sao o padrao
)
$ErrorActionPreference = 'Stop'

if ($args.Count -gt 0) {
  Write-Host "[erro] Argumentos nao reconhecidos: $($args -join ', '). Use -Target <repo> [-WithExamples]."
  exit 1
}

$PackDir = $PSScriptRoot
try {
  $Target = (Resolve-Path -LiteralPath $Target -ErrorAction Stop).Path
} catch {
  Write-Host "[erro] Alvo nao existe: $Target"
  exit 1
}
$seps = [char[]]@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$Target  = $Target.TrimEnd($seps)
$PackDir = $PackDir.TrimEnd($seps)

if ($Target -eq $PackDir) {
  Write-Host "[erro] O alvo e o proprio pack. Aponte pro repo do SERVICO:"
  Write-Host ("       pwsh `"" + (Join-Path $PackDir 'install.ps1') + "`" -Target <repo>")
  exit 1
}

Write-Host "[pack] arquitetura (Amazon Q + Copilot + Kiro) -> $Target`n"

# 1) Rules Amazon Q (nunca tocamos *-context.md)
$rulesDst = Join-Path $Target '.amazonq/rules'
New-Item -ItemType Directory -Force -Path $rulesDst | Out-Null
if (Test-Path (Join-Path $rulesDst 'architecture-style.md')) {
  Write-Host "  i  Instalacao existente - atualizo as rules (arquivos de contexto ficam intactos)."
}
foreach ($f in 'architecture-style.md','frontend-style.md','negocio-style.md','engenharia-style.md','controle-style.md') {
  Copy-Item (Join-Path $PackDir ".amazonq/rules/$f") (Join-Path $rulesDst $f) -Force
  Write-Host "  + .amazonq/rules/$f"
}

# 2) Camada Copilot (nunca tocamos *-context.instructions.md)
$ghDst = Join-Path $Target '.github'
foreach ($d in 'instructions','prompts','skills') {
  New-Item -ItemType Directory -Force -Path (Join-Path $ghDst $d) | Out-Null
}
Copy-Item (Join-Path $PackDir '.github/copilot-instructions.md') (Join-Path $ghDst 'copilot-instructions.md') -Force
Write-Host "  + .github/copilot-instructions.md"
foreach ($f in 'architecture-style','frontend-style','negocio-style','engenharia-style','controle-style') {
  Copy-Item (Join-Path $PackDir ".github/instructions/$f.instructions.md") (Join-Path $ghDst "instructions/$f.instructions.md") -Force
}
Write-Host "  + .github/instructions/ (5 instructions)"
Copy-Item (Join-Path $PackDir '.github/prompts/*') (Join-Path $ghDst 'prompts') -Recurse -Force
Copy-Item (Join-Path $PackDir '.github/skills/*')  (Join-Path $ghDst 'skills')  -Recurse -Force
Write-Host "  + .github/prompts/ (29 wrappers) + .github/skills/ (60: 29 wrappers + 31 importadas)"

# 2b) Camada Kiro (steering + Agent Skills). Copiamos SO as 5 rules de estilo:
#     *-context.md e os foundation files do Kiro (product/tech/structure.md)
#     sao por-servico e ficam intactos.
$kiroDst = Join-Path $Target '.kiro'
foreach ($d in 'steering','skills') {
  New-Item -ItemType Directory -Force -Path (Join-Path $kiroDst $d) | Out-Null
}
foreach ($f in 'architecture-style','frontend-style','negocio-style','engenharia-style','controle-style') {
  Copy-Item (Join-Path $PackDir ".kiro/steering/$f.md") (Join-Path $kiroDst "steering/$f.md") -Force
}
Write-Host "  + .kiro/steering/ (5 rules)"
Copy-Item (Join-Path $PackDir '.kiro/skills/*') (Join-Path $kiroDst 'skills') -Recurse -Force
Write-Host "  + .kiro/skills/ (60 Agent Skills: 29 wrappers + 31 importadas)"

# 3) Prompts (4 trilhas)
$promptsDst = Join-Path $Target 'prompts'
New-Item -ItemType Directory -Force -Path $promptsDst | Out-Null
foreach ($t in 'arquitetura','frontend','negocio','engenharia') {
  Copy-Item (Join-Path $PackDir "prompts/$t") $promptsDst -Recurse -Force
}
Write-Host "  + prompts/{arquitetura,frontend,negocio,engenharia}"

# 3b) Biblioteca de skills importadas (fonte canonica das copias verbatim)
$skillsDst = Join-Path $Target 'skills'
New-Item -ItemType Directory -Force -Path $skillsDst | Out-Null
Copy-Item (Join-Path $PackDir 'skills/*') $skillsDst -Recurse -Force
Write-Host "  + skills/ (biblioteca: 31 skills importadas em 14 categorias)"

# 4) Design system
$dsDst = Join-Path $Target 'docs/arquitetura/design-system'
New-Item -ItemType Directory -Force -Path $dsDst | Out-Null
Copy-Item (Join-Path $PackDir 'docs/arquitetura/design-system/*.css') $dsDst -Force
Write-Host "  + docs/arquitetura/design-system/*.css"

# 5) Runtime dos templates
$tplDst = Join-Path $Target 'docs/arquitetura/templates'
New-Item -ItemType Directory -Force -Path $tplDst | Out-Null
Copy-Item (Join-Path $PackDir 'docs/arquitetura/templates/diagram-viewer.js') $tplDst -Force
Copy-Item (Join-Path $PackDir 'docs/arquitetura/templates/sidebar.js')        $tplDst -Force
Write-Host "  + docs/arquitetura/templates/diagram-viewer.js + sidebar.js"

# 5b) Paginas de exemplo - referencia de FORMA pros prompts (padrao; pule com
#     -NoExamples). NUNCA sobrescreve: paginas ja geradas no alvo ficam intactas.
if ($NoExamples) {
  Write-Host "  > docs/arquitetura/templates/*.html (exemplos) pulados (-NoExamples)"
} else {
  $html = Get-ChildItem (Join-Path $PackDir 'docs/arquitetura/templates') -Filter '*.html' -ErrorAction SilentlyContinue
  if ($html) {
    $copied = 0; $kept = 0
    foreach ($f in $html) {
      $dst = Join-Path $tplDst $f.Name
      if (Test-Path $dst) { $kept++ } else { Copy-Item $f.FullName $dst; $copied++ }
    }
    Write-Host "  + docs/arquitetura/templates/*.html (exemplos de forma: $copied copiados, $kept preservados)"
  } else {
    Write-Host "  ! docs/arquitetura/templates/*.html nao copiados (nenhum .html no pack?)"
  }
}

# 6) Guia de uso (mensagens prontas - fica na RAIZ; abra no navegador)
$comoSrc = Join-Path $PackDir 'COMO-USAR.html'
$comoDst = Join-Path $Target 'COMO-USAR.html'
if (-not (Test-Path -PathType Leaf $comoSrc)) {
  Write-Host "  ! COMO-USAR.html ausente no pack - pulado"
} elseif (Test-Path -PathType Container $comoDst) {
  Write-Host "  ! COMO-USAR.html nao copiado (existe um DIRETORIO com esse nome no alvo)"
} else {
  Copy-Item $comoSrc $comoDst -Force -ErrorAction SilentlyContinue
  if (Test-Path -PathType Leaf $comoDst) {
    Write-Host "  + COMO-USAR.html (raiz do repo)"
    $comoMdSrc = Join-Path $PackDir 'COMO-USAR.md'
    if (Test-Path -PathType Leaf $comoMdSrc) {
      Copy-Item $comoMdSrc (Join-Path $Target 'COMO-USAR.md') -Force
      Write-Host "  + COMO-USAR.md (versao markdown, mesma raiz)"
    }
    # migracao: instalacoes antigas tinham o guia em docs/arquitetura/
    $comoOld = Join-Path $Target 'docs/arquitetura/COMO-USAR.html'
    if (Test-Path -PathType Leaf $comoOld) {
      Remove-Item $comoOld -Force
      Write-Host "  + docs/arquitetura/COMO-USAR.html (local antigo) removido - agora vive na raiz"
    }
  } else {
    Write-Host "  ! COMO-USAR.html nao copiado (destino bloqueado?)"
  }
}

# 7) Hooks de inicio de interacao do protocolo de controle. Substituem o antigo
#    pre-commit punitivo: orientam o agente a abrir/atualizar a task em docs/controle/
#    ANTES de editar - NUNCA bloqueiam o commit do humano.
$cliAgentsDst = Join-Path $Target '.amazonq/cli-agents'
$hooksDst     = Join-Path $Target '.amazonq/hooks'
$kiroHooksDst = Join-Path $Target '.kiro/hooks'
foreach ($d in $cliAgentsDst, $hooksDst, $kiroHooksDst) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
Copy-Item (Join-Path $PackDir '.amazonq/cli-agents/arquitetura.json') (Join-Path $cliAgentsDst 'arquitetura.json') -Force
Write-Host "  + .amazonq/cli-agents/arquitetura.json (ative com: q chat --agent arquitetura)"
Copy-Item (Join-Path $PackDir '.amazonq/hooks/controle-hook.sh') (Join-Path $hooksDst 'controle-hook.sh') -Force
Write-Host "  + .amazonq/hooks/controle-hook.sh (userPromptSubmit)"
Copy-Item (Join-Path $PackDir '.kiro/hooks/controle-prompt.kiro.hook') (Join-Path $kiroHooksDst 'controle-prompt.kiro.hook') -Force
Write-Host "  + .kiro/hooks/controle-prompt.kiro.hook (promptSubmit)"

# 7b) Migracao: remove o pre-commit punitivo antigo (so se for o gerado pelo pack) para
#     destravar o commit do humano.
$oldHook = Join-Path $Target '.git/hooks/pre-commit'
if ((Test-Path -PathType Leaf $oldHook) -and (Select-String -Path $oldHook -Pattern 'pre-commit-controle' -Quiet)) {
  $body = ((Get-Content $oldHook | Where-Object { $_ -notmatch '^\s*$' -and $_ -notmatch '^\s*#' }) -join "`n").Trim()
  if ($body -eq 'bash .amazonq/hooks/pre-commit-controle.sh || exit 1') {
    Remove-Item $oldHook -Force
    Write-Host "  + .git/hooks/pre-commit (punitivo antigo do pack) removido - commit destravado"
  } else {
    Write-Host "  ! .git/hooks/pre-commit tem outras linhas - apague a mao a chamada de pre-commit-controle"
  }
}
$oldScript = Join-Path $Target '.amazonq/hooks/pre-commit-controle.sh'
if (Test-Path -PathType Leaf $oldScript) {
  Remove-Item $oldScript -Force
  Write-Host "  + .amazonq/hooks/pre-commit-controle.sh (script antigo) removido"
}

# 7c) Migracao de caminho: a versao antiga guardava as tasks em controle/ na raiz.
#     Move pra docs/controle/, preservando cada task (nunca sobrescreve task ja existente).
$oldCtl = Join-Path $Target 'controle'
$newCtl = Join-Path $Target 'docs/controle'
if ((Test-Path -PathType Container $oldCtl)) {
  New-Item -ItemType Directory -Force -Path $newCtl | Out-Null
  $moved = 0
  foreach ($d in Get-ChildItem -LiteralPath $oldCtl -Directory -ErrorAction SilentlyContinue) {
    $dst = Join-Path $newCtl $d.Name
    if (Test-Path $dst) {
      Write-Host "  ! docs/controle/$($d.Name) ja existe - task deixada em controle/ (resolva a mao)"
    } else {
      Move-Item -LiteralPath $d.FullName -Destination $dst
      $moved++
    }
  }
  if (-not (Get-ChildItem -LiteralPath $oldCtl -Force -ErrorAction SilentlyContinue)) {
    Remove-Item -LiteralPath $oldCtl -Force
    Write-Host "  + controle/ (raiz, versao antiga) migrado pra docs/controle/ ($moved task(s))"
  } elseif ($moved -gt 0) {
    Write-Host "  ! controle/ migrado em parte ($moved task(s)); restou conteudo - verifique a mao"
  }
}

# 8) Limpeza de lixo do Finder
Get-ChildItem -Path $promptsDst, $skillsDst, $ghDst, $kiroDst, (Join-Path $Target 'docs/arquitetura') -Recurse -Force -Filter '.DS_Store' -ErrorAction SilentlyContinue |
  Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "`n[ok] Instalado. O Amazon Q le .amazonq/rules/, o Copilot le .github/ e o Kiro le .kiro/ automaticamente.`n"
Write-Host 'Comece:'
Write-Host '   Tecnica:    "documenta esse servico"   (Copilot IDE: /analisador-de-projeto na 1a vez)'
Write-Host '   Negocio:    "analisa o dominio" -> "grilla o negocio"'
Write-Host '   Frontend:   "polir essa pagina"'
Write-Host '   Engenharia: "investiga esse bug" / "planeja a implementacao"'
Write-Host '   Controle:   "nova tarefa: <slug> - <descricao>"  (protocolo de 2 turnos)'
Write-Host "`nMensagens prontas por trilha: abra COMO-USAR.html (raiz do repo) no navegador"
