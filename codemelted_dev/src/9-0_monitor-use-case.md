# 9.0 Monitor Use Case

The ability to measure aspects of the host computer / operating system of a developed application is key in identifying metrics that can point to issues with the host system. The *Monitor Use Case* identifies the different areas of a host system typically measured and analyzed to identify potential problem areas or areas for improvement.

## 9.1 Acceptance Criteria

1. The *Monitor Use Case* will provide the ability to measure attached hardware components reporting their current temperature in Celsius, its max temperature, and critical failure temperature.
2. The *Monitor Use Case* will provide the ability to report on attached disks to the host operating system reporting the name, available bytes, used bytes, total bytes, load percentage, file system, is it read only, what kind, and mount point.
3. The *Monitor Use Case* will provide the ability to report on the network of the host operating system identifying names, mac address, mtu, total received / transmitted bytes, total received / transmitted errors, and total received / transmitted packets.
4. The *Monitor Use Case* will provide the ability to measure the host computers overall performance via CPU load (as measured across all CPUs), available RAM in bytes, free RAM in bytes, used RAM in bytes, total RAM in bytes, total RAM load percentage, SWAP free bytes, SWAP used bytes, SWAP total bytes, and the SWAP load percentage.
5. The *Monitor Use Case* will provide the ability to measure the currently running host operating system processes identifying each process by PID, CPU load percentage, current working directory, total read bytes from disk, total written bytes to disk, the executable path, group id, RAM usage in bytes, RAM virtual usage in bytes, name of the process, how many open files, any parent PID, path root directory, session id, status of the running process, time started in seconds, time running in seconds, and the user id of the process. It will also provide the ability to kill and wait for process completion.
6. Each of the monitoring capabilities above will provide the ability to save the monitored data into a textual based format and run in the background as setup by the software engineer.

## 9.2 SDK Notes

- Not applicable to the Flutter / JavaScript (Web) Module. The only item that may be implemented is measurement capabilities of the browser environment but nothing to the depth identified.
- The JavaScript (Deno) portions of the module will implement a subset of the acceptance criteria above.
- The PowerShell / Rust modules will implement most if not all aspects of the Acceptance Criteria above.
- See the module sections below for final implementations.
