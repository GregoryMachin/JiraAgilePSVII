# JiraAgilePSVII API Coverage Matrix

Issue: [#11](https://github.com/AtlassianPS/JiraAgilePS/issues/11)

Last reviewed: 27 July 2026

## Purpose

This matrix maps every exported JiraAgilePSVII command and parameter set to its implemented Cloud route, required enhanced Cloud replacement, Data Center route, pagination model, count and reconciliation behavior, permissions, OAuth scopes, output adapter, and automated coverage.
It describes the current source rather than implying that planned Cloud migration work is already complete.

JiraAgilePSVII exports eleven commands with twenty-four parameter sets after applying its `JiraAgile` command prefix.
Six `Get-JiraAgileIssue` parameter sets now route Cloud calls through the enhanced Jira Software issue-list endpoints with JiraPSVII token pagination, approximate count support, and reconciliation behavior.

## Contract conventions

- **Current Cloud route** is the route used by the code today.
- **Cloud target** is the route that should be used after deployment-aware migration.
- **Data Center route** must remain on `/rest/agile/1.0` while Data Center is supported.
- **Offset** means `startAt`, `maxResults`, and a response `total`.
- **Token** means `nextPageToken`, `maxResults`, and `isLast`; enhanced responses do not return `total`.
- **Parity integration** refers to the shared Cloud/Data Center suite.
  A row explicitly says when that suite does not exercise the parameter set.
- OAuth scopes are the current Jira Software granular scopes documented by Atlassian.
  JiraAgilePSVII does not yet implement OAuth token handling.

## Command and parameter-set coverage

| Exported command/source | Parameter set | HTTP | Current Cloud route | Cloud target | Data Center route | Pagination | Approximate count and reconciliation | Permission class | OAuth 2.0 scopes | Output adapter | Unit test | Integration test | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| [`Add-JiraAgileIssueToSprint`](../JiraAgilePSVII/Public/Add-IssueToSprint.ps1) | `__AllParameterSets` | POST | `/rest/agile/1.0/sprint/{sprintId}/issue` | Same; not in the issue-list deprecation | Same | Input batches of 50; no response paging | N/A | Write; edit issues and manage sprint assignment | `write:sprint:jira-software` | None | [Unit](../Tests/Functions/Public/Add-IssueToSprint.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) when disposable issue/sprint fixtures exist | Current; write-sensitive |
| [`Get-JiraAgileBoard`](../JiraAgilePSVII/Public/Get-Board.ps1) | `_All` | GET | `/rest/agile/1.0/board` | Same; current documented route | Same | Offset through JiraPSVII transport | N/A | Read; view boards | `read:board-scope:jira-software`, `read:project:jira` | `ConvertTo-Board` | [Unit](../Tests/Functions/Public/Get-Board.Unit.Tests.ps1) | [Smoke](../Tests/Integration/AgileSmoke.Integration.Tests.ps1), [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) | Current |
| [`Get-JiraAgileBoard`](../JiraAgilePSVII/Public/Get-Board.ps1) | `_Search` | GET | `/rest/agile/1.0/board/{boardId}` | Same; current documented route | Same | None; one request per ID | N/A | Read; view board | `read:board-scope:jira-software`, `read:issue-details:jira` | `ConvertTo-Board` | [Unit](../Tests/Functions/Public/Get-Board.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) | Current |
| [`Get-JiraAgileBoardConfiguration`](../JiraAgilePSVII/Public/Get-BoardConfiguration.ps1) | `__AllParameterSets` | GET | `/rest/agile/1.0/board/{boardId}/configuration` | Same; current documented route | Same | None | N/A | Board-admin read; view board configuration and project | `read:board-scope.admin:jira-software`, `read:project:jira` | `ConvertTo-BoardConfiguration` | [Unit](../Tests/Functions/Public/Get-BoardConfiguration.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) | Current; board configuration is sensitive |
| [`Get-JiraAgileEpic`](../JiraAgilePSVII/Public/Get-Epic.ps1) | `_ById` | GET | `/rest/agile/1.0/epic/{epicIdOrKey}` | Same; current documented route | Same | None; one request per epic | N/A | Read; view epic | `read:epic:jira-software` | `ConvertTo-Epic` | [Unit](../Tests/Functions/Public/Get-Epic.Unit.Tests.ps1) | Not covered by live parity suite | Current route; integration gap |
| [`Get-JiraAgileEpic`](../JiraAgilePSVII/Public/Get-Epic.ps1) | `_ByBoard` | GET | `/rest/agile/1.0/board/{boardId}/epic` | Same; current documented route | Same | Offset through JiraPSVII transport | N/A | Read; view board epics | `read:epic:jira-software` | `ConvertTo-Epic` | [Unit](../Tests/Functions/Public/Get-Epic.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) | Current |
| [`Get-JiraAgileIssue`](../JiraAgilePSVII/Public/Get-Issue.ps1) | `_Board` | GET | `/rest/software/1.0/board/{boardId}/issue` | Current route | `/rest/agile/1.0/board/{boardId}/issue` | Cloud: token; Data Center: offset | Board count: `GET /rest/software/1.0/board/{boardId}/issue/approximate-count`; `reconcileIssues` accepts up to 50 IDs and must remain constant across pages | Read; view board and browse issues | `read:board-scope:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `Get-AgilePageItem`, `ConvertTo-Issue` | [Unit](../Tests/Functions/Public/Get-Issue.Unit.Tests.ps1), [Route resolver](../Tests/Functions/Private/Resolve-JiraSoftwareRoute.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) | Cloud route and token pagination migrated; count and reconciliation migrated |
| [`Get-JiraAgileIssue`](../JiraAgilePSVII/Public/Get-Issue.ps1) | `_Backlog` | GET | `/rest/software/1.0/board/{boardId}/backlog` | Current route | `/rest/agile/1.0/board/{boardId}/backlog` | Cloud: token; Data Center: offset | Backlog count: `GET /rest/software/1.0/board/{boardId}/backlog/approximate-count`; `reconcileIssues` accepts up to 50 IDs and must remain constant across pages | Read; view board and browse backlog issues | `read:board-scope:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `Get-AgilePageItem`, `ConvertTo-Issue` | [Unit](../Tests/Functions/Public/Get-Issue.Unit.Tests.ps1), [Route resolver](../Tests/Functions/Private/Resolve-JiraSoftwareRoute.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) | Cloud route and token pagination migrated; count and reconciliation migrated |
| [`Get-JiraAgileIssue`](../JiraAgilePSVII/Public/Get-Issue.ps1) | `_Sprint` | GET | `/rest/software/1.0/board/{boardId}/sprint/{sprintId}/issue` | Current route | `/rest/agile/1.0/board/{boardId}/sprint/{sprintId}/issue` | Cloud: token; Data Center: offset | Board count endpoint with JQL `sprint = {sprintId}`; `reconcileIssues` accepts up to 50 IDs and must remain constant across pages | Read; view board/sprint and browse issues | `read:sprint:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `Get-AgilePageItem`, `ConvertTo-Issue` | [Unit](../Tests/Functions/Public/Get-Issue.Unit.Tests.ps1), [Route resolver](../Tests/Functions/Private/Resolve-JiraSoftwareRoute.Unit.Tests.ps1) | Cloud parity canary when fixtures exist | Cloud route, token pagination, count, and reconciliation migrated |
| [`Get-JiraAgileIssue`](../JiraAgilePSVII/Public/Get-Issue.ps1) | `_Epic` | GET | `/rest/software/1.0/epic/{epicIdOrKey}/issue` | Current route | `/rest/agile/1.0/epic/{epicIdOrKey}/issue` | Cloud: token; Data Center: offset | `POST /rest/api/3/search/approximate-count` with JQL `parent = {epicIdOrKey}`; `reconcileIssues` accepts up to 50 IDs and must remain constant across pages | Read; view epic and browse issues | `read:epic:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `Get-AgilePageItem`, `ConvertTo-Issue` | [Unit](../Tests/Functions/Public/Get-Issue.Unit.Tests.ps1), [Route resolver](../Tests/Functions/Private/Resolve-JiraSoftwareRoute.Unit.Tests.ps1) | Cloud parity canary when fixtures exist | Cloud route, token pagination, count, and reconciliation migrated |
| [`Get-JiraAgileIssue`](../JiraAgilePSVII/Public/Get-Issue.ps1) | `_BoardEpic` | GET | `/rest/software/1.0/board/{boardId}/epic/{epicId}/issue` | Current route | `/rest/agile/1.0/board/{boardId}/epic/{epicId}/issue` | Cloud: token; Data Center: offset | Board count endpoint with JQL `parent = {epicIdOrKey}`; `reconcileIssues` accepts up to 50 IDs and must remain constant across pages | Read; view board/epic and browse issues | `read:epic:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `Get-AgilePageItem`, `ConvertTo-Issue` | [Unit](../Tests/Functions/Public/Get-Issue.Unit.Tests.ps1), [Route resolver](../Tests/Functions/Private/Resolve-JiraSoftwareRoute.Unit.Tests.ps1) | Cloud parity canary when fixtures exist | Cloud route, token pagination, count, and reconciliation migrated |
| [`Get-JiraAgileIssue`](../JiraAgilePSVII/Public/Get-Issue.ps1) | `_BoardWithoutEpic` | GET | `/rest/software/1.0/board/{boardId}/epic/none/issue` | Current route | `/rest/agile/1.0/board/{boardId}/epic/none/issue` | Cloud: token; Data Center: offset | Board count endpoint with JQL `parent = null`; `reconcileIssues` accepts up to 50 IDs and must remain constant across pages | Read; view board and browse issues | `read:epic:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `Get-AgilePageItem`, `ConvertTo-Issue` | [Unit](../Tests/Functions/Public/Get-Issue.Unit.Tests.ps1), [Route resolver](../Tests/Functions/Private/Resolve-JiraSoftwareRoute.Unit.Tests.ps1) | Cloud parity canary when fixtures exist | Cloud route, token pagination, count, and reconciliation migrated |
| [`Get-JiraAgileIssueApproximateCount`](../JiraAgilePSVII/Public/Get-IssueApproximateCount.ps1) | `_Board` | GET | `/rest/software/1.0/board/{boardId}/issue/approximate-count` | Current Cloud-only route | Unsupported | None | Returns approximate count; optional JQL forwarded as `jql` | Read; view board and browse issues | `read:board-scope:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `ConvertTo-IssueApproximateCount` | [Unit](../Tests/Functions/Public/Get-IssueApproximateCount.Unit.Tests.ps1) | Cloud parity canary when fixtures exist | Cloud-only count command; Data Center rejected |
| [`Get-JiraAgileIssueApproximateCount`](../JiraAgilePSVII/Public/Get-IssueApproximateCount.ps1) | `_Backlog` | GET | `/rest/software/1.0/board/{boardId}/backlog/approximate-count` | Current Cloud-only route | Unsupported | None | Returns approximate count; optional JQL forwarded as `jql` | Read; view board and browse backlog issues | `read:board-scope:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `ConvertTo-IssueApproximateCount` | [Unit](../Tests/Functions/Public/Get-IssueApproximateCount.Unit.Tests.ps1) | Cloud parity canary when fixtures exist | Cloud-only count command; Data Center rejected |
| [`Get-JiraAgileIssueApproximateCount`](../JiraAgilePSVII/Public/Get-IssueApproximateCount.ps1) | `_Sprint` | GET | `/rest/software/1.0/board/{boardId}/issue/approximate-count` with JQL `sprint = {sprintId}` | Current Cloud-only route | Unsupported | None | Returns approximate count; optional JQL is parenthesized and combined with sprint JQL | Read; view board/sprint and browse issues | `read:sprint:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `ConvertTo-IssueApproximateCount` | [Unit](../Tests/Functions/Public/Get-IssueApproximateCount.Unit.Tests.ps1) | Cloud parity canary when fixtures exist | Cloud-only count command; Data Center rejected |
| [`Get-JiraAgileIssueApproximateCount`](../JiraAgilePSVII/Public/Get-IssueApproximateCount.ps1) | `_Epic` | POST | `/rest/api/3/search/approximate-count` with JQL `parent = {epicId}` | Current Cloud-only route | Unsupported | None | Returns approximate count; optional JQL is parenthesized and combined with epic JQL | Read; view epic and browse issues | `read:epic:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `ConvertTo-IssueApproximateCount` | [Unit](../Tests/Functions/Public/Get-IssueApproximateCount.Unit.Tests.ps1) | Cloud parity canary when fixtures exist | Cloud-only count command; Data Center rejected |
| [`Get-JiraAgileIssueApproximateCount`](../JiraAgilePSVII/Public/Get-IssueApproximateCount.ps1) | `_BoardEpic` | GET | `/rest/software/1.0/board/{boardId}/issue/approximate-count` with JQL `parent = {epicId}` | Current Cloud-only route | Unsupported | None | Returns approximate count; optional JQL is parenthesized and combined with epic JQL | Read; view board/epic and browse issues | `read:epic:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `ConvertTo-IssueApproximateCount` | [Unit](../Tests/Functions/Public/Get-IssueApproximateCount.Unit.Tests.ps1) | Cloud parity canary when fixtures exist | Cloud-only count command; Data Center rejected |
| [`Get-JiraAgileIssueApproximateCount`](../JiraAgilePSVII/Public/Get-IssueApproximateCount.ps1) | `_BoardWithoutEpic` | GET | `/rest/software/1.0/board/{boardId}/issue/approximate-count` with JQL `parent = null` | Current Cloud-only route | Unsupported | None | Returns approximate count; optional JQL is parenthesized and combined with no-epic JQL | Read; view board and browse issues | `read:epic:jira-software`, `read:issue-details:jira`, `read:jql:jira` | `ConvertTo-IssueApproximateCount` | [Unit](../Tests/Functions/Public/Get-IssueApproximateCount.Unit.Tests.ps1) | Cloud parity canary when fixtures exist | Cloud-only count command; Data Center rejected |
| [`Get-JiraAgileSprint`](../JiraAgilePSVII/Public/Get-Sprint.ps1) | `_All` | GET | `/rest/agile/1.0/board/{boardId}/sprint` | Same; current documented route | Same | Offset through JiraPSVII transport | N/A | Read; view board sprints | `read:sprint:jira-software` | `ConvertTo-Sprint` | [Unit](../Tests/Functions/Public/Get-Sprint.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) | Current |
| [`Get-JiraAgileSprint`](../JiraAgilePSVII/Public/Get-Sprint.ps1) | `_ById` | GET | `/rest/agile/1.0/sprint/{sprintId}` | Same; current documented route | Same | None; one request per sprint | N/A | Read; view sprint or its issues | `read:sprint:jira-software` | `ConvertTo-Sprint` | [Unit](../Tests/Functions/Public/Get-Sprint.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) when a sprint exists | Current |
| [`Move-JiraAgileIssueToBacklog`](../JiraAgilePSVII/Public/Move-IssueToBacklog.ps1) | `__AllParameterSets` | POST | `/rest/agile/1.0/backlog/issue` | Same; not in the issue-list deprecation | Same | Input batches of 50; no response paging | N/A | Write; edit issues and change sprint assignment | `write:board-scope:jira-software` | None | [Unit](../Tests/Functions/Public/Move-IssueToBacklog.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) when disposable fixtures exist | Current; write-sensitive |
| [`New-JiraAgileSprint`](../JiraAgilePSVII/Public/New-Sprint.ps1) | `__AllParameterSets` | POST | `/rest/agile/1.0/sprint` | Same; current documented route | Same | None | N/A | Write/board-admin; manage sprints | `write:sprint:jira-software` | `ConvertTo-Sprint` | [Unit](../Tests/Functions/Public/New-Sprint.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) when a disposable board exists | Current; board-admin write |
| [`Remove-JiraAgileSprint`](../JiraAgilePSVII/Public/Remove-Sprint.ps1) | `__AllParameterSets` | DELETE | `/rest/agile/1.0/sprint/{sprintId}` | Same; current documented route | Same | None | N/A | Destructive/board-admin; manage sprints | `write:sprint:jira-software` | None | [Unit](../Tests/Functions/Public/Remove-Sprint.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) with a disposable sprint | Current; destructive and confirmation-protected |
| [`Set-JiraAgileSprint`](../JiraAgilePSVII/Public/Set-Sprint.ps1) | `__AllParameterSets` | POST | `/rest/agile/1.0/sprint/{sprintId}` partial update | Same; current documented route | Same | None | N/A | Write/board-admin; manage sprints | `write:sprint:jira-software` | `ConvertTo-Sprint` | [Unit](../Tests/Functions/Public/Set-Sprint.Unit.Tests.ps1) | [Parity](../Tests/Integration/AgileParity.Integration.Tests.ps1) with a disposable sprint | Current; state transitions are operationally sensitive |

## Cloud issue-list migration contract

All six enhanced Cloud issue-list routes:

- replace `startAt` with opaque `nextPageToken`;
- retain `maxResults`;
- return `isLast` and omit `total`;
- accept `reconcileIssues` with at most 50 issue IDs;
- require the same `reconcileIssues` values on every page;
- preserve JQL, field, expand, and validation options supported by the selected endpoint.

The migration must treat tokens as opaque and fetch pages sequentially.
PowerShell `-Skip` can only be implemented by reading and discarding results in order.
`-IncludeTotalCount` cannot be synthesized from the enhanced list response.
Callers that explicitly request a count should use the mapped approximate-count operation and must understand that the result can be eventually consistent.

Data Center keeps offset pagination and its `total` response.
The shared public output must remain typed as JiraPSVII-compatible issues even though Cloud and Data Center wire envelopes differ.

## Security and permission classes

| Class | Commands | Review requirement |
|---|---|---|
| Read | Board, epic, sprint, and issue retrieval | Use only the documented read scopes and test restricted board/project visibility. |
| Write | Sprint assignment, backlog movement, sprint creation/update | Require edit/manage permission, preserve `ShouldProcess`, and limit batches to 50 issues. |
| Board-admin | Board configuration and sprint management | Do not use administrator credentials merely to make read tests pass; verify least-privilege board access. |
| Destructive | Sprint deletion | Require confirmation, disposable fixtures, and explicit cleanup verification. |

Issue results can include personal data, restricted fields, security-level content, sprint history, and rank information.
Fixtures and test output must be synthetic or redacted.
OAuth tokens, API tokens, cookies, account IDs, tenant URLs, and issue content must not be written to this matrix or persisted in test artifacts.

## Coverage gaps and next actions

1. Run live Cloud canaries for `_Sprint`, `_Epic`, `_BoardEpic`, `_BoardWithoutEpic`, and approximate-count scopes before release.
2. Retain and run Data Center parity tests for all six legacy offset routes.
3. Add a direct `_ById` epic canary.
4. Publish the prerelease and stable release only after release credentials are available and the Cloud canaries have completed their observation window.

## Maintenance rules

- Add a matrix row in the same change that adds an exported command or parameter set.
- Keep one unique row for every exported command/parameter-set pair.
- Keep source and test links relative so the documentation test can validate them.
- Mark Cloud-only, Data Center-only, deprecated, experimental, destructive, or unverified behavior explicitly.
- Update the current route, target route, permissions, scopes, and coverage together when an API migration lands.

## Official references

- [Jira Software Cloud REST API](https://developer.atlassian.com/cloud/jira/software/rest/intro/)
- [Jira Software Cloud board operations](https://developer.atlassian.com/cloud/jira/software/rest/api-group-board/)
- [Jira Software Cloud sprint operations](https://developer.atlassian.com/cloud/jira/software/rest/api-group-sprint/)
- [Jira Software Cloud epic operations](https://developer.atlassian.com/cloud/jira/software/rest/api-group-epic/)
- [Jira Software Cloud changelog and enhanced-route mapping](https://developer.atlassian.com/cloud/jira/software/changelog/)
- [Jira Software Data Center REST API](https://docs.atlassian.com/jira-software/REST/latest/)
