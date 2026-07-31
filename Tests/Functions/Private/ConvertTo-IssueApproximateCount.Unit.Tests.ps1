#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
}

InModuleScope JiraAgilePS {
    Describe "ConvertTo-IssueApproximateCount" -Tag 'Unit' {
        Describe "Behavior" {
            It "converts count response envelopes to typed count objects" {
                $result = [pscustomobject]@{ count = 42 } |
                    ConvertTo-IssueApproximateCount -Scope Board -BoardId 7 -Query 'project = AG'

                $result.PSObject.TypeNames[0] | Should -Be 'AtlassianPS.JiraAgilePS.IssueApproximateCount'
                $result.Count | Should -Be 42
                $result.Scope | Should -Be 'Board'
                $result.BoardId | Should -Be 7
                $result.Query | Should -Be 'project = AG'
            }

            It "ignores null pipeline input" {
                $result = $null | ConvertTo-IssueApproximateCount

                $result | Should -BeNullOrEmpty
            }
        }
    }
}
