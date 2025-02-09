# =============================================================================
# [TERMINAL MODULE DEFINITION] ================================================
# =============================================================================
<#PSScriptInfo
.AUTHOR mark.shaffer@codemelted.com
.COPYRIGHT © 2024 Mark Shaffer. All Rights Reserved. MIT License
.LICENSEURI https://github.com/CodeMelted/codemelted_developer/blob/main/LICENSE
.PROJECTURI https://github.com/codemelted/codemelted_developer
.ICONURI https://codemelted.com/assets/images/icon-codemelted-pwsh.png
.EXTERNALMODULEDEPENDENCIES Microsoft.PowerShell.ConsoleGuiTools
.TAGS pwsh pwsh-scripts pwsh-modules CodeMeltedDEV codemelted
.GUID c757fe44-4ed5-46b0-8e24-9a9aaaad872c
.VERSION 0.1.1
.RELEASENOTES
  0.1.1 2025-01-08
  - Broke out the --json into individual actions.
  - Updated the --help to reflect the module interface going forward.

  0.1.0 2024-12-28
  - Initial release of the codemelted CLI with the --json use case implemented.
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
    # Module Definition Use Case
    "--version",
    "--help",
    # JSON Use Case
    "--as-bool",
    "--as-int",
    "--as-double",
    "--check-has-property",
    "--check-type",
    "--check-valid-url",
    "--create-array",
    "--create-object",
    "--parse-json",
    "--stringify-json",
    "--try-has-property",
    "--try-type",
    "--try-valid-url"
  )]
  [string] $Action,

  [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $false,
    Position = 1
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

      codemelted [Action] [Params]

    PARAMETERS:

      [Action]
        # To Learn About the CLI use cases.
        --about : Get current information about the codemelted CLI
        --help  : Execute 'codemelted --help @{ "action" = [Use Case] }'
                  to learn more about the CLI Actions.

        # JSON Use Cases
        --as-bool
        --as-int
        --as-double
        --check-has-property
        --check-type
        --check-valid-url
        --create-array
        --create-object
        --parse-json
        --stringify-json
        --try-has-property"
        --try-type
        --try-valid-url

      [Params]
        The optional set of named arguments wrapped within a [hashtable]

  .LINK
    CodeMelted DEV | pwsh Module:
    https://codemelted.com/developer/assets/pwsh

    GitHub Source:
    https://github.com/CodeMelted/codemelted_developer/tree/main/terminal
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  [hashtable] $helpLookup = @{
    "--as-bool" = { Get-Help as_bool };
    "--as-int" = { Get-Help as_int };
    "--as-double" = { Get-Help as_double };
    "--check-has-property" = { Get-Help check_has_property };
    "--check-type" = { Get-Help check_type };
    "--check-valid-url" = { Get-Help check_valid_url };
    "--create-array" = { Get-Help create_array };
    "--create-object" = { Get-Help create_object };
    "--parse-json" = { Get-Help parse_json };
    "--stringify-json" = { Get-Help stringify_json };
    "--try-has-property" = { Get-Help try_has_property };
    "--try-type" = { Get-Help try_type };
    "--try-valid-url" = { Get-Help try_valid_url };
  }
  if ($null -ne $Params) {
    if (-not $Params.ContainsKey("action")) {
      throw "--help expects action key to be specified"
    } elseif ($null -eq $helpLookup[$Params["action"]]) {
      throw "--help action specified did not find a help specification"
    }
    Invoke-Command -ScriptBlock $helpLookup[$Params["action"]]
  } else {
    Get-Help help
  }
}

# =============================================================================

# -----------------------------------------------------------------------------
# [Audio Use Case] ------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Compute Use Case] ----------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Console Use Case] ----------------------------------------------------------
# -----------------------------------------------------------------------------

# TODO: Need to test documentation and logic. Then expose / document.

function console_alert {
  <#
    .SYNOPSIS
    Provides an alert to STDOUT pausing execution until [ENTER] is pressed.

    SYNTAX:
      # [ENTER]: STDOUT prompt is supplied.
      console_alert

      # Your custom prompt plus [ENTER]: to STDOUT.
      console_alert @{ "message" = "Custom Prompt" }

    RETURNS:
      [void]
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  if ($null -ne $Params) {
    if (-not $Params.ContainsKey("message")) {
      throw "SyntaxError: console_alert Params did not contain 'message' key."
    }
    $prompt = $Params["message"] + "[ENTER]"
    Read-Host -Prompt $prompt -MaskInput | Out-Null
  } else {
    Read-Host -Prompt "[ENTER]" -MaskInput | Out-Null
  }
}

function console_confirm {
  <#
    .SYNOPSIS
    Provides an confirmation [y/N] prompt to provide a choice to the user.

    SYNTAX:
      # CONFIRM [y/N]: STDOUT prompt is supplied.
      $answer = console_confirm

      # Custom Prompt [y/N]: STDOUT prompt is supplied.
      $answer = console_confirm @{ "message" = "Custom Prompt" }

    RETURNS:
      [boolean] $true if "y" entered, $false for all other values.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  [string] $answer = ""
  if ($null -ne $Params) {
    if (-not $Params.ContainsKey("message")) {
      throw "SyntaxError: console_confirm Params did not contain 'message' key."
    }
    $prompt = $Params["message"] + " [y/N]"
    $answer = Read-Host -Prompt $prompt
  } else {
    $answer = Read-Host -Prompt "CONFIRM [y/N]"
  }
  return $answer -eq "y"
}

function console_choose {
  <#
    .SYNOPSIS
    Provides a basic interactive menu that displays a list of choices
    allowing a user to make the choice. Only valid choices are returned.

    SYNTAX:
      # --------
      # Best Pet
      # --------
      #
      # 0. dog
      # 1. cat
      # 2. fish
      #
      # Make a Selection:
      #
      # ^ THE ABOVE IS PRESENTED TO STDOUT
      $answer = console_choose @{
        "message" = "Favorite Pet";
        "choices" = @( "dog", "cat", "fish" )
      }

    RETURNS:
      [int] The index of the selected item.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  [string] $answer = ""
  if (-not $Params.ContainsKey("message")) {
    throw "SyntaxError: console_choose Params did not contain 'message' key."
  } elseif (-not $Params.ContainsKey("choices")) {
    throw "SyntaxError: console_choose Params did not contain 'choices' key."
  }

  [int] $answer = -1
  [string] $title = $Params["message"]
  [array] $choices = $Params["choices"]
  do {
    Write-Host
    "-" * $title.Length
    Write-Host $title
    "-" * $title.Length
    Write-Host
    [int]$x = 0
    foreach ($choice in $choices) {
      Write-Host "$x. $choice"
      $x += 1
    }
    Write-Host
    $selection = Read-Host -Prompt "Make a Selection"
    try {
      $answer = [int]::Parse($selection)
    } catch {
      Write-Host
      Write-Warning "Entered value was invalid. Please try again."
      $answer = -1
    }
  } while ($answer -eq -1)
  return $answer
}

function console_prompt {
  <#
    .SYNOPSIS
    Provides the ability to prompt for a general answer to be entered.

    SYNTAX:
      # PROMPT: is reported to STDOUT.
      $answer = console_prompt

      # Custom Prompt: is reported to STDOUT.
      $password = console_prompt @{ "message" = "Custom Prompt" }

    RETURNS:
      [string] the entered value
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  [string] $answer = ""
  if ($null -ne $Params) {
    if (-not $Params.ContainsKey("message")) {
      throw "SyntaxError: console_prompt Params did not contain 'message' key."
    }
    $answer = Read-Host -Prompt $Params["message"]
  } else {
    $answer = Read-Host -Prompt "PROMPT"
  }
  return $answer
}

function console_password {
  <#
    .SYNOPSIS
    Provides the ability to prompt for a password via STDOUT.

    SYNTAX:
      # PASSWORD: STDOUT prompt is supplied.
      $password = console_password

      # You specify prompt to STDOUT
      $password = console_password @{ "message" = "Custom Prompt" }

    RETURNS:
      [string] the entered password via stdin
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  [string] $answer = ""
  if ($null -ne $Params) {
    if (-not $Params.ContainsKey("message")) {
      throw "SyntaxError: console_password Params did not contain 'message' key."
    }
    $answer = Read-Host -Prompt $Params["message"] -MaskInput
  } else {
    $answer = Read-Host -Prompt "PASSWORD" -MaskInput
  }
  return $answer
}

function console_writeln {
  <#
    .SYNOPSIS
    Writes a optional message to STDOUT with appended new line.

    SYNTAX:
      # New line
      console_writeln

      # Message with new line
      console_writeln @{ "message" = "The message" }

    RETURNS:
      [void]
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  if ($null -ne $Params) {
    if (-not $Params.ContainsKey("message")) {
      throw "SyntaxError: console_writeln Params did not contain 'message' key."
    }
    Write-Host $Params["message"]
  } else {
    Write-Host
  }
}

# -----------------------------------------------------------------------------
# [Database Use Case] ---------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Dialog Use Case] -----------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Disk Use Case] -------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [File Use Case] -------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Logger Use Case] -----------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Hardware Use Case] ---------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [JSON Use Case] -------------------------------------------------------------
# -----------------------------------------------------------------------------

function as_bool {
  <#
  .SYNOPSIS
    Attempts to convert a string to a boolean.

    SYNTAX:
      codemelted --as-bool @{ "data" = [any] }

    RETURNS:
      boolean $true / $false
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  try {
    if (-not $Params.ContainsKey("data")) {
      throw "--as-bool expects 'data' Params key"
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
  } catch [System.FormatException] {
    return $null
  }
}

function as_int {
  <#
  .SYNOPSIS
    Attempts to convert a string to a int.

    SYNTAX:
      codemelted --as-int @{ "data" = [any] }

    RETURNS:
      int or $null if conversion fails.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  try {
    if (-not $Params.ContainsKey("data")) {
      throw "--as-int expects 'data' Params key"
    }
    return [int]::Parse($Params["data"])
  } catch [System.FormatException] {
    return $null
  }
}

function as_double {
  <#
  .SYNOPSIS
    Attempts to convert a string to a double.

    SYNTAX:
      codemelted --as-double @{ "data" = [any] }

    RETURNS:
      double or $null if conversion fails.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  try {
    if (-not $Params.ContainsKey("data")) {
      throw "--as-double expects 'data' Params key"
    }
    return [double]::Parse($Params["data"])
  } catch [System.FormatException] {
    return $null
  }
}

function check_has_property {
  <#
  .SYNOPSIS
    Checks if a hashtable has a given property.

    SYNTAX:
      codemelted --check-has-property @{ "obj" = [hashtable]; "key" = [string] }

    RETURNS:
      $true if found, $false otherwise.

  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  try {
    if (-not $Params.ContainsKey("obj")) {
      throw "--check-has-property expects 'obj' Params key"
    } elseif (-not $Params.ContainsKey("key")) {
      throw "--check-has-property expects 'key' Params key"
    }
    $obj = $Params["obj"]
    if ($obj.GetType().Name.ToLower() -ne "hashtable") {
      throw "--check-has-property expects 'obj' Params key to be a 'hashtable'"
    }
    return $obj.ContainsKey($Params["key"])
  } catch [System.FormatException] {
    return $null
  }
}

function check_type {
  <#
  .SYNOPSIS
    Checks if the given data is of a specific type.

    SYNTAX:
      codemelted --check-type @{ "type" = [string]; "data" = [any] }

    RETURNS:
      $true if of the given type, $false otherwise.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  try {
    if (-not $Params.ContainsKey("data")) {
      throw "--check-type expects 'data' Params key"
    } elseif (-not $Params.ContainsKey("type")) {
      throw "--check-type expects 'type' Params key"
    }
    return $Params["type"].ToString().ToLower() `
      -eq $Params["data"].GetType().Name.ToLower()
  } catch [System.FormatException] {
    return $null
  }
}

function check_valid_url{
  <#
  .SYNOPSIS
    Checks if a given string is a valid URL.

    SYNTAX:
      codemelted --check-valid-url @{ "data" = [any] }

    RETURNS:
      $true if a valid URL, $false otherwise.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  try {
    if (-not $Params.ContainsKey("data")) {
      throw "--check-valid-url expects 'data' Params key"
    }
    return [uri]::IsWellFormedUriString($Params["data"].ToString(), 0)
  } catch [System.FormatException] {
    return $null
  }
}

function create_array {
  <#
  .SYNOPSIS
    Creates an empty array that is JSON compliant.

    SYNTAX:
      $arrayList = codemelted --create-array

    RETURNS:
      System.Collections.ArrayList
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $obj = New-Object System.Collections.ArrayList
  Write-Output -NoEnumerate $obj
}

function check_object {
  <#
  .SYNOPSIS
    Creates an empty JSON compliant hashtable.

    SYNTAX:
      $obj = codemelted --create-object

    RETURNS:
      hashtable
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return @{}
}

function parse_json {
  <#
  .SYNOPSIS
    Attempts to convert a JSON stringified string to a valid JSON hashtable.

    SYNTAX:
      $obj = codemelted --parse-json @{ "data" = [any] }

    RETURNS:
      hashtable or $null if conversion fails.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  try {
    if (-not $Params.ContainsKey("data")) {
      throw "--parse-json expects 'data' Params key"
    }
    return ConvertFrom-Json -InputObject $Params["data"] -AsHashtable -Depth 100
  } catch [System.FormatException] {
    return $null
  }
}

function stringify_json {
  <#
  .SYNOPSIS
    Attempts to convert a hashtable or System.Collection.ArrayList to a
    JSON stringified string.

    SYNTAX:
      codemelted --stringify-json @{ "data" = [any] }

    RETURNS:
      string or $null if conversion fails.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  try {
    if (-not $Params.ContainsKey("data")) {
      throw "--stringify-json expects 'data' Params key"
    }
    $data = $Params["data"]
    if ($data.GetType().Name.ToLower() -eq "arraylist") {
      return ConvertTo-Json -InputObject $data.ToArray() -Depth 100
    }
    return ConvertTo-Json -InputObject $Params["data"] -Depth 100
  } catch [System.FormatException] {
    return $null
  }
}

function try_has_property {
  <#
  .SYNOPSIS
    Checks if a hashtable has a given property.

    SYNTAX:
      codemelted --try-has-property @{ "obj" = [hashtable]; "key" = [string] }

    RETURNS:
      void

    THROWS:
      string error message if property is not found.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  try {
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
    return [void]
  } catch [System.FormatException] {
    return $null
  }
}

function try_type {
  <#
  .SYNOPSIS
    Checks if the given data is of a specific type.

    SYNTAX:
      codemelted --try-type @{ "type" = [string]; "data" = [any] }

    RETURNS:
      void

    THROWS:
      string error message if not of the expected type.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  try {
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
  } catch [System.FormatException] {
    return $null
  }
}

function try_valid_url {
  <#
  .SYNOPSIS
    Checks if a given string is a valid URL.

    SYNTAX:
      codemelted --try-valid-url @{ "data" = [any] }

    RETURNS:
      void

    THROWS:
      string error message if URL is not valid.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  try {
    if (-not $Params.ContainsKey("data")) {
      throw "try-valid-url Command expects 'data' Params key"
    }
    $wellFormed = [uri]::IsWellFormedUriString($Params["data"].ToString(), 0)
    if (-not $wellFormed) {
      throw "data was not a valid URL string"
    }
  } catch [System.FormatException] {
    return $null
  }
}

# -----------------------------------------------------------------------------
# [Math Use Case] -------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Memory Use Case] -----------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Monitor Use Case] ----------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Network Use Case] ----------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Process Use Case] ----------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Runtime Use Case] ----------------------------------------------------------
# -----------------------------------------------------------------------------

# TODO: Under development. Need testing.

function command_exist {
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  if (-not $Params.ContainsKey("command")) {
    throw "--command-exists expects 'command' key in Params"
  }

  $cmd = $Params["command"]
  $stdout = $Params["stdout"] # TODO: Parse true or false
  if ($IsWindows) {
    if ($stdout) {
      cmd /c "where $cmd"
    } else {
      cmd /c "$where cmd" > nul 2>&1
      return $LASTEXITCODE -eq 0
    }
  } else {
    if ($stdout) {
      sh -c "which $cmd"
    } else {
      sh -c "which $cmd" > /dev/null
      return $LASTEXITCODE -eq 0
    }
  }
}

function find_string {
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  if (-not $Params.ContainsKey("data")) {
    throw "--find-string expects 'data' key in Params"
  }

  $data = $Params["data"]
  $csvFilename = $Params["csv-filename"]
  # Get-ChildItem -Recurse |
  # Select-String "asset" -List |
  # Select-Object LineNumber,Path |
  # Export-Csv -Path c:\temp\output.csv -Append -NoTypeInformation |
  # Format-Table -Wrap
  Get-ChildItem | ForEach-Object {
    if ($null -ne $csvFilename) {
      $_ |
      Select-String $data -List |
      Select-Object Name,Length |
      Export-Csv -Path $csvFilename.csv -Append -NoTypeInformation
    }

    $_ |
    Select-String $data -List |
    Select-Object Name,Length |
    Format-Table -Wrap
  }
}

# -----------------------------------------------------------------------------
# [Setup Use Case] ------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [SPA Use Case] --------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Storage Use Case] ----------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Task Use Case] -------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Theming Use Case] ----------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Widget Use Case] -----------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [Worker Use Case] -----------------------------------------------------------
# -----------------------------------------------------------------------------


# =============================================================================
# [Main API Implementation] ===================================================
# =============================================================================

# OK, go parse the command.
switch ($Action) {
  # Module Information
  "--version" { Get-PSScriptFileInfo -Path $PSScriptRoot/codemelted.ps1 }
  "--help" { help $Params }
  # JSON Use Case
  "--as-bool" { as_bool $Params }
  "--as-int" { as_int $Params }
  "--as-double" { as_double $Params }
  "--check-has-property" { check_has_property $Params }
  "--check-type" { check_type $Params }
  "--check-valid-url" { check_valid_url $Params }
  "--create-array" { create_array }
  "--create-object" { create_object }
  "--parse-json" { parse_json $Params }
  "--stringify-json" { stringify_json $Params }
  "--try-has-property" { try_has_property $Params}
  "--try-type" { try_type $Params }
  "--try-valid-url" { try_valid_url $Params}
}
