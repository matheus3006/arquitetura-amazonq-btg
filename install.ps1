#requires -Version 5
<#
  install.ps1 — instala o pack arquitetura-amazonq (trilha tecnica + de negocio)
                num repositorio de servico, pronto pro Amazon Q ler sozinho.

  Uso (PowerShell / pwsh — Windows, macOS ou Linux):
    pwsh install.ps1                          # instala no diretorio atual
    pwsh install.ps1 -Target C:\repos\servico
    pwsh install.ps1 -WithExamples            # inclui as paginas HTML de exemplo

  Copia: .amazonq/rules/ (3 rules) + prompts/ (2 trilhas) + design-system/*.css
         + templates/{diagram-viewer,sidebar}.js + COMO-USAR.md
  NAO copia: project-context.md / business-context.md (sao por-servico, gerados).
#>
param(
  [string]$Target = (Get-Location).Path,
  [switch]$WithExamples
)
$ErrorActionPreference = 'Stop'

$PackDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Target  = (Resolve-Path $Target).Path

if ($Target -eq $PackDir) {
  Write-Error "O alvo e o proprio pack. Aponte pro repo do SERVICO: pwsh `"$PackDir\install.ps1`" -Target <repo>"
  exit 1
}

Write-Host "[pack] arquitetura-amazonq -> $Target`n"

# 1) Rules — o que o Amazon Q le automaticamente (nao tocamos *-context.md, que sao por-servico)
$rulesDst = Join-Path $Target '.amazonq/rules'
New-Item -ItemType Directory -Force -Path $rulesDst | Out-Null
if (Test-Path (Join-Path $rulesDst 'architecture-style.md')) {
  Write-Host "  i  .amazonq/rules ja existe — atualizando as rules (project/business-context.md ficam intactos)."
}
foreach ($f in 'architecture-style.md','frontend-style.md','negocio-style.md') {
  Copy-Item (Join-Path $PackDir ".amazonq/rules/$f") (Join-Path $rulesDst $f) -Force
  Write-Host "  + .amazonq/rules/$f"
}

# 2) Prompts (as duas trilhas)
$promptsDst = Join-Path $Target 'prompts'
New-Item -ItemType Directory -Force -Path $promptsDst | Out-Null
Copy-Item (Join-Path $PackDir 'prompts/arquitetura') $promptsDst -Recurse -Force
Copy-Item (Join-Path $PackDir 'prompts/negocio')     $promptsDst -Recurse -Force
Write-Host "  + prompts/arquitetura + prompts/negocio"

# 3) Design system (CSS reutilizavel)
$dsDst = Join-Path $Target 'design-system'
New-Item -ItemType Directory -Force -Path $dsDst | Out-Null
Copy-Item (Join-Path $PackDir 'design-system/*.css') $dsDst -Force
Write-Host "  + design-system/*.css"

# 4) Runtime dos templates (viewer + sidebar)
$tplDst = Join-Path $Target 'templates'
New-Item -ItemType Directory -Force -Path $tplDst | Out-Null
Copy-Item (Join-Path $PackDir 'templates/diagram-viewer.js') $tplDst -Force
Copy-Item (Join-Path $PackDir 'templates/sidebar.js')        $tplDst -Force
Write-Host "  + templates/diagram-viewer.js + sidebar.js"

# 4b) Paginas de exemplo (opcional)
if ($WithExamples) {
  Copy-Item (Join-Path $PackDir 'templates/*.html') $tplDst -Force
  Write-Host "  + templates/*.html (exemplos)"
}

# 5) Guia de uso
Copy-Item (Join-Path $PackDir 'COMO-USAR.md') (Join-Path $Target 'COMO-USAR.md') -Force
Write-Host "  + COMO-USAR.md"

Write-Host "`n[ok] Instalado. O Amazon Q le .amazonq/rules/ automaticamente neste repo.`n"
Write-Host "Comece (com @workspace aberto no repo do servico):"
Write-Host '   1.  "analisa o dominio"                   -> gera o business-context.md'
Write-Host '   2.  "documenta o fluxo de negocio do <X>" -> diagrama caminho feliz/triste'
Write-Host '   3.  "grilla o negocio"                    -> interrogatorio por fases'
Write-Host "`nTodos os gatilhos: COMO-USAR.md"
