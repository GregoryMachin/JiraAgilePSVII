---
external help file: JiraAgilePSVII-help.xml
Module Name: JiraAgilePSVII
online version: https://atlassianps.org/docs/JiraAgilePS/commands/Get-IssueApproximateCount/
locale: en-US
layout: documentation
permalink: /docs/JiraAgilePS/commands/Get-IssueApproximateCount/
---
# Get-IssueApproximateCount

## SYNOPSIS

Gets approximate Jira Agile issue counts for Jira Cloud board, backlog, sprint, and epic scopes.

## SYNTAX

### _Board (Default)

```powershell
Get-IssueApproximateCount [-Board] <Board> [-Query <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

### _Backlog

```powershell
Get-IssueApproximateCount [-Board] <Board> -Backlog [-Query <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

### _Sprint

```powershell
Get-IssueApproximateCount [-Board] <Board> [-Sprint] <Sprint[]> [-Query <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

### _Epic

```powershell
Get-IssueApproximateCount [-Epic] <Epic[]> [-Query <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

### _BoardEpic

```powershell
Get-IssueApproximateCount [-Board] <Board> [-Epic] <Epic[]> [-Query <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

### _BoardWithoutEpic

```powershell
Get-IssueApproximateCount [-Board] <Board> -WithoutEpic [-Query <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

`Get-IssueApproximateCount` returns Jira Cloud approximate counts without retrieving every issue.
Board and backlog scopes use Jira Software Cloud approximate-count endpoints under `/rest/software/1.0`.
Sprint, board-epic, and no-epic counts use the board approximate-count endpoint with generated JQL clauses.
Epic-only counts use Jira Cloud search approximate count.

This command is Cloud-only. Jira Data Center does not support these enhanced approximate-count routes.
Counts are permission-scoped and can be eventually consistent.

## EXAMPLES

### EXAMPLE 1

```powershell
$board = JiraAgilePSVII\Get-Board -BoardId 7 -Credential $cred
JiraAgilePSVII\Get-IssueApproximateCount -Board $board -Credential $cred
```

Returns an approximate count for issues visible on board 7.

### EXAMPLE 2

```powershell
$board = JiraAgilePSVII\Get-Board -BoardId 7 -Credential $cred
JiraAgilePSVII\Get-IssueApproximateCount -Board $board -Backlog -Query 'project = AG' -Credential $cred
```

Returns an approximate backlog count filtered by the supplied JQL.

### EXAMPLE 3

```powershell
$board = JiraAgilePSVII\Get-Board -BoardId 7 -Credential $cred
$sprint = JiraAgilePSVII\Get-Sprint -Board $board -State Active -Credential $cred | Select-Object -First 1
JiraAgilePSVII\Get-IssueApproximateCount -Board $board -Sprint $sprint -Credential $cred
```

Returns an approximate count for issues in the sprint.

### EXAMPLE 4

```powershell
$epic = [AtlassianPSVII.JiraAgilePSVII.Epic]::new(10001)
JiraAgilePSVII\Get-IssueApproximateCount -Epic $epic -Credential $cred
```

Returns an approximate count for issues assigned to the epic.

### EXAMPLE 5

```powershell
$board = JiraAgilePSVII\Get-Board -BoardId 7 -Credential $cred
$epic = [AtlassianPSVII.JiraAgilePSVII.Epic]::new(10001)
JiraAgilePSVII\Get-IssueApproximateCount -Board $board -Epic $epic -Credential $cred
```

Returns an approximate board-scoped count for issues assigned to the epic.

### EXAMPLE 6

```powershell
$board = JiraAgilePSVII\Get-Board -BoardId 7 -Credential $cred
JiraAgilePSVII\Get-IssueApproximateCount -Board $board -WithoutEpic -Credential $cred
```

Returns an approximate count for board issues without an epic assignment.

## PARAMETERS

### -Board

Board object to count within.

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

Switch to count backlog issues for the specified board.

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

One or more sprint objects to count.

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

One or more epic objects to count.

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

Switch to count board issues that have no epic assignment.

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

### -Query

JQL expression combined with the generated count filter or forwarded directly to Jira.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### AtlassianPSVII.JiraAgilePSVII.Board

### AtlassianPSVII.JiraAgilePSVII.Sprint[]

### AtlassianPSVII.JiraAgilePSVII.Epic[]

## OUTPUTS

### AtlassianPSVII.JiraAgilePSVII.IssueApproximateCount

## NOTES

Use `Get-JiraAgileIssueApproximateCount` in normal module usage. `Get-IssueApproximateCount` is the source function name.

## RELATED LINKS

[Get-Issue](../Get-Issue/)
