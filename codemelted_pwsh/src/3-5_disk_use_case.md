## 3.5 Disk Use Case

The following is displayed when you execute `codemelted --help @{ action = "disk" }`. It reflects the use case functions available further described in the sub-sections below.

```
=================================
codemelted CLI (disk) Use Case
=================================

This use case provides the ability to interact with a user

--disk-cp
--disk-exists
--disk-ls
--disk-mkdir
--disk-mv
--disk-read-file (IN DEVELOPMENT)
--disk-rm
--disk-size
--disk-write-file (IN DEVELOPMENT)

Execute 'codemelted --help @ { action = "--uc-name" }'
for more details.
```

<mark>TBD Function Relationships</mark>

### 3.5.1 --disk-cp Function

```
NAME
    disk_cp

SYNOPSIS
    Copies a file / directory from one location on disk to another.

    SYNTAX:
      $success = codemelted --disk-cp @{
        src = [string];  # required
        dest = [string]; # required
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [bool] $true if successful, $false otherwise.
```

### 3.5.2 --disk-exists Function

```
NAME
    disk_exists

SYNOPSIS
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
```

### 3.5.3 --disk-ls Function

```
NAME
    disk_ls

SYNOPSIS
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
```

### 3.5.4 --disk-mkdir Function

```
NAME
    disk_mkdir

SYNOPSIS
    Creates the src specified directory (including parents) on the designated
    disk.

    SYNTAX:
      $success = codemelted --disk-mkdir @{
        src = [string];  # required
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [bool] $true if the transaction was successful, $false otherwise.
```

### 3.5.5. --disk-mv

```
NAME
    disk_mv

SYNOPSIS
    Moves a file / directory from one location on disk to the other.

    SYNTAX:
      $success = codemelted --disk-mv @{
        src = [string];  # required
        dest = [string]; # required
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [bool] $true if successfully moved, $false otherwise.
```

### 3.5.6 --disk-read-file Function

<mark>TBD</mark>

### 3.5.7 --disk-rm Function

```
NAME
    disk_rm

SYNOPSIS
    Removes a file / directory from disk.

    SYNTAX:
      $success = codemelted --disk-rm @{
        src = [string];  # required
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [bool] $true if successfully moved, $false otherwise.
```

### 3.5.8 --disk-size Function

```
NAME
    disk_size

SYNOPSIS
    Retrieves the size of the file / directory on disk.

    SYNTAX:
      $sizeInBytes = codemelted --disk-size @{
        src = [string];  # required
        report = [bool]; # optional, to write a warning on failure.
      }

    RETURNS:
      [int] The size in bytes on disk of the item specified whether directory
            or file or -1 if an error occurs.
```

### 3.5.9 --disk-write-file Function

<mark>TBD</mark>