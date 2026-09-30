#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2"; MaximumVersion = "6.999" }

Describe 'AtlassianPSVII.Standards version consistency' -Tag Unit {
    BeforeAll {
        $script:projectRoot = if (
            $env:BHProjectPath -and
            (Test-Path -LiteralPath (Join-Path $env:BHProjectPath 'Tools/build.requirements.psd1'))
        ) {
            (Resolve-Path -LiteralPath $env:BHProjectPath).ProviderPath
        }
        else {
            (Resolve-Path -LiteralPath "$PSScriptRoot/../..").ProviderPath
        }
        $requirementsPath = Join-Path $script:projectRoot 'Tools/build.requirements.psd1'
        $requirements = Import-PowerShellDataFile -LiteralPath $requirementsPath
        $script:standardsVersion = [String](
            $requirements |
                Where-Object { $_.ModuleName -eq 'AtlassianPSVII.Standards' } |
                Select-Object -First 1 -ExpandProperty RequiredVersion
        )
    }

    It 'keeps every workflow setup action aligned with build.requirements' {
        $workflowPaths = Get-ChildItem `
            -Path (Join-Path $script:projectRoot '.github/workflows') `
            -File `
            -Filter '*.yml'
        $matches = @(
            foreach ($workflowPath in $workflowPaths) {
                $workflow = Get-Content -LiteralPath $workflowPath.FullName -Raw
                [Regex]::Matches(
                    $workflow,
                    'GregoryMachin/AtlassianPSVII\.Standards/\.github/actions/setup-powershell@' +
                    '(?<sha>[0-9a-f]{40})\s+#\s+v(?<version>\d+\.\d+\.\d+)'
                )
            }
        )

        $matches.Count | Should -BeGreaterThan 0
        @($matches | ForEach-Object { $_.Groups['sha'].Value } | Select-Object -Unique).Count |
            Should -Be 1
        @($matches | ForEach-Object { $_.Groups['version'].Value } | Select-Object -Unique) |
            Should -Be @($script:standardsVersion)
    }

    It 'keeps build and setup imports aligned with build.requirements' {
        $escapedVersion = [Regex]::Escape($script:standardsVersion)
        $buildScript = Get-Content `
            -LiteralPath (Join-Path $script:projectRoot 'JiraAgilePSVII.build.ps1') `
            -Raw
        $setupScript = Get-Content `
            -LiteralPath (Join-Path $script:projectRoot 'Tools/setup.ps1') `
            -Raw

        $buildScript | Should -Match (
            "ModuleName\s*=\s*'AtlassianPSVII\.Standards';\s*" +
            "ModuleVersion\s*=\s*'$escapedVersion';\s*" +
            "MaximumVersion\s*=\s*'$escapedVersion'"
        )
        $setupScript | Should -Match (
            "Import-Module\s+AtlassianPSVII\.Standards\s+-RequiredVersion\s+'$escapedVersion'"
        )
    }
}
