#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
}

BeforeAll {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
}

Describe "Get-JiraAgileBoardConfiguration" -Tag 'Unit' {
    BeforeAll {
        . "$PSScriptRoot/../../Helpers/TestTools.ps1"
        $script:jiraServer = "https://jira.example.com"

        Mock Get-JiraConfigServer -ModuleName JiraAgilePSVII {
            $jiraServer
        }
    }

    Describe "Signature" {
        BeforeAll {
            $script:command = Get-Command -Name "Get-JiraAgileBoardConfiguration"
        }

        Context "Parameter Types" {
            It "has a parameter '<parameter>' of type '<type>'" -TestCases @(
                @{ parameter = "Board"; type = [AtlassianPSVII.JiraAgilePSVII.Board] }
                @{ parameter = "Credential"; type = [System.Management.Automation.PSCredential] }
            ) {
                $command | Should -HaveParameter $parameter -Type $type
            }
        }
    }

    Describe "Behavior" {
        It "requests board configuration and returns converted object" {
            Mock Invoke-JiraMethod -ModuleName JiraAgilePSVII {
                [pscustomobject]@{
                    id     = 9
                    name   = "Main board"
                    type   = "scrum"
                    filter = [pscustomobject]@{
                        id   = 10030
                        self = "$jiraServer/rest/api/2/filter/10030"
                    }
                }
            }
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new(9)

            $result = Get-JiraAgileBoardConfiguration -Board $board

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/9/configuration"
            }

            $result.id | Should -Be 9
            $result.filter.id | Should -Be 10030
            $result.PSObject.TypeNames[0] | Should -Be "AtlassianPSVII.JiraAgilePSVII.BoardConfiguration"
        }
    }
}

