# =============================================================================
# [TERMINAL MODULE DEFINITION] ================================================
# =============================================================================
<#PSScriptInfo

.VERSION 0.0.0

.RELEASENOTES
 0.0.0 yyyy-mm-dd
 - Description of the changes.

.GUID c757fe44-4ed5-46b0-8e24-9a9aaaad872c

.AUTHOR Mark Shaffer

.COPYRIGHT © 2024 Mark Shaffer. All Rights Reserved. MIT License

.TAGS pwsh pwsh-scripts pwsh-modules CodeMeltedDEV codemelted

.LICENSEURI https://github.com/CodeMelted/codemelted_developer/blob/main/LICENSE

.PROJECTURI https://github.com/codemelted/codemelted_developer

.ICONURI https://codemelted.com/favicon.png

.EXTERNALMODULEDEPENDENCIES Microsoft.PowerShell.ConsoleGuiTools

.COMPANYNAME N/A

.REQUIREDSCRIPTS N/A

.EXTERNALSCRIPTDEPENDENCIES N/A

.PRIVATEDATA N/A
#>

<#
.DESCRIPTION
EXEC: codemelted --help
#>
param(
  [Parameter(
    Mandatory = $true,
    ValueFromPipeline = $false,
    Position = 0
  )]
  [ValidateSet(
    "--about",
    "--runtime",
    "--help"
  )]
  [string] $Action,

  [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $false,
    Position = 1
  )]
  [AllowEmptyString()]
  [string] $Command,

  [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $false,
    Position = 2
  )]
  [hashtable]$Params
)

function help {
  <#
  .SYNOPSIS
    The codemelted Command Line Interface (CLI) Terminal Module. It allows
    a developer to execute the CodeMelted DEV | Cross Platform Module use
    cases within a pwsh terminal shell. This allows for building CLI tools,
    Terminal User Interface (TUI) tools, or building DevOps toolchain
    automations.

  .DESCRIPTION
    SYNTAX:
      codemelted [Action] [Command] [Params]

    PARAMETERS:
      [Action]
        --about : Displays the current PSScriptInfo about this module CLI.
        --help  : Displays this help system to facilitate navigating the CLI.

      [Command]
        Commands attached to each [Action] parameter. Execute the following
        to get the specific [Command] parameters associated with the [Action]
        parameter and the [Args] associated with the [Command] parameters.

        codemelted [Action] help

      [Params]
        The optional set of named arguments wrapped within a [hashtable]

  .LINK
    https://developer.codemelted.com (CodeMelted DEV)
    https://codemelted.com (CodeMelted | PWA)

  #>
  Get-Help help
}

# -----------------------------------------------------------------------------
# [Disk Use Case] -------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Runtime Use Case] ----------------------------------------------------------
# -----------------------------------------------------------------------------

function runtime {
  <#
  .SYNOPSIS
    runtime something something
  .DESCRIPTION
    runtime something something.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [ValidateSet(
      "help",
      "setup"
    )]
    [string] $Command,

    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 1
    )]
    [hashtable]$Params
  )

  Write-Host $Params

  switch ($Command) {
    "help" { Get-Help runtime }
    "setup" {
      Write-Host $Params["2"]
      #
    }
  }

  # # Install
  # $repoPath = "C:\MyLocalRepository"
  # New-Item -Path $repoPath -ItemType Directory -Force
  # Register-PSRepository -Name LocalRepo -SourceLocation $repoPath
  # Publish-Script -Path "C:\Path\To\MyScript.ps1" -Repository LocalRepo
  # Find-Script -Repository LocalRepo -Name MyScript
  # Install-Script

  # # Uninstall
  # Uninstall-Script
  # Unregister-PSRepository -Name "RepositoryName"
}

# =============================================================================
# [Main API Implementation] ===================================================
# =============================================================================

switch ($Action) {
  "--about" { Get-PSScriptFileInfo -Path $PSScriptRoot/codemelted.ps1 }
  # "--runtime" { runtime $Command $Params }
  "--help" { help }
}
