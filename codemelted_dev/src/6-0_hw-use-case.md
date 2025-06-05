# 6.0 HW Use Case

According to Wikipedia for the hardware of interest.

> Bluetooth Low Energy (Bluetooth LE, colloquially BLE, formerly marketed as Bluetooth Smart) is a wireless personal area network technology designed and marketed by the Bluetooth Special Interest Group (Bluetooth SIG) aimed at novel applications in the healthcare, fitness, beacons, security, and home entertainment industries. Compared to Classic Bluetooth, Bluetooth Low Energy is intended to provide considerably reduced power consumption and cost while maintaining a similar communication range.

> A serial port is a serial communication interface through which information transfers in or out sequentially one bit at a time. This is in contrast to a parallel port, which communicates multiple bits simultaneously in parallel. Throughout most of the history of personal computers, data has been transferred through serial ports to devices such as modems, terminals, various peripherals, and directly between computers.

The *HW Use Case* will support these different hardware types. Each of them is similar in terms of how you interact with them. You must first scan for devices connected to the host operating system. Once you identify the hardware you want, you connect to it. Once connected, you are able to read / write data with the hardware until you close the connection. This use case will facilitate this transactions.

## 6.1 Acceptance Criteria

1. The *HW Use Case* will provide the ability to scan for connected hardware devices based on the hardware type. The result will be a list of connected devices one can open a connection.
2. The *HW Use Case* will provide the ability to open a connection to a hardware device. The result will be a Protocol Handler to facilitate reading and writing data to the hardware until disconnected. Failed connections will result in a NULL return.
3. The *HW Use Case* will provide the ability to attach event listeners to the browser based global events and individual object events.
4. The *HW Use Case* will provide the ability to query the current device location and orientation in 3D space.

## 6.2 SDK Notes

- Acceptance criteria 1 - 2 apply to all modules.
- Acceptance criteria 3 - 4 applies to Flutter / JavaScript modules only.
