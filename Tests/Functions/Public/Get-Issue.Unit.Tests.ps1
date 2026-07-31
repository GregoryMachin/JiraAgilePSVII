#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
}

BeforeAll {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
}

Describe "Get-JiraAgileIssue" -Tag 'Unit' {
    BeforeAll {
        . "$PSScriptRoot/../../Helpers/TestTools.ps1"
        $script:jiraServer = "https://jira.example.com"

        Mock Get-JiraConfigServer -ModuleName JiraAgilePS {
            $jiraServer
        }

        Mock Get-JiraServerInformation -ModuleName JiraAgilePS {
            [pscustomobject]@{
                DeploymentType = 'DataCenter'
            }
        }
    }

    Describe "Signature" {
        BeforeAll {
            $script:command = Get-Command -Name "Get-JiraAgileIssue"
        }

        Context "Parameter Types" {
            It "has a parameter '<parameter>' of type '<type>'" -TestCases @(
                @{ parameter = "Board"; type = [AtlassianPS.JiraAgilePS.Board] }
                @{ parameter = "Backlog"; type = [System.Management.Automation.SwitchParameter] }
                @{ parameter = "Sprint"; type = [AtlassianPS.JiraAgilePS.Sprint[]] }
                @{ parameter = "Epic"; type = [AtlassianPS.JiraAgilePS.Epic[]] }
                @{ parameter = "WithoutEpic"; type = [System.Management.Automation.SwitchParameter] }
                @{ parameter = "PageSize"; type = [UInt32] }
                @{ parameter = "Query"; type = [String] }
                @{ parameter = "Fields"; type = [String[]] }
                @{ parameter = "Expand"; type = [String[]] }
                @{ parameter = "Credential"; type = [System.Management.Automation.PSCredential] }
            ) {
                $command | Should -HaveParameter $parameter -Type $type
            }
        }
    }

    Describe "Behavior" {
        BeforeEach {
            Mock Invoke-JiraMethod -ModuleName JiraAgilePS {
                param($Uri)
                [pscustomobject]@{
                    issues = @(
                        [pscustomobject]@{
                            id  = "1000"
                            key = "AG-1000"
                            uri = $Uri
                        }
                    )
                }
            }
        }

        It "uses board issue endpoint by default" {
            $board = [AtlassianPS.JiraAgilePS.Board]::new(7)

            $result = Get-JiraAgileIssue -Board $board

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/7/issue" -and
                $Paging
            }
            $result[0].Key | Should -Be "AG-1000"
        }

        It "uses enhanced Jira Software issue-list endpoint for Cloud deployments" {
            Mock Get-JiraServerInformation -ModuleName JiraAgilePS {
                [pscustomobject]@{
                    DeploymentType = 'Cloud'
                }
            }
            $board = [AtlassianPS.JiraAgilePS.Board]::new(7)

            $null = Get-JiraAgileIssue -Board $board

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/software/1.0/board/7/issue" -and
                $Paging
            }
        }

        It "uses enhanced Jira Software issue-list endpoints for every Cloud parameter set" -TestCases @(
            @{
                Board        = [AtlassianPS.JiraAgilePS.Board]::new(7)
                Arguments    = @{}
                ExpectedPath = "rest/software/1.0/board/7/issue"
            }
            @{
                Board        = [AtlassianPS.JiraAgilePS.Board]::new(8)
                Arguments    = @{ Backlog = $true }
                ExpectedPath = "rest/software/1.0/board/8/backlog"
            }
            @{
                Board        = [AtlassianPS.JiraAgilePS.Board]::new(9)
                Arguments    = @{ Sprint = [AtlassianPS.JiraAgilePS.Sprint]::new(21) }
                ExpectedPath = "rest/software/1.0/board/9/sprint/21/issue"
            }
            @{
                Arguments    = @{ Epic = [AtlassianPS.JiraAgilePS.Epic]::new(55) }
                ExpectedPath = "rest/software/1.0/epic/55/issue"
            }
            @{
                Board        = [AtlassianPS.JiraAgilePS.Board]::new(10)
                Arguments    = @{ Epic = [AtlassianPS.JiraAgilePS.Epic]::new(56) }
                ExpectedPath = "rest/software/1.0/board/10/epic/56/issue"
            }
            @{
                Board        = [AtlassianPS.JiraAgilePS.Board]::new(11)
                Arguments    = @{ WithoutEpic = $true }
                ExpectedPath = "rest/software/1.0/board/11/epic/none/issue"
            }
        ) {
            Mock Get-JiraServerInformation -ModuleName JiraAgilePS {
                [pscustomobject]@{
                    DeploymentType = 'Cloud'
                }
            }

            $splat = @{} + $Arguments
            if ($Board) {
                $splat['Board'] = $Board
            }

            $script:expectedCloudIssueUri = "$jiraServer/$ExpectedPath"
            $null = Get-JiraAgileIssue @splat

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq $script:expectedCloudIssueUri -and
                $Paging -and
                $OutputType -eq "JiraIssue"
            }
        }

        It "uses backlog endpoint when Backlog switch is specified" {
            $board = [AtlassianPS.JiraAgilePS.Board]::new(8)

            $result = Get-JiraAgileIssue -Board $board -Backlog

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/8/backlog" -and
                $Paging
            }
            $result[0].Key | Should -Be "AG-1000"
        }

        It "uses sprint endpoint for each sprint in sprint parameter set" {
            $board = [AtlassianPS.JiraAgilePS.Board]::new(9)
            $sprintA = [AtlassianPS.JiraAgilePS.Sprint]::new(21)
            $sprintB = [AtlassianPS.JiraAgilePS.Sprint]::new(22)

            $result = Get-JiraAgileIssue -Board $board -Sprint @($sprintA, $sprintB)

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 2 -Scope It
            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/9/sprint/21/issue" -and
                $Paging
            }
            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/9/sprint/22/issue" -and
                $Paging
            }
            @($result).Count | Should -Be 2
        }

        It "uses epic endpoint when Epic is supplied without Board" {
            $epicA = [AtlassianPS.JiraAgilePS.Epic]::new(55)
            $epicB = [AtlassianPS.JiraAgilePS.Epic]::new(56)

            $result = Get-JiraAgileIssue -Epic @($epicA, $epicB)

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 2 -Scope It
            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/epic/55/issue" -and
                $Paging
            }
            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/epic/56/issue" -and
                $Paging
            }
            @($result).Count | Should -Be 2
        }

        It "uses board epic endpoint when Board and Epic are supplied" {
            $board = [AtlassianPS.JiraAgilePS.Board]::new(8)
            $epic = [AtlassianPS.JiraAgilePS.Epic]::new(66)

            $null = Get-JiraAgileIssue -Board $board -Epic $epic

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/8/epic/66/issue" -and
                $Paging
            }
        }

        It "uses board none endpoint when WithoutEpic is used" {
            $board = [AtlassianPS.JiraAgilePS.Board]::new(8)

            $null = Get-JiraAgileIssue -Board $board -WithoutEpic

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/8/epic/none/issue" -and
                $Paging
            }
        }

        It "accepts Board from pipeline in backlog parameter set" {
            $board = [AtlassianPS.JiraAgilePS.Board]::new(11)

            $null = $board | Get-JiraAgileIssue -Backlog

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/11/backlog" -and
                $Paging
            }
        }

        It "forwards paging parameters to Invoke-JiraMethod" {
            $board = [AtlassianPS.JiraAgilePS.Board]::new(13)

            $null = Get-JiraAgileIssue -Board $board -First 2 -Skip 1

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/13/issue" -and
                $Paging -and
                $First -eq 2 -and
                $Skip -eq 1
            }
        }

        It "forwards JQL, field, expand, and page-size options to Invoke-JiraMethod" {
            $board = [AtlassianPS.JiraAgilePS.Board]::new(14)

            $null = Get-JiraAgileIssue -Board $board -Query 'project = AG ORDER BY rank' -Fields key, summary, status -Expand renderedFields -PageSize 10

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePS -Exactly -Times 1 -Scope It -ParameterFilter {
                $GetParameter['maxResults'] -eq 10 -and
                $GetParameter['jql'] -eq 'project = AG ORDER BY rank' -and
                $GetParameter['fields'] -eq 'key,summary,status' -and
                $GetParameter['expand'] -eq 'renderedFields'
            }
        }

        It "expands token-paged issue envelopes that have no total property" {
            Mock Invoke-JiraMethod -ModuleName JiraAgilePS {
                @(
                    [pscustomobject]@{
                        issues        = @([pscustomobject]@{ id = "1001"; key = "AG-1001" })
                        nextPageToken = "opaque-token"
                        isLast        = $false
                    }
                    [pscustomobject]@{
                        issues = @([pscustomobject]@{ id = "1002"; key = "AG-1002" })
                        isLast = $true
                    }
                )
            }
            $board = [AtlassianPS.JiraAgilePS.Board]::new(15)

            $result = Get-JiraAgileIssue -Board $board

            @($result).Key | Should -Be @("AG-1001", "AG-1002")
            $result[0].PSObject.Properties.Name | Should -Not -Contain 'total'
        }

        It "throws when Board has no numeric id" {
            $board = [AtlassianPS.JiraAgilePS.Board]::new("my-board")

            { Get-JiraAgileIssue -Board $board } |
                Should -Throw "*Board input must contain a non-zero Id.*"
        }

        It "throws when Sprint has no numeric id" {
            $board = [AtlassianPS.JiraAgilePS.Board]::new(9)
            $sprint = [AtlassianPS.JiraAgilePS.Sprint]::new("my-sprint")

            { Get-JiraAgileIssue -Board $board -Sprint $sprint } |
                Should -Throw "*Sprint input must contain a non-zero Id.*"
        }

        It "throws when Epic has no numeric id" {
            $epic = [AtlassianPS.JiraAgilePS.Epic]::new("my-epic")

            { Get-JiraAgileIssue -Epic $epic } |
                Should -Throw "*Epic input must contain a non-zero Id.*"
        }
    }
}
