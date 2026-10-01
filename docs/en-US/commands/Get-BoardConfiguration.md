---
external help file: JiraAgilePSVII-help.xml
Module Name: JiraAgilePSVII
online version: https://github.com/GregoryMachin/JiraAgilePSVII/blob/master/docs/en-US/commands/Get-BoardConfiguration.md
locale: en-US
---
# Get-BoardConfiguration

## SYNOPSIS

Gets configuration details for a Jira Agile board.

## SYNTAX

```powershell
Get-BoardConfiguration [-Board] <Board> [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

`Get-BoardConfiguration` calls:

- `GET /rest/agile/1.0/board/{boardId}/configuration`

Returns the board configuration payload as a typed JiraAgilePSVII board configuration object.

## EXAMPLES

### EXAMPLE 1

```powershell
$board = JiraAgilePSVII\Get-Board -BoardId 7 -Credential $cred
JiraAgilePSVII\Get-BoardConfiguration -Board $board -Credential $cred
```

Returns configuration details for board 7.

## PARAMETERS

### -Board

Board object to query.

```yaml
Type: Board
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
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

## OUTPUTS

### AtlassianPSVII.JiraAgilePSVII.BoardConfiguration

## NOTES

Use `Get-JiraAgileBoardConfiguration` in normal module usage. `Get-BoardConfiguration` is the source function name.

## RELATED LINKS

[Get-Issue](../Get-Issue/)

[Commands index](/docs/JiraAgilePS/commands/)
