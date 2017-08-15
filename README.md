<h1>ssbb-wiiu-gc-controller-adapter</h1>

PPC code to inject functionality into SSBB for enabling the WiiU GameCube Controller Adapter via USB

This project is very much a work in progress. Any feedback or insight is encouraged!

<img src="https://wiki.dolphin-emu.org/images/4/4c/Wiiugcpadadapter.jpg" alt="WiiU GameCube Controller Adapter" width="128" />


### Compiling to Gecko
Insert into [ASMWiiRd](https://code.google.com/archive/p/geckowii/downloads), [CodeWrite](https://github.com/TheGag96/CodeWrite), or
[PyiiASMH](https://github.com/seanhawk27/PyiiASMH) to obtain the generated Gecko code

**NOTE:**

Confirm the following when compiling:

- The insertion address is set to an instruction where the function [IPCCltInit](https://github.com/devkitPro/libogc/blob/master/libogc/ipc.c#L804) has already been called
- The instruction replaced by a branch to this code is restored at the end of the PPC code

For an example of how to handle these two points, please refer to [the last few lines](main.s#L113) of the main source file


### Completed
So far, the code implements the following features to enable USB HID for GC controller adapters

- Reserve IPC memory heap via `iosCreateHeap`
- Allocate needed memory via `iosAlloc`
- Obtain file descriptor (fd) for USB HID devices via `IOS_Open`
- Listen for USB device changes via `IOS_IoctlAsync`
- Listen for USB device inputs (interrupts) via `IOS_IoctlAsync`


### TODO

- Determine the best place to free allocated memory via `iosFree`
- Determine the best place to map inputs from USB to inputs for game (when interrupts are captured or when game looks for inputs)
- Determine how to optimally punish all recovery options as Falco

Soon<sup>TM</sup>
