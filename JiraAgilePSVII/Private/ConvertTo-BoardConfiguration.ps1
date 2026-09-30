function ConvertTo-BoardConfiguration {
    <#
    .SYNOPSIS
        Converts board configuration responses to typed objects.

    .DESCRIPTION
        Clones each response object into a PSCustomObject and applies the
        AtlassianPSVII.JiraAgilePSVII.BoardConfiguration typename for formatting
        and downstream processing.
    #>
    [CmdletBinding()]
    [OutputType([PSObject])]
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

            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to AtlassianPSVII.JiraAgilePSVII.BoardConfiguration"

            $configuration = [PSCustomObject](ConvertTo-Hashtable -InputObject ($object | Select-Object -Property *))
            $configuration.PSObject.TypeNames.Insert(0, "AtlassianPSVII.JiraAgilePSVII.BoardConfiguration")

            $configuration
        }
    }
}
