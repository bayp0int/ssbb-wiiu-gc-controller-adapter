<h1>ssbb-wiiu-gc-controller-adapter</h1>

PPC code to inject functionality into SSBB for enabling the WiiU GameCube Controller Adapter via USB

This project is very much a work in progress. It will be done Soon<sup>TM</sup>. Any feedback or insight is encouraged!

<img src="https://wiki.dolphin-emu.org/images/4/4c/Wiiugcpadadapter.jpg" alt="WiiU GameCube Controller Adapter" width="128" />


### Compiling to Gecko
Insert into [ASMWiiRd](https://code.google.com/archive/p/geckowii/downloads) or [CodeWrite](https://github.com/TheGag96/CodeWrite) and set the insertion address at 80230b8c (this is just after IPC functions and Wiimote bluetooth have been enabled)

### TODO
Right now the code only obtains a file descriptor via [IOS_Open](https://github.com/devkitPro/libogc/blob/master/libogc/ipc.c#L843) and subscribes to USB device changes on the file descriptor via [IOS_IoctlAsync](https://github.com/devkitPro/libogc/blob/master/libogc/ipc.c#L1078). TODO items include:

- Determine appropriate length of buffer_io to IOS_IoctlAsync
- Determine viable memory range to perminately store USB device information
- Determine how to recieve controller inputs
- Determine how to map controller inputs to existing game functionality
- Determine how to optimally punish all recovery options as Falco
