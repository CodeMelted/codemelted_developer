## 3.8 Logger Use Case

The following is displayed when you execute `codemelted --help @{ action = "logger" }`. It reflects the use case functions available further described in the sub-sections below.

```
=================================
codemelted CLI (logger) Use Case
=================================

This use case provides a logging facility with PowerShell.
All logging is sent to STDOUT color coded based on the log
level of the logged item. Simply set the log level and
log events that meet that level, are logged to STDOUT. To
further process the log event, set a log handler.
The available use case options are:

--logger-level
--logger-handler
--logger-log

Execute 'codemelted --help @{ action = "--uc-name" }'
for more details.
```

<mark>TBD Function Relationships</mark>

### 3.8.1 --logger-level Function

```
NAME
    logger_level

SYNOPSIS
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
```

### 3.8.2 --logger-handler Function

```
NAME
    logger_handler

SYNOPSIS
    Provides the ability to setup a log handler that can receive a log record
    after written to STDOUT.

    SYNTAX:
      codemelted --logger-handler @{
        "handler" = [scriptblock] / $null  # required
      }

    RETURNS:
      [void]
```

### 3.8.3 -logger-log Function

```
NAME
    logger_log

SYNOPSIS
    Provides the logging of 'info' / 'warning' / 'error' / 'debug' messages
    to STDOUT and to be further processed via a log handler.

    SYNTAX:
      codemelted --logger-log @{
        level = [string]; # required
        data = [string];  # required
      }

    RETURNS:
      [void]
```
