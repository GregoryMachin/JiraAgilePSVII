#requires -Modules @{ ModuleName='PowerShellGet'; ModuleVersion='1.6.0' }

[CmdletBinding()]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
param()

$psScriptAnalyzerSettingsPath = Join-Path (Join-Path $PSScriptRoot '..') 'PSScriptAnalyzerSettings.psd1'

# A sibling, git-ignored ".local-modules" directory (outside every repo, never committed)
# holds AtlassianPSVII.Standards builds that have not been published to the real PowerShell
# Gallery -- consumed directly per the project's own direction, without ever installing
# into (or colliding with) the machine's real, shared module path. Prepending it here is
# scoped to this process only; it is never written to $PROFILE or a persistent
# environment variable.
$projectRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..')).ProviderPath
$localModulesPath = Join-Path -Path (Split-Path -Path $projectRoot -Parent) -ChildPath '.local-modules'

# The fork's AtlassianPSVII.Standards is not on the PowerShell Gallery, and CI runners have no
# .local-modules folder: fetch the pinned version from its GitHub release (backlog PSVII-11),
# verify it against the SHA-256 below, and unpack it there. The requirements file is parsed
# (not Import-PowerShellDataFile, which returns only its first entry).
# When bumping the Standards pin in build.requirements.psd1, add the new release's SHA-256 (from
# its SHA256SUMS asset) here; an unlisted version falls back to Install-Module from the Gallery.
$standardsReleaseSha256 = @{
    '1.0.0' = 'b91646f8d6f52aae517e95496a36f3b69d1f45f52c1b6b17b90b6c536f78839c'
}
$requirementsAst = [System.Management.Automation.Language.Parser]::ParseFile(
    (Join-Path -Path $projectRoot -ChildPath 'Tools/build.requirements.psd1'), [ref]$null, [ref]$null)
$standardsPin = $requirementsAst.EndBlock.Statements[0].PipelineElements[0].Expression.SafeGetValue() |
    Where-Object { $_.ModuleName -eq 'AtlassianPSVII.Standards' } |
    Select-Object -First 1
if ($standardsPin -and $standardsReleaseSha256.ContainsKey([String]$standardsPin.RequiredVersion)) {
    $expectedSha256 = $standardsReleaseSha256[[String]$standardsPin.RequiredVersion]
    $standardsTarget = Join-Path -Path $localModulesPath -ChildPath "AtlassianPSVII.Standards/$($standardsPin.RequiredVersion)"
    if (-not (Test-Path -LiteralPath (Join-Path -Path $standardsTarget -ChildPath 'AtlassianPSVII.Standards.psd1'))) {
        if ($PSVersionTable.PSEdition -eq 'Desktop') {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        }
        $releaseUri = 'https://github.com/GregoryMachin/AtlassianPSVII.Standards/releases/download/v{0}/AtlassianPSVII.Standards.zip' -f $standardsPin.RequiredVersion
        $downloadPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName())
        $null = New-Item -Path $downloadPath -ItemType Directory -Force
        try {
            $zipPath = Join-Path -Path $downloadPath -ChildPath 'AtlassianPSVII.Standards.zip'
            Invoke-WebRequest -Uri $releaseUri -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
            $actualHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
            if ($actualHash -ne $expectedSha256) {
                throw "AtlassianPSVII.Standards $($standardsPin.RequiredVersion) from '$releaseUri' has SHA-256 $actualHash, expected $expectedSha256."
            }
            Expand-Archive -LiteralPath $zipPath -DestinationPath $downloadPath -Force
            $null = New-Item -Path $standardsTarget -ItemType Directory -Force
            Copy-Item -Path (Join-Path -Path $downloadPath -ChildPath 'AtlassianPSVII.Standards/*') -Destination $standardsTarget -Recurse -Force
        }
        finally {
            Remove-Item -LiteralPath $downloadPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# JiraAgilePSVII also needs JiraPSVII, which is not on the PowerShell Gallery either: fetch the
# pinned version from its GitHub release the same way. (Locally the build also puts a sibling
# ../JiraPSVII checkout on PSModulePath; CI runners only have this download.)
$jiraPSReleaseSha256 = @{
    '4.0.0' = 'db801e204adf63bf1fb9e471f6b393b73f5450d883a1e4b6c8f5289991c9784c'
}
$jiraPSPin = $requirementsAst.EndBlock.Statements[0].PipelineElements[0].Expression.SafeGetValue() |
    Where-Object { $_.ModuleName -eq 'JiraPSVII' } |
    Select-Object -First 1
if ($jiraPSPin -and $jiraPSReleaseSha256.ContainsKey([String]$jiraPSPin.RequiredVersion)) {
    $expectedSha256 = $jiraPSReleaseSha256[[String]$jiraPSPin.RequiredVersion]
    $jiraPSTarget = Join-Path -Path $localModulesPath -ChildPath "JiraPSVII/$($jiraPSPin.RequiredVersion)"
    if (-not (Test-Path -LiteralPath (Join-Path -Path $jiraPSTarget -ChildPath 'JiraPSVII.psd1'))) {
        if ($PSVersionTable.PSEdition -eq 'Desktop') {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        }
        $releaseUri = 'https://github.com/GregoryMachin/JiraPSVII/releases/download/v{0}/JiraPSVII.zip' -f $jiraPSPin.RequiredVersion
        $downloadPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName())
        $null = New-Item -Path $downloadPath -ItemType Directory -Force
        try {
            $zipPath = Join-Path -Path $downloadPath -ChildPath 'JiraPSVII.zip'
            Invoke-WebRequest -Uri $releaseUri -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
            $actualHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
            if ($actualHash -ne $expectedSha256) {
                throw "JiraPSVII $($jiraPSPin.RequiredVersion) from '$releaseUri' has SHA-256 $actualHash, expected $expectedSha256."
            }
            Expand-Archive -LiteralPath $zipPath -DestinationPath $downloadPath -Force
            $null = New-Item -Path $jiraPSTarget -ItemType Directory -Force
            Copy-Item -Path (Join-Path -Path $downloadPath -ChildPath 'JiraPSVII/*') -Destination $jiraPSTarget -Recurse -Force
        }
        finally {
            Remove-Item -LiteralPath $downloadPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

if ((Test-Path -LiteralPath $localModulesPath -PathType Container) -and ($env:PSModulePath -notlike "*$localModulesPath*")) {
    $env:PSModulePath = '{0}{1}{2}' -f $localModulesPath, [System.IO.Path]::PathSeparator, $env:PSModulePath
    # Later GitHub Actions steps run in new processes: hand the module path on to them.
    if ($env:GITHUB_ENV) {
        Add-Content -LiteralPath $env:GITHUB_ENV -Value "PSModulePath=$env:PSModulePath"
    }
}

function Sync-PSScriptAnalyzerSetting {
    [CmdletBinding()]
    param()

    Write-Host "Syncing PSScriptAnalyzer settings from AtlassianPSVII.Standards"

    try {
        # Read the pinned version from build.requirements.psd1 instead of a hardcoded
        # literal here: Install-Dependency (below) already installs/imports whatever
        # version that file pins, so a separate hardcoded version in this function could
        # silently drift from it and try to load a different (possibly no longer
        # installed) copy of AtlassianPSVII.Standards.
        # Parse the array-style requirements file: Import-PowerShellDataFile returns only its first entry.
        $buildRequirements = @([System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'build.requirements.psd1'), [ref]$null, [ref]$null).EndBlock.Statements[0].PipelineElements[0].Expression.SafeGetValue())
        $standardsRequirement = $buildRequirements |
            Where-Object { $_.ModuleName -eq 'AtlassianPSVII.Standards' } |
            Select-Object -First 1
        if (-not $standardsRequirement -or -not $standardsRequirement.RequiredVersion) {
            throw "Could not resolve AtlassianPSVII.Standards required version from 'Tools/build.requirements.psd1'."
        }

        Import-Module AtlassianPSVII.Standards -RequiredVersion $standardsRequirement.RequiredVersion -Force -ErrorAction Stop
        $resolvedSettingsPath = Sync-AtlassianPSVIIScriptAnalyzerSettings `
            -DestinationPath $psScriptAnalyzerSettingsPath `
            -ErrorAction Stop
        Write-Host "Shared PSScriptAnalyzer settings synchronized to '$resolvedSettingsPath'."
    }
    catch {
        throw "Unable to sync PSScriptAnalyzer settings from AtlassianPSVII.Standards. $($_.Exception.Message)"
    }
}

# PowerShell 5.1 and bellow need the PSGallery to be intialized
if (-not ($gallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue)) {
    Write-Host "Installing PackageProvider NuGet"
    $null = Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue
    Register-PSRepository -Default -ErrorAction SilentlyContinue
    $gallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
    if (-not $gallery) {
        throw "Unable to register the default PSGallery repository."
    }
}

# Make PSGallery trusted, to aviod a confirmation in the console
if ($gallery -and -not ($gallery.Trusted)) {
    Write-Host "Trusting PSGallery"
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue
}

Write-Host "Installing InvokeBuild"
Install-Module InvokeBuild -Scope CurrentUser -Force

Write-Host "Installing Dependencies"
Import-Module "$PSScriptRoot/BuildTools.psm1" -Force
Install-Dependency

Sync-PSScriptAnalyzerSetting
