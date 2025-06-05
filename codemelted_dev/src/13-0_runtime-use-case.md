# 13.0 Runtime Use Case

According to Tech Target:

> Runtime is a piece of code that implements portions of a programming language's execution model. In doing this, it allows the program to interact with the computing resources it needs to work. Runtimes are often integral parts of the programming language and don't need to be installed separately.

> Runtime is also when a program is running. That is, when you start a program running in a computer, it is runtime for that program. In some programming languages, certain reusable programs or "routines" are built and packaged as a "runtime library." These routines can be linked to and used by any program when it is running.

The *Runtime Use Case* will provide queryable actions common between all the runtimes for the chosen languages models. It will then implement SDK specific functions to fully exercise the availability of functionality for a chosen SDK programming language.

## 13.1 Acceptance Criteria

1. The *Runtime Use Case* will provide the following queryable actions. Failed queryable values will result in a minimum value or UNDETERMINED if a String return:
   1. CPU architecture
   2. Number of CPUs
   3. Environment variables
   4. User's home directory
   5. Hostname
   6. Kernel version
   7. Online access to the Internet
   8. OS name
   9. OS version
   10. Path separator
   11. Temp path
   12. User name
2. The *Runtime Use Case* will provide access to SDK language specific features not common between the chosen module languages. (i.e. Event attachment in JavaScript, etc.).

## 13.2 SDK Notes

None.
