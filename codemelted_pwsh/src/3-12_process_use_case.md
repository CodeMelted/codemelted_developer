## 3.12 Process Use Case

The following is displayed when you execute `codemelted --help @{ action = "process" }`. It reflects the use case functions available further described in the sub-sections below.

```
=================================
codemelted CLI (process) Use Case
=================================

This use case facilitates the ability to kick-off other
operating system commands and process their output. This
is done either as a one-off run or a spawned bi-direction
process where you interact with said process via
STDIN / STDOUT until the process is terminated.

--process-exists
--process-run
--process-spawn (TBD)

Execute 'codemelted --help @{ action = "--uc-name" }'
for more details.
```

<mark>TBD Function Relationships</mark>

### 3.12.1 --process-exists Function

```
NAME
    process_exists

SYNOPSIS
    Determines if a given executable program is known by the host operating
    system. NOTE: regular terminal commands (i.e. ls, dir) will not register.

    SYNTAX:
      $exists = codemelted --process-exists @{
        command = [string]; # required
      }

    RETURNS:
      [bool] $true if the specified command exists, $false otherwise.
```

### 3.12.2 --process-run Function

```
NAME
    process_run

SYNOPSIS
    Runs a one-off operating system process and captures its STDOUT output.

    SYNTAX:
      # Example listing files on a linux terminal.
      $output = codemelted --process-run @{
        command = "ls"; [string] # required
        args = "-latr"; [string] # optional
      }

    RETURNS:
      [string] The capture output from the process via STDOUT.
```

### 3.12.3 --process-spawn Function

<mark>TBD</mark>