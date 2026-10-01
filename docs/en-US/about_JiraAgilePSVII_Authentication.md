---
locale: en-US
online version: https://github.com/GregoryMachin/JiraAgilePSVII/blob/master/docs/en-US/about_JiraAgilePSVII_Authentication.md
Module Name: JiraAgilePSVII
---
# Authentication

## about_JiraAgilePSVII_Authentication

# SHORT DESCRIPTION

JiraAgilePSVII uses the same authentication/session model as JiraPSVII.

# LONG DESCRIPTION

JiraAgilePSVII does not implement a separate login mechanism.
It relies on JiraPSVII for server configuration and authentication.

For most automation flows, do this once per session:

```powershell
Import-Module JiraPSVII
Import-Module JiraAgilePSVII

Set-JiraConfigServer 'https://yourcompany.atlassian.net'
$cred = Get-Credential
New-JiraSession -Credential $cred
```

After that, JiraAgilePSVII commands can run without passing `-Credential` every time.

## Cloud and Data Center

Authentication behavior is inherited from JiraPSVII:

- Jira Cloud: API token + email via `New-JiraSession -ApiToken -EmailAddress`
- Jira Data Center: PAT via `New-JiraSession -PersonalAccessToken`
- Legacy/basic: `-Credential`

See JiraPSVII authentication guidance for details and security recommendations.

# SEE ALSO

- [about_JiraPSVII_Authentication](https://github.com/GregoryMachin/JiraPSVII/blob/master/docs/en-US/about_JiraPSVII_Authentication.md)
- [New-JiraSession](https://github.com/GregoryMachin/JiraPSVII/blob/master/docs/en-US/commands/New-JiraSession.md)
