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
.VERSION 0.5.1
.RELEASENOTES
  0.5.1 2025-02-23
  - Tailored the script to match the use case groups.
  - Implemented the --data-check, --json, and --string-parse options of the
    Data use cases, the --console of the User Interface use cases and the
    --logger of the SDK use cases.
  - The --disk use case is in development and exposed.

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
    # Async I/O Use Cases

    # Data Use Cases
    "--data-check",
    "--disk",
    "--json",
    "--string-parse",

    # NPU Use Cases

    # SDK Use Cases
    "--logger",

    # User Interface Use Cases
    "--console"
  )]
  [string] $Action,

  [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $false,
    Position = 1
  )]
  [hashtable]$Params
)

function codemelted_help {
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
        --help : Execute 'codemelted --help @{ "action" = "--use-case" }'
                 to learn more about the CLI Actions.
        --version : Get current information about the codemelted CLI

        # Async I/O Use Cases
        TBD

        # Data Use Cases
        --data-check
        --disk (IN DEVELOPMENT. DON'T USE)
        --json
        --string-parse

        # NPU Use Cases
        TBD

        # SDK Use Cases
        --logger

        # User Interface Use Cases
        --console

      [Params]
        The optional set of named arguments wrapped within a [hashtable]

    RETURNS:
      Will vary depending on the called [Action].

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
    # Async I/O Use Cases
    # Data Use Cases
    "--data-check" = { Get-Help codemelted_data_check };
    "--disk" = { Get-Help codemelted_disk };
    "--json" = { Get-Help codemelted_json };
    "--string-parse" = { Get-Help codemelted_string_parse };
    # NPU Use Cases
    # SDK Use Cases
    "--logger" = { Get-Help codemelted_logger };
    # User Interface Use Cases
    "--console" = { Get-Help codemelted_console };
  }
  if ($null -ne $Params) {
    if (-not $Params.ContainsKey("action")) {
      throw "--help expects action key to be specified"
    } elseif ($null -eq $helpLookup[$Params["action"]]) {
      throw "--help action specified did not find a help specification"
    }
    Invoke-Command -ScriptBlock $helpLookup[$Params["action"]]
  } else {
    Get-Help codemelted_help
  }
}

# =============================================================================
# [USE CASE DEFINITIONS] ======================================================
# =============================================================================

# -----------------------------------------------------------------------------
# [Async I/O Use Cases] -------------------------------------------------------
# -----------------------------------------------------------------------------

# TBD

# -----------------------------------------------------------------------------
# [Data Use Cases] ------------------------------------------------------------
# -----------------------------------------------------------------------------

# TBD - Database

function codemelted_data_check {
  <#
    .SYNOPSIS
    Provides basic data validation and type checking of dynamic variables
    within a powershell script.

    SYNTAX:
      # Checks that the specified 'data' [hashtable] has the specified 'key'.
      $answer = codemelted --data-check @{
        "action" = "has_property";      # required
        "data" = [hashtable];           # required
        "key" = "name of key in data";  # required
        "should_throw" = $false         # optional
      }

      # Checks that the specified 'data' variable is the expected typename
      # specified by the 'key'.
      $answer = codemelted --data-check @{
        "action" = "type";       # required
        "data" = $variable;      # required
        "key" = "typename";      # required (.NET type names)
        "should_throw" = $false  # optional
      }

      # Checks that the specified 'data' is a well formed URI object.
      $answer = codemelted --data-check @{
        "action" = "url";        # required
        "data" = "url string";   # required
        "should_throw" = $false  # optional
      }

    RETURNS:
      [boolean] $true if data check passes, $false otherwise

    THROWS:
      [string] if 'should_throw' is set to $true in the $Params.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  $action = $Params["action"]
  $data = $Params["data"]
  $key = $Params["key"]
  $shouldThrow = $Params["should_throw"] -is [boolean] `
    ? $Params["should_throw"]
    : $false

  if ($null -eq $data) {
    throw "SyntaxError: codemelted --data-check Params did not have a " +
      "specified data key and value."
  }

  $answer = $false
  $throwMessage = ""
  if ($action -eq "has_property") {
    if (-not ($data -is [hashtable])) {
      throw "SyntaxError: codemelted --data-check Params data key was not " +
        "a [hashtable] value for the 'has_property' action."
    } elseif ([string]::IsNullOrEmpty($key) `
               -or [string]::IsNullOrWhiteSpace($key)) {
      throw "SyntaxError: codemelted --data-check Params 'key' key " +
        "was not set."
    }
    $throwMessage = "$key did not exist for the codemelted --data-check " +
        "'has_property' action."
    $answer = $data.ContainsKey($key)

  } elseif ($action -eq "type") {
    if ([string]::IsNullOrEmpty($key) -or [string]::IsNullOrWhiteSpace($key)) {
      throw "SyntaxError: codemelted --data-check Params 'key' key "
        "was not set."
    }
    $throwMessage = "$key was not the expected type for the codemelted " +
        "--data-check 'type' action."
    $answer = $key.ToString().ToLower() -eq $data.GetType().Name.ToLower()

  } elseif ($action -eq "url") {
    $throwMessage = "$data failed the codemelted --data-check 'url' action."
    $answer = [uri]::IsWellFormedUriString($data.ToString(), 0)

  } else {
    throw "SyntaxError: codemelted --data-check Params did not have a " +
      "supported action key specified. Valid actions are has_property / " +
      "type / url"
  }

  # Handle how we are returning from this function whether to throw or return
  # boolean.
  if ($shouldThrow) {
    if ( -not $answer) {
      throw $throwMessage
    } else {
      return [void] $answer
    }
  }
  return $answer
}

function codemelted_disk {
  <#
    .SYNOPSIS
    Provides the actions to manage files and directories on disk. This
    includes getting a listing, determining if an item exists, what type it is
    along with being able to copy, delete, and moving items. Lastly you can
    determine the size of an item in bytes on disk.

    SYNTAX:
      # Copy or move a file / directory from the identified "src" location to
      # the specified "dest" location. The "mv" can also be used as a rename.
      $success = codemelted --disk @{
        "action" = "cp" / "mv"; # required
        "src" = [string];       # required
        "dest" = [string];      # required
        "report" = $true        # optional - warning if command fails
      }

      # Create a "src" directory or delete a "src" file / directory
      $success = codemelted --disk @{
        "action" = "mkdir" / "rm";  # required
        "src" = [string];           # required
        "report" = $false           # optional - warning if command fails
      }

      # Determine if a "src" file / directory exists or if it is of a
      # given type.
      $exists = codemelted --disk @{
        "action" = "exists";           # required
        "src" = [string];              # required
        "type" = "file" / "directory"; # optional that type vs. just existing
        "report" = $false              # optional - warning if command fails
      }

      # Get a listing of "src" directory for only the specified "type". This
      # means either only the directories, files, or recurse to get all
      # files and directories from the specified "src".
      $listing = codemelted --disk @{
        "action" = "ls";                            # required
        "src" = [string];                           # required
        "type" = "directory" / "file" / "recurse";  # optional
        "report" = $false                           # optional
      }

      # Gets the size in bytes of a "src" file / directory.
      $sizeInBytes = codemelted --disk @{
        "action" = "size";  # required
        "src" = [string];   # required
        "report" = $false   # optional
      }

    RETURNS:
      [boolean] $true for successful actions of 'cp' / 'exists' / 'mkdir' /
                'mv' / 'rm'. $false otherwise.

      [System.IO.DirectoryInfo] When executing an 'ls' action.

      [int] When executing a 'size' action.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  $action = $Params["action"]
  $src = $Params["src"]
  $dest = $Params["dest"]
  $type = $Params["type"]
  $report = $Params["report"] ?? $false

  if ([string]::IsNullOrEmpty($src) `
      -or [string]::IsNullOrWhiteSpace($src)) {
    throw "SyntaxError: codemelted --disk Params requires a src key / value"
  } elseif (-not ($report -is [boolean])) {
    throw "SyntaxError: codemelted --disk Params optional report key is " +
      "expected to be a [boolean] value"
  }

  try {
    if ($action -eq "cp") {
      if ([string]::IsNullOrEmpty($dest) `
            -or [string]::IsNullOrWhiteSpace($dest)) {
        throw "SyntaxError: codemelted --disk Params dest key is expected."
      }
      $isSrcADirectory = (Test-Path $src -PathType Container)
      if ($isSrcADirectory) {
        Copy-Item -Path $src -Destination $dest -Recurse -Force `
          -ErrorAction Stop
        return $true
      }
      Copy-Item -Path $src -Destination $dest -Force -ErrorAction Stop
      return $true
    } elseif ($action -eq "exists") {
      $answer = $type -eq "directory" `
        ? (Test-Path $src -PathType Container)
        : $type -eq  "file" `
          ? (Test-Path $src -PathType Leaf)
          : (Test-Path $src)
      return $answer
    } elseif ($action -eq "ls") {
      $answer = $type -eq "directory" `
        ? (Get-ChildItem -Path $src -Directory -ErrorAction Stop)
        : $type -eq "file" `
          ? (Get-ChildItem -Path $src -File -ErrorAction Stop)
          : $type -eq "recurse" `
            ? (Get-ChildItem -Path $src -Recurse -ErrorAction Stop)
            : (Get-ChildItem -Path $src -ErrorAction Stop)
      return $answer
    } elseif ($action -eq "mkdir") {
      New-Item -ItemType Directory -Path $src -Force -ErrorAction Stop
      return $true
    } elseif ($action -eq "mv") {
      if ([string]::IsNullOrEmpty($dest) `
            -or [string]::IsNullOrWhiteSpace($dest)) {
        throw "SyntaxError: codemelted --disk Params dest key is expected."
      }
      Move-Item -Path $src -Destination $dest -Force -ErrorAction Stop
      return $true
    } elseif ($action -eq "rm") {
      Remove-Item -Path $src -Recurse -Force -ErrorAction Stop
      return $true
    } elseif ($action -eq "size") {
      $isFile = Test-Path $src -PathType Leaf
      if ($isFile) {
        $sizeInBytes = (Get-ChildItem $src -ErrorAction Stop).Length
        return $sizeInBytes
      }
      $sizeInBytes = (Get-ChildItem -Path $directoryPath -Recurse | `
        Measure-Object -Property Length -Sum -ErrorAction Stop).Sum
      return $sizeInBytes
    } else {
      throw "SyntaxError: codemelted --disk Params did not have a " +
        "supported action key specified. Valid actions are cp / exists / ls " +
        "mkdir / mv / rm / size"
    }
  } catch [string] {
    throw
  } catch {
    if ($report) {
      Write-Warning $_.Exception.Message
    }
    return $false
  }
}

# TBD - File

function codemelted_json {
  <#
    .SYNOPSIS
    Provides the facilities to create / copy JSON compliant .NET objects and
    the ability to parse / stringify that data for storage, transmission, and
    processing of the data.

    SYNTAX:
      # Create / copy data into a new [arraylist]
      $data = codemelted --json @{
        "action" = "create_array";  # required
        "data" = $arrayListData     # optional [arraylist] to copy
      }

      # Create / copy data into a new [arraylist]
      $data = codemelted --json @{
        "action" = "create_object";  # required
        "data" = $hashTableData      # optional [arraylist] to copy
      }

      # Parse a string into a [hashtable] or [arraylist] or generic datatype
      $data = codemelted --json @{
        "action" = "parse";   # required
        "data" = $stringData  # required [string] data
      }

      # Transform a [arraylist] or [hashtable] into string data
      $data = codemelted --json @{
        "action" = "stringify"; # required
        "data" = $theData       # required [arraylist] or [hashtable] data
      }

    RETURNS:
      [arraylist] for 'create_array' / 'parse' actions.
      [hashtable] for 'create_object' / 'parse' actions.
      [string] for 'stringify' action.
      $null for invalid data types that can't be translated.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  $action = $Params["action"]
  $data = $Params["data"]

  try {
    if ($action -eq "create_array") {
      $obj = New-Object System.Collections.ArrayList
      if ($data -is [System.Collections.ArrayList]) {
        $obj = $data.Clone()
      } elseif ($data -is [array]) {
        $obj += $data
      }
      return $obj
    } elseif ($action -eq "create_object") {
      $obj = $data -is [hashtable] ? $data.Clone() : @{}
      return $obj
    } elseif ($action -eq "parse") {
      if ([string]::IsNullOrEmpty($data) -or [string]::IsNullOrWhiteSpace($data)) {
        throw "SyntaxError: codemelted --json Params expects a data key."
      }
      return ConvertFrom-Json -InputObject $data -AsHashtable -Depth 100
    } elseif ($action -eq "stringify") {
      if ($null -eq $data) {
        throw "SyntaxError: codemelted --json Params expects a data key."
      }
      if ($data.GetType().Name.ToLower() -eq "arraylist") {
        return ConvertTo-Json -InputObject $data.ToArray() -Depth 100
      }
      return ConvertTo-Json -InputObject $data -Depth 100
    } else {
      throw "SyntaxError: codemelted json Params did not have a " +
        "supported action key specified. Valid actions are create_array / " +
        "create_object / parse / stringify"
    }
  } catch [System.FormatException] {
    return $null
  }
}

function codemelted_string_parse {
  <#
    .SYNOPSIS
    Provides the facilities to translate strings into their appropriate
    data type.

    SYNTAX:
      $data = codemelted --string-parse @{
        "action" = "";  # required
        "data" = $dataString  # required
      }

    ACTIONS:
      array / boolean / double / int / object

    RETURNS:
      [System.Collections.ArrayList] for 'array' action.
      [boolean] for 'boolean' action.
      [double] for 'double' action.
      [int] for 'int' action.
      [object] for 'object' action.
      $null for string data that can't be translated.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $action = $Params["action"]
  $data = $Params["data"]
  if ([string]::IsNullOrEmpty($data) `
      -or [string]::IsNullOrWhiteSpace($data)) {
    throw "SyntaxError: codemelted --string-parse Params expects a " +
      "data key value."
  }

  try {
    if ($action -eq "array" -or $action -eq "object") {
      $answer = codemelted_json @{ "action" = "parse"; "data" = $data }
      return $answer
    } elseif ($action -eq "boolean") {
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
      return $trueStrings.Contains(
        $data.ToString().ToLower()
      )
    } elseif ($action -eq "double") {
      return [double]::Parse($data)
    } elseif ($action -eq "int") {
      return [int]::Parse($data)
    } else {
      throw "SyntaxError: codemelted --string-parse Params did not have a " +
        "supported action key specified. Valid actions are array / " +
        "boolean / double / int / object"
    }
  } catch [FormatException] {
    return $null
  }
}

# TBD - Storage

# TBD - XML

# -----------------------------------------------------------------------------
# [NPU Use Cases] -------------------------------------------------------------
# -----------------------------------------------------------------------------

# TBD

# -----------------------------------------------------------------------------
# [SDK Use Cases] -------------------------------------------------------------
# -----------------------------------------------------------------------------

# Provides the log record object to pass to a handler for post processing.
# Attached to it is the module log level along with the current captured
# log level, data, and the time it was logged.
class CLogRecord {
  # Constants
  static [int] $debugLogLevel = 0
  static [int] $infoLogLevel = 1
  static [int] $warningLogLevel = 2
  static [int] $errorLogLevel = 3
  static [int] $offLogLevel = 4

  # Utility to translate to the constants to string representation.
  static [string] logLevelString([int]$logLevel) {
    if ($logLevel -eq [CLogRecord]::debugLogLevel) {
      return "DEBUG"
    } elseif ($logLevel -eq [CLogRecord]::infoLogLevel) {
      return "INFO"
    } elseif ($logLevel -eq [CLogRecord]::warningLogLevel) {
      return "WARNING"
    } elseif ($logLevel -eq [CLogRecord]::errorLogLevel) {
      return "ERROR"
    } elseif ($logLevel -eq [CLogRecord]::offLogLevel) {
      return "OFF"
    }

    return "UNKNOWN"
  }

  # Utility to translate from string to constant log level number.
  static [int] logLevelInt([string]$logLevel) {
    if ($logLevel.ToLower() -eq "debug") {
      return [CLogRecord]::debugLogLevel
    } elseif ($logLevel.ToLower() -eq "info") {
      return [CLogRecord]::infoLogLevel
    } elseif ($logLevel.ToLower() -eq "warning") {
      return [CLogRecord]::warningLogLevel
    } elseif ($logLevel.ToLower() -eq "error") {
      return [CLogRecord]::errorLogLevel
    }

    return -1
  }

  # Member Fields
  [string]$timestamp
  [int]$moduleLogLevel = -1
  [int]$logLevel = -1
  [string]$data = ""

  # Constructor for the class.
  CLogRecord([int]$moduleLogLevel, [int] $logLevel, [string] $data) {
    $this.timestamp = (Get-Date -Format "yyyy/MM/dd HH:mm:ss.fff")
    $this.moduleLogLevel = $moduleLogLevel
    $this.logLevel = $logLevel
    $this.data = $data
  }

  [string] ToString() {
    return $this.timestamp +
      " [" +
      [CLogRecord]::logLevelString($this.logLevel) +
      "]: " +
      $this.data
  }
}

function codemelted_logger {
  <#
    .SYNOPSIS
    Provides a logging facility to report log events to STDOUT color coded
    based on the type of event. Also provides for setting up a handler to
    perform other types of processing not just to STDOUT.

    SYNTAX:
      # Set up the log level for the logging facility within the module.
      # The "data" levels are 'debug' / 'info' / 'warning' / 'error' / 'off'.
      codemelted --logger @{
        "action" = "log_level";  # required
        "data" = [string]       # optional
      }

      # Set up a log handler for logged events via the logger. This will
      # be called when the logger is not configured as off. Regardless of
      # the log level, the event will be passed to the handler. The
      # CLogRecord object will include the current moduleLogLevel.
      codemelted --logger @{
        "action" = "handler";           # required
        "data" = [scriptblock] / $null  # required
      }

      # To log data to STDOUT set the "action" to 'debug' / 'info' /
      # 'warning' / 'error'. If the event meets the module log level,
      # it will report to STDOUT color coded and time stamped.
      codemelted --logger @{
        "action" = [string]  # required
        "data"   = [string]  # required
      }

    RETURNS:
      [string] When the action is 'log_level' but no log level is set.
      [void]   For all other actions.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  # Properly initialize the log level if not set yet.
  if ($null -eq $Global:logLevel) {
    $Global:logLevel = [CLogRecord]::offLogLevel
  }

  $action = $Params["action"]
  $data = $Params["data"]

  if ($action -eq "log_level") {
    if ($null -eq $data) {
      $logLevelString = [CLogRecord]::logLevelString($Global:logLevel)
      return $logLevelString
    }
    $level = [CLogRecord]::logLevelInt($data)
    if ($level -eq -1) {
      throw "SyntaxError: codemelted --logger Params data key not a valid " +
        "value for setting log level. Valid values are 'debug' / 'info' " +
        "/ 'warning' / 'error'"
    }
    $Global:logLevel = $level
  } elseif ($action -eq "handler") {
    if ($null -eq $data) {
      $Global:logHandler = $null
    } elseif ($data -is [scriptblock]) {
      $Global:logHandler = $data
    } else {
      throw "SyntaxError: codemelted --logger Params handler action only " +
        "supports a data value of [null] or [scriptblock]"
    }
  } elseif ($action -eq "debug" -or $action -eq "info" -or `
            $action -eq "warning" -or $action -eq "error") {
    if ($Global:logLevel -eq [CLogRecord]::offLogLevel) {
      return [void]
    }
    $level = [CLogRecord]::logLevelInt($action)
    $record = [CLogRecord]::new($Global:logLevel, $level, $data)
    if ($Global:logLevel -le [CLogRecord]::debugLogLevel -and `
        $level -eq [CLogRecord]::debugLogLevel) {
      Write-Host $record.ToString() -ForegroundColor White
    } elseif ($Global:logLevel -le [CLogRecord]::infoLogLevel -and `
            $level -eq [CLogRecord]::infoLogLevel) {
      Write-Host $record.ToString() -ForegroundColor Green
    } elseif ($Global:logLevel -le [CLogRecord]::warningLogLevel -and `
            $level -eq [CLogRecord]::warningLogLevel) {
      Write-Host $record.ToString() -ForegroundColor Yellow
    } elseif ($Global:logLevel -le [CLogRecord]::errorLogLevel -and `
            $level -eq [CLogRecord]::errorLogLevel) {
      Write-Host $record.ToString() -ForegroundColor Red
    }

    if ($null -ne $Global:logHandler) {
      Invoke-Command -ScriptBlock $Global:logHandler -ArgumentList $record
    }
  } else {
    throw "SyntaxError: codemelted --slogger Params did not have a " +
    "supported action key specified. Valid actions are log_level / " +
    "handler / debug / info / warning / error."
  }
}

# -----------------------------------------------------------------------------
# [User Interface Use Cases] --------------------------------------------------
# -----------------------------------------------------------------------------

function codemelted_console {
  <#
    .SYNOPSIS
    Provides a basic mechanism for interacting with a user via STDIN and
    STDOUT for later processing within a script.

    SYNTAX:
      $answer = codemelted --console @{
        "action" = "";  # required
        "message" = ""; # optional message to associate with action
        "choices" = @(  # required when using the 'choose' action.
          "dog",
          "cat",
          "fish"
        )
      }

    ACTIONS:
      alert / confirm / choose / password / prompt / writeln

    RETURNS:
      alert    [void]
      confirm  [boolean]
      choose   [int]
      password [string]
      prompt   [string]
      writeln  [void]
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  $action = $Params["action"]
  $message = $Params["message"]
  $choices = $params["choices"]
  if ($action -eq "alert") {
    $prompt = $null -ne $message ? "$message [ENTER]" : "[ENTER]"
    Read-Host -Prompt $prompt -MaskInput | Out-Null
  } elseif ($action -eq "confirm") {
    $prompt = $null -ne $message ? "$message [y/N]" : "CONFIRM [y/N]"
    $answer = Read-Host -Prompt $prompt
    return $answer.ToLower() -eq "y"
  } elseif ($action -eq "choose") {
    if ((-not ($choices -is [array])) -or $choices.Length -eq 0) {
      throw "SyntaxError: codemelted --console Params expects a choices " +
        "key with an array of string values."
    }

    [int] $answer = -1
    [string] $title = $message ?? "CHOOSE"
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
  } elseif ($action -eq "password") {
    $answer = Read-Host -Prompt ($message ?? "PASSWORD") -MaskInput
    return $answer
  } elseif ($action -eq "prompt") {
    $answer = Read-Host -Prompt ($message ?? "PROMPT")
    return $answer
  } elseif ($action -eq "writeln") {
    Write-Host ($message ?? "")
  } else {
    throw "SyntaxError: codemelted --console Params did not have a " +
      "supported action key specified. Valid actions are alert / " +
      "confirm / choose / password / prompt / writeln."
  }
}

# TBD - Dialog

# TBD - SPA

# TBD - UI Widgets

# =============================================================================
# [MAIN API DEFINITION] =======================================================
# =============================================================================

# OK, go parse the command.
switch ($Action) {
  # Module Information
  "--version" { Get-PSScriptFileInfo -Path $PSScriptRoot/codemelted.ps1 }
  "--help" { codemelted_help $Params }
  # Async I/O Use Cases
  # Data Use Cases
  "--data-check" { codemelted_data_check $Params }
  "--disk" { codemelted_disk $Params }
  "--json" { codemelted_json $Params }
  "--string-parse" { codemelted_string_parse $Params }
  # NPU Use Cases
  # SDK Use Cases
  "--logger" { codemelted_logger $Params }
  # User Interface Use Case
  "--console" { codemelted_console $Params }
}
