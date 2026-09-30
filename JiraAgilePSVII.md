# JiraAgilePSVII current state

Reviewed: 2026-07-27

## Purpose

`JiraAgilePSVII` adds PowerShell cmdlets for Jira Software boards, sprints, epics, backlogs, and Agile issue listings.
It builds on JiraPSVII for authentication, server configuration, transport, and core issue types.

## How it works

- The manifest is version `0.1`, declares PowerShell 3.0, requires JiraPSVII, and applies the `JiraAgile` default prefix.
- Ten public source files implement board/configuration, sprint CRUD, epic reads, issue listing, sprint assignment, and backlog movement.
- Eleven private files convert Agile response objects and unwrap paginated values.
- Every product request is routed through JiraPSVII `Invoke-JiraMethod`.
- Current routes use `/rest/agile/1.0`.
- Public source names are unprefixed; imported commands receive names such as `Get-JiraAgileBoard`.

Snapshot: branch `master`, last local commit `3e195d8` dated 2026-05-31.
Three workflow files had pre-existing line-ending-only working-tree changes during review; this report did not modify them.

## Testing and delivery

- 25 `*.Tests.ps1` files are present: 16 named unit-test files and 2 integration-test files, plus build/help/example/manifest suites.
- Unit tests cover public commands and private converters/helpers.
- CI lints, builds, performs a release dry-run, tests Windows PowerShell 5.1 and PowerShell 7 across Windows/Linux/macOS, and runs Cloud smoke tests when secrets are available.
- Scheduled/manual integration workflows cover Cloud and Dockerized Jira Data Center.
- Build dependencies pin Pester 5.7.1, JiraPSVII 2.16.0, and Standards 0.1.2.

## Current strengths

- The first practical command set and corresponding tests were delivered in 2026.
- Transport and authentication correctly remain in JiraPSVII.
- Cloud/Data Center integration scaffolding exists.
- The command prefix avoids collisions with JiraPSVII.
- `docs/agile-api-coverage-matrix.md` provides a useful endpoint planning pattern.

## Gaps and risks

1. Critical: every issue-listing route implemented by `Get-JiraAgileIssue` is in Atlassian's 2026 Cloud deprecation set.
   The legacy routes will be removed after 2026-11-01.
2. Cloud replacements use `/rest/software/1.0/...` and continuation tokens (`nextPageToken`) instead of `startAt`; `total` is no longer returned.
3. Data Center still uses the legacy Agile routes, so routing and pagination must become deployment-aware without breaking public output.
4. `docs/agile-api-coverage-matrix.md` is stale: its "current coverage" section lists only three cmdlets even though ten public commands now exist.
5. The manifest/build requirement still references JiraPSVII 2.16.0 while the local JiraPSVII source is 3.0.0.
   Compatibility with JiraPSVII 3 types and removed parameters needs an explicit tested release requirement.
6. `PowerShellVersion = '3.0'` does not match the effective CI baseline.
7. The local Standards dependency is far behind 0.1.12.
8. Cloud write consistency and approximate counts are not represented in the public design.

## Recommended update plan

### Urgent: complete before 2026-11-01

1. Add a Cloud route table from each affected `/rest/agile/1.0` issue-list endpoint to its `/rest/software/1.0` enhanced equivalent.
2. Implement continuation-token pagination and treat `total` as optional.
3. Preserve current `/rest/agile/1.0` offset pagination for Data Center behind deployment detection.
4. Add Cloud contract fixtures and live canaries for board, backlog, sprint, epic, and no-epic issue listing.
5. Add optional `reconcileIssues` support and separate approximate-count commands or switches where useful.
6. Emit actionable diagnostics when responses contain deprecation/sunset headers.

### Next

7. Update the coverage matrix to the actual ten-command surface and mark endpoint behavior separately for Cloud and Data Center.
8. Validate and declare JiraPSVII 3.x compatibility; update argument handling noted by the existing `Add-IssueToSprint` TODO.
9. Align the Standards dependency and action pins with the current shared release blueprint.
10. Raise the minimum PowerShell version in the next intentional compatibility release.
11. Add typed Agile domain models and stable output contracts rather than exposing loosely shaped responses.
12. Plan Data Center maintenance mode toward Atlassian's 2029 end-of-life date.

## Primary platform references

- Jira Software Cloud deprecation notice and enhanced endpoint mapping: <https://developer.atlassian.com/cloud/jira/software/changelog/>
- Jira Software Cloud REST API: <https://developer.atlassian.com/cloud/jira/software/rest/intro/>
- Jira Software Data Center REST API: <https://docs.atlassian.com/jira-software/REST/latest/>
- Data Center end of life: <https://www.atlassian.com/licensing/data-center-end-of-life>

## Review boundary

This was a static review.
No authenticated integration tests or full build were executed.

