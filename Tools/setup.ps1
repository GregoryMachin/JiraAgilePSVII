#requires -Modules @{ ModuleName='PowerShellGet'; ModuleVersion='1.6.0' }

[CmdletBinding()]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
param()

$psScriptAnalyzerSettingsPath = Join-Path (Join-Path $PSScriptRoot '..') 'PSScriptAnalyzerSettings.psd1'

# A sibling, git-ignored ".local-modules" directory (outside every repo, never committed)
# holds AtlassianPS.Standards builds that have not been published to the real PowerShell
# Gallery -- consumed directly per the project's own direction, without ever installing
# into (or colliding with) the machine's real, shared module path. Prepending it here is
# scoped to this process only; it is never written to $PROFILE or a persistent
# environment variable.
$projectRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..')).ProviderPath
$localModulesPath = Join-Path -Path (Split-Path -Path $projectRoot -Parent) -ChildPath '.local-modules'
if ((Test-Path -LiteralPath $localModulesPath -PathType Container) -and ($env:PSModulePath -notlike "*$localModulesPath*")) {
    $env:PSModulePath = "$localModulesPath;$env:PSModulePath"
}

function Sync-PSScriptAnalyzerSetting {
    [CmdletBinding()]
    param()

    Write-Host "Syncing PSScriptAnalyzer settings from AtlassianPS.Standards"

    try {
        # Read the pinned version from build.requirements.psd1 instead of a hardcoded
        # literal here: Install-Dependency (below) already installs/imports whatever
        # version that file pins, so a separate hardcoded version in this function could
        # silently drift from it and try to load a different (possibly no longer
        # installed) copy of AtlassianPS.Standards.
        $buildRequirements = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot 'build.requirements.psd1')
        $standardsRequirement = $buildRequirements |
            Where-Object { $_.ModuleName -eq 'AtlassianPS.Standards' } |
            Select-Object -First 1
        if (-not $standardsRequirement -or -not $standardsRequirement.RequiredVersion) {
            throw "Could not resolve AtlassianPS.Standards required version from 'Tools/build.requirements.psd1'."
        }

        Import-Module AtlassianPS.Standards -RequiredVersion $standardsRequirement.RequiredVersion -Force -ErrorAction Stop
        $resolvedSettingsPath = Sync-AtlassianPSScriptAnalyzerSettings `
            -DestinationPath $psScriptAnalyzerSettingsPath `
            -ErrorAction Stop
        Write-Host "Shared PSScriptAnalyzer settings synchronized to '$resolvedSettingsPath'."
    }
    catch {
        throw "Unable to sync PSScriptAnalyzer settings from AtlassianPS.Standards. $($_.Exception.Message)"
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
