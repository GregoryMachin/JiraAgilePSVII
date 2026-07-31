#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
}

InModuleScope JiraAgilePS {
    Describe "ConvertTo-Issue" -Tag 'Unit' {
        BeforeAll {
            . "$PSScriptRoot/../../Helpers/TestTools.ps1"

            $script:issuePayload = [pscustomobject]@{
                id     = '10010'
                key    = 'DEL-10'
                fields = [pscustomobject]@{
                    summary = 'Fix board view'
                }
            }
        }

        Describe "Behavior" {
            It "adds the Agile issue type name" {
                $result = ConvertTo-Issue -InputObject $issuePayload

                $result.PSObject.TypeNames[0] | Should -Be 'AtlassianPS.JiraAgilePS.Issue'
            }

            It "preserves all payload properties" {
                $result = ConvertTo-Issue -InputObject $issuePayload

                $result.id | Should -Be '10010'
                $result.key | Should -Be 'DEL-10'
                $result.fields.summary | Should -Be 'Fix board view'
            }

            It "preserves JiraPS issue typing behind the Agile issue type" {
                $typedIssue = [pscustomobject]@{
                    id  = '10011'
                    key = 'DEL-11'
                }
                $typedIssue.PSObject.TypeNames.Insert(0, 'AtlassianPS.JiraPS.Issue')

                $result = ConvertTo-Issue -InputObject $typedIssue

                $result.PSObject.TypeNames[0] | Should -Be 'AtlassianPS.JiraAgilePS.Issue'
                $result.PSObject.TypeNames | Should -Contain 'AtlassianPS.JiraPS.Issue'
            }

            It "ignores null pipeline input" {
                $result = $null | ConvertTo-Issue

                $result | Should -BeNullOrEmpty
            }
        }
    }
}
