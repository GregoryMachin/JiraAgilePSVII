function Get-IssueApproximateCount {
    # .ExternalHelp ..\JiraAgilePSVII-help.xml
    [CmdletBinding(DefaultParameterSetName = '_Board')]
    [OutputType([PSObject])]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Board')]
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Backlog')]
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Sprint')]
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_BoardEpic')]
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_BoardWithoutEpic')]
        [AtlassianPSVII.JiraAgilePSVII.Board]
        $Board,

        [Parameter(Mandatory, ParameterSetName = '_Backlog')]
        [switch]
        $Backlog,

        [Parameter(Position = 1, Mandatory, ValueFromPipeline, ParameterSetName = '_Sprint')]
        [AtlassianPSVII.JiraAgilePSVII.Sprint[]]
        $Sprint,

        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Epic')]
        [Parameter(Position = 1, Mandatory, ValueFromPipeline, ParameterSetName = '_BoardEpic')]
        [AtlassianPSVII.JiraAgilePSVII.Epic[]]
        $Epic,

        [Parameter(Mandatory, ParameterSetName = '_BoardWithoutEpic')]
        [switch]
        $WithoutEpic,

        [Parameter()]
        [Alias('JQL')]
        [String]
        $Query,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop
        $serverInformation = Get-JiraServerInformation -Credential $Credential -ErrorAction Stop
        $deploymentType = $null
        if ($serverInformation.PSObject.Properties.Name -contains 'DeploymentType') {
            $deploymentType = $serverInformation.DeploymentType
        }
        if ($deploymentType -ne 'Cloud') {
            throw "[$($MyInvocation.MyCommand.Name)] Jira Agile issue approximate counts are supported only for Jira Cloud."
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"

        $requestParameter = @{
            Method     = "GET"
            Credential = $Credential
            Cmdlet     = $PSCmdlet
            Verbose    = $VerbosePreference
            Debug      = $DebugPreference
        }
        if ($PSBoundParameters.ContainsKey('Query')) {
            $requestParameter['GetParameter'] = @{ jql = $Query }
        }

        switch ($PSCmdlet.ParameterSetName) {
            '_Board' {
                Assert-JiraAgileIssueCountBoard -Board $Board
                $requestParameter['Uri'] = "$($server.TrimEnd('/'))/rest/software/1.0/board/$($Board.Id)/issue/approximate-count"
                Invoke-JiraMethod @requestParameter |
                    ConvertTo-IssueApproximateCount -Scope Board -BoardId $Board.Id -Query $Query
            }
            '_Backlog' {
                Assert-JiraAgileIssueCountBoard -Board $Board
                $requestParameter['Uri'] = "$($server.TrimEnd('/'))/rest/software/1.0/board/$($Board.Id)/backlog/approximate-count"
                Invoke-JiraMethod @requestParameter |
                    ConvertTo-IssueApproximateCount -Scope Backlog -BoardId $Board.Id -Query $Query
            }
            '_Sprint' {
                Assert-JiraAgileIssueCountBoard -Board $Board
                foreach ($_sprint in $Sprint) {
                    Assert-JiraAgileIssueCountId -Name Sprint -Value $_sprint.Id
                    $countJql = Join-JiraAgileIssueCountJql -Query $Query -Clause "sprint = $($_sprint.Id)"
                    $requestParameter['Uri'] = "$($server.TrimEnd('/'))/rest/software/1.0/board/$($Board.Id)/issue/approximate-count"
                    $requestParameter['GetParameter'] = @{ jql = $countJql }
                    Invoke-JiraMethod @requestParameter |
                        ConvertTo-IssueApproximateCount -Scope Sprint -BoardId $Board.Id -SprintId $_sprint.Id -Query $countJql
                }
            }
            '_Epic' {
                foreach ($_epic in $Epic) {
                    Assert-JiraAgileIssueCountId -Name Epic -Value $_epic.Id
                    $countJql = Join-JiraAgileIssueCountJql -Query $Query -Clause "parent = $($_epic.Id)"
                    $requestParameter['Uri'] = "$($server.TrimEnd('/'))/rest/api/3/search/approximate-count"
                    $requestParameter['Method'] = "POST"
                    $requestParameter.Remove('GetParameter')
                    $requestParameter['Body'] = @{
                        jql = $countJql
                    } | ConvertTo-Json
                    Invoke-JiraMethod @requestParameter |
                        ConvertTo-IssueApproximateCount -Scope Epic -EpicId $_epic.Id -Query $countJql
                }
            }
            '_BoardEpic' {
                Assert-JiraAgileIssueCountBoard -Board $Board
                foreach ($_epic in $Epic) {
                    Assert-JiraAgileIssueCountId -Name Epic -Value $_epic.Id
                    $countJql = Join-JiraAgileIssueCountJql -Query $Query -Clause "parent = $($_epic.Id)"
                    $requestParameter['Uri'] = "$($server.TrimEnd('/'))/rest/software/1.0/board/$($Board.Id)/issue/approximate-count"
                    $requestParameter['GetParameter'] = @{ jql = $countJql }
                    Invoke-JiraMethod @requestParameter |
                        ConvertTo-IssueApproximateCount -Scope BoardEpic -BoardId $Board.Id -EpicId $_epic.Id -Query $countJql
                }
            }
            '_BoardWithoutEpic' {
                Assert-JiraAgileIssueCountBoard -Board $Board
                $countJql = Join-JiraAgileIssueCountJql -Query $Query -Clause "parent = null"
                $requestParameter['Uri'] = "$($server.TrimEnd('/'))/rest/software/1.0/board/$($Board.Id)/issue/approximate-count"
                $requestParameter['GetParameter'] = @{ jql = $countJql }
                Invoke-JiraMethod @requestParameter |
                    ConvertTo-IssueApproximateCount -Scope BoardWithoutEpic -BoardId $Board.Id -Query $countJql
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

function Assert-JiraAgileIssueCountBoard {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AtlassianPSVII.JiraAgilePSVII.Board]
        $Board
    )

    Assert-JiraAgileIssueCountId -Name Board -Value $Board.Id
}

function Assert-JiraAgileIssueCountId {
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
        throw "[$($MyInvocation.MyCommand.Name)] $Name input must contain a non-zero Id."
    }
}

function Join-JiraAgileIssueCountJql {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter()]
        [String]
        $Query,

        [Parameter(Mandatory)]
        [String]
        $Clause
    )

    if ([String]::IsNullOrWhiteSpace($Query)) {
        return $Clause
    }

    return "($Query) AND $Clause"
}
