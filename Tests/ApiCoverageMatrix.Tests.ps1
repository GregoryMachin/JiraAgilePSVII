#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
    $script:moduleRoot = Resolve-ProjectRoot
}

Describe "Jira Agile API coverage matrix" -Tag Unit {
    BeforeDiscovery {
        $script:matrixPath = Join-Path $moduleRoot "docs/agile-api-coverage-matrix.md"
        $script:matrixContent = if (Test-Path -LiteralPath $matrixPath) {
            Get-Content -LiteralPath $matrixPath -Raw
        }
        else {
            ""
        }

        $entryPattern = '(?m)^(?<Row>\| \[`(?<Command>[^`]+)`\]\((?<Source>[^)]+)\) \| `(?<ParameterSet>[^`]+)` \|.*)$'
        $script:matrixEntries = @(
            [regex]::Matches($matrixContent, $entryPattern) | ForEach-Object {
                [pscustomobject]@{
                    Command      = $_.Groups["Command"].Value
                    ParameterSet = $_.Groups["ParameterSet"].Value
                    Source       = $_.Groups["Source"].Value
                    Row          = $_.Groups["Row"].Value
                }
            }
        )

        $script:exportedFunctionNames = @(
            (Get-Module "JiraAgilePSVII").ExportedFunctions.Keys | Sort-Object
        )

        $script:expectedContracts = @(
            foreach ($functionName in $exportedFunctionNames) {
                foreach ($parameterSet in (Get-Command -Name $functionName).ParameterSets.Name) {
                    "$functionName|$parameterSet"
                }
            }
        ) | Sort-Object

        $referencePattern = '\[[^\]]+\]\((?<Path>\.\./(?:JiraAgilePSVII|Tests)/[^)]+)\)'
        $script:referencedFiles = @(
            [regex]::Matches($matrixContent, $referencePattern) |
                ForEach-Object { $_.Groups["Path"].Value } |
                Sort-Object -Unique
        )
    }

    It "exists" {
        $matrixPath | Should -Exist
    }

    It "contains every exported function" {
        @($matrixEntries.Command | Sort-Object -Unique) | Should -Be $exportedFunctionNames
    }

    It "contains exactly one row for every exported command and parameter set" {
        $actualContracts = @(
            $matrixEntries | ForEach-Object { "$($_.Command)|$($_.ParameterSet)" }
        ) | Sort-Object

        $actualContracts.Count | Should -Be $expectedContracts.Count
        @($actualContracts | Sort-Object -Unique).Count | Should -Be $actualContracts.Count
        $actualContracts | Should -Be $expectedContracts
    }

    Context "Contract <_>" -ForEach $matrixEntries {
        BeforeAll {
            $script:matrixEntry = $_
            $script:sourceFunctionName = $matrixEntry.Command -replace '^([^-]+)-JiraAgile', '$1-'
        }

        It "references its public source file" {
            $matrixEntry.Source | Should -Be "../JiraAgilePSVII/Public/$sourceFunctionName.ps1"
        }

        It "references its unit test file" {
            $expectedUnitTest = "../Tests/Functions/Public/$sourceFunctionName.Unit.Tests.ps1"
            $matrixEntry.Row | Should -Match ([regex]::Escape("]($expectedUnitTest)"))
        }

        It "defines all coverage columns" {
            @($matrixEntry.Row -split '\|').Count | Should -Be 16
            $matrixEntry.Row | Should -Not -Match '\|\s*\|'
        }
    }

    Context "Referenced source or test <_>" -ForEach $referencedFiles {
        It "exists relative to the matrix" {
            $relativePath = $_ -replace '/', [System.IO.Path]::DirectorySeparatorChar
            $resolvedPath = [System.IO.Path]::GetFullPath(
                (Join-Path (Split-Path $matrixPath -Parent) $relativePath)
            )

            $resolvedPath | Should -Exist
        }
    }
}
