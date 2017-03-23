# ssbb-wiiu-gc-controller-adapter
<img src="https://wiki.dolphin-emu.org/images/4/4c/Wiiugcpadadapter.jpg" alt="WiiU GameCube Controller Adapter" style="width: 50px; height: 50px; float: right;"/>
PPC code to inject functionality into SSBB for enabling the WiiU GameCube Controller Adapter via USB

### Compiling to Gecko
Insert into [ASMWiiRd](https://code.google.com/archive/p/geckowii/downloads) or [CodeWrite](https://github.com/TheGag96/CodeWrite) and set the insertion address at 80230b8c (this is just after IPC functions and Wiimote bluetooth have been enabled)

### TODO
Right now the code only obtains a file descriptor via [IOS_Open](https://github.com/devkitPro/libogc/blob/master/libogc/ipc.c#L843) and subscribes to USB device changes on the file descriptor via [IOS_IoctlAsync](https://github.com/devkitPro/libogc/blob/master/libogc/ipc.c#L1078). TODO items include:

- Determine appropriate length of buffer_io to IOS_IoctlAsync
- Determine viable memory range to perminately store USB device information
- Determine how to recieve controller inputs
- Determine how to map controller inputs to existing game functionality
- Determine how to optimally punish all recovery options as Falco
