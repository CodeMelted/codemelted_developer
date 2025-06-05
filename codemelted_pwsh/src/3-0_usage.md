# 3.0 USAGE

<center><img src="https://codemelted.com/developer/codemelted_dev/models/all/use-case-model.drawio.png" /></center>

The following sub-sections describe the core use cases above along with additional `codemelted.ps1` module specific use cases.

## 3.1 Core Use Case Breakdown

As identified from the *The CodeMelted DEV: Rosetta Stone* book, the core use cases are as follows.

> 1. **Async:** Asynchronous processing both on a main thread, via background threads, repeating timers, and dedicated workers provide a software engineer the ability to schedule work in a way to run more then one task efficiently.
> 2. **Console:** Provides a set of STDIN / STDOUT functionality to build an interactive terminal application without a dedicated UI.
> 3. **DB:** Provides the mechanism for building out an embedded database solution specific to the chosen SDK environment for the language to store complex data structures.
> 4. **Disk:** Provides the functionality to work with and manage files on a hard disk.
> 5. **HW:** Provides the mechanisms to interact with hardware peripherals via BLE and RS-232 Serial connected to a system.
> 6. **JSON:** JSON is the most common data format to work with for web technologies. This will provide all the mechanisms necessary to work with this data.
> 7. **Logger:** Provides a simple logging facility to log to STDOUT along with hookup a log handler for further processing in production.
> 8. **Monitor:** Running a dedicated application or service necessitates the ability to monitor the host operating environment. This will establish monitoring capabilities based on the SDK technology.
> 9. **Network:** The Internet is how apps communicate. This will provide access to web technologies to facilitate this communication.
> 10. **NPU:**  Stands for Numeric Processing Unit, this will be where all the math is at. Applications need to crunch numbers. This will provide that functionality.
> 11. **Process:** Provides the interface to interact with host operating system programs as one-off / bi-directional dedicated processes.
> 12. **Runtime:** Provides the ability to query common properties of the host operating system along with SDK specific hookups for the given runtime.
> 13. **Storage:** Provides the ability to store data in key / value pairs of strings.
> 14. **UI:** Identifies the items necessary for the SDK to build either a Graphical User Interface (GUI) or a Terminal User Interface (TUI) to interact with users and provide audio feedback. This establishes UI design goals but is highly tailored to the SDK.

## 3.2 `codemelted.ps1` Module Use Cases

1. **Developer:** Implements developer specific use case functions that support the *CodeMelted DEV* project along with useful commands a developer will find useful.
2. **Setup:** Supports setting up different operating system platforms via the CLI allowing for quickly setting up a computer with free and open source tools.