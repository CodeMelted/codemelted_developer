# =============================================================================
# [TERMINAL MODULE DEFINITION] ================================================
# =============================================================================
<#PSScriptInfo
.AUTHOR mark.shaffer@codemelted.com
.COPYRIGHT © 2025 Mark Shaffer. All Rights Reserved. MIT License
.LICENSEURI https://github.com/CodeMelted/codemelted_developer/blob/main/LICENSE
.PROJECTURI https://github.com/codemelted/codemelted_developer
.ICONURI https://codemelted.com/assets/images/icon-codemelted-pwsh.png
.EXTERNALMODULEDEPENDENCIES Microsoft.PowerShell.ConsoleGuiTools
.TAGS pwsh pwsh-scripts pwsh-modules CodeMeltedDEV codemelted codemelted.ps1
.GUID c757fe44-4ed5-46b0-8e24-9a9aaaad872c
.VERSION 25.1.1
.RELEASENOTES
  v25.1.1 (2025-07-20)
  - Completed refactor to the new system to match the use case fleshed out
    design.
  - This supersedes the previous v0.8.0 version going forward.
  - See the website for details of the new semantic versioning details and new
    CLI structure.
#>

# =============================================================================
# [MODULE DATA DEFINITION] ====================================================
# =============================================================================

<#
  .DESCRIPTION
    A CLI to facilitate common developer use cases on Mac / Linux / Windows.
#>
param(
  [Parameter(
    Mandatory = $true,
    ValueFromPipeline = $false,
    Position = 0
  )]
  [ValidateSet(
    # Module Definition
    "--version",
    "--help",
    # Async Use Case
    "--async-sleep",
    "--async-task",
    "--async-timer",
    # Console Use Case
    "--console-alert",
    "--console-confirm",
    "--console-choose",
    "--console-password",
    "--console-prompt",
    "--console-write",
    "--console-writeln",
    # DB Use Case
    # TBD
    # Developer Use Case
    # TBD
    # Disk Use Case
    "--disk-cp",
    "--disk-exists",
    "--disk-ls",
    "--disk-mkdir",
    "--disk-mv",
    "--disk-rm",
    "--disk-size",
    # HW Use Case
    # TBD
    # JSON Use Case
    "--json-check-type",
    "--json-create-array",
    "--json-create-object",
    "--json-check-type",
    "--json-parse",
    "--json-stringify",
    "--json-valid-url",
    # Logger Use Case
    "--logger-level",
    "--logger-handler",
    "--logger-log",
    # Network Use Case
    "--network-fetch",
    # NPU Use Case
    # TBD
    # Process Use Case
    "--process-exists",
    "--process-run",
    # Runtime Use Case
    "--runtime-cpu-arch",
    "--runtime-cpu-count",
    "--runtime-environment",
    "--runtime-home-path",
    "--runtime-hostname",
    "--runtime-newline",
    "--runtime-online",
    "--runtime-os-name",
    "--runtime-os-version",
    "--runtime-path-separator",
    "--runtime-temp-path",
    "--runtime-user"
    # Setup Use Case
    # TBD
    # Storage Use Case
    # TBD
    # UI Use Case
    # TBD
  )]
  [string] $Action,

  [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $false,
    Position = 1
  )]
  [hashtable]$Params
)

# .NET Assemblies
Add-Type -AssemblyName Microsoft.PowerShell.Commands.Utility

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
        # To Learn About the CLI use case functions.
        --help : Execute 'codemelted --help @{ action = "use_case" }'
                 to learn about the CLI actions associated with the
                 use case.

                 Execute
                   codemelted --help @{
                     action = "--use_case-function"
                   }
                 to learn about an individual CLI action associated
                 with the given use case listed above.

        --version : Get current information about the codemelted CLI

        --function-name : The identified use case function name to execute.
                          Ex. codemelted --logger-log [Params]

      [Params]
        The optional set of named arguments wrapped within a [hashtable]

    USE CASES:
      async     : IN DEVELOPMENT
      console   : COMPLETED
      db        : TBD
      developer : TBD
      disk      : IN DEVELOPMENT
      hw        : TBD
      json      : COMPLETED
      logger    : COMPLETED
      monitor   : TBD
      network   : IN DEVELOPMENT
      npu       : TBD
      process   : IN DEVELOPMENT
      runtime   : COMPLETED
      setup     : TBD
      storage   : TBD
      ui        : TBD

    RETURNS:
      Will vary depending on the called [Action] representing a use case
      function call. It will be documented with each use case function.

  .LINK
    codemelted.ps1 SDK Docs:
    https://developer.codemelted.com/modules/powershell

    GitHub Source:
    https://github.com/CodeMelted/codemelted_developer
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
    # async use case functions
    "async" = {
      Write-Host "==============================="
      Write-Host "codemelted CLI (async) Use Case"
      Write-Host "==============================="
      Write-Host
      Write-Host "This use case provides the ability to schedule background"
      Write-Host "work off the main thread to provide asynchronous processing"
      Write-Host "within a PowerShell script / terminal."
      Write-Host
      Write-Host "--async-sleep"
      Write-Host "--async-task"
      Write-Host "--async-timer"
      Write-Host "--async-worker (TBD)"
      Write-Host
      Write-Host "Execute 'codemelted --help @ { action = ""--uc-name"" }'"
      Write-Host "for more details."
    };
    "--async-sleep" = { Get-Help async_sleep };
    "--async-task" = { Get-Help async_task };
    "--async-timer" = { Get-Help async_timer };

    # console use case functions
    "console" = {
      Write-Host "================================="
      Write-Host "codemelted CLI (console) Use Case"
      Write-Host "================================="
      Write-Host
      Write-Host "This use case provides the ability to interact with a user"
      Write-Host "via STDIN and STDOUT to provide an interactive console"
      Write-Host "experience. The use case options available are:"
      Write-Host
      Write-Host "--console-alert"
      Write-Host "--console-confirm"
      Write-Host "--console-choose"
      Write-Host "--console-password"
      Write-Host "--console-prompt"
      Write-Host "--console-write"
      Write-Host "--console-writeln"
      Write-Host
      Write-Host "Execute 'codemelted --help @ { action = ""--uc-name"" }'"
      Write-Host "for more details."
    };
    "--console-alert" = { Get-Help console_alert };
    "--console-confirm" = { Get-Help console_confirm };
    "--console-choose" = { Get-Help console_choose };
    "--console-password" = { Get-Help console_password };
    "--console-prompt" = { Get-Help console_prompt };
    "--console-write" = { Get-Help console_write };
    "--console-writeln" = { Get-Help console_writeln };

    # db use case functions
    "db" = {
      Write-Host "TBD"
    };

    # developer use case functions
    "developer" = {
      Write-Host "TBD"
    };

    # disk use case functions
    "disk" = {
      Write-Host "================================="
      Write-Host "codemelted CLI (disk) Use Case"
      Write-Host "================================="
      Write-Host
      Write-Host "This use case provides the ability to interact with a user"
      Write-Host
      Write-Host "--disk-cp"
      Write-Host "--disk-exists"
      Write-Host "--disk-ls"
      Write-Host "--disk-mkdir"
      Write-Host "--disk-mv"
      Write-Host "--disk-read-file (IN DEVELOPMENT)"
      Write-Host "--disk-rm"
      Write-Host "--disk-size"
      Write-Host "--disk-write-file (IN DEVELOPMENT)"
      Write-Host
      Write-Host "Execute 'codemelted --help @ { action = ""--uc-name"" }'"
      Write-Host "for more details."
    };
    "--disk-cp" = { Get-Help disk_cp };
    "--disk-exists" = { Get-Help disk_exists };
    "--disk-ls" = { Get-Help disk_ls };
    "--disk-mkdir" = { Get-Help disk_mkdir };
    "--disk-mv" = { Get-Help disk_mv };
    "--disk-rm" = { Get-Help disk_rm };
    "--disk-size" = { Get-Help disk_size };

    # hw use case functions
    "hw" = {
      Write-Host "TBD"
    };

    # json use case functions
    "json" = {
      Write-Host "=============================="
      Write-Host "codemelted CLI (json) Use Case"
      Write-Host "=============================="
      Write-Host
      Write-Host "This use case provides the ability to work with JSON data."
      Write-Host "This includes creating compliant JSON container objects,"
      Write-Host "checking data types, parsing, and serializing the data"
      Write-Host "for storage / transmission. The available use case options"
      Write-Host "are:"
      Write-Host
      Write-Host "--json-check-type"
      Write-Host "--json-create-array"
      Write-Host "--json-create-object"
      Write-Host "--json-parse"
      Write-Host "--json-stringify"
      Write-Host "--json-valid-url"
      Write-Host
      Write-Host "Execute 'codemelted --help @{ action = ""--uc-name"" }'"
      Write-Host "for more details."
    };
    "--json-check-type" = { Get-Help json_check_type };
    "--json-create-array" = { Get-Help json_create_array };
    "--json-create-object" = { Get-Help json_create_object };
    "--json-parse" = { Get-Help json_parse };
    "--json-stringify" = { Get-Help json_stringify };
    "--json-valid-url" = { Get-Help json_valid_url };

    # logger use case functions
    "logger" = {
      Write-Host "================================="
      Write-Host "codemelted CLI (logger) Use Case"
      Write-Host "================================="
      Write-Host
      Write-Host "This use case provides a logging facility with PowerShell."
      Write-Host "All logging is sent to STDOUT color coded based on the log"
      Write-Host "level of the logged item. Simply set the log level and"
      Write-Host "log events that meet that level, are logged to STDOUT. To"
      Write-Host "further process the log event, set a log handler."
      Write-Host "The available use case options are:"
      Write-Host
      Write-Host "--logger-level"
      Write-Host "--logger-handler"
      Write-Host "--logger-log"
      Write-Host
      Write-Host "Execute 'codemelted --help @{ action = ""--uc-name"" }'"
      Write-Host "for more details."
    };
    "--logger-level" = { Get-Help logger_level };
    "--logger-handler" = { Get-Help logger_handler };
    "--logger-log" = { Get-Help logger_log };

    # monitor use case functions
    "monitor" = {
      Write-Host "TBD"
    };

    # network use case functions
    "network" = {
      Write-Host "================================="
      Write-Host "codemelted CLI (network) Use Case"
      Write-Host "================================="
      Write-Host
      Write-Host "This use case provides the ability to fetch data from"
      Write-Host "server REST API endpoints along with setting up and hosting"
      Write-Host "your own HTTP server endpoint for REST API services and"
      Write-Host "creating a web socket server for web sockets. The use case"
      Write-Host "available are:"
      Write-Host
      Write-Host "--network-connect (TBD)"
      Write-Host "--network-fetch"
      Write-Host "--network-serve (TBD)"
      Write-Host "--upgrade-web-socket (TBD)"
      Write-Host
      Write-Host "Execute 'codemelted --help @{ action = ""--uc-name"" }'"
      Write-Host "for more details."
    };
    "--network-fetch" = { Get-Help network_fetch };

    # npu use cse functions
    "npu" = {
      Write-Host "TBD"
    };

    # process use case functions
    "process" = {
      Write-Host "================================="
      Write-Host "codemelted CLI (process) Use Case"
      Write-Host "================================="
      Write-Host
      Write-Host "This use case facilitates the ability to kick-off other"
      Write-Host "operating system commands and process their output. This"
      Write-Host "is done either as a one-off run or a spawned bi-direction"
      Write-Host "process where you interact with said process via "
      Write-Host "STDIN / STDOUT until the process is terminated."
      Write-Host
      Write-Host "--process-exists"
      Write-Host "--process-run"
      Write-Host "--process-spawn (TBD)"
      Write-Host
      Write-Host "Execute 'codemelted --help @{ action = ""--uc-name"" }'"
      Write-Host "for more details."
    };
    "--process-exists" = { Get-Help process_exists };
    "--process-run" = { Get-Help process_run };

    # runtime use case functions
    "runtime" = {
      Write-Host "================================="
      Write-Host "codemelted CLI (runtime) Use Case"
      Write-Host "================================="
      Write-Host
      Write-Host "This use case provides queryable information about the host"
      Write-Host "operating system running the pwsh terminal shell."
      Write-Host
      Write-Host "--runtime-cpu-arch"
      Write-Host "--runtime-cpu-count"
      Write-Host "--runtime-environment"
      Write-Host "--runtime-home-path"
      Write-Host "--runtime-hostname"
      Write-Host "--runtime-newline"
      Write-Host "--runtime-online"
      Write-Host "--runtime-os-name"
      Write-Host "--runtime-os-version"
      Write-Host "--runtime-path-separator"
      Write-Host "--runtime-temp-path"
      Write-Host "--runtime-user"
      Write-Host
      Write-Host "Execute 'codemelted --help @{ action = ""--uc-name"" }'"
      Write-Host "for more details."
    };
    "--runtime-cpu-arch" = { Get-Help runtime_cpu_arch };
    "--runtime-cpu-count" = { Get-Help runtime_cpu_count };
    "--runtime-environment" = { Get-Help runtime_environment };
    "--runtime-home-path" = { Get-Help runtime_home_path };
    "--runtime-hostname" = { Get-Help runtime_hostname };
    "--runtime-newline" = { Get-Help runtime_newline };
    "--runtime-online" = { Get-Help runtime_online };
    "--runtime-os-name" = { Get-Help runtime_os_name };
    "--runtime-os-version" = { Get-Help runtime_os_version };
    "--runtime-path-separator" = { Get-Help runtime_path_separator };
    "--runtime-temp-path" = { Get-Help runtime_temp_path };
    "--runtime-user" = { Get-Help runtime_user };

    # setup use case functions
    "setup" = {
      Write-Host "TBD"
    };

    # storage use case functions
    "storage" = {
      Write-Host "TBD"
    };

    # ui use case functions
    "ui" = {
      Write-Host "TBD"
    };
  }
  if ($null -ne $Params) {
    if (-not $Params.ContainsKey("action")) {
      throw "expects action key to be specified"
    } elseif ($null -eq $helpLookup[$Params["action"]]) {
      throw "action specified did not find a help specification"
    }
    Invoke-Command -ScriptBlock $helpLookup[$Params["action"]]
  } else {
    Get-Help codemelted_help
  }
}

# =============================================================================
# [ASYNC UC IMPLEMENTATION] ===================================================
# =============================================================================

# Holds the results of a codemelted_task 'run' action. This happens in a
# background thread.
class CTaskResult {
  # Member Fields
  hidden [object] $threadJob = $null

  # Will contain the final result of the ran task. Will block if called
  # before the task has completed.
  [object] value() {
    $this.threadJob | Wait-Job
    $answer = ($this.threadJob | Receive-Job)
    $this.threadJob | Remove-Job
    return $answer
  }

  # Provides the ability to check if the task has completed.
  [bool] has_completed() {
    return $this.threadJob.State.ToLower() -eq "completed"
  }

  # Constructor for the class.
  CTaskResult([scriptblock] $task, [object] $data, [int] $delay) {
    $this.threadJob = Start-ThreadJob -ScriptBlock {
      param($taskRunner, $taskData, $taskDelay)
      Start-Sleep -Milliseconds $taskDelay
      $answer = Invoke-Command -ScriptBlock $taskRunner -ArgumentList $taskData
      return $answer
    } -ArgumentList $task, $data, $delay
  }
}

# Object for tracking codemelted_task 'start_timer' action. This happens in a
# background thread.
class CTimerResult {
  # Member Fields
  [int] $id = -1
  hidden [object] $threadJob = $null

  # Provides the ability to check if the task is running or not.
  [bool] is_running() {
    return $this.threadJob.State.ToLower() -eq "running"
  }

  # Stops the running timer.
  [void] stop() {
    if ($this.is_running()) {
      Stop-Job -Job $this.threadJob
      Remove-Job -Job $this.threadJob
    }
  }

  # Constructor for the class.
  CTimerResult([scriptblock] $task, [int] $interval) {
    # Setup the background thread job to call the task on the given
    # interval.
    $this.threadJob = Start-ThreadJob -ScriptBlock {
      param([scriptblock] $timerTask, [int] $timerDelay)
      while ($true) {
        Start-Sleep -Milliseconds $timerDelay
        Invoke-Command -ScriptBlock $timerTask
      }
    } -ArgumentList $task, $interval
  }
}

function async_sleep {
  <#
  .SYNOPSIS
    Will delay a given script task for the specified time in milliseconds.

    SYNTAX:
      codemelted --async-sleep @{
        delay = [int]; # required
      }

    RETURNS:
      [void]
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $delay = $Params["delay"] ?? 0

  # Do validity checks of said parameters
  if ($delay -lt 0) {
    throw "Params 'delay' key needs to be an [int] >= 0."
  }
  Start-Sleep -Milliseconds $delay
}

function async_task {
  <#
  .SYNOPSIS
    Starts a background processing task that will run to completion and
    provide the answer to the returned from the task.

    SYNTAX:
      # 'task' Example:
      $task = {
        param($data)
        return $data + 5
      }

      $scheduledTask = codemelted --async-task @{
        task = $task;    # [scriptblock] required
        data = [object]; # optional
        delay = [int];   # optional
      }

      # Some processing later...
      if ($scheduleTask.has_completed()) {
        # This blocks if it has not completed.
        $value = $scheduledTask.value()
      }

    RETURNS:
      [CTaskResult] object that will hold the task running in the background
        until completed. You can check if it has completed via the
        has_completed() function call and access the final calculated value
        via the value() function.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  # Get the named parameters and validate them.
  $task = $Params["task"]
  $data = $Params["data"]
  $delay = $Params["delay"] ?? 0
  if ($delay -lt 0) {
    throw "Params 'delay' key needs to be an [int] >= 0."
  } elseif (-not ($task -is [scriptblock])) {
    throw "Params 'task' key needs to be a [scriptblock]"
  }

  # Return the task running in the background
  return [CTaskResult]::new($task, $data, $delay)
}

function async_timer {
  <#
  .SYNOPSIS
    Kicks off a repeating background timer on a given interval in
    milliseconds.

    SYNTAX:
      $timer = codemelted --async-timer @{
        task = [scriptblock]; # required
        interval = [int]; # required
      }

      # Some processing later...
      if ($timer.is_running()) {
        $timer.stop()
      }

    RETURNS:
      [CTimerResult] object with the methods of is_running() and stop() to
      determine if the timer is running and stopping it altogether.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  # Get the named parameters and validate them.
  $task = $Params["task"]
  $interval = $Params["interval"] ?? 0
  if ($interval -lt 99) {
    throw "Params 'interval' key needs to be an [int] >= 100."
  } elseif (-not ($task -is [scriptblock])) {
    throw "Params 'task' key needs to be a [scriptblock]"
  }
  return [CTimerResult]::new($task, $interval)
}

# TODO async_worker()
#   Items needs to be synchronized.
#   Also need to "copy" the array list into thread job for it to work
#   properly.
#   queued = [System.Collections.ArrayList]::Synchronized( `
#     [System.Collections.ArrayList]::new()
#   );

# =============================================================================
# [CONSOLE UC IMPLEMENTATION] =================================================
# =============================================================================

function console_alert {
  <#
  .SYNOPSIS
    Provides a pausing alert to STDOUT with an optional message until the user
    presses [ENTER] to continue. If no message is specified then just [ENTER]
    is presented.

    SYNTAX:
      codemelted --console-alert @{
        message = ""; # optional
      }

    RETURNS:
      [void]
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $message = $Params["message"]
  $prompt = $null -ne $message ? "$message [ENTER]" : "[ENTER]"
  Read-Host -Prompt $prompt -MaskInput | Out-Null
}

function console_confirm {
  <#
  .SYNOPSIS
    Will prompt to STDOUT a confirmation request with optional message. The
    user will need to press [y/N] to continue with those answers turning into
    a [boolean]. If no message is specified, then "CONFIRM [y/N]" is presented
    to STDOUT.

    SYNTAX:
      $answer = codemelted --console-confirm @{
        message = "Proceed with action"; # optional
      }

    RETURNS:
      [boolean] $true if confirmed, $false otherwise.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $message = $Params["message"]
  $prompt = $null -ne $message ? "$message [y/N]" : "CONFIRM [y/N]"
  $answer = Read-Host -Prompt $prompt
  return $answer.ToLower() -eq "y"
}

function console_choose {
  <#
  .SYNOPSIS
    Will present a selection menu to STDOUT based on a specified array of
    choices. Optionally you can specify a message as to what the user is
    choosing. Not specifying the message will yield a CHOOSE prompt stand in.

    SYNTAX:
      $answer = codemelted --console-choose @{
        message = "Whats the best pet"; # optional
        choices = @(  # required
          "dog",
          "cat",
          "fish"
        )
      }

    RETURNS:
      [int] based on the selected index of the choices array.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $message = $Params["message"]
  $choices = $params["choices"]
  if ((-not ($choices -is [array])) -or $choices.Length -eq 0) {
    throw "Params expects a choices key with an array of string values."
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
}

function console_password {
  <#
  .SYNOPSIS
    Writes an optional message to STDOUT to prompt for a password via STDIN.
    Not specifying a message will result in a PASSWORD stand in for the
    prompt.

    SYNTAX:
      $answer = codemelted --console-password @{
        message = [string]; # optional
      }

    RETURNS:
      [string] of the entered password.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $answer = Read-Host -Prompt ($message ?? "PASSWORD") -MaskInput
  return $answer
}

function console_prompt {
  <#
  .SYNOPSIS
    Writes a optional message to STDOUT to prompt for user input returned as a
    string. Not specifying the message will yield a PROMPT as the stand in
    prompt.

    SYNTAX:
      $answer = codemelted --console-prompt @{
        message = [string]; # optional
      }

    RETURNS:
      [string] of the entered prompt.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $answer = Read-Host -Prompt ($message ?? "PROMPT")
  return $answer
}

function console_write {
  <#
  .SYNOPSIS
    Writes a optional message to STDOUT on the same line. Not specifying a
    message is essentially a NO-OP as nothing will be written to STDOUT.

    SYNTAX:
      codemelted --console-write @{
        message = [string]; # optional
      }

    RETURNS:
      [void]
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  Write-Host ($message ?? "") -NoNewline
}

function console_writeln {
  <#
  .SYNOPSIS
    Writes an optional message to STDOUT with a newline. Not specifying the
    message will just write a newline to STDOUT.

    SYNTAX:
      codemelted --console-writeln @{
        message = ""; # optional message to associate with action
      }

    RETURNS:
      [void]
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  Write-Host ($message ?? "")
}

# =============================================================================
# [DB UC IMPLEMENTATION] ======================================================
# =============================================================================

# TO BE DEVELOPED

# =============================================================================
# [DISK UC IMPLEMENTATION] ====================================================
# =============================================================================

function disk_cp {
  <#
  .SYNOPSIS
    Copies a file / directory from one location on disk to another.

    SYNTAX:
      $success = codemelted --disk-cp @{
        src = [string];  # required
        dest = [string]; # required
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [bool] $true if successful, $false otherwise.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  # Grab and validate the parameters.
  $src = $Params["src"]
  $dest = $Params["dest"]
  $report = $Params["report"] ?? $false
  if ([string]::IsNullOrEmpty($src) `
      -or [string]::IsNullOrWhiteSpace($src)) {
    throw "Params requires a src key / value"
  } elseif ([string]::IsNullOrEmpty($dest) `
      -or [string]::IsNullOrWhiteSpace($dest)) {
    throw "Params requires a dest key / value"
  } elseif (-not ($report -is [bool])) {
    throw "Params report key must be a [bool] value"
  }

  # Carry our the transaction
  try {
    $isSrcADirectory = (Test-Path $src -PathType Container)
    if ($isSrcADirectory) {
      Copy-Item -Path $src -Destination $dest -Recurse -Force `
        -ErrorAction Stop
      return $true
    }
    Copy-Item -Path $src -Destination $dest -Force -ErrorAction Stop
    return $true
  } catch {
    if ($report) {
      Write-Warning $_.Exception.Message
    }
    return $false
  }
}

function disk_exists {
  <#
  .SYNOPSIS
    Determines if the specified src item exists on the system disk and is of
    a particular type (if specified).

    SYNTAX:
      $exists = codemelted --disk-exists @{
        src = [string];  # required
        type = [string]; # optional, 'directory' / 'file'
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [bool] $true if it exists and is of the specified type (if specified),
        $false otherwise.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  # Grab and validate the parameters.
  $src = $Params["src"]
  $type = $Params["type"] ?? ""
  $report = $Params["report"] ?? $false
  if ([string]::IsNullOrEmpty($src) `
      -or [string]::IsNullOrWhiteSpace($src)) {
    throw "Params requires a src key / value"
  } elseif (-not ($report -is [bool])) {
    throw "Params report key must be a [bool] value"
  }

  # Try the transaction
  try {
    $answer = $type -eq "directory" `
      ? (Test-Path $src -PathType Container)
      : $type -eq  "file" `
        ? (Test-Path $src -PathType Leaf)
        : (Test-Path $src)
    return $answer
  } catch {
    if ($report) {
      Write-Warning $_.Exception.Message
    }
    return $false
  }
}

function disk_ls {
  <#
  .SYNOPSIS
    Gets a listing of the src item specified. Also provides the ability to
    get a recursive listing if specified.

    SYNTAX:
      $info = codemelted --disk-ls @{
        src = [string];  # required
        type = [string]; # optional, 'directory' / 'file' / 'recurse
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [System.IO.DirectoryInfo] when listing the specified src parameter or
        $null if an error occurs.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  # Grab and validate the parameters.
  $src = $Params["src"]
  $type = $Params["type"] ?? ""
  $report = $Params["report"] ?? $false
  if ([string]::IsNullOrEmpty($src) `
      -or [string]::IsNullOrWhiteSpace($src)) {
    throw "Params requires a src key / value"
  } elseif (-not ($report -is [bool])) {
    throw "Params report key must be a [bool] value"
  }

  # Execute the transaction
  try {
    $answer = $type -eq "directory" `
      ? (Get-ChildItem -Path $src -Directory -ErrorAction Stop)
      : $type -eq "file" `
        ? (Get-ChildItem -Path $src -File -ErrorAction Stop)
        : $type -eq "recurse" `
          ? (Get-ChildItem -Path $src -Recurse -ErrorAction Stop)
          : (Get-ChildItem -Path $src -ErrorAction Stop)
    return $answer
  } catch {
    if ($report) {
      Write-Warning $_.Exception.Message
    }
    return $null
  }
}

function disk_mkdir {
  <#
  .SYNOPSIS
    Creates the src specified directory (including parents) on the designated
    disk.

    SYNTAX:
      $success = codemelted --disk-mkdir @{
        src = [string];  # required
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [bool] $true if the transaction was successful, $false otherwise.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  # Grab and validate the parameters.
  $src = $Params["src"]
  $report = $Params["report"] ?? $false
  if ([string]::IsNullOrEmpty($src) `
      -or [string]::IsNullOrWhiteSpace($src)) {
    throw "Params requires a src key / value"
  } elseif (-not ($report -is [bool])) {
    throw "Params report key must be a [bool] value"
  }

  # Execute the transaction
  try {
    New-Item -ItemType Directory -Path $src -Force -ErrorAction Stop
    return $true
  } catch {
    if ($report) {
      Write-Warning $_.Exception.Message
    }
    return $false
  }
}

function disk_mv {
  <#
  .SYNOPSIS
    Moves a file / directory from one location on disk to the other.

    SYNTAX:
      $success = codemelted --disk-mv @{
        src = [string];  # required
        dest = [string]; # required
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [bool] $true if successfully moved, $false otherwise.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  # Grab and validate the parameters.
  $src = $Params["src"]
  $dest = $Params["dest"]
  $report = $Params["report"] ?? $false
  if ([string]::IsNullOrEmpty($src) `
      -or [string]::IsNullOrWhiteSpace($src)) {
    throw "Params requires a src key / value"
  } elseif ([string]::IsNullOrEmpty($dest) `
      -or [string]::IsNullOrWhiteSpace($dest)) {
    throw "Params requires a dest key / value"
  } elseif (-not ($report -is [bool])) {
    throw "Params report key must be a [bool] value"
  }

  # Execute the transaction
  try {
    Move-Item -Path $src -Destination $dest -Force -ErrorAction Stop
    return $true
  } catch {
    if ($report) {
      Write-Warning $_.Exception.Message
    }
    return $false
  }
}

# TBD: Build out read_file, different formats.
# function disk_read_file {
#   <#
#   .SYNOPSIS
#     Something Something Star Wars.

#     SYNTAX:

#     RETURNS:

#   #>
#   param(
#     [Parameter(
#       Mandatory = $true,
#       ValueFromPipeline = $false,
#       Position = 0
#     )]
#     [hashtable]$Params
#   )
# }

function disk_rm {
  <#
  .SYNOPSIS
    Removes a file / directory from disk.

    SYNTAX:
      $success = codemelted --disk-rm @{
        src = [string];  # required
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [bool] $true if successfully moved, $false otherwise.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  # Grab and validate the parameters.
  $src = $Params["src"]
  $report = $Params["report"] ?? $false
  if ([string]::IsNullOrEmpty($src) `
      -or [string]::IsNullOrWhiteSpace($src)) {
    throw "Params requires a src key / value"
  } elseif (-not ($report -is [bool])) {
    throw "Params report key must be a [bool] value"
  }

  # Execute the transaction
  try {
    Remove-Item -Path $src -Recurse -Force -ErrorAction Stop
    return $true
  } catch {
    if ($report) {
      Write-Warning $_.Exception.Message
    }
    return $false
  }
}

function disk_size {
  <#
  .SYNOPSIS
    Retrieves the size of the file / directory on disk.

    SYNTAX:
      $sizeInBytes = codemelted --disk-size @{
        src = [string];  # required
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [int] The size in bytes on disk of the item specified whether directory
            or file or -1 if an error occurs.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  # Grab and validate the parameters.
  $src = $Params["src"]
  $report = $Params["report"] ?? $false
  if ([string]::IsNullOrEmpty($src) `
      -or [string]::IsNullOrWhiteSpace($src)) {
    throw "Params requires a src key / value"
  } elseif (-not ($report -is [bool])) {
    throw "Params report key must be a [bool] value"
  }

  # Go execute the transaction
  try {
    $isFile = Test-Path $src -PathType Leaf
    if ($isFile) {
      $sizeInBytes = (Get-ChildItem $src -ErrorAction Stop).Length
      return $sizeInBytes
    }
    $sizeInBytes = (Get-ChildItem -Path $directoryPath -Recurse | `
      Measure-Object -Property Length -Sum -ErrorAction Stop).Sum
    return $sizeInBytes
  } catch {
    if ($report) {
      Write-Warning $_.Exception.Message
    }
    return -1
  }
}

# TBD: Build out write_file, different formats.
# function disk_write_file {
#   <#
#   .SYNOPSIS
#     Something Something Star Wars.

#     SYNTAX:

#     RETURNS:

#   #>
#   param(
#     [Parameter(
#       Mandatory = $true,
#       ValueFromPipeline = $false,
#       Position = 0
#     )]
#     [hashtable]$Params
#   )
# }

# =============================================================================
# [HW UC IMPLEMENTATION] ======================================================
# =============================================================================

# TO BE DEVELOPED

# =============================================================================
# [JSON UC IMPLEMENTATION] ====================================================
# =============================================================================

function json_check_type {
  <#
  .SYNOPSIS
    Validates that a specified variable is of an expected type providing
    the option to either handle a return value or to throw if the data check
    fails.

    NOTE: the type represents the .NET type name but a Contains compare
    is done to try to establish partial name finds but that is not a
    guarantee.

    SYNTAX:
      $isType = codemelted --json-check-type @{
        type = "string";       # required
        data = $var1;          # required
        should_throw = [bool]; # optional
      }

    RETURNS:
      [bool] $true if the types match. $false otherwise

    THROWS:
      When the type is not met and should_throw = $true;
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  # Setup the data requests and validate expectations
  $type = $Params["type"]
  $data = $Params["data"]
  $shouldThrow = $Params["should_throw"] -is [boolean] `
    ? $Params["should_throw"]
    : $false
  if ($null -eq $data) {
    throw "Params 'data' key was not set."
  } elseif ([string]::IsNullOrEmpty($type) -or
            [string]::IsNullOrWhiteSpace($type)) {
    throw "Params 'type' key was not set."
  }

  # Carry out the data check
  $throwMessage = "$type was not the expected type."
  $answer = $type.ToString().ToLower().Contains(
    $data.GetType().Name.ToLower()
  )

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

function json_create_array {
  <#
  .SYNOPSIS
    Creates a JSON compliant array with the option to copy data into the
    newly created array.

    SYNTAX:
      $data = codemelted --json-create-array @{
        "data" = [array] or [System.Collection.ArrayList] # optional
      }

    RETURNS:
      [System.Collections.ArrayList] object or $null if it could not be
      created.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $data = $Params["data"]
  try {
    $obj = New-Object System.Collections.ArrayList
    if ($data -is [System.Collections.ArrayList]) {
      $obj = $data.Clone()
    } elseif ($data -is [array]) {
      $obj += $data
    }
    return $obj
  } catch [System.FormatException] {
    return $null
  }
}

function json_create_object {
  <#
  .SYNOPSIS
    Creates a JSON compliant object with the option to copy data to it upon
    creation.

    SYNTAX:
      $data = codemelted --json-create-object @{
        "data" = [hashtable]  # optional
      }

    RETURNS:
      [hashtable] of the newly created object or $null if a failure occurs.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $data = $Params['data']
  try {
    $obj = $data -is [hashtable] ? $data.Clone() : @{}
    return $obj
  } catch [System.FormatException] {
    return $null
  }
}

function json_has_key {
  <#
  .SYNOPSIS
    Validates that a given [hashtable] contains the key specified or not.

    SYNTAX:
      $isType = codemelted --json-has-key @{
        data = [hashtable];    # required
        key = "key_name";      # required
        should_throw = [bool]; # optional
      }

    RETURNS:
      [bool] $true if the key is found, $false otherwise.

    THROWS:
      When the type is not met and should_throw = $true;
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  # Setup the data requests and validate expectations
  $key = $Params["key"]
  $data = $Params["data"]
  $shouldThrow = $Params["should_throw"] -is [boolean] `
    ? $Params["should_throw"]
    : $false
  if (-not ($data -is [hashtable])) {
    throw "Params 'data' key was not a [hashtable] value."
  } elseif ([string]::IsNullOrEmpty($key) `
            -or [string]::IsNullOrWhiteSpace($key)) {
    throw "Params 'key' key was not set."
  }

  # Carry out the request
  $throwMessage = "$key did not exist."
  $answer = $data.ContainsKey($key)

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

function json_parse {
  <#
  .SYNOPSIS
    Will parse a specified [string] data parameter and convert it to its
    JSON compliant PowerShell type. So a stringified [hashtable] will become
    a [hashtable]. A stringified [bool] becomes a [bool], etc.

    SYNTAX:
      $data = codemelted --json-parse @{
        data = [string]; # required
      }

    RETURNS:
      [array], [double], [int], [bool], [hashtable] JSON compliant types or
      $null if conversion failed.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $data = $Params["data"]
  if ([string]::IsNullOrEmpty($data) -or [string]::IsNullOrWhiteSpace($data)) {
    throw "Params expects a 'data' key with a string value."
  }
  try {
    return ConvertFrom-Json -InputObject $data -Depth 100
  } catch [System.FormatException] {
    return $null
  }
}

function json_stringify {
  <#
  .SYNOPSIS
    Will stringify a JSON compliant specified data parameter.

    SYNTAX:
      $data = codemelted --json-stringify @{
        data = [object]; # required, JSON compliant type.
      }

    RETURNS:
      [string] or $null if the 'data' was not a JSON compliant type.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $data = $Params["data"]
  if ($null -eq $data) {
    throw "Params expects a 'data' key and value."
  }
  try {
    if ($data.GetType().Name.ToLower() -eq "arraylist") {
      return ConvertTo-Json -InputObject $data.ToArray() -Depth 100
    }
    return ConvertTo-Json -InputObject $data -Depth 100
  } catch [System.FormatException] {
    return $null
  }
}

function json_valid_url {
  <#
  .SYNOPSIS
    Validates that the url is valid or not.

    SYNTAX:
      $isType = codemelted --json-valid-url @{
        data = [string];       # required
        should_throw = [bool]; # optional
      }

    RETURNS:
      [bool] $true if the url is well formed, $false otherwise.

    THROWS:
      When the type is not met and should_throw = $true;
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  # Parse the request elements.
  $data = $Params["data"]
  $shouldThrow = $Params["should_throw"] -is [boolean] `
    ? $Params["should_throw"]
    : $false
  if ([string]::IsNullOrEmpty($data) -or [string]::IsNullOrWhiteSpace($data)) {
    throw "Params 'data' key expected a [string] value."
  }

  # Carry out the url request.
  $throwMessage = "$data failed the codemelted --json-valid-url request."
  $answer = [uri]::IsWellFormedUriString($data.ToString(), 0)

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

# =============================================================================
# [LOGGER UC IMPLEMENTATION] ==================================================
# =============================================================================

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
  static [string] logLevelString([int] $logLevel) {
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
  static [int] logLevelInt([string] $logLevel) {
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
    if ($logLevel -eq -1) {
      throw "Params 'level' key is expected to be set.";
    }
    $this.data = $data
    if ($null -eq $data) {
      throw "Params 'data' key is expected to be set.";
    }
  }

  [string] ToString() {
    return $this.timestamp +
      " [" +
      [CLogRecord]::logLevelString($this.logLevel) +
      "]: " +
      $this.data
  }
}

# Tracks the logger settings for the loaded module.
if ($null -eq $Global:CodeMeltedLogger) {
  $Global:CodeMeltedLogger = @{
    level = $null;
    handler = $null;
  }
}

function logger_level {
  <#
  .SYNOPSIS
    Sets / gets the log level for the module. By setting this, any log that
    meets the log level will be reported to STDOUT and sent onto the log
    handler if set. The supported log levels are 'debug' / 'info' /
    'warning' / 'error' / 'off'.

    SYNTAX:
      codemelted --logger-level @{
        level = [string]; # required for setting
      }

      # Get the log level
      $level = codemelted --logger-level

    RETURNS:
      [string] representation of the log level if getting the log level.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  # Get data and see if we are returning the log level.
  $log_level = $null -ne $Params ? $Params["log_level"] : $null
  if ($null -eq $log_level) {
    $logLevelString = [CLogRecord]::logLevelString($Global:CodeMeltedLogger.level)
    return $logLevelString
  }

  # Ok, we are setting the log level, not retrieving it. Go get the int value
  # and set it in the global store.
  $level = [CLogRecord]::logLevelInt($log_level)
  if ($level -eq -1) {
    throw "Params data 'key' not a valid value for setting log level. " +
      "Valid values are 'debug' / 'info' / 'warning' / 'error'"
  }
  $Global:CodeMeltedLogger.level = $level
}

function logger_handler {
  <#
  .SYNOPSIS
    Provides the ability to setup a log handler that can receive a log record
    after written to STDOUT.

    SYNTAX:
      codemelted --logger-handler @{
        "handler" = [scriptblock] / $null  # required
      }

    RETURNS:
      [void]
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  $handler = $Params["handler"]
  if ($null -eq $handler -and $null -eq $Params) {
    $Global:CodeMeltedLogger.handler = $null
  } elseif ($data -is [scriptblock]) {
    $Global:CodeMeltedLogger.handler = $data
  } else {
    throw "Params 'handler' key value was not $null or [scriptblock]"
  }
}

function logger_log {
  <#
  .SYNOPSIS
    Provides the logging of 'info' / 'warning' / 'error' / 'debug' messages
    to STDOUT and to be further processed via a log handler.

    SYNTAX:
      codemelted --logger-log @{
        level = [string]; # required
        data = [string];  # required
      }

    RETURNS:
      [void]
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  if ($Global:CodeMeltedLogger.level -eq [CLogRecord]::offLogLevel) {
    return [void]
  }

  $level = [CLogRecord]::logLevelInt($Params["level"])
  $record = [CLogRecord]::new($Global:CodeMeltedLogger.level, $level, $data)
  if ($Global:CodeMeltedLogger.level -le [CLogRecord]::debugLogLevel -and `
      $level -eq [CLogRecord]::debugLogLevel) {
    Write-Host $record.ToString() -ForegroundColor White
  } elseif ($Global:CodeMeltedLogger.level -le [CLogRecord]::infoLogLevel -and `
          $level -eq [CLogRecord]::infoLogLevel) {
    Write-Host $record.ToString() -ForegroundColor Green
  } elseif ($Global:CodeMeltedLogger.level -le [CLogRecord]::warningLogLevel -and `
          $level -eq [CLogRecord]::warningLogLevel) {
    Write-Host $record.ToString() -ForegroundColor Yellow
  } elseif ($Global:CodeMeltedLogger.level-le [CLogRecord]::errorLogLevel -and `
          $level -eq [CLogRecord]::errorLogLevel) {
    Write-Host $record.ToString() -ForegroundColor Red
  }

  if ($null -ne $Global:CodeMeltedLogger.handler) {
    Invoke-Command -ScriptBlock $Global:CodeMeltedLogger.handler `
      -ArgumentList $record
  }
}

# =============================================================================
# [MONITOR UC IMPLEMENTATION] =================================================
# =============================================================================

# TO BE DEVELOPED
#    Will bind with Rust codemelted-monitor program I will eventually
#    right.

# =============================================================================
# [NETWORK UC IMPLEMENTATION] =================================================
# =============================================================================

# A response object returned from the codemelted_network fetch action.
# Contains the statusCode, statusText, and the data.
class CFetchResponse {
  # Member Fields
  [int] $statusCode
  [object] $data

  # Signals whether the statusCode was a 2XX HTTP Response Code or not.
  [bool] isOk() {
    return $this.statusCode -gt 199 && $this.statusCode -lt 300
  }

  # Will treat the data as a series of bytes if it is that or return $null.
  [byte[]] asBytes() {
    return $this.data -is [byte[]] ? $this.data : $null
  }

  # Will treat the data as a JSON object if it is that or return $null.
  [hashtable] asObject() {
    return $this.data -is [hashtable] ? $this.data : $null
  }

  # Will treat the data as a string if it is that or return $null.
  [string] asString() {
    return $this.data -is [string] ? $this.data : $null
  }

  # Constructor for the class transforming the response into the appropriate
  # data for consumption.
  CFetchResponse($resp) {
    $this.statusCode = $resp.StatusCode
    [string] $headers = $resp.Headers | Out-String
    if ($headers.ToLower().Contains("application/json")) {
      $this.data = json_parse @{
        "data" = $resp.Content
      }
    } else {
      $this.data = $resp.Content
    }
  }
}

function network_fetch {
  <#
  .SYNOPSIS
    Provides a mechanism for fetching data from a server REST API. The result
    is a [CFetchResponse] object with the statusCode along with the data
    received asBytes(), asObject(), or asString(). If it is not any of those
    types, a $null is returned.

    SYNTAX:
      # Perform a network fetch to a REST API. The "data" is a [hashtable]
      # reflecting the named parameters of the Invoke-WebRequest. So the two
      # most common items will be "method" / "body" / "headers" but others
      # are reflected via the link.
      $resp = codemelted --network-fetch @{
        "url" = [string / ip]; # required
        "data" = [hashtable]   # required
      }

    RETURNS:
      [CFetchResponse] that has the statusCode and data as properties.
        Methods of asBytes(), asObject(), asString() exists to get the data
        of the expected type or $null if not of that type. A method of isOk()
        signals whether the statusCode was a 2XX HTTP Status Code.

  .LINK
    Invoke-WebRequest Details:
      https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  # Validate the required entries utilized by all actions.
  $url = $Params["url"]
  $data = $Params["data"]

  if ([string]::IsNullOrEmpty($url) -or [string]::IsNullOrWhiteSpace($url)) {
    throw "Params expects a url key with a [string] URL / IP address"
  } elseif (-not ($data -is [hashtable])) {
    throw "Params expects a data [hashtable] entry."
  }

  # Go carry out the fetch.
  [hashtable] $request = json_create_object @{
    "data" = $data
  }
  $request.Add("uri", $url)
  $resp = Invoke-WebRequest @request -SkipHttpErrorCheck
  return [CFetchResponse]::new($resp)
}

# =============================================================================
# [NPU UC IMPLEMENTATION] =====================================================
# =============================================================================

# TO BE DEVELOPED

# =============================================================================
# [PROCESS UC IMPLEMENTATION] =================================================
# =============================================================================

# Adds the [CProcess] C# class to support the [process_spawn] function.
# TODO: Match Rust construct.
Add-Type -Language CSharp @"
  using System;
  using System.Diagnostics;
  using System.IO;
  using System.Text;

  // Main class definition for the process_spawn cmdlet.
  public class CProcess {
    // Member Fields
    private String _output;
    private Process _process;
    private DataReceivedEventHandler _dataRxHandler;

    // Gets the PID of the kicked off powershell process.
    public int id() {
      return _process.Id;
    }

    // Kills this process and deregisters the handlers.
    public void kill() {
      _process.Kill();
      _process.OutputDataReceived -= _dataRxHandler;
      _process.ErrorDataReceived -= _dataRxHandler;
    }

    // Gets the current output captured by the process and clears the
    // member field for later queries.
    public string read() {
      var rtnval = _output;
      _output = "";
      return rtnval;
    }

    /// Takes a string of data to write and converts it to bytes.
    public void write(string data) {
      var buffer = System.Text.Encoding.ASCII.GetBytes(data);
      _process.StandardInput.BaseStream.Write(buffer, 0, buffer.Length);
      _process.StandardInput.BaseStream.Flush();
    }

    // Constructor for the class. Takes the command and arguments to run the
    // command.
    public CProcess(string command, string arguments) {
      _process = new Process();
      _process.StartInfo.FileName = command;
      _process.StartInfo.Arguments = arguments;
      _process.StartInfo.UseShellExecute = false;
      _process.StartInfo.RedirectStandardInput = true;
      _process.StartInfo.RedirectStandardError = true;
      _process.StartInfo.RedirectStandardOutput = true;

      _dataRxHandler = new DataReceivedEventHandler((sender, e) => {
          _output += e.Data;
          _output += "\n";
      });
      _process.OutputDataReceived += _dataRxHandler;
      _process.ErrorDataReceived += _dataRxHandler;

      _process.Start();
      _process.BeginErrorReadLine();
      _process.BeginOutputReadLine();
    }
  }
"@

function process_exists {
  <#
  .SYNOPSIS
    Determines if a given executable program is known by the host operating
    system. NOTE: regular terminal commands (i.e. ls, dir) will not register.

    SYNTAX:
      $exists = codemelted --process-exists @{
        command = [string]; # required
      }

    RETURNS:
      [bool] $true if the specified command exists, $false otherwise.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $cmd = $Params["command"]
  if ([string]::IsNullOrEmpty($cmd) -or [string]::IsNullOrWhiteSpace($cmd)) {
    throw "'command' key / value expected with named parameters"
  }

  if ($IsWindows) {
    cmd /c where $cmd > nul 2>&1
  } else {
    which -s $cmd > /dev/null
  }
  return $LASTEXITCODE -eq 0
}

function process_run {
  <#
  .SYNOPSIS
    Runs a one-off operating system process and captures its STDOUT output.

    SYNTAX:
      # Example listing files on a linux terminal.
      $output = codemelted --process-run @{
        command = "ls"; [string] # required
        args = "-latr"; [string] # optional
      }

    RETURNS:
      [string] The capture output from the process via STDOUT.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $cmd = $Params["command"]
  $arguments = $Params["args"]
  if ([string]::IsNullOrEmpty($cmd) -or [string]::IsNullOrWhiteSpace($cmd)) {
    throw "'command' key / value expected with named parameters"
  }

  if (-not [string]::IsNullOrEmpty($arguments) -and
      -not [string]::IsNullOrWhiteSpace($arguments)) {
    $cmd += " " + $arguments
  }

  return $IsWindows ? (cmd /c $cmd) : (sh -c $cmd)
}

# function process_spawn {
#   <#
#   .SYNOPSIS
#     Something Something Star Wars.

#     SYNTAX:

#     RETURNS:

#   #>
#   param(
#     [Parameter(
#       Mandatory = $true,
#       ValueFromPipeline = $false,
#       Position = 0
#     )]
#     [hashtable]$Params
#   )
# }

# =============================================================================
# [RUNTIME UC IMPLEMENTATION] =================================================
# =============================================================================

function runtime_cpu_arch {
  <#
  .SYNOPSIS
    Retrieves whether the host operating system is 64-bit or 32-bit.

    SYNTAX:
      $arch = codemelted --runtime-cpu-arch

    RETURNS:
      [string] Identifies if the operating system is '64-bit' or '32-bit'
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return [System.Environment]::Is64BitOperatingSystem `
    ? "64-bit"
    : "32-bit"
}

function runtime_cpu_count {
  <#
  .SYNOPSIS
    Retrieves the available CPUs for processing work for the host operating
    system.

    SYNTAX:
      $cpuCount = codemelted --runtime-cpu-count

    RETURNS:
      [int] Identifies how many CPUs available for parallel work.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return [System.Environment]::ProcessorCount
}

function runtime_environment {
  <#
  .SYNOPSIS
    Retrieves an environment variable held by the host operating system based
    on the name you specify.

    SYNTAX:
      $value = codemelted --runtime-environment @{
        name = [string]; # required
      }

    RETURNS:
      [string] Retrieves the environment variable value or $null if not found.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  $name = $Params["name"]
  if ([string]::IsNullOrEmpty($name) -or [string]::IsNullOrWhiteSpace($name)) {
    throw "Params 'name' key is required."
  }
  return [System.Environment]::GetEnvironmentVariable($name)
}

function runtime_home_path {
  <#
  .SYNOPSIS
    Retrieves the logged in user's home directory on the given operating
    system.

    SYNTAX:
      $path = codemelted --runtime-home-path

    RETURNS:
      [string] Identifies the user's home directory.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return $IsWindows `
    ? [System.Environment]::GetEnvironmentVariable("USERPROFILE")
    : [System.Environment]::GetEnvironmentVariable("HOME")
}

function runtime_hostname {
  <#
  .SYNOPSIS
    Retrieves the hostname of the given operating system.

    SYNTAX:
      $hostname = codemelted --runtime-hostname

    RETURNS:
      [string] The hostname of how your machine identifies itself on a
        network.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return [System.Environment]::MachineName
}

function runtime_newline {
  <#
  .SYNOPSIS
    Retrieves the newline character for the given operating system.

    SYNTAX:
      $newLine = codemelted --runtime-newline

    RETURNS:
      [string] The newline character for the given operating system.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return [System.Environment]::NewLine
}

function runtime_online {
  <#
  .SYNOPSIS
    Determines if the given operating system has access to the Internet.

    SYNTAX:
      $online = codemelted --runtime-online

    RETURNS:
      [bool] $true if access to the Internet exists. $false otherwise.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return (Test-Connection -Ping google.com -Count 1 -Quiet)
}

function runtime_os_name {
  <#
  .SYNOPSIS
    Retrieves the name of the operating system. The value will be 'mac' /
    'windows' / 'linux' / 'pi'

    SYNTAX:
      $name = codemelted --runtime-os-name

    RETURNS:
      [string] A string representing the name of the operating system.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return $IsMacOS `
    ? "mac"
    : $IsWindows `
      ? "windows"
      : (Test-Path "/etc/rpi-issue") `
        ? "pi"
        : "linux"
}

function runtime_os_version {
  <#
  .SYNOPSIS
    Retrieves the current operating system version.

    SYNTAX:
      $version = codemelted --runtime-os-version

    RETURNS:
      [string] Identifying version number for the operating system.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return [System.Environment]::OSVersion.VersionString
}

function runtime_path_separator {
  <#
  .SYNOPSIS
    Retrieves the path separator for the host operating system.

    SYNTAX:
      $separator = codemelted --runtime-path-separator

    RETURNS:
      [string] The separator character for directories on disk for the given
        host operating system.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return [System.IO.Path]::DirectorySeparatorChar
}

function runtime_temp_path {
  <#
  .SYNOPSIS
    Retrieves the temporary directory for the given operating system for
    storing temporary data.

    SYNTAX:
      $tempPath = codemelted --runtime-temp-path

    RETURNS:
      [string] reflecting the operating system temp path for temporary data.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return [System.IO.Path]::GetTempPath()
}

function runtime_user {
  <#
  .SYNOPSIS
    Retrieves the currently logged in user.

    SYNTAX:
      $user = codemelted --runtime-user

    RETURNS:
      [string] reflecting the logged in user.
  #>
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  return $IsWindows `
    ? [System.Environment]::GetEnvironmentVariable("USERNAME")
    : [System.Environment]::GetEnvironmentVariable("USER")
}

# =============================================================================
# [STORAGE UC IMPLEMENTATION] =================================================
# =============================================================================

# TO BE DEVELOPED

# =============================================================================
# [UI UC IMPLEMENTATION] ======================================================
# =============================================================================

# TO BE DEVELOPED

# =============================================================================
# [MAIN CLI API] ==============================================================
# =============================================================================

try {
  # OK, go parse the command.
  switch ($Action) {
    # Module Information
    "--version"            {
      Get-PSScriptFileInfo -Path $PSScriptRoot/codemelted.ps1
    }
    "--help"                  { codemelted_help $Params }
    # Async Use Case
    "--async-sleep"           { async_sleep $Params }
    "--async-task"            { async_task $Params }
    "--async-timer"           { async_timer $Params }
    # Console Use Case
    "--console-alert"         { console_alert $Params }
    "--console-confirm"       { console_confirm $Params }
    "--console-choose"        { console_choose $Params }
    "--console-password"      { console_password $Params }
    "--console-prompt"        { console_prompt $Params }
    "--console-write"         { console_write $Params }
    "--console-writeln"       { console_writeln $Params }
    # DB Use Case
    # TBD
    # Developer Use Case
    # TBD
    # Disk Use Case
    "--disk-cp"               { disk_cp $Params }
    "--disk-exists"           { disk_exists $Params }
    "--disk-ls"               { disk_ls $Params }
    "--disk-mkdir"            { disk_mkdir $Params }
    "--disk-mv"               { disk_mv $Params }
    "--disk-rm"               { disk_rm $Params }
    "--disk-size"             { disk_size $Params }
    # HW Use Case
    # TBD
    # JSON Use Case
    "--json-check-type"        { json_check_type $Params }
    "--json-create-array"      { json_create_array $Params }
    "--json-create-object"     { json_create_object $Params }
    "--json-check-type"        { json_check_type $Params }
    "--json-parse"             { json_parse $Params }
    "--json-stringify"         { json_stringify $Params }
    "--json-valid-url"         { json_valid_url $Params }
    # Logger Use Case
    "--logger-level"           { logger_level $Params }
    "--logger-handler"         { logger_handler $Params }
    "--logger-log"             { logger_log $Params }
    # Monitor Use Case
    # TBD
    # Network Use Case
    "--network-fetch"          { network_fetch $Params }
    # NPU Use Case
    # TBD
    # Process Use Case
    "--process-exists"         { process_exists $Params }
    "--process-run"            { process_run $Params }
    # Runtime Use Case
    "--runtime-cpu-arch"       { runtime_cpu_arch $Params }
    "--runtime-cpu-count"      { runtime_cpu_count $Params }
    "--runtime-environment"    { runtime_environment $Params }
    "--runtime-home-path"      { runtime_home_path $Params }
    "--runtime-hostname"       { runtime_hostname $Params }
    "--runtime-newline"        { runtime_newline $Params }
    "--runtime-online"         { runtime_online $Params }
    "--runtime-os-name"        { runtime_os_name $Params }
    "--runtime-os-version"     { runtime_os_version $Params }
    "--runtime-path-separator" { runtime_path_separator $Params }
    "--runtime-temp-path"      { runtime_temp_path $Params }
    "--runtime-user"           { runtime_user $Params }
    # Setup Use Case
    # TBD
    # Storage Use Case
    # TBD
    # UI Use Case
    # TBD
  }
} catch {
  Write-Warning ("SyntaxError: codemelted $Action " + $_.Exception.Message)
}
