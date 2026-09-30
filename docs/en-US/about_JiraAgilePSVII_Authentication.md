---
locale: en-US
layout: documentation
online version: https://atlassianps.org/docs/JiraAgilePS/about/authentication.html
Module Name: JiraAgilePSVII
permalink: /docs/JiraAgilePS/about/authentication.html
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

- [about_JiraPSVII_Authentication](https://atlassianps.org/docs/JiraPS/about/authentication.html)
- [New-JiraSession](https://atlassianps.org/docs/JiraPS/commands/New-JiraSession/)
