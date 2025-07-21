## 3.13 Runtime Use Case

## 3.12 Process Use Case

The following is displayed when you execute `codemelted --help @{ action = "runtime" }`. It reflects the use case functions available further described in the sub-sections below.

```
=================================
codemelted CLI (runtime) Use Case
=================================

This use case provides queryable information about the host
operating system running the pwsh terminal shell.

--runtime-cpu-arch
--runtime-cpu-count
--runtime-environment
--runtime-home-path
--runtime-hostname
--runtime-newline
--runtime-online
--runtime-os-name
--runtime-os-version
--runtime-path-separator
--runtime-temp-path
--runtime-user

Execute 'codemelted --help @{ action = "--uc-name" }'
for more details.
```

<mark>TBD Function Relationships</mark>

### 3.13.1 --runtime-cpu-arch Function

```
NAME
    runtime_cpu_arch

SYNOPSIS
    Retrieves whether the host operating system is 64-bit or 32-bit.

    SYNTAX:
      $arch = codemelted --runtime-cpu-arch

    RETURNS:
      [string] Identifies if the operating system is '64-bit' or '32-bit'
```

### 3.13.2 --runtime-cpu-count Function

```
NAME
    runtime_cpu_count

SYNOPSIS
    Retrieves the available CPUs for processing work for the host operating
    system.

    SYNTAX:
      $cpuCount = codemelted --runtime-cpu-count

    RETURNS:
      [int] Identifies how many CPUs available for parallel work.
```

### 3.13.3 --runtime-environment Function

```
NAME
    runtime_environment

SYNOPSIS
    Retrieves an environment variable held by the host operating system based
    on the name you specify.

    SYNTAX:
      $value = codemelted --runtime-environment @{
        name = [string]; # required
      }

    RETURNS:
      [string] Retrieves the environment variable value or $null if not found.
```

### 3.13.4 --runtime-home-path Function

```
NAME
    runtime_home_path

SYNOPSIS
    Retrieves the logged in user's home directory on the given operating
    system.

    SYNTAX:
      $path = codemelted --runtime-home-path

    RETURNS:
      [string] Identifies the user's home directory.
```

### 3.13.5 --runtime-hostname Function

```
NAME
    runtime_hostname

SYNOPSIS
    Retrieves the hostname of the given operating system.

    SYNTAX:
      $hostname = codemelted --runtime-hostname

    RETURNS:
      [string] The hostname of how your machine identifies itself on a
        network.
```

### 3.13.6 --runtime-newline Function

```
NAME
    runtime_newline

SYNOPSIS
    Retrieves the newline character for the given operating system.

    SYNTAX:
      $newLine = codemelted --runtime-newline

    RETURNS:
      [string] The newline character for the given operating system.
```

### 3.13.7 --runtime-online Function

```
NAME
    runtime_online

SYNOPSIS
    Determines if the given operating system has access to the Internet.

    SYNTAX:
      $online = codemelted --runtime-online

    RETURNS:
      [bool] $true if access to the Internet exists. $false otherwise.
```

### 3.13.8 --runtime-os-name Function

```
NAME
    runtime_os_name

SYNOPSIS
    Retrieves the name of the operating system. The value will be 'mac' /
    'windows' / 'linux' / 'pi'

    SYNTAX:
      $name = codemelted --runtime-os-name

    RETURNS:
      [string] A string representing the name of the operating system.
```

### 3.13.9 --runtime-os-version Function

```
NAME
    runtime_os_version

SYNOPSIS
    Retrieves the current operating system version.

    SYNTAX:
      $version = codemelted --runtime-os-version

    RETURNS:
      [string] Identifying version number for the operating system.
```

### 3.13.10 --runtime-path-separator Function

```
NAME
    runtime_path_separator

SYNOPSIS
    Retrieves the path separator for the host operating system.

    SYNTAX:
      $separator = codemelted --runtime-path-separator

    RETURNS:
      [string] The separator character for directories on disk for the given
        host operating system.
```

### 3.13.11 --runtime-temp-path Function

```
NAME
    runtime_temp_path

SYNOPSIS
    Retrieves the temporary directory for the given operating system for
    storing temporary data.

    SYNTAX:
      $tempPath = codemelted --runtime-temp-path

    RETURNS:
      [string] reflecting the operating system temp path for temporary data.
```

### 3.13.12 --runtime-user Function

```
NAME
    runtime_user

SYNOPSIS
    Retrieves the currently logged in user.

    SYNTAX:
      $user = codemelted --runtime-user

    RETURNS:
      [string] reflecting the logged in user.
```