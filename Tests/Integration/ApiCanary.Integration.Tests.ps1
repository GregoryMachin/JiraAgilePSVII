#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

<#
.SYNOPSIS
    Bounded write-lifecycle API canary (Phase 9 Task 60).

.DESCRIPTION
    Proves the full create -> read -> update -> delete -> confirm-gone contract
    for a single disposable sprint still round-trips against Jira Software
    Cloud. Deliberately narrow (one sprint, one pass through the lifecycle):
    the canary exists to catch a Cloud contract change quickly on its own
    schedule, not to be a regression suite.

    A sprint can only be created on a Scrum board (Kanban/simple boards do not
    support sprints), and no existing fixture tracks one, so this file
    discovers the first Scrum board it can see and skips cleanly if none
    exists. It also sweeps any stale canary sprint left on that board by a
    previous failed run before creating a new one: unlike the generic
    Remove-StaleTestResource helper (which only knows about issues, versions,
    and filters), no shared sweep covers sprints, so this file owns its own
    narrow one rather than extending the shared helper to discover boards for
    every integration test file's cleanup pass.

    Tagged 'CanaryWrite' (not 'Smoke'): the scheduled canary workflow selects
    this tag on a slower, off-peak cadence separate from the per-PR Smoke gate
    and the nightly full integration suite, and publishes a machine-readable
    result via Tools/Publish-ApiCanaryResult.ps1 for each step.

    Cloud-only by design: Data Center is pinned, versioned software with no
    "surprise contract change" risk the way a continuously deployed Cloud API
    has, and is already covered by integration_tests.yml's nightly run.
#>

BeforeDiscovery {
    . "$PSScriptRoot/../Helpers/TestTools.ps1"
    . "$PSScriptRoot/../Helpers/IntegrationTestTools.ps1"

    $script:moduleToTest = Initialize-TestEnvironment

    $script:Skip = Skip-IntegrationTest
    if (-not $Skip) {
        $testEnv = Initialize-IntegrationEnvironment
        $script:SkipWrite = $testEnv.ReadOnly
    }
}

InModuleScope JiraAgilePS {
    Describe "Api Canary - Sprint Lifecycle" -Tag 'Integration', 'CanaryWrite', 'Cloud' -Skip:($Skip -or $SkipWrite) {
        BeforeAll {
            . "$PSScriptRoot/../Helpers/IntegrationTestTools.ps1"

            $script:env = Initialize-IntegrationEnvironment
            $script:session = Connect-JiraTestServer -Environment $env

            # Sprints only exist on Scrum boards; no fixture tracks one, so
            # discover the first one this account can see.
            $script:scrumBoard = Get-Board -PageSize 50 -ErrorAction SilentlyContinue |
                Where-Object { $_.Type -eq 'scrum' } |
                Select-Object -First 1

            $script:canarySprintId = $null

            if ($script:scrumBoard) {
                $prefix = Get-TestResourcePrefix
                Get-Sprint -Board $script:scrumBoard -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -like "$prefix*" } |
                    ForEach-Object {
                        Write-Verbose "Removing stale canary sprint: $($_.Name)"
                        Remove-Sprint -Sprint $_ -ErrorAction SilentlyContinue
                    }
            }
        }

        AfterAll {
            if ($script:canarySprintId) {
                try {
                    Remove-Sprint -Sprint $script:canarySprintId -ErrorAction SilentlyContinue
                }
                catch {
                    Write-Verbose "Cleanup: failed to remove canary sprint $($script:canarySprintId) - $_"
                }
            }
            Remove-JiraSession -ErrorAction SilentlyContinue
        }

        It "creates a canary sprint" {
            if (-not $script:scrumBoard) {
                Set-ItResult -Skipped -Because "no Scrum board is visible to this account"
                return
            }

            $sprint = New-Sprint -Board $script:scrumBoard -Name (New-TestResourceName -Type "Sprint")
            $script:canarySprintId = $sprint.Id

            $sprint | Should -Not -BeNullOrEmpty
            $sprint.Id | Should -BeGreaterThan 0
        }

        It "reads the canary sprint back" {
            if (-not $script:canarySprintId) {
                Set-ItResult -Skipped -Because "canary sprint was not created"
                return
            }

            $read = Get-Sprint -Sprint $script:canarySprintId
            $read | Should -Not -BeNullOrEmpty
            $read.Id | Should -Be $script:canarySprintId
        }

        It "updates the canary sprint" {
            if (-not $script:canarySprintId) {
                Set-ItResult -Skipped -Because "canary sprint was not created"
                return
            }

            $updatedName = New-TestResourceName -Type "SprintUpdated"
            Set-Sprint -Sprint $script:canarySprintId -Name $updatedName

            $updated = Get-Sprint -Sprint $script:canarySprintId
            $updated.Name | Should -Be $updatedName
        }

        It "deletes the canary sprint" {
            if (-not $script:canarySprintId) {
                Set-ItResult -Skipped -Because "canary sprint was not created"
                return
            }

            { Remove-Sprint -Sprint $script:canarySprintId -ErrorAction Stop } | Should -Not -Throw
        }

        It "confirms the canary sprint no longer exists" {
            if (-not $script:canarySprintId) {
                Set-ItResult -Skipped -Because "canary sprint was not created"
                return
            }

            { Get-Sprint -Sprint $script:canarySprintId -ErrorAction Stop } | Should -Throw

            # The delete step already succeeded and Jira confirmed the sprint
            # is gone: clear the tracked id so AfterAll does not attempt a
            # redundant (and noisy) second delete.
            $script:canarySprintId = $null
        }
    }
}
