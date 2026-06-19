#requires -Version 5
<#
  install.ps1 - instala o pack arquitetura (Amazon Q + GitHub Copilot) num repositorio de servico.

  Uso (PowerShell / pwsh - Windows, macOS ou Linux):
    pwsh install.ps1                          # instala no diretorio atual
    pwsh install.ps1 -Target C:\repos\servico
    pwsh install.ps1 -NoExamples              # NAO inclui as paginas HTML de exemplo

  Copia: .amazonq/rules/ (5 rules) + .github/ (camada Copilot) + .kiro/ (camada Kiro:
           steering + Agent Skills) + ia/prompts/ (4 trilhas) + ia/skills/ (biblioteca de
           32 skills importadas)
         + ia/COMO-USAR.html + ia/design-system/ (css) + ia/templates/ (prefs.js + js +
           templates e paginas HTML de exemplo — referencia de FORMA pros prompts;
           nunca sobrescreve arquivo ja existente no alvo)
         + doc/templates/ + doc/design-system/ (assets de runtime semeados de ia/ pros
           docs gerados em doc/arquitetura/) + ia/tools/seed-doc-assets.sh (re-semear)
         + ia/tools/validar-doc.sh + ia/tools/lib/ (3 SoT) - validacao determinista que os
           prompts validadores (etapas 6/7 da trilha) rodam no "done" da geracao
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
Write-Host "  + .github/prompts/ (32 wrappers) + .github/skills/ (64: 32 wrappers + 32 importadas)"

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
Write-Host "  + .kiro/skills/ (64 Agent Skills: 32 wrappers + 32 importadas)"

# 3) Prompts (4 trilhas) — copia o CONTEUDO de cada trilha (glob /*) pra um dir criado,
#    como as demais copias recursivas: evita aninhar ia/prompts/<t>/<t>/ em re-run no Windows.
$promptsDst = Join-Path $Target 'ia/prompts'
New-Item -ItemType Directory -Force -Path $promptsDst | Out-Null
foreach ($t in 'arquitetura','frontend','negocio','engenharia') {
  $tDst = Join-Path $promptsDst $t
  New-Item -ItemType Directory -Force -Path $tDst | Out-Null
  Copy-Item (Join-Path $PackDir "ia/prompts/$t/*") $tDst -Recurse -Force
}
Write-Host "  + ia/prompts/{arquitetura,frontend,negocio,engenharia}"

# 3b) Biblioteca de skills importadas (fonte canonica das copias verbatim)
$skillsDst = Join-Path $Target 'ia/skills'
New-Item -ItemType Directory -Force -Path $skillsDst | Out-Null
Copy-Item (Join-Path $PackDir 'ia/skills/*') $skillsDst -Recurse -Force
Write-Host "  + ia/skills/ (biblioteca: 32 skills importadas em 14 categorias)"

# 4) Design system
$dsDst = Join-Path $Target 'ia/design-system'
New-Item -ItemType Directory -Force -Path $dsDst | Out-Null
Copy-Item (Join-Path $PackDir 'ia/design-system/*.css') $dsDst -Force
Write-Host "  + ia/design-system/*.css"

# 5) Runtime dos templates (prefs + viewer + sidebar)
$tplDst = Join-Path $Target 'ia/templates'
New-Item -ItemType Directory -Force -Path $tplDst | Out-Null
Copy-Item (Join-Path $PackDir 'ia/templates/prefs.js')          $tplDst -Force
Copy-Item (Join-Path $PackDir 'ia/templates/diagram-viewer.js') $tplDst -Force
Copy-Item (Join-Path $PackDir 'ia/templates/sidebar.js')        $tplDst -Force
Write-Host "  + ia/templates/prefs.js + diagram-viewer.js + sidebar.js"

# 5b) Paginas de exemplo - referencia de FORMA pros prompts (padrao; pule com
#     -NoExamples). NUNCA sobrescreve: paginas ja geradas no alvo ficam intactas.
if ($NoExamples) {
  Write-Host "  > ia/templates/*.html (exemplos) pulados (-NoExamples)"
} else {
  $html = Get-ChildItem (Join-Path $PackDir 'ia/templates') -Filter '*.html' -ErrorAction SilentlyContinue
  if ($html) {
    $copied = 0; $kept = 0
    foreach ($f in $html) {
      $dst = Join-Path $tplDst $f.Name
      if (Test-Path $dst) { $kept++ } else { Copy-Item $f.FullName $dst; $copied++ }
    }
    Write-Host "  + ia/templates/*.html (exemplos de forma: $copied copiados, $kept preservados)"
  } else {
    Write-Host "  ! ia/templates/*.html nao copiados (nenhum .html no pack?)"
  }
}

# 5c) Assets de runtime sob doc/ (os docs gerados em doc/arquitetura/ referenciam
#     ../templates/prefs.js e ../design-system/*.css). Artefato de build: semeado de ia/
#     (idempotente). Instala tambem o helper .sh para re-semear quando ia/ mudar.
$toolsDst = Join-Path $Target 'ia/tools'
New-Item -ItemType Directory -Force -Path $toolsDst | Out-Null
Copy-Item (Join-Path $PackDir 'ia/tools/seed-doc-assets.sh') $toolsDst -Force
$docTpl = Join-Path $Target 'doc/templates'
$docDs  = Join-Path $Target 'doc/design-system'
New-Item -ItemType Directory -Force -Path $docTpl, $docDs | Out-Null
foreach ($j in 'prefs.js','sidebar.js','diagram-viewer.js') {
  $src = Join-Path $tplDst $j
  if (Test-Path -PathType Leaf $src) { Copy-Item $src (Join-Path $docTpl $j) -Force }
}
Copy-Item (Join-Path $dsDst '*.css') $docDs -Force
Write-Host "  + doc/templates/ + doc/design-system/ semeados de ia/ (artefato de build)"

# 5d) Validador de doc - roda NO CLIENTE nas etapas 6/7 da trilha. Sem o script + os 3 SoT em
#     lib/, os prompts validadores caem no fallback textual. Bash puro: o cliente nao precisa
#     de node. Mesmos arquivos que o install.sh leva (sem drift entre os instaladores).
$libDst = Join-Path $Target 'ia/tools/lib'
New-Item -ItemType Directory -Force -Path $libDst | Out-Null
Copy-Item (Join-Path $PackDir 'ia/tools/validar-doc.sh') $toolsDst -Force
foreach ($sot in 'design-system-classes.txt','forbidden-terms.txt','mermaid-classdefs.txt') {
  Copy-Item (Join-Path $PackDir "ia/tools/lib/$sot") (Join-Path $libDst $sot) -Force
}
Write-Host "  + ia/tools/validar-doc.sh + lib/ (3 SoT) - validacao roda no done da trilha"

# 6) Guia de uso (mensagens prontas - fica em ia/; abra no navegador)
$comoSrc = Join-Path $PackDir 'ia/COMO-USAR.html'
$comoDst = Join-Path $Target 'ia/COMO-USAR.html'
if (-not (Test-Path -PathType Leaf $comoSrc)) {
  Write-Host "  ! COMO-USAR.html ausente no pack - pulado"
} elseif (Test-Path -PathType Container $comoDst) {
  Write-Host "  ! COMO-USAR.html nao copiado (existe um DIRETORIO com esse nome no alvo)"
} else {
  Copy-Item $comoSrc $comoDst -Force -ErrorAction SilentlyContinue
  if (Test-Path -PathType Leaf $comoDst) {
    Write-Host "  + ia/COMO-USAR.html"
    $comoMdSrc = Join-Path $PackDir 'ia/COMO-USAR.md'
    if (Test-Path -PathType Leaf $comoMdSrc) {
      Copy-Item $comoMdSrc (Join-Path $Target 'ia/COMO-USAR.md') -Force
      Write-Host "  + ia/COMO-USAR.md (versao markdown)"
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
#    pre-commit punitivo: orientam o agente a abrir/atualizar a task em doc/controle/
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
#     Move pra doc/controle/, preservando cada task (nunca sobrescreve task ja existente).
$oldCtl = Join-Path $Target 'controle'
$newCtl = Join-Path $Target 'doc/controle'
if ((Test-Path -PathType Container $oldCtl)) {
  New-Item -ItemType Directory -Force -Path $newCtl | Out-Null
  $moved = 0
  foreach ($d in Get-ChildItem -LiteralPath $oldCtl -Directory -ErrorAction SilentlyContinue) {
    $dst = Join-Path $newCtl $d.Name
    if (Test-Path $dst) {
      Write-Host "  ! doc/controle/$($d.Name) ja existe - task deixada em controle/ (resolva a mao)"
    } else {
      Move-Item -LiteralPath $d.FullName -Destination $dst
      $moved++
    }
  }
  if (-not (Get-ChildItem -LiteralPath $oldCtl -Force -ErrorAction SilentlyContinue)) {
    Remove-Item -LiteralPath $oldCtl -Force
    Write-Host "  + controle/ (raiz, versao antiga) migrado pra doc/controle/ ($moved task(s))"
  } elseif ($moved -gt 0) {
    Write-Host "  ! controle/ migrado em parte ($moved task(s)); restou conteudo - verifique a mao"
  }
}

# 7d) Migracao de LAYOUT (pre-ia/doc): o pack agora vive em ia/ e os outputs em doc/.
#     Move os DADOS do usuario (docs/*) pra doc/ e remove as copias antigas do pack na raiz.
$oldDocs = Join-Path $Target 'docs'
if (Test-Path -PathType Container $oldDocs) {
  New-Item -ItemType Directory -Force -Path (Join-Path $Target 'doc') | Out-Null
  foreach ($d in Get-ChildItem -LiteralPath $oldDocs -Directory -ErrorAction SilentlyContinue) {
    if ($d.Name -eq 'arquitetura') {
      $dstArq = Join-Path $Target 'doc/arquitetura'
      New-Item -ItemType Directory -Force -Path $dstArq | Out-Null
      foreach ($item in Get-ChildItem -LiteralPath $d.FullName -Force -ErrorAction SilentlyContinue) {
        if ($item.Name -in @('templates','design-system')) {
          Remove-Item -LiteralPath $item.FullName -Recurse -Force          # do pack - ja em ia/
        } elseif (-not (Test-Path (Join-Path $dstArq $item.Name))) {
          Move-Item -LiteralPath $item.FullName -Destination (Join-Path $dstArq $item.Name)
        }
      }
      Remove-Item -LiteralPath $d.FullName -Force -ErrorAction SilentlyContinue
    } elseif (-not (Test-Path (Join-Path $Target ('doc/' + $d.Name)))) {
      Move-Item -LiteralPath $d.FullName -Destination (Join-Path $Target ('doc/' + $d.Name))
      Write-Host "  + docs/$($d.Name) (layout antigo) -> doc/$($d.Name)"
    }
  }
  Remove-Item -LiteralPath $oldDocs -Force -ErrorAction SilentlyContinue
}
foreach ($old in 'prompts','skills','tools','COMO-USAR.html','COMO-USAR.md') {
  $p = Join-Path $Target $old
  if (Test-Path $p) { Remove-Item -LiteralPath $p -Recurse -Force; Write-Host "  + $old (raiz, layout antigo) removido - agora em ia/" }
}

# 8) Limpeza de lixo do Finder
Get-ChildItem -Path (Join-Path $Target 'ia'), $ghDst, $kiroDst, (Join-Path $Target 'doc') -Recurse -Force -Filter '.DS_Store' -ErrorAction SilentlyContinue |
  Remove-Item -Force -ErrorAction SilentlyContinue

# 9) .gitignore do produto - bloco idempotente: ignora as replicas pesadas (skills/prompts) e
#    mantem versionada a config + o contexto por-servico + doc/. Le a MESMA fonte unica do bash
#    (ia/tools/lib/gitignore-pack-block.txt) - sem drift entre os instaladores.
$giToolsDst = Join-Path $Target 'ia/tools'
$giLibDst   = Join-Path $Target 'ia/tools/lib'
New-Item -ItemType Directory -Force -Path $giLibDst | Out-Null
Copy-Item (Join-Path $PackDir 'ia/tools/seed-gitignore.sh') (Join-Path $giToolsDst 'seed-gitignore.sh') -Force
Copy-Item (Join-Path $PackDir 'ia/tools/lib/gitignore-pack-block.txt') (Join-Path $giLibDst 'gitignore-pack-block.txt') -Force
$giSot   = Join-Path $PackDir 'ia/tools/lib/gitignore-pack-block.txt'
$giFile  = Join-Path $Target '.gitignore'
$giStart = '# >>> arquitetura-pack (gerado pelo instalador) >>>'
$giEnd   = '# <<< arquitetura-pack <<<'
$giBlock = @($giStart) + (Get-Content -LiteralPath $giSot) + @($giEnd)
if (-not (Test-Path -PathType Leaf $giFile)) {
  Set-Content -LiteralPath $giFile -Value $giBlock -Encoding utf8
} else {
  $giCur = @(Get-Content -LiteralPath $giFile)
  if ($giCur -contains $giStart) {
    $giOut = New-Object System.Collections.Generic.List[string]
    $giSkip = $false
    foreach ($line in $giCur) {
      if ($line -eq $giStart) { $giBlock | ForEach-Object { $giOut.Add($_) }; $giSkip = $true; continue }
      if ($giSkip -and $line -eq $giEnd) { $giSkip = $false; continue }
      if ($giSkip) { continue }
      $giOut.Add($line)
    }
    Set-Content -LiteralPath $giFile -Value $giOut -Encoding utf8
  } else {
    Add-Content -LiteralPath $giFile -Value (@('') + $giBlock) -Encoding utf8
  }
}
Write-Host "  + .gitignore (bloco do pack)"

Write-Host "`n[ok] Instalado. O Amazon Q le .amazonq/rules/, o Copilot le .github/ e o Kiro le .kiro/ automaticamente.`n"
Write-Host 'Comece:'
Write-Host '   Tecnica:    "documenta esse servico"   (Copilot IDE: /analisador-de-projeto na 1a vez)'
Write-Host '   Negocio:    "analisa o dominio" -> "grilla o negocio"'
Write-Host '   Frontend:   "polir essa pagina"'
Write-Host '   Engenharia: "investiga esse bug" / "planeja a implementacao"'
Write-Host '   Controle:   "nova tarefa: <slug> - <descricao>"  (protocolo de 2 turnos)'
Write-Host "`nMensagens prontas por trilha: abra ia/COMO-USAR.html no navegador"
