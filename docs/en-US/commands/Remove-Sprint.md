---
external help file: JiraAgilePSVII-help.xml
Module Name: JiraAgilePSVII
online version: https://github.com/GregoryMachin/JiraAgilePSVII/blob/master/docs/en-US/commands/Remove-Sprint.md
locale: en-US
---
# Remove-Sprint

## SYNOPSIS

Deletes Jira Agile sprints.

## SYNTAX

```powershell
Remove-Sprint [-Sprint] <Sprint[]> [-Credential <PSCredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

`Remove-Sprint` deletes one or more Jira Agile sprints.

When Jira deletes a sprint, open issues in that sprint are moved to the backlog.

When imported normally, run this command as `Remove-JiraAgileSprint`.

## EXAMPLES

### EXAMPLE 1

```powershell
$sprint = [AtlassianPSVII.JiraAgilePSVII.Sprint]::new(42)
JiraAgilePSVII\Remove-Sprint -Sprint $sprint -Credential $cred -Confirm:$false
```

Deletes sprint 42 without an interactive confirmation prompt.

### EXAMPLE 2

```powershell
$sprints = JiraAgilePSVII\Get-Sprint -Board $board -State Future -Credential $cred
$sprints | JiraAgilePSVII\Remove-Sprint -Credential $cred -WhatIf
```

Shows which future sprints would be deleted without deleting them.

## PARAMETERS

### -Sprint

Sprint object(s) to delete.

```yaml
Type: Sprint[]
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

### AtlassianPSVII.JiraAgilePSVII.Sprint[]

## OUTPUTS

### System.Void

## NOTES

This command does not emit output on success.

Use `Remove-JiraAgileSprint` in normal module usage. `Remove-Sprint` is the source function name.

## RELATED LINKS

[Get-Sprint](../Get-Sprint/)

[New-Sprint](../New-Sprint/)
