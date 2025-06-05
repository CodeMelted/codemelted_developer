# 8.0 Logger Use Case

The most tried and true method of performing application diagnostics is logging. While Integrated Development Environments (IDEs) provide many tools to aid in development, logging captures what is happening within your application when a bug arises. And at the end of the day, bugs will always occur. To that end, the *Logger Use Case* represents a simple logging facility to STDOUT supporting four log levels.

The four log levels are DEBUG, INFO, WARNING, and ERROR. The STDOUT logging can aid while the application is being developed. Additionally, the *Logger Use Case* will provide a logged event handler that allows expanding on this logging facility to attach other processing. This can be as simple as logging to file to logging events to log server. You can decide.

## 8.1 Acceptance Criteria

1. The *Logger Use Case* will provide the ability to log to STDOUT supporting the logging levels of DEBUG, INFO, WARNING, and ERROR. The log format will be `TIMESTAMP [LEVEL]: MESSAGE`.
2. The *Logger Use Case* will support the setting of the given log level where logged events that don't meet that log level are not processed. It will also provide the ability to turn off the logging altogether.
3. The *Logger Use Case* will support the attaching of a Logged Event Handler to process logged events once they are logged to STDOUT.

## 8.2 SDK Notes

```mermaid
---
title: Log Message Flow
---
stateDiagram-v2
  direction LR
  state is_logging_off <<choice>>
  build : Build log record.
  state is_log_level <<choice>>
  log : Write log record to STDOUT.
  state is_log_handler <<choice>>
  handler : Send log record to log handler for further processing.
  [*] --> is_logging_off
  is_logging_off --> build : logging is on
  is_logging_off --> [*] : logging is off
  build --> is_log_level
  is_log_level --> log : log record meets log level
  is_log_level --> [*] : log record does not meet log level
  log --> is_log_handler
  is_log_handler --> handler : log handler set
  is_log_handler --> [*] : no log handler
  handler --> [*]
```
