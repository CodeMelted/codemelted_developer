## 3.7 JSON Use Case

The following is displayed when you execute `codemelted --help @{ action = "json" }`. It reflects the use case functions available further described in the sub-sections below.

```
==============================
codemelted CLI (json) Use Case
==============================

This use case provides the ability to work with JSON data.
This includes creating compliant JSON container objects,
checking data types, parsing, and serializing the data
for storage / transmission. The available use case options
are:

--json-check-type
--json-create-array
--json-create-object
--json-parse
--json-stringify
--json-valid-url

Execute 'codemelted --help @{ action = "--uc-name" }'
for more details.
```

<mark>TBD Function Relationships</mark>

### 3.7.1 --json-check-type Function

```
NAME
    json_check_type

SYNOPSIS
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
```

### 3.7.2 --json-create-array Function

```
NAME
    json_create_array

SYNOPSIS
    Creates a JSON compliant array with the option to copy data into the
    newly created array.

    SYNTAX:
      $data = codemelted --json-create-array @{
        "data" = [array] or [System.Collection.ArrayList] # optional
      }

    RETURNS:
      [System.Collections.ArrayList] object or $null if it could not be
      created.
```

### 3.7.3 --json-create-object Function

```
NAME
    json_create_object

SYNOPSIS
    Creates a JSON compliant object with the option to copy data to it upon
    creation.

    SYNTAX:
      $data = codemelted --json-create-object @{
        "data" = [hashtable]  # optional
      }

    RETURNS:
      [hashtable] of the newly created object or $null if a failure occurs.
```

### 3.7.4 ---json-parse Function

```
NAME
    json_parse

SYNOPSIS
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
```

### 3.7.5 ---json-stringify Function

```
NAME
    json_stringify

SYNOPSIS
    Will stringify a JSON compliant specified data parameter.

    SYNTAX:
      $data = codemelted --json-stringify @{
        data = [object]; # required, JSON compliant type.
      }

    RETURNS:
      [string] or $null if the 'data' was not a JSON compliant type.
```

### 3.7.6 --json-valid-url Function

```
NAME
    json_valid_url

SYNOPSIS
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
```