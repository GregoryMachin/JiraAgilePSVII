function ConvertTo-Epic {
    <#
    .SYNOPSIS
        Converts Jira Agile epic payloads to Epic objects.

    .DESCRIPTION
        Maps API response fields to [AtlassianPSVII.JiraAgilePSVII.Epic], including
        normalization of color values returned as either strings or objects.
    #>
    [CmdletBinding()]
    [OutputType([AtlassianPSVII.JiraAgilePSVII.Epic])]
    param(
        [Parameter(ValueFromPipeline)]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            if ($null -eq $object) {
                continue
            }

            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to AtlassianPSVII.JiraAgilePSVII.Epic"

            [AtlassianPSVII.JiraAgilePSVII.Epic](ConvertTo-Hashtable -InputObject ($object | Select-Object `
                        Id,
                    Key,
                    Name,
                    Summary,
                    @{
                        Name       = 'Color'
                        Expression = {
                            if ($null -eq $object.color) {
                                $null
                            }
                            elseif ($object.color -is [String]) {
                                $object.color
                            }
                            elseif ($object.color.PSObject.Properties['key']) {
                                $object.color.key
                            }
                            elseif ($object.color.PSObject.Properties['name']) {
                                $object.color.name
                            }
                            else {
                                [String]$object.color
                            }
                        }
                    },
                    @{ Name = 'Done'; Expression = { [bool]$object.done } },
                    Self
                )
            )
        }
    }
}
