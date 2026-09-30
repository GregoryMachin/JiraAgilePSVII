function ConvertTo-Board {
    <#
    .SYNOPSIS
        Converts Jira Agile board payloads to Board objects.

    .DESCRIPTION
        Selects the board properties used by JiraAgilePSVII and casts each
        pipeline input object to [AtlassianPSVII.JiraAgilePSVII.Board].
    #>
    [CmdletBinding()]
    [OutputType( [AtlassianPSVII.JiraAgilePSVII.Board] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$object to custom object"

            [AtlassianPSVII.JiraAgilePSVII.Board](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        Id,
                    Name,
                    Type,
                    Self
                )
            )
        }
    }
}


