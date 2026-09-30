#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2"; MaximumVersion = "6.999" }

BeforeDiscovery {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
}

BeforeAll {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
}

Describe "Remove-JiraAgileSprint" -Tag 'Unit' {
    BeforeAll {
        $script:jiraServer = "https://jira.example.com"

        Mock Get-JiraConfigServer -ModuleName JiraAgilePSVII {
            $jiraServer
        }
    }

    BeforeEach {
        Mock Invoke-JiraMethod -ModuleName JiraAgilePSVII { }
    }

    Describe "Signature" {
        BeforeAll {
            $script:command = Get-Command -Name "Remove-JiraAgileSprint"
        }

        Context "Parameter Types" {
            It "has a parameter '<parameter>' of type '<type>'" -TestCases @(
                @{ parameter = "Sprint"; type = [AtlassianPSVII.JiraAgilePSVII.Sprint[]] }
                @{ parameter = "Credential"; type = [System.Management.Automation.PSCredential] }
            ) {
                $command | Should -HaveParameter $parameter -Type $type
            }
        }

        Context "Mandatory Parameters" {
            It "parameter '<parameter>' is mandatory" -TestCases @(
                @{ parameter = "Sprint" }
            ) {
                $command | Should -HaveParameter $parameter -Mandatory
            }
        }
    }

    Describe "Behavior" {
        It "deletes each supplied sprint" {
            $sprintA = [AtlassianPSVII.JiraAgilePSVII.Sprint]::new(21)
            $sprintB = [AtlassianPSVII.JiraAgilePSVII.Sprint]::new(22)

            { Remove-JiraAgileSprint -Sprint @($sprintA, $sprintB) -Confirm:$false } | Should -Not -Throw

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 2 -Scope It
            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "DELETE" -and $Uri -eq "$jiraServer/rest/agile/1.0/sprint/21"
            }
            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "DELETE" -and $Uri -eq "$jiraServer/rest/agile/1.0/sprint/22"
            }
        }

        It "throws when Sprint has no numeric id" {
            $sprint = [AtlassianPSVII.JiraAgilePSVII.Sprint]::new("sprint-name")

            { Remove-JiraAgileSprint -Sprint $sprint -Confirm:$false } |
                Should -Throw "*Sprint input must contain a non-zero Id.*"
        }

        It "does not invoke Jira when WhatIf is used" {
            $sprint = [AtlassianPSVII.JiraAgilePSVII.Sprint]::new(21)

            Remove-JiraAgileSprint -Sprint $sprint -WhatIf

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 0 -Scope It
        }
    }
}
