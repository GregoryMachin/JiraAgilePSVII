# [JiraAgilePSVII](https://github.com/GregoryMachin/JiraAgilePSVII)

[![Build Status](https://img.shields.io/github/actions/workflow/status/GregoryMachin/JiraAgilePSVII/ci.yml?style=for-the-badge)](https://github.com/GregoryMachin/JiraAgilePSVII/actions/workflows/ci.yml)
![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)

> **Fork notice:** JiraAgilePSVII is a fork of [JiraAgilePS](https://github.com/AtlassianPS/JiraAgilePS) by the [AtlassianPS](https://github.com/AtlassianPS) team (MIT License), renamed and maintained by Gregory Machin. "VII" is only part of the name: it supports Windows PowerShell 5.1 and PowerShell 7.4+, and can be loaded side by side with the upstream module.

JiraAgilePSVII is a PowerShell module to interact with _Agile_, Atlassian [JIRA]'s plugin,
via a REST API, while maintaining a consistent PowerShell look and feel.

> JiraAgilePSVII is a module that extends [JiraPSVII](https://github.com/GregoryMachin/JiraPSVII).

<!--more-->

---

## Instructions

### Installation

JiraAgilePSVII is not published to the PowerShell Gallery; use it straight from its repository:

```powershell
git clone https://github.com/GregoryMachin/JiraAgilePSVII.git
# JiraAgilePSVII requires JiraPSVII: clone it alongside and put that folder on PSModulePath
git clone https://github.com/GregoryMachin/JiraPSVII.git
$env:PSModulePath = "$PWD/JiraPSVII;$env:PSModulePath"
Import-Module ./JiraAgilePSVII/JiraAgilePSVII/JiraAgilePSVII.psd1
```

For the built release copy (merged module and compiled help) run `./Tools/setup.ps1` and
`Invoke-Build -Task Build` in the clone, then import `./Release/JiraAgilePSVII/JiraAgilePSVII.psd1`.

### Usage

```powershell
# To use each session:
Import-Module JiraAgilePSVII
Set-JiraConfigServer 'https://YourCloud.atlassian.net'
New-JiraSession -Credential $cred
```

The full documentation is in the [docs folder](https://github.com/GregoryMachin/JiraAgilePSVII/tree/master/docs/en-US)
and in the console.

```powershell
# Review the help at any time!
Get-Help about_JiraAgilePSVII
Get-Command -Module JiraAgilePSVII
Get-Help Get-JiraAgileBoard -Full # or any other command
```

For more information on how to use JiraAgilePSVII, check out the [Documentation](https://github.com/GregoryMachin/JiraAgilePSVII/tree/master/docs/en-US).
For release planning context, see the [Jira Agile API coverage matrix](docs/agile-api-coverage-matrix.md).

### Integration tests (local)

JiraAgilePSVII uses the same `.env`-based integration test setup as JiraPSVII.

1. Copy `.env.example` to `.env` in the repository root.
2. Fill in the `JIRA_CLOUD_*` and `JIRA_TEST_*` values.
3. Optionally set `CI_JIRA_TYPE=Server` and `CI_JIRA_*` for Data Center track testing.

The integration helper in `Tests/Helpers/IntegrationTestTools.ps1` reads `.env` and applies the same Cloud/Server variable model used in JiraPSVII.

### Contribute

Want to contribute? Great!
Contributions are welcome: open an issue or a pull request in this repository.


#### DevContainer

This repository offers a ["devcontainer"](https://containers.dev/) setup.

> **What are Development Containers?**  
> A development container (or dev container for short) allows you to use
> a container as a full-featured development environment.
> It can be used to run an application, to separate tools, libraries,
> or runtimes needed for working with a codebase,
> and to aid in continuous integration and testing.

You can use the devcontainer to spin up a fine tuned development environment with
everything you need for working on this project.

The easiest way for using DevContainers is with [VS Code](https://code.visualstudio.com/),
its extension `ms-vscode-remote.remote-containers`,
and [docker](https://docs.docker.com/engine/install/).  
When opening the repository in VS Code, it will recommend the installation of the extension.
And once installed, you will be prompted to "Reopen in Container".

## Tested on

| Configuration | Status |
| ------------- | ------ |
| Windows PowerShell v5.1 | [CI workflow](https://github.com/GregoryMachin/JiraAgilePSVII/actions/workflows/ci.yml) |
| PowerShell 7 on Windows | [CI workflow](https://github.com/GregoryMachin/JiraAgilePSVII/actions/workflows/ci.yml) |
| PowerShell 7 on Ubuntu | [CI workflow](https://github.com/GregoryMachin/JiraAgilePSVII/actions/workflows/ci.yml) |
| PowerShell 7 on macOS | [CI workflow](https://github.com/GregoryMachin/JiraAgilePSVII/actions/workflows/ci.yml) |

## Acknowledgements

* This module is a fork of [JiraAgilePS](https://github.com/AtlassianPS/JiraAgilePS); thanks to its original authors and contributors.

## Useful links

* [Source Code]
* [Latest Release]
* [Submit an Issue]
* How you can help us: [List of Issues](https://github.com/GregoryMachin/JiraAgilePSVII/issues?q=is%3Aissue+is%3Aopen+label%3Aup-for-grabs)

## Disclaimer

Hopefully this is obvious, but:

> This is an open source project (under the [MIT license]), and all contributors are volunteers.
> All commands are executed at your own risk.
> Please have good backups before you start, because you can delete a lot of stuff if you're not careful.

<!-- reference-style links -->
  [JIRA]: https://www.atlassian.com/software/jira
  [PowerShell Gallery]: https://www.powershellgallery.com/
  [Source Code]: https://github.com/GregoryMachin/JiraAgilePSVII
  [Latest Release]: https://github.com/GregoryMachin/JiraAgilePSVII/releases/latest
  [Submit an Issue]: https://github.com/GregoryMachin/JiraAgilePSVII/issues/new
  [MIT license]: https://github.com/GregoryMachin/JiraAgilePSVII/blob/master/LICENSE

<!-- [//]: # (Sweet online markdown editor at http://dillinger.io) -->
<!-- [//]: # ("GitHub Flavored Markdown" https://help.github.com/articles/github-flavored-markdown/) -->
