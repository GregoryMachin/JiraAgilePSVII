---
locale: en-US
layout: documentation
online version: https://atlassianps.org/docs/JiraAgilePS/about/automation-patterns.html
Module Name: JiraAgilePSVII
permalink: /docs/JiraAgilePS/about/automation-patterns.html
---
# Automation Patterns

## about_JiraAgilePSVII_AutomationPatterns

# SHORT DESCRIPTION

Practical scripting patterns for repeatable board/sprint automation.

# LONG DESCRIPTION

## Add all issues from a JQL query to the active sprint

```powershell
$board = JiraAgilePSVII\Get-Board -BoardId 42 -Credential $cred
$activeSprint = JiraAgilePSVII\Get-Sprint -Board $board -State Active -Credential $cred | Select-Object -First 1
$issues = Get-JiraIssue -Query 'project = APP AND status = "Selected for Development"' -Credential $cred

JiraAgilePSVII\Add-IssueToSprint -Issue $issues -Sprint $activeSprint -Credential $cred
```

## Resolve sprint context once, then pipeline issues

```powershell
$sprint = JiraAgilePSVII\Get-Sprint -Board $board -State Active -Credential $cred | Select-Object -First 1
Get-JiraIssue -Query 'project = APP AND labels = automation' -Credential $cred |
    JiraAgilePSVII\Add-IssueToSprint -Sprint $sprint -Credential $cred
```

## Defensive checks

Before mutating sprint assignments, validate assumptions:

```powershell
if (-not $board) { throw "Board not found." }
if (-not $sprint) { throw "No matching sprint found." }
if (-not $issues) { throw "No issues matched the query." }
```

# SEE ALSO

- [Get-JiraAgileBoard](/docs/JiraAgilePS/commands/Get-Board/)
- [Get-JiraAgileSprint](/docs/JiraAgilePS/commands/Get-Sprint/)
- [Get-JiraIssue](https://atlassianps.org/docs/JiraPS/commands/Get-JiraIssue/)
