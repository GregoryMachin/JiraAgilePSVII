#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
}

Describe "General project validation" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/Helpers/TestTools.ps1"
        $script:manifest = Test-ModuleManifest -Path $moduleToTest -ErrorAction Stop -WarningAction SilentlyContinue
        Initialize-TestEnvironment | Out-Null
    }

    It "passes Test-ModuleManifest" {
        { Test-ModuleManifest -Path $moduleToTest -ErrorAction Stop } | Should -Not -Throw
    }

    It "module 'JiraAgilePSVII' can import cleanly" {
        { Import-Module $moduleToTest } | Should -Not -Throw
    }

    It "module 'JiraAgilePSVII' exports functions" {
        Import-Module $moduleToTest

        (Get-Command -Module JiraAgilePSVII | Measure-Object).Count | Should -BeGreaterThan 0
    }

    It "module uses the correct root module" {
        $manifest.RootModule | Should -Be 'JiraAgilePSVII.psm1'
    }

    It "module uses the correct guid" {
        $manifest.Guid | Should -Be '1f85db59-454c-4ade-89df-626c225a5f7d'
    }

    It "module uses a valid version" {
        $manifest.Version | Should -Not -BeNullOrEmpty
        [Version]($manifest.Version) | Should -BeOfType [Version]
    }

    It "module manifest only defines major and minor versions" {
        $manifest.Version | Should -Match '^\d+\.\d+$'
    }
}
