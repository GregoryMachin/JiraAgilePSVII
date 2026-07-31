---
external help file: JiraAgilePS-help.xml
Module Name: JiraAgilePS
online version: https://atlassianps.org/docs/JiraAgilePS/commands/Get-Issue/
locale: en-US
layout: documentation
permalink: /docs/JiraAgilePS/commands/Get-Issue/
---
# Get-Issue

## SYNOPSIS

Gets Jira Agile issues across board, backlog, sprint, and epic scopes.

## SYNTAX

### _Board (Default)

```powershell
Get-Issue [-Board] <Board> [[-PageSize] <UInt32>] [-Query <String>] [-Fields <String[]>] [-Expand <String[]>] [-ReconcileIssue <Object[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### _Backlog

```powershell
Get-Issue [-Board] <Board> -Backlog [[-PageSize] <UInt32>] [-Query <String>] [-Fields <String[]>] [-Expand <String[]>] [-ReconcileIssue <Object[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### _Sprint

```powershell
Get-Issue [-Board] <Board> [-Sprint] <Sprint[]> [[-PageSize] <UInt32>] [-Query <String>] [-Fields <String[]>] [-Expand <String[]>] [-ReconcileIssue <Object[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### _Epic

```powershell
Get-Issue [-Epic] <Epic[]> [[-PageSize] <UInt32>] [-Query <String>] [-Fields <String[]>] [-Expand <String[]>] [-ReconcileIssue <Object[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### _BoardEpic

```powershell
Get-Issue [-Board] <Board> [-Epic] <Epic[]> [[-PageSize] <UInt32>] [-Query <String>] [-Fields <String[]>] [-Expand <String[]>] [-ReconcileIssue <Object[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### _BoardWithoutEpic

```powershell
Get-Issue [-Board] <Board> -WithoutEpic [[-PageSize] <UInt32>] [-Query <String>] [-Fields <String[]>] [-Expand <String[]>] [-ReconcileIssue <Object[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

`Get-Issue` consolidates Jira Agile issue retrieval endpoints.
For Jira Cloud, issue-list operations use the enhanced Jira Software route family under `/rest/software/1.0`.
For Jira Data Center, the command preserves the existing `/rest/agile/1.0` route family.

- Cloud: `GET /rest/software/1.0/board/{boardId}/issue`; Data Center: `GET /rest/agile/1.0/board/{boardId}/issue`.
- Cloud: `GET /rest/software/1.0/board/{boardId}/backlog`; Data Center: `GET /rest/agile/1.0/board/{boardId}/backlog`.
- Cloud: `GET /rest/software/1.0/board/{boardId}/sprint/{sprintId}/issue`; Data Center: `GET /rest/agile/1.0/board/{boardId}/sprint/{sprintId}/issue`.
- Cloud: `GET /rest/software/1.0/epic/{epicId}/issue`; Data Center: `GET /rest/agile/1.0/epic/{epicId}/issue`.
- Cloud: `GET /rest/software/1.0/board/{boardId}/epic/{epicId}/issue`; Data Center: `GET /rest/agile/1.0/board/{boardId}/epic/{epicId}/issue`.
- Cloud: `GET /rest/software/1.0/board/{boardId}/epic/none/issue`; Data Center: `GET /rest/agile/1.0/board/{boardId}/epic/none/issue`.

The command supports paging and converts issue results into JiraAgilePS issue objects while preserving JiraPS issue typing.
Cloud issue-list routes use token pagination (`nextPageToken`/`isLast`) through JiraPS; Data Center routes keep offset pagination.
`-Query`, `-Fields`, and `-Expand` are forwarded as query parameters to Jira.
`-ReconcileIssue` is Cloud-only and forwards up to 50 unique numeric Jira issue IDs through the enhanced issue-list reconciliation option.

## EXAMPLES

### EXAMPLE 1

```powershell
$board = JiraAgilePS\Get-Board -BoardId 7 -Credential $cred
JiraAgilePS\Get-Issue -Board $board -Credential $cred
```

Returns issues visible on board 7.

### EXAMPLE 2

```powershell
$board = JiraAgilePS\Get-Board -BoardId 7 -Credential $cred
JiraAgilePS\Get-Issue -Board $board -Backlog -Credential $cred
```

Returns backlog issues for board 7.

### EXAMPLE 3

```powershell
$board = JiraAgilePS\Get-Board -BoardId 7 -Credential $cred
$sprint = JiraAgilePS\Get-Sprint -Board $board -State Active -Credential $cred | Select-Object -First 1
JiraAgilePS\Get-Issue -Board $board -Sprint $sprint -Credential $cred
```

Returns issues for the active sprint.

### EXAMPLE 4

```powershell
$epic = [AtlassianPS.JiraAgilePS.Epic]::new(10001)
JiraAgilePS\Get-Issue -Epic $epic -Credential $cred
```

Returns issues for epic 10001.

### EXAMPLE 5

```powershell
$board = JiraAgilePS\Get-Board -BoardId 7 -Credential $cred
$epic = [AtlassianPS.JiraAgilePS.Epic]::new(10001)
JiraAgilePS\Get-Issue -Board $board -Epic $epic -Credential $cred
```

Returns board-scoped issues for the epic.

### EXAMPLE 6

```powershell
$board = JiraAgilePS\Get-Board -BoardId 7 -Credential $cred
JiraAgilePS\Get-Issue -Board $board -WithoutEpic -Credential $cred
```

Returns board issues that are not assigned to an epic.

### EXAMPLE 7

```powershell
$board = JiraAgilePS\Get-Board -BoardId 7 -Credential $cred
JiraAgilePS\Get-Issue -Board $board -Query 'project = AG ORDER BY rank' -Fields key,summary,status -Credential $cred
```

Returns board issues matching the JQL expression with only the requested fields.

### EXAMPLE 8

```powershell
$board = JiraAgilePS\Get-Board -BoardId 7 -Credential $cred
JiraAgilePS\Get-Issue -Board $board -ReconcileIssue 10000,10001 -Credential $cred
```

Returns board issues while asking Jira Cloud to reconcile the supplied issue IDs during eventually consistent search.

## PARAMETERS

### -Board

Board object to query.

```yaml
Type: Board
Parameter Sets: _Board, _Backlog, _Sprint, _BoardEpic, _BoardWithoutEpic
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Backlog

Switch to retrieve backlog issues for the specified board.

```yaml
Type: SwitchParameter
Parameter Sets: _Backlog
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sprint

One or more sprint objects to retrieve sprint-scoped issues.

```yaml
Type: Sprint[]
Parameter Sets: _Sprint
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Epic

One or more epic objects/identifiers to retrieve epic-scoped issues.

```yaml
Type: Epic[]
Parameter Sets: _Epic, _BoardEpic
Aliases:

Required: True
Position: 0 (_Epic), 1 (_BoardEpic)
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WithoutEpic

Switch to retrieve board issues that have no epic assignment.

```yaml
Type: SwitchParameter
Parameter Sets: _BoardWithoutEpic
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize

Maximum number of issues requested per page.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 25
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query

JQL expression forwarded to Jira for additional issue filtering.

```yaml
Type: String
Parameter Sets: (All)
Aliases: JQL

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Fields

Issue fields to request from Jira.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Expand

Issue expansions to request from Jira.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReconcileIssue

Cloud-only Jira issue IDs, or JiraPS issue objects with numeric `Id` values, to reconcile during enhanced issue-list retrieval.
The command deduplicates values and accepts at most 50 unique IDs.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Credentials used for Jira authentication.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: [System.Management.Automation.PSCredential]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeTotalCount

Causes an extra output of the total count at the beginning of paged output.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skip

Controls how many items are skipped before output starts.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -First

Controls how many items are returned.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 18446744073709551615
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### AtlassianPS.JiraAgilePS.Board

### AtlassianPS.JiraAgilePS.Sprint[]

### AtlassianPS.JiraAgilePS.Epic[]

## OUTPUTS

### AtlassianPS.JiraAgilePS.Issue

## NOTES

Use `Get-JiraAgileIssue` in normal module usage. `Get-Issue` is the source function name.

## RELATED LINKS

[Get-BoardConfiguration](../Get-BoardConfiguration/)

[Get-Epic](../Get-Epic/)
