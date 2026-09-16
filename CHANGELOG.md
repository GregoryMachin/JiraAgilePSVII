# Change Log

## Unreleased

### Added

- Added `Tests/DataCenterSupportPolicy.Unit.Tests.ps1` (Phase 9 Task 61), asserting `docker-compose.yml` still pins the Data Center test image recorded in `Project/DataCenterMaintenance.md`'s version table, so an undocumented pin change fails the build. See that document for the supported-version table, test-image update cadence, security-fix criteria, Cloud migration guidance, and the 2029 retirement process, extending `Project/SupportPolicy.md`'s previously deferred "exact version and image cadence" note.
- Added scheduled API contract canaries (Phase 9 Task 60): `.github/workflows/api_canary.yml` runs a low-impact `CanaryRead` tier every 4 hours (reusing the existing `Agile smoke` check) and a bounded `CanaryWrite` tier once daily (a new `Tests/Integration/ApiCanary.Integration.Tests.ps1`, one disposable sprint through create/read/update/delete/confirm-gone on the first Scrum board the canary account can see), both Cloud-only and both against a dedicated, least-privilege `ATLASSIAN_CANARY_USER`/`ATLASSIAN_CANARY_PAT` account separate from the shared smoke/nightly credentials. Each run publishes a machine-readable per-operation result (`Tools/Publish-ApiCanaryResult.ps1`) as a workflow artifact. See `docs/ApiCanaries.md`, including the required manual account-provisioning step this environment cannot perform itself, and why the results format is hand-built rather than calling `AtlassianPS.Standards`' already-written `ConvertTo-ApiCanaryResult` (that function has never been published; this repository still pins the release that predates it).

### Changed

- Raised the minimum supported PowerShell version from 3.0 to 5.1 (Phase 9 Task 59), aligning the manifest's declared `PowerShellVersion` with CI reality: the CI matrix has never actually tested PowerShell 3.0/4.0, only Windows PowerShell 5.x and current PowerShell 7.x, and this module's own required dependency, `JiraPS`, already declares `PowerShellVersion = '5.1'`, so the previous `3.0` declaration was already inconsistent in practice. No PowerShell 3.0/4.0-specific compatibility code was found to remove.
- Declared the source manifest's `FunctionsToExport`/`AliasesToExport` explicitly instead of `'*'` (Phase 9 Task 58), making the manifest's `FunctionsToExport` this module's committed compatibility baseline, and added new `Tests/Project.Tests.ps1` assertions that fail the build if the declared list drifts from the actual `Public/` folder contents. Module behavior is unchanged: `JiraAgilePS.psm1` already restricted runtime exports to `Public/*.ps1` via `Export-ModuleMember`, and no persistent alias was ever actually exported despite the wildcard.
- Updated the shared build dependency and workflow action pins to `AtlassianPS.Standards` `0.1.11`.
- Updated the build dependency pin and compatibility tests for JiraPS `3.0.0`.
- Added deployment-aware Jira Software route selection for `Get-JiraAgileIssue`, using enhanced Cloud issue-list routes while preserving Data Center Agile routes.
- Migrated `Get-JiraAgileIssue` issue-list behavior to JiraPS token pagination for Cloud, forwarded JQL/field/expand query options, and preserved JiraPS issue typing in Agile issue output.
- Added Cloud-only `Get-JiraAgileIssueApproximateCount` for board, backlog, sprint, epic, board-epic, and no-epic issue count scopes.
- Added Cloud-only `Get-JiraAgileIssue -ReconcileIssue` support for up to 50 unique numeric Jira issue IDs.
- Added live parity canaries for migrated Cloud issue-list, reconciliation, and approximate-count scopes.

## 0.1 - 2026-05-20

### Added

- Added Cloud and Data Center integration smoke test wiring with fail-fast environment validation.
- Added `Get-JiraAgileIssue` with board, backlog, and sprint parameter sets for:
  - `GET /rest/agile/1.0/board/{boardId}/issue`
  - `GET /rest/agile/1.0/board/{boardId}/backlog`
  - `GET /rest/agile/1.0/board/{boardId}/sprint/{sprintId}/issue`
- Extended `Get-JiraAgileIssue` with epic parameter sets for:
  - `GET /rest/agile/1.0/epic/{epicId}/issue`
  - `GET /rest/agile/1.0/board/{boardId}/epic/{epicId}/issue`
  - `GET /rest/agile/1.0/board/{boardId}/epic/none/issue`
- Added `Get-JiraAgileBoardConfiguration` for `GET /rest/agile/1.0/board/{boardId}/configuration`
- Added `Get-JiraAgileEpic` with direct epic and board-scoped parameter sets for:
  - `GET /rest/agile/1.0/epic/{epicId}`
  - `GET /rest/agile/1.0/board/{boardId}/epic`
- Added first-release write cmdlets for Jira Agile sprint and backlog operations:
  - `Move-JiraAgileIssueToBacklog` for `POST /rest/agile/1.0/backlog/issue`
  - `New-JiraAgileSprint` for `POST /rest/agile/1.0/sprint`
  - `Set-JiraAgileSprint` for `POST /rest/agile/1.0/sprint/{sprintId}`
  - `Remove-JiraAgileSprint` for `DELETE /rest/agile/1.0/sprint/{sprintId}`
- Added conversion helpers for paged Agile issue/epic responses and board configuration payloads

### Changed

- Harmonized integration test environment setup with JiraPS by adopting `.env.example` and a shared-style `.env` loader/validator in `Tests/Helpers/IntegrationTestTools.ps1`.
- Added JiraPS-style test guidance and private helper/converter unit coverage for JiraAgilePS.
- Documented the release readiness checklist, required secrets, dry-run validation, prerelease path, and stable release path for JiraAgilePS v0.1.0.

### Fixed

- Added support for Jira Cloud `simple` board payloads returned by the Agile board API.

<!-- reference-style links -->

[@lipkau]: https://github.com/lipkau
