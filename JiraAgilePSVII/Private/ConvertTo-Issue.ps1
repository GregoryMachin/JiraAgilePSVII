function ConvertTo-Issue {
    <#
    .SYNOPSIS
        Converts Jira issue payloads to typed Issue objects.

    .DESCRIPTION
        Copies all properties from each issue response object and applies the
        AtlassianPSVII.JiraAgilePSVII.Issue typename to preserve rich output typing.
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

            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to AtlassianPSVII.JiraAgilePSVII.Issue"

            $issue = [PSCustomObject](ConvertTo-Hashtable -InputObject ($object | Select-Object -Property *))
            foreach ($typeName in @($object.PSObject.TypeNames)) {
                if ($typeName -like 'AtlassianPSVII.JiraPSVII.*' -and $issue.PSObject.TypeNames -notcontains $typeName) {
                    $issue.PSObject.TypeNames.Insert(0, $typeName)
                }
            }
            $issue.PSObject.TypeNames.Insert(0, "AtlassianPSVII.JiraAgilePSVII.Issue")

            $issue
        }
    }
}
