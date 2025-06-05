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
.VERSION 25.1.1
.RELEASENOTES
TBD
#>

# =============================================================================
# [MODULE DATA DEFINITION] ====================================================
# =============================================================================

<#
  .DESCRIPTION
  A CLI to facilitate common developer use cases on Mac / Linux / Windows OS.
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
    # Console Use Case
    "--console-alert",
    "--console-confirm",
    "--console-choose",
    "--console-password",
    "--console-prompt",
    "--console-write",
    "--console-writeln"
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
      async     : TBD
      console   : COMPLETED
      db        : TBD
      developer : TBD
      disk      : TBD
      hw        : TBD
      json      : TBD
      logger    : TBD
      monitor   : TBD
      network   : TBD
      npu       : TBD
      process   : TBD
      runtime   : TBD
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
      Write-Host "TBD"
    };

    # console use case functions
    "console" = {
      Write-Host "=================================="
      Write-Host "codemelted CLI (console) Use Case"
      Write-Host "=================================="
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
      Write-Host "Execute 'codemelted --help @ {action = ""--uc-name""}'"
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
      Write-Host "TBD"
    };

    # hw use case functions
    "hw" = {
      Write-Host "TBD"
    };

    # json use case functions
    "json" = {
      Write-Host "TBD"
    };

    # logger use case functions
    "logger" = {
      Write-Host "TBD"
    };

    # monitor use case functions
    "monitor" = {
      Write-Host "TBD"
    };

    # network use case functions
    "network" = {
      Write-Host "TBD"
    };

    # npu use cse functions
    "npu" = {
      Write-Host "TBD"
    };

    # process use case functions
    "process" = {
      Write-Host "TBD"
    };

    # runtime use case functions
    "runtime" = {
      Write-Host "TBD"
    };

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
# [ASYNC UC IMPLEMENTATION] ===================================================
# =============================================================================

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
    throw "SyntaxError: codemelted --console-choose Params expects a " +
      "choices key with an array of string values."
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
        message = ""; # optional
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
        message = "First Name"; # optional
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

# =============================================================================
# [DISK UC IMPLEMENTATION] ====================================================
# =============================================================================

# =============================================================================
# [HW UC IMPLEMENTATION] ======================================================
# =============================================================================

# =============================================================================
# [JSON UC IMPLEMENTATION] ====================================================
# =============================================================================

# =============================================================================
# [LOGGER UC IMPLEMENTATION] ==================================================
# =============================================================================

# =============================================================================
# [MONITOR UC IMPLEMENTATION] =================================================
# =============================================================================

# =============================================================================
# [NETWORK UC IMPLEMENTATION] =================================================
# =============================================================================

# =============================================================================
# [NPU UC IMPLEMENTATION] =====================================================
# =============================================================================

# =============================================================================
# [PROCESS UC IMPLEMENTATION] =================================================
# =============================================================================

# =============================================================================
# [RUNTIME UC IMPLEMENTATION] =================================================
# =============================================================================

# =============================================================================
# [STORAGE UC IMPLEMENTATION] =================================================
# =============================================================================

# =============================================================================
# [UI UC IMPLEMENTATION] ======================================================
# =============================================================================

# =============================================================================
# [MAIN CLI API] ==============================================================
# =============================================================================

# OK, go parse the command.
switch ($Action) {
  # Module Information
  "--version" { Get-PSScriptFileInfo -Path $PSScriptRoot/codemelted.ps1 }
  "--help" { codemelted_help $Params }
  # Console Use Case
  "--console-alert" { console_alert $Params }
  "--console-confirm" { codemelted_confirm $Params }
  "--console-choose" { codemelted_choose $Params }
  "--console-password" {codemelted_password $Params }
  "--console-prompt" { codemelted_prompt $Params }
  "--console-write" { codemelted_write $Params }
  "--console-writeln" { codemelted_writeln $Params }
}

# ---- REFACTORS BELOW INTO NEW USE CASE STRUCTURE ABOVE ----

# -----------------------------------------------------------------------------
# [Data Types] ----------------------------------------------------------------
# -----------------------------------------------------------------------------

# .NET Assemblies
Add-Type -AssemblyName Microsoft.PowerShell.Commands.Utility

# Setup our module API for tracking items and supporting each of the use case
# functions.
if ($null -eq $Global:CodeMeltedAPI) {
  $Global:CodeMeltedAPI = @{
    tracker = @{
      id = 0;
      map = @{};
    };
    logger = @{
      level = [CLogRecord]::offLogLevel;
      handler = $null;
    };
    process = @{};
    worker = @{
      threadJob = $null;
      queued = [System.Collections.ArrayList]::Synchronized( `
        [System.Collections.ArrayList]::new()
      );
      scheduled = [System.Collections.ArrayList]::Synchronized( `
        [System.Collections.ArrayList]::new()
      );
      task = $null;
      handler = $null;
    };
  }
}

# A response object returned from the codemelted_network fetch action.
# Contains the statusCode, statusText, and the data.
class CFetchResponse {
  # Member Fields
  [int] $statusCode
  [string] $statusText
  [object] $data

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
    $this.statusText = $resp.StatusDescription
    [string] $headers = $resp.Headers | Out-String
    if ($headers.ToLower().Contains("application/json")) {
      $this.data = codemelted_json @{
        "action" = "parse";
        "data" = $resp.Content
      }
      $this.data -is [hashtable]
    } else {
      $this.data = $resp.Content
    }
  }
}

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

# Adds the [CProcess] type for C# to support the codemelted_process cmdlet.
Add-Type -Language CSharp @"
  using System;
  using System.Diagnostics;
  using System.IO;
  using System.Text;

  // Main class definition for the codemelted_process cmdlet.
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

# Holds the results of a codemelted_task 'run' action. This happens in a
# background thread.
class CTaskRunResult {
  # Member Fields
  hidden [object] $threadJob = $null

  # Will contain the final result of the ran task. Will block if called
  # before the task has completed.
  [object] result() {
    $this.threadJob | Wait-Job
    $answer = ($this.threadJob | Receive-Job)
    $this.threadJob | Remove-Job
    return $answer
  }

  # Provides the ability to check if the task has completed.
  [bool] hasCompleted() {
    return $this.threadJob.State.ToLower() -eq "completed"
  }

  # Constructor for the class.
  CTaskRunResult([scriptblock] $task, [object] $data, [int] $delay) {
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
class CTaskTimer {
  # Member Fields
  [int] $id = -1
  hidden [object] $threadJob = $null

  # Provides the ability to check if the task is running or not.
  [bool] isRunning() {
    return $this.threadJob.State.ToLower() -eq "running"
  }

  # Stops the running timer.
  [void] stop() {
    Stop-Job -Job $this.threadJob
    Remove-Job -Job $this.threadJob
  }

  # Constructor for the class.
  CTaskTimer([int] $id, [scriptblock] $task, [int] $delay) {
    # Setup the background thread job to call the task on the given
    # delay interval.
    $this.id = $id
    $this.threadJob = Start-ThreadJob -ScriptBlock {
      param([scriptblock] $timerTask, [int] $timerDelay)
      while ($true) {
        Start-Sleep -Milliseconds $timerDelay
        Invoke-Command -ScriptBlock $timerTask
      }
    } -ArgumentList $task, $delay
  }
}


# =============================================================================
# [USE CASE DEFINITIONS] ======================================================
# =============================================================================

# -----------------------------------------------------------------------------
# [Async I/O Use Cases] -------------------------------------------------------
# -----------------------------------------------------------------------------

function codemelted_process {
  <#
    .SYNOPSIS
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  # Go get our parameters for our actions.
  $action = $Params["action"]
  $arguments = $Params["arguments"]
  $command = $Params["command"]
  $data = $Params["data"]
  $id = $Params["id"]
  $includeUserName = $Params["include_user_name"] ?? $false

  # For actions utilizing id, go check it so those actions can be carried out.
  if ((-not ($id -is [int])) -and ($action -ne "list" -and `
      $action -ne "start")) {
    throw "SyntaxError: codemelted --process Params expects a specified " +
      "'id' key to be an [int] type."
  } elseif ($action -eq "read" -or $action -eq "write" -or $action -eq "kill") {
    $p = $Global:CodeMeltedAPI.process[$id]
    if ($null -eq $p) {
      throw "SyntaxError: codemelted --process '$action' Params action " +
        "did not find the specified $id 'id'."
    }
  }

  # Now carry out the actions. First two deal with operating system processes.
  if ($action -eq "list") {
    $name = $data ?? "*"
    if ([string]::IsNullOrEmpty($name) -or `
        [string]::IsNullOrWhiteSpace($name)) {
      throw "SyntaxError: codemelted --process 'list' Params action " +
        "expects 'data' key / [string] value when specified."
    }
    return $includeUserName -eq $true `
      ? (Get-Process -Name $data -IncludeUserName)
      : (Get-Process -Name $data)
  } elseif ($action -eq "stop") {
      Stop-Process -id $id -ErrorAction -SilentlyContinue

  # The remainder of these actions deal with working with a process spawned
  # from the codemelted.ps1 module.
  } elseif ($action -eq "start") {
    if ([string]::IsNullOrEmpty($command) -or `
        [string]::IsNullOrWhiteSpace($command)) {
      throw "SyntaxError: codemelted --process 'start' Params action " +
        "expects 'command' key to be a [string] value."
    }
    $p = [CProcess]::new($command, $arguments)
    $id = $Global:CodeMeltedAPI.tracker.allocate()
    $Global:CodeMeltedAPI.process[$id] = $p
    return $id
  } elseif ($action -eq "kill") {
    $p = $Global:CodeMeltedAPI.process[$id]
    $p.Kill()
    $Global:CodemeltedAPI.process.Remove($id)
  } elseif ($action -eq "read") {
    $p = $Global:CodeMeltedAPI.process[$id]
    $rtnval = $p.read()
    return $rtnval
  } elseif ($action -eq "write") {
    if ([string]::IsNullOrEmpty($data)) {
      throw "SyntaxError: codemelted --process 'write' Params action " +
        "expects 'data' key be a [string] type and not NULL"
    }
    $p = $Global:CodeMeltedAPI.process[$id]
    $p.write($data)
  } else {
    throw "SyntaxError: codemelted --process Params did not have a " +
      "supported action key specified. Valid actions are start / kill / " +
      "read / write"
  }
}

function codemelted_task {
  <#
    .SYNOPSIS
    Provides the ability to kick-off background threaded tasks. Either a
    one-off that returns a promise, a repeating timer that can stopped later,
    and the ability to sleep the given background tasks in milliseconds.

    SYNTAX:
      # Kicks off a one off background processing task that returns a
      # promise that will eventually hold the answer. The two required
      # are the action and task. Utilize the param() within the task
      # scriptblock to receive data for the task. Make sure to return the
      # answer for the promise to contain the result.
      $answer = codemelted --task @{
        action = "run";        # required
        task = [scriptblock];  # required
        data = [object];       # optional
        delay = [int];         # optional
      }

        'task' Example:
          $task = {
            param($data)
            return $data + 5
          }

      # To sleep the processing within the given code specify the action
      # and a delay in milliseconds. The delay is required and must be >= 0.
      codemelted --task @{
        action = "sleep";  # required
        delay = [int];     # required
      }

      # Kick-off a background repeating timer that kicks of the given
      # delay interval.
      $id = codemelted --task @{
        action = "start_timer";  # required
        task = [scriptblock];    # required
        delay = [int];           # required
      }

      codemelted --task @{
        action = "stop_timer";  # required
        data = $id;             # required
      }

    RETURNS:
      [CTaskRunResult] 'run' action result that represents a promise with
        two methods. The hasCompleted() will return $true if the answer is
        ready or $false. The result() is a blocking call that will return
        the result. It is of an [object] type so any data type can be
        returned.

      [int] 'start_timer' action with a successfully created repeating
        background timer.

      [void] 'sleep' action delays processing for a specified milliseconds.
        'stop_timer' action will end a 'start_timer' action repeating task.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  # Get the parameters to support the requested action.
  $action = $Params["action"]
  $task = $Params["task"]
  $data = $Params["data"]
  $delay = $Params["delay"] ?? 0

  # Do validity checks of said parameters
  if ($delay -lt 0) {
    throw "SyntaxError: codemelted --task expects the Params 'delay' key " +
      "to be a [int] >= 0"
  } elseif ($action -eq "run" -or $action -eq "sleep" -or `
            $action -eq "start_timer") {
    if (-not ($task -is [scriptblock])) {
      throw "SyntaxError: codemelted --task expects the Params 'task' key " +
        "to be a [scriptblock]"
    }
  }

  # Carry out the requested action.
  if ($action -eq "run") {
    return [CTaskRunResult]::new($task, $data, $delay)
  } elseif ($action -eq "sleep") {
    Start-Sleep -Milliseconds $delay
  } elseif ($action -eq "start_timer") {
    if ($delay -lt 100) {
      throw "SyntaxError: codemelted --task 'start_timer' action requires " +
        "delay to be >= 100"
    }
    $id = $Global:CodeMeltedAPI.tracker.id += 1
    $Global:CodeMeltedAPI.tracker.map.Add($id, [CTaskTimer]::new(
      $id,
      $task,
      $delay
    ))
    return $id
  } elseif ($action -eq "stop_timer") {
    $timerTask = $Global:CodeMeltedAPI.tracker.map[$data]
    $timerTask.stop()
    $Global:CodeMeltedAPI.tracker.map.Remove($data)
  } else {
    throw "SyntaxError: codemelted --task Params did not have a " +
      "supported action key specified. Valid actions are run / sleep / " +
      "start_timer / stop_timer"
  }
}

function codemelted_worker {
  <#
    .SYNOPSIS
    Sets up a background worker pool that supports queuing JSON based objects
    to process with your own custom ID system and communicate the results
    once the background worker has completed the processing. The number of
    workers for the pool are based on the number of physical processors
    available on the host system. If the queued work exceeds the number of
    available workers, it is queued up in FIFO order so as work completes,
    a worker will pick up its processing.

    NOTE 1: The scheduling of work is FIFO. The completion of work is not
      guaranteed to complete in that order. Hence a custom ID system is
      necessary.

    NOTE 2: Only one worker pool may be running. If you attempt to start
      a new pool before stopping an existing one will result in a
      SyntaxError. This is also true if you attempt to stop or post work
      to be done on a pool that is not running.

    SYNTAX:
      # Check to see if a worker pool is running
      $isRunning = codemelted --worker @{
        action = "is_running" # required
      }

      # Post message (a.k.a.) work to the pool to process. The result of the
      # worker completing the worker will be received via the 'handler'
      # setup via the Params for the 'start' action.
      #
      # data must be a [hashtable] in whatever construct you setup.
      codemelted --worker @{
        action = "post_message";           # required
        data = @{ id = "add"; data = 25; } # required
      }

      # To terminate the worker pool.
      codemelted --worker @{
        action = "terminate"; # required
      }

      # To start a worker pool for custom background work processing.
      codemelted --worker @{
        # required
        action = "start";

        # required, The common background worker logic for all queued work.
        task = [scriptblock] {
          param([hashtable] $evt)
          $id = $evt["id"]
          $data = $evt["data"]
          if ($id -eq "add") {
            return @{
              id = "add";
              data = 25 + $data
            }
          }
        };

        # required, where you will receive the completed work
        handler = [scriptblock] {
          param([hashtable] $evt)
          Write-Host $evt["data"]
        };

        # optional (how often to check queues)
        delay = 500;
      }

    RETURNS:
      [boolean] action 'is_running' $true if a pool is running,
        $false otherwise.

      [void] for all other actions.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )
  # Go get our actions and supporting variables to carry them out.
  $action = $Params["action"]
  $data = $Params["data"]
  $task = $Params["task"]
  $handler = $Params["handler"]
  $delay = $Params["delay"] ?? 500
  $isRunning = $null -eq $Global:CodeMeltedAPI.worker.threadJob `
    ? $false
    : ($Global:CodeMeltedAPI.worker.threadJob.State.ToLower() -eq "running")

  # Carry out the action requested.
  if ($action -eq "is_running") {
    return $isRunning
  } elseif ($action -eq "start") {
    # Validate our given parameters to start a worker pool.
    if (-not ($task -is [scriptblock])) {
      throw "SyntaxError: codemelted --worker Params 'start' action " +
        "expects 'task' [scriptblock] key / value entry."
    } elseif (-not ($handler -is [scriptblock])) {
      throw "SyntaxError: codemelted --worker Params 'start' action " +
        "expects 'handler' [scriptblock] key / value entry."
    } elseif ((-not ($delay -is [int])) -or $delay -lt 100) {
      throw "SyntaxError: codemelted --worker Params 'start' action " +
        "expects 'delay' [int] key / value entry if specified to be > 99."
    } elseif ($isRunning) {
      throw "SyntaxError: codemelted --worker pool is already running."
    }

    # Setup the handler for when tasks are completed.
    $Global:CodeMeltedAPI.worker.handler = $handler

    # Starter the worker pool thread that will process through the queues
    # as work is received for processing.
    $Global:CodeMeltedAPI.worker.threadJob = Start-ThreadJob -ScriptBlock {
      param($delayTime, $inQueue, $outQueue)

      # We will not allow more than processorCount of work tasks.
      $processorCount = codemelted --runtime @{
        action = "processor_count"
      }

      "Processor Count = $processorCount" | Out-File -FilePath "workerThread.txt"
      # Run the worker pool until we are terminated.
      while ($true) {
        # Delay before processing our queues.
        Start-Sleep -Milliseconds $delayTime

        # See what our completed tasks are, report the answer, and
        # dequeue for the next batch of tasks.
        "Before outQueue $($outQueue.Count)" | Out-File -FilePath "workerThread.txt" -Append
        for ($i = $outQueue.Count - 1; `
            $i -ge 0; $i--) {
          $task = $outQueue[$i]
          "Dequeuing task" | Out-File -FilePath "workerThread.txt" -Append
          "Has Completed $($task.hasCompleted())" | Out-File -FilePath "workerThread.txt" -Append
          if ($task.hasCompleted()) {
            "It completed" | Out-File -FilePath "workerThread.txt" -Append
            $answer = $task.result()
            "Answer is $answer" | Out-File -FilePath "workerThread.txt" -Append
            Invoke-Command -ScriptBlock $Global:CodeMeltedAPI.worker.handler `
              -ArgumentList $answer
            "ScriptBlock invoked" | Out-File -FilePath "workerThread.txt" -Append
            $outQueue.RemoveAt($i)
            Write-Host "outQueue dequeued $($outQueue.Count)" | Out-File -FilePath "workerThread.txt" -Append
          }
        }

        # Now go see what queued work there is to go process and kick off
        # those tasks.
        "Before inQueue $($inQueue.Count)" | Out-File -FilePath "workerThread.txt" -Append
        for ($i = $inQueue.Count - 1; `
            $i -ge 0; $i--) {
          # If our currently processing work is the same as our processor count,
          # then break loop.
          "Checking outQueue for work $($outQueue.Count)" | Out-File -FilePath "workerThread.txt" -Append
          if ($outQueue.Count -ge $processorCount) {
            break
          }

          # Nope we have room for work, lets go queue up some work.
          $data = $inQueue[$i]
          $task = [CTaskRunResult]::new($task, $data, 0)
          $outQueue.Add($task)
          $inQueue.RemoveAt($i)
        }
      }
    } -ArgumentList ($delay, $Global:CodeMeltedAPI.worker.inQueue, $Global:CodeMeltedAPI.worker.outQueue)
  } elseif ($action -eq "post_message") {
    # Validate our conditions before carrying out the post.
    if (-not ($data -is [hashtable])) {
      throw "SyntaxError: codemelted --worker Params 'post_message' action " +
        "expects a data [hashtable] entry for worker processing."
    } elseif (-not $isRunning) {
      throw "SyntaxError: codemelted --worker pool is not running."
    }

    # We are good, go post the message for later processing.
    $Global:CodeMeltedAPI.worker.inQueue.Insert(0, $data)
  } elseif ($action -eq "terminate") {
    # Make sure we are actually running before terminating.
    if (-not $isRunning) {
      throw "SyntaxError: codemelted --worker pool is not running."
    }

    # We are, go clear our global module.
    $Global:CodeMeltedAPI.worker.threadJob | Stop-Job
    $Global:CodeMeltedAPI.worker.threadJob | Remove-Job
    $Global:CodeMeltedAPI.worker.threadJob = $null
    $Global:CodeMeltedAPI.worker.inQueue.Clear()
    $Global:CodeMeltedAPI.worker.outQueue.Clear()
    $Global:CodeMeltedAPI.worker.handler = $null
  } else {
    throw "SyntaxError: codemelted --worker Params did not have a " +
      "supported action key specified. Valid actions are is_running / " +
      "start / post_message / terminate"
  }
}

# -----------------------------------------------------------------------------
# [Data Use Cases] ------------------------------------------------------------
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# [SDK Use Cases] -------------------------------------------------------------
# -----------------------------------------------------------------------------

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

  $action = $Params["action"]
  $data = $Params["data"]

  if ($action -eq "log_level") {
    if ($null -eq $data) {
      $logLevelString = [CLogRecord]::logLevelString($Global:CodeMeltedAPI.logger.level)
      return $logLevelString
    }
    $level = [CLogRecord]::logLevelInt($data)
    if ($level -eq -1) {
      throw "SyntaxError: codemelted --logger Params data key not a valid " +
        "value for setting log level. Valid values are 'debug' / 'info' " +
        "/ 'warning' / 'error'"
    }
    $Global:CodeMeltedAPI.logger.level = $level
  } elseif ($action -eq "handler") {
    if ($null -eq $data) {
      $Global:CodeMeltedAPI.logger.handler = $null
    } elseif ($data -is [scriptblock]) {
      $Global:CodeMeltedAPI.logger.handler = $data
    } else {
      throw "SyntaxError: codemelted --logger Params handler action only " +
        "supports a data value of [null] or [scriptblock]"
    }
  } elseif ($action -eq "debug" -or $action -eq "info" -or `
            $action -eq "warning" -or $action -eq "error") {
    if ($Global:CodeMeltedAPI.logger.level -eq [CLogRecord]::offLogLevel) {
      return [void]
    }
    $level = [CLogRecord]::logLevelInt($action)
    $record = [CLogRecord]::new($Global:CodeMeltedAPI.logger.level, $level, $data)
    if ($Global:CodeMeltedAPI.logger.level -le [CLogRecord]::debugLogLevel -and `
        $level -eq [CLogRecord]::debugLogLevel) {
      Write-Host $record.ToString() -ForegroundColor White
    } elseif ($Global:CodeMeltedAPI.logger.level -le [CLogRecord]::infoLogLevel -and `
            $level -eq [CLogRecord]::infoLogLevel) {
      Write-Host $record.ToString() -ForegroundColor Green
    } elseif ($Global:CodeMeltedAPI.logger.level -le [CLogRecord]::warningLogLevel -and `
            $level -eq [CLogRecord]::warningLogLevel) {
      Write-Host $record.ToString() -ForegroundColor Yellow
    } elseif ($Global:CodeMeltedAPI.logger.level-le [CLogRecord]::errorLogLevel -and `
            $level -eq [CLogRecord]::errorLogLevel) {
      Write-Host $record.ToString() -ForegroundColor Red
    }

    if ($null -ne $Global:CodeMeltedAPI.logger.handler) {
      Invoke-Command -ScriptBlock $Global:logHandler -ArgumentList $record
    }
  } else {
    throw "SyntaxError: codemelted --slogger Params did not have a " +
    "supported action key specified. Valid actions are log_level / " +
    "handler / debug / info / warning / error."
  }
}

function codemelted_network {
  <#
    .SYNOPSIS
    Provides a mechanism for getting data within a script via various network
    calls or setting up a server based network protocol. These are focused
    around web OSS network technologies and not all the different networking
    technologies available.

    SYNTAX:
      # Perform a network fetch to a REST API. The "data" is a [hashtable]
      # reflecting the named parameters of the Invoke-WebRequest. So the two
      # most common items will be "method" / "body" / "headers" but others
      # are reflected via the link.
      $resp = codemelted --network @{
        "action" = "fetch";    # required
        "url" = [string / ip]; # required
        "data" = [hashtable]   # required
      }

      # FUTURE ACTIONS not implemented yet.
      http_server / websocket_client / websocket_server

    RETURNS:
      [CNetworkResponse] for the 'fetch' action that has the statusCode,
        statusText, and data as properties. Methods of asBytes(), asObject(),
        asString() exists to get the data of the expected type or $null if
        not of that type.

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

  $action = $Params["action"]
  $url = $Params["url"]
  # TBD FUTURE $port = $Params["port"]
  $data = $Params["data"]

  # Validate the required entries utilized by all actions.
  if ([string]::IsNullOrEmpty($url) -or [string]::IsNullOrWhiteSpace($url)) {
    throw "SyntaxError: codemelted --network Params expects a url key with " +
      "a [string] URL / IP address"
  }

  # Go perform the actions.
  try {
    if ($action -eq "fetch") {
      # data needs to be a hashtable or this won't work.
      if (-not ($data -is [hashtable])) {
        throw "SyntaxError: codemelted --network Params 'fetch' action " +
          "expects a data [hashtable] entry."
      }

      # Go carry out the fetch.
      [hashtable] $request = codemelted_json @{
        "action" = "create_object";
        "data" = $data
      }
      $request.Add("uri", $url)
      $resp = Invoke-WebRequest @request -SkipHttpErrorCheck
      return [CFetchResponse]::new($resp)
    } elseif ($action -eq "http_server") {
      throw "FUTURE IMPLEMENTATION"
    } elseif ($action -eq "websocket_client") {
      throw "FUTURE IMPLEMENTATION"
    } elseif ($action -eq "websocket_server") {
      throw "FUTURE IMPLEMENTATION"
    } else {
      throw "SyntaxError: codemelted --network Params did not have a " +
        "supported action key specified. Valid actions are fetch / "
    }
  } catch {
    throw "SyntaxError: codemelted --network encountered an issue. " +
      $_.Exception.Message
  }
}

function codemelted_runtime {
  <#
    .SYNOPSIS
    Provides an interface for interacting and learning about the host
    operating system.

    SYNTAX:
      Lookups:
        # Provides the ability to lookup / run commands with the host
        # operating system. These actions are 'environment' / 'exist' /
        # 'system'. These would have a corresponding name identified that
        # will lookup a variable with the environment, check on a command
        # that exist, or a system command to execute (to include
        # parameters to command).
        $answer = codemelted --runtime @{
          "action" = [string] # required action identified above.
          "name" = [string]   # required
        }

      Queryable Actions:
        # Queryable answers to items available about the host operating
        # system. These actions are 'home_path' / 'hostname' / 'newline' /
        # 'online' / 'os_name' / 'os_version' / 'path_separator' /
        # 'processor_count' / 'temp_path' / 'username'
        $answer = codemelted --runtime @{
          "action" = [string] # required action identified above.
        }

      Stats:
        # Gets the current stats of the host operating system.
        # These actions are 'stats_disk' / 'stats_perf' / 'stats_tcp' /
        # 'stats_udp'
        $answer = codemelted --runtime @{
          "action" = [string] # required action identified above.
        }

    RETURNS:
      Lookups:
        [bool] $true if a 'command' action exists.
        [string] For a environment variable found or $null if not. For a
          'system' action, this will be the STDOUT of the command.

      Queryable Actions:
        [bool] for the 'online' queryable action. $true means path to Internet.
          $False means no path to the Internet.
        [char] for the 'newline' queryable action.
        [int] for the 'processor_count' queryable action.
        [string] for all the queryable actions.

      Stats:
        # 'stats_disk' action:
        [hashtable] @{
          "bytes_used_percent" = [double];
          "bytes_used" = [int]; # kilobytes
          "bytes_free" = [int]; # kilobytes
          "bytes_total" = [int]; # kilobytes
        }

        # 'stats_perf' action:
        [hashtable] @{
          "cpu_used_percent" = [double];
          "cpu_processor_count" = [int];
          "mem_used_percent" = [double];
          "mem_used_kb" = [int];
          "mem_available_kb" = [int];
          "mem_total_kb" = [int];
      }

      [string] for 'stats_tcp' / 'stats_udp' action.
  #>
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $false,
      Position = 0
    )]
    [hashtable]$Params
  )

  # Get our expected parameters.
  $action = $Params["action"]
  $name = $Params["name"]

  # Validate name parameter based on actions that would use it.
  if ($action -eq "environment" -or $action -eq "exist" `
        -or $action -eq "system") {
    if ([string]::isNullOrEmpty($name) -or
        [string]::IsNullOrWhiteSpace($name)) {
      throw "SyntaxError: codemelted --runtime $action action expects the " +
        "name Params key to have a string value."
    }
  }

  # Now go carry out the request.
  if ($action -eq "environment") {
    return [System.Environment]::GetEnvironmentVariable($name)
  } elseif ($action -eq "exist") {
    if ($IsWindows) {
      cmd /c where $name > nul 2>&1
    } else {
      which -s $name
    }
    return $LASTEXITCODE -eq 0
  } elseif ($action -eq "home_path") {
    return $IsWindows `
      ? [System.Environment]::GetEnvironmentVariable("USERPROFILE")
      : [System.Environment]::GetEnvironmentVariable("HOME")
  } elseif ($action -eq "hostname") {
    return [System.Environment]::MachineName
  } elseif ($action -eq "newline") {
    return [System.Environment]::NewLine
  } elseif ($action -eq "online") {
    return (Test-Connection -Ping google.com -Count 1 -Quiet)
  } elseif ($action -eq "os_name") {
    return $IsMacOS `
      ? "mac"
      : $IsWindows `
        ? "windows"
        : (Test-Path "/etc/rpi-issue") `
          ? "pi"
          : "linux"
  } elseif ($action -eq "os_version") {
    return [System.Environment]::OSVersion.VersionString
  } elseif ($action -eq "path_separator") {
    return [System.IO.Path]::DirectorySeparatorChar
  } elseif ($action -eq "processor_count") {
    return [System.Environment]::ProcessorCount
  } elseif ($action -eq "stats_disk") {
    $diskStats = (Get-PSDrive -PSProvider FileSystem)
    $diskTotal = $diskStats[0].Free + $diskStats[0].Used
    $diskTotalUsedPercent = ($diskStats[0].Used / $diskTotal) * 100
    return [ordered] @{
      "bytes_used_percent" = $diskTotalUsedPercent;
      "bytes_used" = $diskStats[0].Used;
      "bytes_free" = $diskStats[0].Free;
      "bytes_total" = $diskTotal;
    }
  } elseif ($action -eq "stats_perf") {
    if ($IsWindows) {
      if ($null -eq $Global:cpuCounter) {
        $Global:cpuCounter = [System.Diagnostics.PerformanceCounter]::new(
          "Processor", "% Processor Time", "_Total"
        )
        $Global:cpuCounter.NextValue() | Out-Null
      }
      if ($null -eq $Global:memCounter) {
        $Global:memCounter = [System.Diagnostics.PerformanceCounter]::new(
          "Memory", "Available MBytes"
        )
        $Global:memCounter.NextValue() | Out-Null
      }

      # All memory stats in Kilobytes
      $availableRam = $Global:memCounter.NextValue()
      $totalRam = (wmic ComputerSystem get TotalPhysicalMemory | findstr [0..9])
      $totalRam = $totalRam.Trim()
      $totalRam = [double]::Parse($totalRam) / 1e+6
      $memUsedKb = $totalRam - $availableRam
      $memUsed = ($memUsedKb / $totalRam) * 100
      return [ordered] @{
        "cpu_used_percent" = $Global:cpuCounter.NextValue();
        "cpu_processor_count" = [System.Environment]::ProcessorCount;
        "mem_used_percent" = $memUsed;
        "mem_used_kb" = $memUsedKb;
        "mem_available_kb" = $availableRam
        "mem_total_kb" = $totalRam
      }
    } elseif ($IsMacOS) {
      $cpuLoad = (top -l 1 | grep -E "^CPU" | tail -1 | awk '{ print $3 + $5"%" }').Replace("%", "")
      $cpuLoad = [double]::Parse($cpuLoad)
      $usedMemM = (top -l 1 | grep "^Phys" | awk '{ print $2 }').Replace("M", "")
      $usedMemKb = [double]::Parse($usedMemM) * 1000
      $availableMemM = (top -l 1 | grep "^Phys" | awk '{ print $8 }').Replace("M", "")
      $availableMemKb = [double]::Parse($availableMemM) * 1000
      $totalMemKb = $availableMemKb + $usedMemKb
      $memUsedPercent = ($usedMemKb / $totalMemKb) * 100
      return [ordered]  @{
        "cpu_used_percent" = $cpuLoad;
        "cpu_processor_count" = [System.Environment]::ProcessorCount;
        "mem_used_percent" = $memUsedPercent;
        "mem_used_kb" = $usedMemKb;
        "mem_available_kb" = $availableMemKb;
        "mem_total_kb" = $totalMemKb;
      }
    } else {
      $memUsedKb = (free --line | awk '{ print $6}')
      $memUsedKb = [double]::Parse($memUsedKb)
      $memFreeKb = (free --line | awk '{ print $8}')
      $memFreeKb = [double]::Parse($memFreeKb)
      $memTotalKb = $memFreeKb + $memUsedKb
      $memUsedPercent = ($memUsedKb / $memTotalKb) * 100
      $cpuIdle = (top -b -d1 -n1 | grep Cpu | awk '{ print $8 }')
      $cpuUsed = 100.0 - [double]::Parse($cpuIdle)
      return [ordered]  @{
        "cpu_used_percent" = $cpuUsed;
        "cpu_processor_count" = [System.Environment]::ProcessorCount;
        "mem_used_percent" = $memUsedPercent;
        "mem_used_kb" = $memUsedKb;
        "mem_available_kb" = $memFreeKb;
        "mem_total_kb" = $memTotalKb;
      }
    }
  } elseif ($action -eq "stats_tcp") {
    return $IsLinux ? (netstat -na | grep "tcp") : (netstat -nap tcp)
  } elseif ($action -eq "stats_udp") {
    return $IsLinux ? (netstat -na | grep "udp") : (netstat -nap tcp)
  } elseif ($action -eq "system") {
    return $IsWindows ? (cmd /c $name) : (sh -c $name)
  } elseif ($action -eq "temp_path") {
    return [System.IO.Path]::GetTempPath()
  } elseif ($action -eq "username") {
    return $IsWindows `
      ? [System.Environment]::GetEnvironmentVariable("USERNAME")
      : [System.Environment]::GetEnvironmentVariable("USER")
  } else {
    throw "SyntaxError: codemelted --runtime Params did not have a " +
      "supported action key specified. Valid actions are environment / " +
      "exist / home_path / hostname / newline / online / os_name / " +
      "os_version / path_separator / processor_count / stats_disk / " +
      "stats_perf / stats_tcp / stats_udp / system / temp_path / username"
  }
}
