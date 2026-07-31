function ConvertTo-IssueApproximateCount {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(ValueFromPipeline)]
        [PSObject[]]
        $InputObject,

        [Parameter()]
        [String]
        $Scope,

        [Parameter()]
        [UInt64]
        $BoardId,

        [Parameter()]
        [UInt64]
        $SprintId,

        [Parameter()]
        [UInt64]
        $EpicId,

        [Parameter()]
        [String]
        $Query
    )

    process {
        foreach ($object in $InputObject) {
            if ($null -eq $object) {
                continue
            }

            $count = if ($object.PSObject.Properties.Name -contains 'count') {
                [UInt64]$object.count
            }
            else {
                [UInt64]$object
            }

            $result = [PSCustomObject]@{
                Count    = $count
                Scope    = $Scope
                BoardId  = $BoardId
                SprintId = $SprintId
                EpicId   = $EpicId
                Query    = $Query
            }
            $result.PSObject.TypeNames.Insert(0, "AtlassianPS.JiraAgilePS.IssueApproximateCount")
            $result
        }
    }
}
