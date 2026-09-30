function Resolve-JiraSoftwareRoute {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $BaseUri,

        [Parameter(Mandatory)]
        [ValidateSet('BoardIssue', 'BacklogIssue', 'SprintIssue', 'EpicIssue', 'BoardEpicIssue', 'BoardWithoutEpicIssue')]
        [String]
        $Operation,

        [Parameter()]
        [ValidateSet('', 'Cloud', 'DataCenter', 'Server')]
        [String]
        $DeploymentType,

        [Parameter()]
        [UInt64]
        $BoardId,

        [Parameter()]
        [UInt64]
        $SprintId,

        [Parameter()]
        [UInt64]
        $EpicId
    )

    process {
        $deployment = if ([String]::IsNullOrWhiteSpace($DeploymentType)) { 'DataCenter' } else { $DeploymentType }
        if ($deployment -eq 'Server') {
            $deployment = 'DataCenter'
        }

        $apiRoot = switch ($deployment) {
            'Cloud' { 'rest/software/1.0' }
            'DataCenter' { 'rest/agile/1.0' }
            default { throw "Unsupported Jira Software DeploymentType '$DeploymentType'." }
        }

        $base = $BaseUri.TrimEnd('/')

        switch ($Operation) {
            'BoardIssue' {
                Assert-JiraSoftwareRouteId -Name BoardId -Value $BoardId
                return "$base/$apiRoot/board/$BoardId/issue"
            }
            'BacklogIssue' {
                Assert-JiraSoftwareRouteId -Name BoardId -Value $BoardId
                return "$base/$apiRoot/board/$BoardId/backlog"
            }
            'SprintIssue' {
                Assert-JiraSoftwareRouteId -Name BoardId -Value $BoardId
                Assert-JiraSoftwareRouteId -Name SprintId -Value $SprintId
                return "$base/$apiRoot/board/$BoardId/sprint/$SprintId/issue"
            }
            'EpicIssue' {
                Assert-JiraSoftwareRouteId -Name EpicId -Value $EpicId
                return "$base/$apiRoot/epic/$EpicId/issue"
            }
            'BoardEpicIssue' {
                Assert-JiraSoftwareRouteId -Name BoardId -Value $BoardId
                Assert-JiraSoftwareRouteId -Name EpicId -Value $EpicId
                return "$base/$apiRoot/board/$BoardId/epic/$EpicId/issue"
            }
            'BoardWithoutEpicIssue' {
                Assert-JiraSoftwareRouteId -Name BoardId -Value $BoardId
                return "$base/$apiRoot/board/$BoardId/epic/none/issue"
            }
        }
    }
}

function Assert-JiraSoftwareRouteId {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]
        $Name,

        [Parameter()]
        [UInt64]
        $Value
    )

    if ($Value -eq 0) {
        throw "Jira Software route value '$Name' must be a non-zero numeric identifier."
    }
}
