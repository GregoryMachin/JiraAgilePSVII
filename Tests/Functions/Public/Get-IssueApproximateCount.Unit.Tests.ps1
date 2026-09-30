#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
}

BeforeAll {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
}

Describe "Get-JiraAgileIssueApproximateCount" -Tag 'Unit' {
    BeforeAll {
        . "$PSScriptRoot/../../Helpers/TestTools.ps1"
        $script:jiraServer = "https://jira.example.com"

        Mock Get-JiraConfigServer -ModuleName JiraAgilePSVII {
            $jiraServer
        }

        Mock Get-JiraServerInformation -ModuleName JiraAgilePSVII {
            [pscustomobject]@{
                DeploymentType = 'Cloud'
            }
        }

        Mock Invoke-JiraMethod -ModuleName JiraAgilePSVII {
            [pscustomobject]@{
                count = 17
            }
        }
    }

    Describe "Signature" {
        BeforeAll {
            $script:command = Get-Command -Name "Get-JiraAgileIssueApproximateCount"
        }

        Context "Parameter Types" {
            It "has a parameter '<parameter>' of type '<type>'" -TestCases @(
                @{ parameter = "Board"; type = [AtlassianPSVII.JiraAgilePSVII.Board] }
                @{ parameter = "Backlog"; type = [System.Management.Automation.SwitchParameter] }
                @{ parameter = "Sprint"; type = [AtlassianPSVII.JiraAgilePSVII.Sprint[]] }
                @{ parameter = "Epic"; type = [AtlassianPSVII.JiraAgilePSVII.Epic[]] }
                @{ parameter = "WithoutEpic"; type = [System.Management.Automation.SwitchParameter] }
                @{ parameter = "Query"; type = [String] }
                @{ parameter = "Credential"; type = [System.Management.Automation.PSCredential] }
            ) {
                $command | Should -HaveParameter $parameter -Type $type
            }
        }
    }

    Describe "Behavior" {
        It "uses the board approximate-count endpoint" {
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new(7)

            $result = Get-JiraAgileIssueApproximateCount -Board $board

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/software/1.0/board/7/issue/approximate-count"
            }
            $result.Count | Should -Be 17
            $result.Scope | Should -Be "Board"
        }

        It "uses the backlog approximate-count endpoint" {
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new(8)

            $result = Get-JiraAgileIssueApproximateCount -Board $board -Backlog -Query 'project = AG'

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/software/1.0/board/8/backlog/approximate-count" -and
                $GetParameter['jql'] -eq 'project = AG'
            }
            $result.Scope | Should -Be "Backlog"
        }

        It "uses board approximate-count with sprint JQL" {
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new(9)
            $sprint = [AtlassianPSVII.JiraAgilePSVII.Sprint]::new(21)

            $result = Get-JiraAgileIssueApproximateCount -Board $board -Sprint $sprint -Query 'project = AG'

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/software/1.0/board/9/issue/approximate-count" -and
                $GetParameter['jql'] -eq '(project = AG) AND sprint = 21'
            }
            $result.Scope | Should -Be "Sprint"
            $result.SprintId | Should -Be 21
        }

        It "uses Jira Cloud approximate-count search for epic-only counts" {
            $epic = [AtlassianPSVII.JiraAgilePSVII.Epic]::new(55)

            $result = Get-JiraAgileIssueApproximateCount -Epic $epic

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $bodyObject = $Body | ConvertFrom-Json
                $Method -eq "POST" -and
                $Uri -eq "$jiraServer/rest/api/3/search/approximate-count" -and
                $bodyObject.jql -eq 'parent = 55'
            }
            $result.Scope | Should -Be "Epic"
        }

        It "uses board approximate-count with epic JQL" {
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new(10)
            $epic = [AtlassianPSVII.JiraAgilePSVII.Epic]::new(56)

            $result = Get-JiraAgileIssueApproximateCount -Board $board -Epic $epic

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/software/1.0/board/10/issue/approximate-count" -and
                $GetParameter['jql'] -eq 'parent = 56'
            }
            $result.Scope | Should -Be "BoardEpic"
        }

        It "uses board approximate-count with no-epic JQL" {
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new(11)

            $result = Get-JiraAgileIssueApproximateCount -Board $board -WithoutEpic

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/software/1.0/board/11/issue/approximate-count" -and
                $GetParameter['jql'] -eq 'parent = null'
            }
            $result.Scope | Should -Be "BoardWithoutEpic"
        }

        It "rejects Data Center deployments" {
            Mock Get-JiraServerInformation -ModuleName JiraAgilePSVII {
                [pscustomobject]@{
                    DeploymentType = 'DataCenter'
                }
            }
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new(7)

            { Get-JiraAgileIssueApproximateCount -Board $board } |
                Should -Throw "*supported only for Jira Cloud*"
        }

        It "throws when Board has no numeric id" {
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new("my-board")

            { Get-JiraAgileIssueApproximateCount -Board $board } |
                Should -Throw "*Board input must contain a non-zero Id.*"
        }
    }
}
