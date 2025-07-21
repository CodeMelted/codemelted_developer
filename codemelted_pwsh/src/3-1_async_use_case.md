## 3.1 Async Use Case

The following is displayed when you execute `codemelted --help @{ action = "async" }`. It reflects the use case functions available further described in the sub-sections below.

```
===============================
codemelted CLI (async) Use Case
===============================

This use case provides the ability to schedule background
work off the main thread to provide asynchronous processing
within a PowerShell script / terminal.

--async-sleep
--async-task
--async-timer
--async-worker (TBD)

Execute 'codemelted --help @ { action = "--uc-name" }'
for more details.
```

<mark>TBD UML RELATIONSHIPS</mark>

### 3.2.1 --async-sleep Function

```
NAME
    async_sleep

SYNOPSIS
    Will delay a given script task for the specified time in milliseconds.

    SYNTAX:
      codemelted --async-sleep @{
        delay = [int]; # required
      }

    RETURNS:
      [void]
```

### 3.2.2 --async-task Function

```
NAME
    async_task

SYNOPSIS
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
```

### 3.2.3 --async-timer

```
NAME
    async_timer

SYNOPSIS
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
```

### 3.2.4 --async-worker Function

<mark>TBD</mark>