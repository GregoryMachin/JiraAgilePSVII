#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2"; MaximumVersion = "6.999" }

BeforeDiscovery {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
}

BeforeAll {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"
    $script:moduleToTest = Initialize-TestEnvironment
}

Describe "Get-JiraAgileEpic" -Tag 'Unit' {
    BeforeAll {
        . "$PSScriptRoot/../../Helpers/TestTools.ps1"
        $script:jiraServer = "https://jira.example.com"

        Mock Get-JiraConfigServer -ModuleName JiraAgilePSVII {
            $jiraServer
        }
    }

    Describe "Signature" {
        BeforeAll {
            $script:command = Get-Command -Name "Get-JiraAgileEpic"
        }

        Context "Parameter Types" {
            It "has a parameter '<parameter>' of type '<type>'" -TestCases @(
                @{ parameter = "Epic"; type = [AtlassianPSVII.JiraAgilePSVII.Epic[]] }
                @{ parameter = "Board"; type = [AtlassianPSVII.JiraAgilePSVII.Board] }
                @{ parameter = "PageSize"; type = [UInt32] }
                @{ parameter = "Credential"; type = [System.Management.Automation.PSCredential] }
            ) {
                $command | Should -HaveParameter $parameter -Type $type
            }
        }
    }

    Describe "Behavior" {
        It "requests each epic id and converts response to Epic objects" {
            Mock Invoke-JiraMethod -ModuleName JiraAgilePSVII {
                param($Uri)
                $epicId = [int]($Uri -replace "^.*/epic/(\d+)$", '$1')

                [pscustomobject]@{
                    id      = $epicId
                    key     = "EPIC-$epicId"
                    name    = "Epic $epicId"
                    summary = "Summary $epicId"
                    done    = $false
                    self    = "$jiraServer/rest/agile/1.0/epic/$epicId"
                }
            }
            $epicA = [AtlassianPSVII.JiraAgilePSVII.Epic]::new(41)
            $epicB = [AtlassianPSVII.JiraAgilePSVII.Epic]::new(42)

            $result = Get-JiraAgileEpic -Epic @($epicA, $epicB)

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 2 -Scope It
            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/epic/41"
            }
            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/epic/42"
            }

            @($result).Count | Should -Be 2
            $result[0] | Should -BeOfType [AtlassianPSVII.JiraAgilePSVII.Epic]
            (@($result | Select-Object -ExpandProperty Key) -join ",") | Should -Be "EPIC-41,EPIC-42"
        }

        It "requests board epics when Board is supplied" {
            Mock Invoke-JiraMethod -ModuleName JiraAgilePSVII {
                [pscustomobject]@{
                    values = @(
                        [pscustomobject]@{
                            id   = 31
                            key  = "EPIC-31"
                            name = "Epic 31"
                            done = $false
                            self = "$jiraServer/rest/agile/1.0/epic/31"
                        },
                        [pscustomobject]@{
                            id   = 32
                            key  = "EPIC-32"
                            name = "Epic 32"
                            done = $true
                            self = "$jiraServer/rest/agile/1.0/epic/32"
                        }
                    )
                }
            }
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new(5)

            $result = Get-JiraAgileEpic -Board $board

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/5/epic" -and
                $Paging
            }

            @($result).Count | Should -Be 2
            $result[0] | Should -BeOfType [AtlassianPSVII.JiraAgilePSVII.Epic]
            $result[0].Name | Should -Be "Epic 31"
            $result[1].Done | Should -BeTrue
        }

        It "accepts Board from pipeline in board parameter set" {
            Mock Invoke-JiraMethod -ModuleName JiraAgilePSVII {
                [pscustomobject]@{
                    values = @()
                }
            }
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new(17)

            $null = $board | Get-JiraAgileEpic

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/17/epic" -and
                $Paging
            }
        }

        It "forwards paging parameters to Invoke-JiraMethod in board parameter set" {
            Mock Invoke-JiraMethod -ModuleName JiraAgilePSVII {
                [pscustomobject]@{
                    values = @()
                }
            }
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new(19)

            $null = Get-JiraAgileEpic -Board $board -First 2 -Skip 1

            Should -Invoke -CommandName Invoke-JiraMethod -ModuleName JiraAgilePSVII -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq "GET" -and
                $Uri -eq "$jiraServer/rest/agile/1.0/board/19/epic" -and
                $Paging -and
                $First -eq 2 -and
                $Skip -eq 1
            }
        }

        It "throws when Epic has no numeric id" {
            $epic = [AtlassianPSVII.JiraAgilePSVII.Epic]::new("my-epic")

            { Get-JiraAgileEpic -Epic $epic } |
                Should -Throw "*Epic input must contain a non-zero Id.*"
        }

        It "throws when Board has no numeric id" {
            $board = [AtlassianPSVII.JiraAgilePSVII.Board]::new("my-board")

            { Get-JiraAgileEpic -Board $board } |
                Should -Throw "*Board input must contain a non-zero Id.*"
        }
    }
}
