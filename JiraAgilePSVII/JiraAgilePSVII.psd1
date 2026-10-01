@{
    RootModule           = 'JiraAgilePSVII.psm1'
    ModuleVersion        = '1.0'
    GUID                 = '1f85db59-454c-4ade-89df-626c225a5f7d'
    Author               = 'Gregory Machin'
    CompanyName          = 'AtlassianPSVII'
    Copyright            = '(c) 2017 AtlassianPS; (c) 2026 Gregory Machin. MIT License.'
    Description          = 'placeholder'
    PowerShellVersion    = '5.1'
    RequiredModules      = @("JiraPSVII")
    FormatsToProcess     = 'JiraAgilePSVII.format.ps1xml'
    # NestedModules     = @()
    FunctionsToExport    = @(
        'Add-IssueToSprint'
        'Get-Board'
        'Get-BoardConfiguration'
        'Get-Epic'
        'Get-Issue'
        'Get-IssueApproximateCount'
        'Get-Sprint'
        'Move-IssueToBacklog'
        'New-Sprint'
        'Remove-Sprint'
        'Set-Sprint'
    )
    # CmdletsToExport   = '*'
    # VariablesToExport = '*'
    AliasesToExport      = @()
    FileList             = @()
    PrivateData          = @{
        PSData = @{
            Tags                       = @( "rest", "api", "atlassianpsvii", "jira", "atlassian", "agile" )
            LicenseUri                 = 'https://github.com/GregoryMachin/JiraAgilePSVII/blob/master/LICENSE'
            ProjectUri                 = 'https://github.com/GregoryMachin/JiraAgilePSVII'
            Prerelease                 = ''
            ReleaseNotes               = 'https://github.com/GregoryMachin/JiraAgilePSVII/blob/master/CHANGELOG.md'
            ExternalModuleDependencies = 'JiraPSVII'
        }
    }
    DefaultCommandPrefix = 'JiraAgile'
}
