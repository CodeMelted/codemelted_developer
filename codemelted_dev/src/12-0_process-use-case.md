# 12.0 Process Use Case

According to Wikipedia,

> In computing, a process is the instance of a computer program that is being executed by one or many threads. There are many different process models, some of which are light weight, but almost all processes (even entire virtual machines) are rooted in an operating system (OS) process which comprises the program code, assigned system resources, physical and logical access permissions, and data structures to initiate, control and coordinate execution activity. Depending on the OS, a process may be made up of multiple threads of execution that execute instructions concurrently.

This use case will facilitate the functionality to detect installed programs, run one off command to gather outputs, and setup a bi-directional STDIN / STDOUT dedicated process your program can communicate.

## 12.1 Acceptance Criteria

1. The *Process Use Case* will support the ability to detect if a command exists with the host operating system.
2. The *Process Use Case* will support the ability to run a one-off command and capture its STDOUT / STDERR output.
3. The *Process Use Case* will support the ability to run a bi-directional command that is communicated with via STDIN / STDOUT / STDERR until command to end its processing

## 12.2 SDK Notes

None.
