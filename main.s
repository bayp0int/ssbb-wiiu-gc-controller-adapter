## Pertinent info:
# Addresses in SSBB:
# 801d76e8 - DCFlushRange
# 80213468 - iosCreateHeap
# 80213598 - iosAlloc
# 802137a8 - iosFree
# 802123a8 - IOS_Open
# 80212c08 - IOS_IoctlAsync


# First line run - Skip functions that are declared first in this code
# Since this line is never run again, this block will be reused in this
# code to store the heap index (hid) created via iosCreateHeap
gc_adapter_initialize:
## RAI:hid:OFFSET
b      gc_adapter_start

# Will be used to store the address of memeory allocated via iosAlloc
## RAI:iosAlloc_memory:OFFSET
nop

# Will be used to store the file descriptor (fd) for interacting with ioctl
## RAI:fd:OFFSET
nop

#####
# FUNCTION - bl_generator
# Desc: Converts value at LR + offset into bl instruction pointing to specified
#       memory location. Instruction is then copied to main memory via dcbf and
#       and the cache block is then invalidated with icbi
# Parameters:
# r3: Offset from LR to memory address that will be converted to bl instruction
# r4: Memory address that the bl instruction will branch to
bl_generator:
mflr   r5
li     r0, 0
add    r3, r3,r5
sub    r5, r4,r3
rlwinm r5, r5,0,6,31
addis  r5, r5, 0x4800
addi   r5, r5, 0x0001
stw    r5, 0(r3)
dcbf   r0,r3
sync
icbi   r0,r3
isync
blr
#####


#####
# FUNCTION - get_current_address
# Desc: Gets LR of this function and stores it in r9
# Parameters: N/A
# Modified: r9
# Return:
# r9 - Value of LR
#####
get_current_address:
mflr   r9
blr


#####
# FUNCTION - setup_Ioctl_InterruptMessage_in
# Desc: Sets up registers for call to IOS_IoctlAsync will ioctl message 3 (
#       InterruptMessage(IN))
#####
setup_Ioctl_InterruptMessage_in:

# Save LR in r0 to be able to jump back to correct location
mflr   r0

# Store current address in r9 to be able to retrieve fd stored above
bl     get_current_address

# Restore LR to be able to jump back to correct location
mtlr   r0

# Load fd (above) into r3
## RAI:fd:ONSET
lwz    r3, -0x0048(r9)

# Load r4 with 3 (3 is ioctl message InterruptMessage(IN) for getting inputs
# from USB devices)
li     r4, 3

# Load r5 with pointer to buffer_in (also known as req_args for v4 of the USB
# HID module)
## RAI:iosAlloc_memory:ONSET
lwz    r5, -0x004c(r9)
addi   r5, r5,0x0600

# Load r6 with length of buffer_in (req_args is 32 bytes)
li     r6, 0x0020

# Load r7 with pointer to buffer_io (NULL for InterruptMessage(IN); don't care
# about output via host to device)
li     r7, 0

# Load r8 with length of buffer_io (0 because NULL buffer_io)
li     r8, 0

# r9 is loaded with LR for convenience, needs to be modified further outside
# this function to point to proper callback
mflr   r9

# Load r10 with pointer to req_args (set in r5 above)
mr     r10, r5

blr
#####


#####
# FUNCTION - setup_Ioctl_GetDeviceChange
# Desc: Sets up registers for call to IOS_IoctlAsync will ioctl message 0 (
#       GetDeviceChange)
setup_Ioctl_GetDeviceChange:

# Save LR in r0 to be able to jump back to correct location
mflr   r0

# Store current address in r9 to be able to retrieve fd stored above
bl     get_current_address

# Restore LR to be able to jump back to correct location
mtlr   r0

# Load fd (above) into r3
## RAI:fd:ONSET
lwz    r3, -0x007c(r9)

# Load r4 with 0 (0 is ioctl message for responding to device changes
# from USB devices)
li     r4, 0

# Load r5 with pointer to buffer_in (NULL for GetDeviceChange because no inputs)
li     r5, 0

# Load r6 with length of buffer_in (0 because NULL buffer_in)
li     r6, 0

# Load r7 with pointer to buffer_io (also known as device_desc)
## RAI:iosAlloc_memory:ONSET
lwz    r7, -0x0080(r9)

# Load r8 with length of buffer_io (0x0600 bytes of device descriptors)
li     r8, 0x0600

# r9 is loaded with LR for convenience, needs to be manipulated outside
# this function to point to proper callback
mflr   r9

# Load r10 with pointer to device_desc (set in r7 above)
mr     r10, r7

blr
#####


#####
# FUNCTION - callback_InterruptMessage_in
# Desc:

# Store LR before losing it via bl instructions
## RAI:callback_InterruptMessage_in:OFFSET
mflr   r0
# r4 is address to req_args
# Store it after device_desc, req_args, and data of req_args
stw    r0, 0x0028(r4)

# Copy address of req_args to r6 so that it is not lost
mr     r6,r4


## Sync data using DCFlushRange
# r3 holds the address of memory to Sync
# r4 holds the number of bytes to sync
addi   r3, r4,0x0020
li     r4, 8
# Will be replaced by bl -> DCFlushRange via bl_generator
## RAI:DCFlushRange:OFFSET
nop

## Check to see if A button has been pressed
# Get first byte from data buffer of req_args
lbz    r3,0x0020(r6)
# Compare with 2 (value when A button is pressed)
cmpwi  r3, 2
# Continue on if A button not pressed
bne    setup_next_interrupt
# Load 0x0100 to r3 (used for A presses in Brawl)
li     r3, 0x0100
# Load address for A button in r4 (805bad04)
lis    r4, 0x805c
subi   r4, r4,0x52fc

# Store A button press at memory address
stw    r3, 0(r4)


setup_next_interrupt:
# Setup registers accordingly for IOS_IoctlAsync with InterruptMessage(IN)
bl     setup_Ioctl_InterruptMessage_in

# LR of the previous function is stored in r9
# Modify r9 to point to callback function (callback_InterruptMessage_in above)
## RAI:callback_InterruptMessage_in:ONSET
addi   r9, r9,-0x0038

# Will be replaced by bl -> IOS_IoctlAsync via bl_generator
## RAI:callback_InterruptMessage_in-InterruptMessage(IN):OFFSET
nop


## Restore LR (stored previous directly below data of req_args)
# Get current LR to be able to locate memory address needed above
mflr   r9
# Get the address to memory allocated by iosAlloc (stored above)
## RAI:iosAlloc_memory:ONSET
lwz    r3, -0x00e8(r9)
# Get LR from memory
lwz    r0, 0x0628(r3)
# Restore the proper LR
mtlr   r0

blr
#####


#####
# FUNCTION - callback_GetDeviceChange
# Desc: Called after USB devices change from IOS_IoctlAsync with ioctl request
#       type GetDeviceChange. The main purpose of this function will be to setup
#       IOS_IoctlAsync calls for interrupt messages gotten from the GameCube
#       (GC) adapter. Starts by loading size of userdata buffer into r3
# Parameters:
# r3: The result of the IPC function
# r4: Pointer to device_desc buffer (device information such as device ID)

# Load first value of device_desc buffer into r3 (the total size)
## RAI:callback_GetDeviceChange:OFFSET
lwz    r3, 0(r4)

# If beginning of buffer is all F's (means no data), break out early
cmpwi  r3, 0xFFFFFFFF
beq    callback_GetDeviceChange_return

# Store LR before losing it via bl instructions
mflr   r0
# r4 is address to beginning of memory from iosAlloc (device_desc)
# Store LR after device_desc, req_args, and data of req_args
stw    r0, 0x0628(r4)

## Setting up req_args

# Get device no and store it in r3
lwz    r3, 0x0004(r4)
# Save device_no after 16 bytes of padding in req_args
stw    r3, 0x0610(r4)

# Get interrupt endpoint (IN) address and store it in r3
li     r3, 0x0081
# Save interrupt endpoint (IN) address after device_no in req_args
stw    r3, 0x0614(r4)

# Set length of transfer
li     r3, 0x0008
# Save length of transfer after endpoint address in req_args
stw    r3, 0x0618(r4)

# Set pointer to data of req_args to be after location of req_args
addi   r3, r4,0x0620
# Save pointer after transfer length in req_args
stw    r3, 0x061c(r4)


## Setting up registers to call IOS_Ioctl with message InterruptMessage(IN)

# Setup registers for IOS_IoctlAsync accordingly
bl     setup_Ioctl_InterruptMessage_in

# Modify r9 to point to callback function (callback_InterruptMessage_in above)
## RAI:callback_InterruptMessage_in:ONSET
addi   r9, r9,-0x008c


# Will be replaced by bl -> IOS_IoctlAsync via bl_generator to capture inputs
## RAI:callback_GetDeviceChange-InterruptMessage(IN):OFFSET
nop


## Restore LR (stored previous directly below data of req_args)
# Get current LR to be able to locate memory address needed above
mflr   r9
# Get the address to memory allocated by iosAlloc (stored above)
## RAI:iosAlloc_memory:ONSET
lwz    r3, -0x013c(r9)
# Get LR from memory
lwz    r0, 0x0628(r3)
# Restore the proper LR
mtlr   r0

callback_GetDeviceChange_return:
blr
#####


##########
# Function Declarations End
##########


gc_adapter_start:
## Setup multiple instructions to be called later in this code (DCFlushRange,
## iosCreateHeap, iosAlloc, IOS_Open, and IOS_IoctlAsync) using bl_generator

# Modify r4 to be address to DCFlushRange (801d76e8)
lis    r4, 0x801d
addi   r4, r4,0x76e8
# r4 will now be used to benerate bl -> DCFlushRange instruction

# Setup bl -> DCFlushRange using bl_generator
## RAI:DCFlushRange:ONSET
li     r3, -0x00a4
bl     bl_generator


# Modify r4 to be address for iosCreateHeap (80213468)
lis    r4, 0x8021
addi   r4, r4,0x3468
# r4 will now be used to generate bl -> iosCreateHeap instruction

# Setup bl -> iosCreateHeap using bl_generator
## RAI:iosCreateHeap:ONSET
li     r3, 0x003c
bl     bl_generator


# Modify r4 to be address for iosAlloc (80213598)
addi   r4, r4,0x0130
# r4 will now be used to generate bl -> iosAlloc instruction

# Setup bl -> iosAlloc using bl_generator
## RAI:iosAlloc:ONSET
li     r3, 0x0044
bl     bl_generator


# Modify r4 to be address for IOS_Open (802123a8)
subi   r4, r4,0x11f0
# r4 will now be used to generate bl -> IOS_Open instruction

# Setup bl -> IOS_Open using bl_generator
## RAI:IOS_Open:ONSET
li     r3, 0x006c
bl     bl_generator


# Modify r4 to be address for IOS_IoctlAsync (80212c08)
addi   r4, r4,0x0860
# r4 will now be used to generate bl -> IOS_IoctlAsync instructions

# Setup bl -> IOS_IoctlAsync(GetDeviceChange) that occurs after IOS_Open
## RAI:GetDeviceChange:ONSET
li     r3, 0x0074
bl     bl_generator

# Setup bl -> IOS_IoctlAsync(InterruptMessage(IN)) in
# callback_InterruptMessage_in
## RAI:callback_GetDeviceChange-InterruptMessage(IN):ONSET
li     r3, -0x0064
bl     bl_generator

# Setup bl -> IOS_IoctlAsync (InterruptMessage(IN)) in
# callback_InterruptMessage_in
## RAI:callback_InterruptMessage_in-InterruptMessage(IN):ONSET
li     r3, -0x00c0
bl     bl_generator



## Call iosCreateHeap to reserve memory
# r3 holds the memory address to start of the heap (get via r13)
lwz    r3, -0x3844(r13)
# r4 holds number of bytes of memory to reserve
# Need enough memory for GetDeviceChange, req_args, and data of req_args
li     r4, 0x0800
# Will be replaced with call to iosCreateHeap
## RAI:iosCreateHeap:OFFSET
nop

# r3 now holds the heap index (hid) of reserved memory
# Store the hid above
bl     get_current_address
## RAI:hid:ONSET
stw    r3, -0x01b8(r9)

# Allocate memory via iosAlloc
# r3 is used to hold hid (already held)
# r4 is used to specify size of memory to allocate
li     r4, 0x0700
# r5 is used to specify the memory alignment(??)
li     r5, 32
# Will be replaced with call to iosAlloc
## RAI:iosAlloc:OFFSET
nop

# r3 now holds the address pointing to newly allocated memory
# Store the address above
bl     get_current_address
## RAI:iosAlloc_memory:ONSET
stw    r3, -0x01c8(r9)



## Insert "/dev/usb/hid" at address of allocated memory (in r3)

# Load string "/dev" (0x2f646576) into r4
lis    r4, 0x2f64
addi   r4, r4,0x6576

# Store contents of r4 ("/dev" or 0x2f646576) at memory address 0x935e2e18
stw    r4, 0(r3)

# Load string "/usb" (0x2f757362) into r4
lis    r4, 0x2f75
addi   r4, r4,0x7362

# Store contents of r4 ("/usb" or 0x2f757362) at memory address 0x935e1c
stw    r4, 4(r3)

# Load string "/hid" (0x2f686964) into r4
lis    r4, 0x2f68
addi   r4, r4,0x6964

# Store contents of r4 ("/hid" or 0x2f686964) at memory address 0x935e20
stw    r4, 8(r3)



## Call IOS_Open to obtain file descriptor (fd) using filepath "/dev/usb/hid"
# r3 is already pointing to string "/dev/usb/hid"
# Load mode 0 for IOS_Open into r4
li     r4, 0

# Will be replaced by bl -> IOS_Open via bl_generator
## RAI:IOS_Open:OFFSET
nop

# fd is now in r3
# Store the fd above
bl     get_current_address
## RAI:fd:ONSET
stw    r3, -0x01f8(r9)



## Set up registers to call IOS_Ioctl accordingly
bl     setup_Ioctl_GetDeviceChange

# r9 has the current address, need to manipulate it to point to the callback
## RAI:callback_GetDeviceChange:ONSET
addi   r9, r9,-0x0108

# Will be replaced by bl -> IOS_IoctlAsync via bl_generator
## RAI:GetDeviceChange:OFFSET
nop


## IMPORTANT: Perform replaced instruction before ending
# Injecting code at memory address 80230b8c replaces the below instruction
# Uncomment below line to restore original flow for insertion address 80230b8c:
lwz    r0, 0x0024(sp)
