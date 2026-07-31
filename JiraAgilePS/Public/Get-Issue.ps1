function Get-Issue {
    # .ExternalHelp ..\JiraAgilePS-help.xml
    [CmdletBinding(SupportsPaging, DefaultParameterSetName = '_Board')]
    [OutputType([PSObject])]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Board')]
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Backlog')]
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Sprint')]
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_BoardEpic')]
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_BoardWithoutEpic')]
        [AtlassianPS.JiraAgilePS.Board]
        $Board,

        [Parameter(Mandatory, ParameterSetName = '_Backlog')]
        [switch]
        $Backlog,

        [Parameter(Position = 1, Mandatory, ValueFromPipeline, ParameterSetName = '_Sprint')]
        [AtlassianPS.JiraAgilePS.Sprint[]]
        $Sprint,

        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Epic')]
        [Parameter(Position = 1, Mandatory, ValueFromPipeline, ParameterSetName = '_BoardEpic')]
        [AtlassianPS.JiraAgilePS.Epic[]]
        $Epic,

        [Parameter(Mandatory, ParameterSetName = '_BoardWithoutEpic')]
        [switch]
        $WithoutEpic,

        [Parameter()]
        [ValidateRange(1, 4294967295)]
        [UInt32]$PageSize = $script:DefaultPageSize,

        [Parameter()]
        [Alias('JQL')]
        [String]
        $Query,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Fields,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Expand,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Object[]]
        $ReconcileIssue,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop
        $deploymentType = $null
        $serverInformation = Get-JiraServerInformation -Credential $Credential -ErrorAction Stop
        if ($serverInformation.PSObject.Properties.Name -contains 'DeploymentType') {
            $deploymentType = $serverInformation.DeploymentType
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"

        $requestParameter = @{
            Method       = "GET"
            GetParameter = @{
                maxResults = $PageSize
            }
            OutputType   = "JiraIssue"
            Paging       = $true
            Credential   = $Credential
            Cmdlet       = $PSCmdlet
            Verbose      = $VerbosePreference
            Debug        = $DebugPreference
        }
        if ($PSBoundParameters.ContainsKey('Query')) {
            $requestParameter["GetParameter"]["jql"] = $Query
        }
        if ($PSBoundParameters.ContainsKey('Fields')) {
            $requestParameter["GetParameter"]["fields"] = $Fields -join ","
        }
        if ($PSBoundParameters.ContainsKey('Expand')) {
            $requestParameter["GetParameter"]["expand"] = $Expand -join ","
        }
        if ($PSBoundParameters.ContainsKey('ReconcileIssue')) {
            if ($deploymentType -ne 'Cloud') {
                throw "[$($MyInvocation.MyCommand.Name)] -ReconcileIssue is supported only for Jira Cloud issue-list routes."
            }

            $reconcileIssueIds = Resolve-JiraAgileReconcileIssueId -InputObject $ReconcileIssue
            $requestParameter["GetParameter"]["reconcileIssues"] = $reconcileIssueIds -join ","
        }

        # Paging
        ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
            $requestParameter[$_] = $PSCmdlet.PagingParameters.$_
        }

        switch ($PSCmdlet.ParameterSetName) {
            '_Board' {
                if ($Board.Id -eq 0) {
                    throw "[$($MyInvocation.MyCommand.Name)] Board input must contain a non-zero Id."
                }

                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing Board ID [$($Board.Id)]"
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$Board [$($Board.Id)]"

                $requestParameter["Uri"] = Resolve-JiraSoftwareRoute -BaseUri $server -DeploymentType $deploymentType -Operation BoardIssue -BoardId $Board.Id
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$requestParameter"
                Invoke-JiraMethod @requestParameter | Get-AgilePageItem | ConvertTo-Issue
            }
            '_Backlog' {
                if ($Board.Id -eq 0) {
                    throw "[$($MyInvocation.MyCommand.Name)] Board input must contain a non-zero Id."
                }

                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing Board ID [$($Board.Id)] backlog"
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$Board [$($Board.Id)]"

                $requestParameter["Uri"] = Resolve-JiraSoftwareRoute -BaseUri $server -DeploymentType $deploymentType -Operation BacklogIssue -BoardId $Board.Id
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$requestParameter"
                Invoke-JiraMethod @requestParameter | Get-AgilePageItem | ConvertTo-Issue
            }
            '_Sprint' {
                foreach ($_sprint in $Sprint) {
                    if ($Board.Id -eq 0) {
                        throw "[$($MyInvocation.MyCommand.Name)] Board input must contain a non-zero Id."
                    }
                    if ($_sprint.Id -eq 0) {
                        throw "[$($MyInvocation.MyCommand.Name)] Sprint input must contain a non-zero Id."
                    }

                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing Sprint ID [$($_sprint.Id)] for Board ID [$($Board.Id)]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_sprint [$($_sprint.Id)]"

                    $requestParameter["Uri"] = Resolve-JiraSoftwareRoute -BaseUri $server -DeploymentType $deploymentType -Operation SprintIssue -BoardId $Board.Id -SprintId $_sprint.Id
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$requestParameter"
                    Invoke-JiraMethod @requestParameter | Get-AgilePageItem | ConvertTo-Issue
                }
            }
            '_Epic' {
                foreach ($_epic in $Epic) {
                    if ($_epic.Id -eq 0) {
                        throw "[$($MyInvocation.MyCommand.Name)] Epic input must contain a non-zero Id."
                    }

                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing Epic ID [$($_epic.Id)]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_epic [$($_epic.Id)]"

                    $requestParameter["Uri"] = Resolve-JiraSoftwareRoute -BaseUri $server -DeploymentType $deploymentType -Operation EpicIssue -EpicId $_epic.Id
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$requestParameter"
                    Invoke-JiraMethod @requestParameter | Get-AgilePageItem | ConvertTo-Issue
                }
            }
            '_BoardEpic' {
                foreach ($_epic in $Epic) {
                    if ($Board.Id -eq 0) {
                        throw "[$($MyInvocation.MyCommand.Name)] Board input must contain a non-zero Id."
                    }
                    if ($_epic.Id -eq 0) {
                        throw "[$($MyInvocation.MyCommand.Name)] Epic input must contain a non-zero Id."
                    }

                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing Epic ID [$($_epic.Id)] for Board ID [$($Board.Id)]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_epic [$($_epic.Id)]"

                    $requestParameter["Uri"] = Resolve-JiraSoftwareRoute -BaseUri $server -DeploymentType $deploymentType -Operation BoardEpicIssue -BoardId $Board.Id -EpicId $_epic.Id
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$requestParameter"
                    Invoke-JiraMethod @requestParameter | Get-AgilePageItem | ConvertTo-Issue
                }
            }
            '_BoardWithoutEpic' {
                if ($Board.Id -eq 0) {
                    throw "[$($MyInvocation.MyCommand.Name)] Board input must contain a non-zero Id."
                }

                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing Board ID [$($Board.Id)] with no epic"
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$Board [$($Board.Id)]"

                $requestParameter["Uri"] = Resolve-JiraSoftwareRoute -BaseUri $server -DeploymentType $deploymentType -Operation BoardWithoutEpicIssue -BoardId $Board.Id
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$requestParameter"
                Invoke-JiraMethod @requestParameter | Get-AgilePageItem | ConvertTo-Issue
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

function Resolve-JiraAgileReconcileIssueId {
    [CmdletBinding()]
    [OutputType([String[]])]
    param(
        [Parameter(Mandatory)]
        [Object[]]
        $InputObject
    )

    $ids = @(
        foreach ($item in $InputObject) {
            $candidate = if ($null -ne $item -and $item.PSObject.Properties.Name -contains 'Id') {
                $item.Id
            }
            else {
                $item
            }

            if ($candidate -is [Array]) {
                foreach ($value in $candidate) {
                    [String]$value
                }
            }
            else {
                [String]$candidate
            }
        }
    ) |
        Where-Object { -not [String]::IsNullOrWhiteSpace($_) } |
        ForEach-Object { $_.Trim() } |
        Select-Object -Unique

    foreach ($id in $ids) {
        if ($id -notmatch '^\d+$' -or [UInt64]$id -eq 0) {
            throw "[$($MyInvocation.MyCommand.Name)] -ReconcileIssue accepts only non-zero numeric Jira issue IDs."
        }
    }

    if ($ids.Count -gt 50) {
        throw "[$($MyInvocation.MyCommand.Name)] -ReconcileIssue accepts at most 50 unique Jira issue IDs."
    }

    $ids
}
