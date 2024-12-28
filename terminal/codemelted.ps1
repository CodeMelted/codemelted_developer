# =============================================================================
# [TERMINAL MODULE DEFINITION] ================================================
# =============================================================================
<#PSScriptInfo

.VERSION 0.1.0

.RELEASENOTES
 0.1.0 2024-12-28
 - Initial release of the codemelted CLI with the --json use case implemented.

.GUID c757fe44-4ed5-46b0-8e24-9a9aaaad872c

.AUTHOR mark.shaffer@codemelted.com

.COPYRIGHT © 2024 Mark Shaffer. All Rights Reserved. MIT License

.TAGS pwsh pwsh-scripts pwsh-modules CodeMeltedDEV codemelted

.LICENSEURI https://github.com/CodeMelted/codemelted_developer/blob/main/LICENSE

.PROJECTURI https://github.com/codemelted/codemelted_developer

.ICONURI https://codemelted.com/assets/images/icon-codemelted-terminal.png

.EXTERNALMODULEDEPENDENCIES Microsoft.PowerShell.ConsoleGuiTools

.COMPANYNAME N/A

.REQUIREDSCRIPTS N/A

.EXTERNALSCRIPTDEPENDENCIES N/A

.PRIVATEDATA N/A
#>

<#
.DESCRIPTION
  A CLI to facilitate common developer use cases on Mac, Linux, or Windows systems.
#>
param(
  [Parameter(
    Mandatory = $true,
    ValueFromPipeline = $false,
    Position = 0
  )]
  [ValidateSet(
    "--about",
    "--json",
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
    a developer to execute the CodeMelted DEV | Module use cases within a
    pwsh terminal shell. This allows for building CLI tools, Terminal User
    Interface (TUI) tools, or building DevOps toolchain automation.

    SYNTAX:

      codemelted [Action] [Command] [Params]

  .DESCRIPTION
    PARAMETERS:

      [Action]
        --about : Displays the current PSScriptInfo about this module CLI.
        --json  : Provides the ability to work with JSON data.
        --help  : Displays this help system to facilitate navigating the CLI.

      [Command]
        Commands attached to each [Action] parameter. Execute the following
        to get the specific [Command] parameters associated with the [Action]
        parameter and the [Args] associated with the [Command] parameters.

        codemelted [Action] help

      [Params]
        The optional set of named arguments wrapped within a [hashtable]

  .LINK
    CodeMelted | DEV Modules:
    https://developer.codemelted.com

    GitHub Source:
    https://github.com/CodeMelted/codemelted_developer/tree/main/terminal
  #>
  Get-Help help
}

# =============================================================================

# -----------------------------------------------------------------------------
# [JSON Use Case] -------------------------------------------------------------
# -----------------------------------------------------------------------------

function json {
  <#
  .SYNOPSIS
    codemelted --json [Command] [Params]

  .DESCRIPTION
    [Command]
      as-bool            : Takes a string and attempts to convert to a
                           boolean.
      as-int             : Takes a string and attempts to convert to a Int32.
      as-double          : Takes a string and attempts to convert to a Double.
      check-has-property : Takes a [Hashtable] and checks if it has the given
                           property.
      check-type         : Takes a variable and checks if it is a given .NET
                           data type.
      check-valid-url    : Takes a string and checks if a Uri can be created
                           from it.
      create-array       : Creates an empty [System.Collections.ArrayList].
                           This is the object to work with this command.
      create-object      : Creates an empty [hashtable]. Thi is the object
                           to work with this command.
      parse              : Will attempt to create a [hashtable] or
                           [System.Collections.ArrayList] from the specified
                           string.
      stringify          : Will attempt to stringify a [hashtable] or
                           [System.Collections.ArrayList] to a JSON string
                           representation.
      try-has-property   : Performs a check-has-property but will throw
                           instead of returning a boolean.
      try-type           : Performs a check-type but will throw instead of
                           returning a boolean.
      try-valid-url      : Performs a try-valid-url but will throw instead of
                           returning a boolean.

      NOTE: Any conversion failure will result in a $null return. Any
           [Command] API violations will result in a thrown exception.

    [Params]
      as-bool / as-int / as-double / check-valid-url / parse /
      stringify / try-valid-url
        @{
          "data" = [any]
        }

      check-type / try-type
        @{
          "type" = [string] # a .NET representation of the type
          "data" = [any]
        }

        check-has-property / try-has-property
        @{
          "obj" = [hashtable]
          "key" = [string]
        }
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [ValidateSet(
      "as-bool",
      "as-int",
      "as-double",
      "check-has-property",
      "check-type",
      "check-valid-url",
      "create-array",
      "create-object",
      "parse",
      "stringify",
      "try-has-property",
      "try-type",
      "try-valid-url",
      "help"
    )]
    [string] $Command,

    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 1
    )]
    [hashtable]$Params
  )

  try {
    if ($Command -eq "as-bool") {
      if (-not $Params.ContainsKey("data")) {
        throw "as-bool Command expects 'data' Params key"
      }
      $trueStrings = @(
        "true",
        "1",
        "t",
        "y",
        "yes",
        "yeah",
        "yup",
        "certainly",
        "uh-huh"
      )
      if ($null -eq $Params["data"]) {
        return $false
      }
      return $trueStrings.Contains(
        $Params["data"].ToString().ToLower()
      )
    } elseif ($Command -eq "as-int") {
      if (-not $Params.ContainsKey("data")) {
        throw "as-int Command expects 'data' Params key"
      }
      return [int]::Parse($Params["data"])
    } elseif ($Command -eq "as-double") {
      if (-not $Params.ContainsKey("data")) {
        throw "as-double Command expects 'data' Params key"
      }
      return [double]::Parse($Params["data"])
    } elseif ($Command -eq "check-has-property") {
      if (-not $Params.ContainsKey("obj")) {
        throw "check-has-property Command expects 'obj' Params key"
      } elseif (-not $Params.ContainsKey("key")) {
        throw "check-has-property Command expects 'key' Params key"
      }
      $obj = $Params["obj"]
      if ($obj.GetType().Name.ToLower() -ne "hashtable") {
        throw "check-has-property expects 'obj' Params key to be a 'hashtable'"
      }
      return $obj.ContainsKey($Params["key"])
    } elseif ($Command -eq "check-type") {
      if (-not $Params.ContainsKey("data")) {
        throw "check-type Command expects 'data' Params key"
      } elseif (-not $Params.ContainsKey("type")) {
        throw "check-type Command expects 'type' Params key"
      }
      return $Params["type"].ToString().ToLower() `
        -eq $Params["data"].GetType().Name.ToLower()
    } elseif ($Command -eq "check-valid-url") {
      if (-not $Params.ContainsKey("data")) {
        throw "check-valid-url Command expects 'data' Params key"
      }
      return [uri]::IsWellFormedUriString($Params["data"].ToString(), 0)
    } elseif ($Command -eq "create-array") {
      $obj = New-Object System.Collections.ArrayList
      Write-Output -NoEnumerate $obj
    } elseif ($Command -eq "create-object") {
      return @{}
    } elseif ($Command -eq "parse") {
      if (-not $Params.ContainsKey("data")) {
        throw "$Command Command expects 'data' Params key"
      }
      return ConvertFrom-Json -InputObject $Params["data"] -AsHashtable -Depth 100
    } elseif ($Command -eq "stringify") {
      if (-not $Params.ContainsKey("data")) {
        throw "stringify Command expects 'data' Params key"
      }
      $data = $Params["data"]
      if ($data.GetType().Name.ToLower() -eq "arraylist") {
        return ConvertTo-Json -InputObject $data.ToArray() -Depth 100
      }
      return ConvertTo-Json -InputObject $Params["data"] -Depth 100
    } elseif ($Command -eq "try-has-property") {
      if (-not $Params.ContainsKey("obj")) {
        throw "try-has-property Command expects 'obj' Params key"
      } elseif (-not $Params.ContainsKey("key")) {
        throw "try-has-property Command expects 'key' Params key"
      }
      $obj = $Params["obj"]
      if ($obj.GetType().Name.ToLower() -ne "hashtable") {
        throw "try-has-property expects 'obj' Params key to be a 'hashtable'"
      }
      $hasKey = $obj.ContainsKey($Params["key"])
      if (-not $hasKey) {
        throw "obj does not contain specified key"
      }
    } elseif ($Command -eq "try-type") {
      if (-not $Params.ContainsKey("data")) {
        throw "try-type Command expects 'data' Params key"
      } elseif (-not $Params.ContainsKey("type")) {
        throw "try-type Command expects 'type' Params key"
      }
      $isSame = $Params["type"].ToString().ToLower() `
        -eq $Params["data"].GetType().Name.ToLower()
      if (-not $isSame) {
        throw "variable was not of an expected type"
      }
    } elseif ($Command -eq "try-valid-url") {
      if (-not $Params.ContainsKey("data")) {
        throw "try-valid-url Command expects 'data' Params key"
      }
      $wellFormed = [uri]::IsWellFormedUriString($Params["data"].ToString(), 0)
      if (-not $wellFormed) {
        throw "data was not a valid URL string"
      }
    } else {
      Get-Help json
    }
  } catch [System.FormatException] {
    return $null
  }
}

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
  "--json" { json $Command $Params }
  # "--runtime" { runtime $Command $Params }
  "--help" { help }
}
