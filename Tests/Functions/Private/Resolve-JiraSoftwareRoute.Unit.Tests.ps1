#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

BeforeDiscovery {
    . "$PSScriptRoot/../../Helpers/TestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment
}

InModuleScope JiraAgilePS {
    Describe "Resolve-JiraSoftwareRoute" -Tag 'Unit' {
        It "resolves Cloud issue-list routes to the enhanced Jira Software API" -TestCases @(
            @{ Operation = 'BoardIssue'; BoardId = 7; Expected = 'https://jira.example.com/rest/software/1.0/board/7/issue' }
            @{ Operation = 'BacklogIssue'; BoardId = 8; Expected = 'https://jira.example.com/rest/software/1.0/board/8/backlog' }
            @{ Operation = 'SprintIssue'; BoardId = 9; SprintId = 21; Expected = 'https://jira.example.com/rest/software/1.0/board/9/sprint/21/issue' }
            @{ Operation = 'EpicIssue'; EpicId = 55; Expected = 'https://jira.example.com/rest/software/1.0/epic/55/issue' }
            @{ Operation = 'BoardEpicIssue'; BoardId = 8; EpicId = 66; Expected = 'https://jira.example.com/rest/software/1.0/board/8/epic/66/issue' }
            @{ Operation = 'BoardWithoutEpicIssue'; BoardId = 8; Expected = 'https://jira.example.com/rest/software/1.0/board/8/epic/none/issue' }
        ) {
            $params = @{
                BaseUri        = 'https://jira.example.com/'
                DeploymentType = 'Cloud'
                Operation      = $Operation
                BoardId        = $BoardId
                SprintId       = $SprintId
                EpicId         = $EpicId
            }

            Resolve-JiraSoftwareRoute @params | Should -Be $Expected
        }

        It "resolves Data Center issue-list routes to the legacy Agile API" {
            Resolve-JiraSoftwareRoute `
                -BaseUri 'https://jira.example.com/context/' `
                -DeploymentType DataCenter `
                -Operation SprintIssue `
                -BoardId 9 `
                -SprintId 21 |
                Should -Be 'https://jira.example.com/context/rest/agile/1.0/board/9/sprint/21/issue'
        }

        It "preserves legacy route selection when deployment metadata is absent" {
            Resolve-JiraSoftwareRoute `
                -BaseUri 'https://jira.example.com' `
                -Operation BoardIssue `
                -BoardId 7 |
                Should -Be 'https://jira.example.com/rest/agile/1.0/board/7/issue'
        }

        It "treats Server metadata as Data Center compatibility" {
            Resolve-JiraSoftwareRoute `
                -BaseUri 'https://jira.example.com' `
                -DeploymentType Server `
                -Operation BacklogIssue `
                -BoardId 7 |
                Should -Be 'https://jira.example.com/rest/agile/1.0/board/7/backlog'
        }

        It "rejects zero identifiers" {
            {
                Resolve-JiraSoftwareRoute `
                    -BaseUri 'https://jira.example.com' `
                    -DeploymentType Cloud `
                    -Operation BoardIssue `
                    -BoardId 0
            } | Should -Throw "*non-zero numeric identifier*"
        }
    }
}
