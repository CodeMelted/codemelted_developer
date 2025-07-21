## 3.10 Network Use Case

The following is displayed when you execute `codemelted --help @{ action = "network" }`. It reflects the use case functions available further described in the sub-sections below.

```
=================================
codemelted CLI (network) Use Case
=================================

This use case provides the ability to fetch data from
server REST API endpoints along with setting up and hosting
your own HTTP server endpoint for REST API services and
creating a web socket server for web sockets. The use case
available are:

--network-connect (TBD)
--network-fetch
--network-serve (TBD)
--upgrade-web-socket (TBD)

Execute 'codemelted --help @{ action = "--uc-name" }'
for more details.
```

<mark>TBD Function Relationships</mark>

### 3.10.1 --network-connect Function

<mark>TBD</mark>

### 3.10.2 --network-fetch Function

```
NAME
    network_fetch

SYNOPSIS
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
```

## 3.10.3 --network-serve Function

<mark>TBD</mark>

## 3.10.4 --network-upgrade-web-socket Function

<mark>TBD</mark>
