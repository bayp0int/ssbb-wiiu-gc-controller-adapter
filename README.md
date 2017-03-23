<h1>ssbb-wiiu-gc-controller-adapter</h1>

PPC code to inject functionality into SSBB for enabling the WiiU GameCube Controller Adapter via USB

This project is very much a work in progress. Any feedback or insight is encouraged!

<img src="https://wiki.dolphin-emu.org/images/4/4c/Wiiugcpadadapter.jpg" alt="WiiU GameCube Controller Adapter" width="128" />


### Compiling to Gecko
Insert into [ASMWiiRd](https://code.google.com/archive/p/geckowii/downloads) or [CodeWrite](https://github.com/TheGag96/CodeWrite) to obtain the generated Gecko code

**NOTE:**

Confirm the following when compiling:
- The insertion address is set to an instruction where the function [IPCCltInit](https://github.com/devkitPro/libogc/blob/master/libogc/ipc.c#L804) has already been called
- The instruction replaced by a branch to this code is restored at the end of the PPC code

For an example of how to handle these two points, please refer to [the last few lines](main.s#L113) of the main source file


### TODO
Right now the code only obtains a file descriptor via [IOS_Open](https://github.com/devkitPro/libogc/blob/master/libogc/ipc.c#L843) and subscribes to USB device changes on the file descriptor via [IOS_IoctlAsync](https://github.com/devkitPro/libogc/blob/master/libogc/ipc.c#L1078). TODO items include:

- Determine appropriate length of buffer_io to IOS_IoctlAsync
- Determine viable memory range to perminately store USB device information
- Determine how to recieve controller inputs
- Determine how to map controller inputs to existing game functionality
- Determine how to optimally punish all recovery options as Falco

Soon<sup>TM</sup>
