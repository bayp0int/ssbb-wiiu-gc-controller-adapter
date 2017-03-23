# Skip functions that are declared first in this entire code block
gc_adapter_initialize:
b      gc_adapter_start


# FUNCTION - bl_generator
# Desc: Converts value at LR + offset to bl instruction pointing to specified memory location
# r3: Offset from LR to memory address that will be converted to bl instruction
# r4: Memory address that the bl instruction will branch to
bl_generator:
mflr   r29
add    r3, r3,r29
sub    r29, r4,r3
rlwinm r29, r29,0,6,31
addis  r29, r29, 0x4800
addi   r29, r29, 0x0001
stw    r29, 0(r3)
blr



# Setup bl to IOS_Open (IOS_Open located at 802123a8) using bl_generator
gc_adapter_start:
li     r3, 0x0030
lis    r4, 0x8021
addi   r4, r4,0x23a8
bl     bl_generator

## Insert "/dev/usb/hid" at 935e2e18

# Load string "/dev" (0x2f646576) into r4
lis    r4, 0x2f64
addi   r4, r4,0x6576

# Load memory address 0x935e2e18 into r3 (pointer to where to store string "/dev/usb/hid")
lis    r3, 0x935e
addi   r3, r3,0x2e18

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

# Load mode 0 for IOS_Open
li     r4, 0

# Will be replaced by bl -> IOS_Open
nop

# Save fd in r3 to r31 to for instructions requiring r3 ahead
mr     r31, r3



## Call IOS_IoctlAsync with message GetDeviceChange to listen for devices

# Setup bl to IOS_IoctlAsync (IOS_IoctlAsync located at 80212c08) using bl_generator
li     r3, 0x0030
lis    r4, 0x8021
addi   r4, r4,0x2c08
bl     bl_generator

# Load r4 with 0 (0 is ioctl message GetDeviceChange for listening to device changes)
li     r4, 0

# Load r5 with pointer to buffer_in (Will be NULL)
li     r5, 0

# Load r6 with length of buffer_in (0)
li     r6, 0

# Load r7 with pointer to buffer_io (Is random memory address for now)
lis    r7, 0x8000
addi   r7, r7,0x2a00

# Load r8 with length of buffer_io (0x600 constant)
li     r8, 0x0600

# Load r9 with pointer to callback function
lis    r9, 0x4e80
addi   r9, r9,0x0020
stw    r9, -0x0020(r7)
subi   r9, r7, 0x0020

# Load r10 with pointer to buffer_io (Is random memory address for now)
mr     r10, r7

# Load r3 with fd that was temporarily stored in r31
mr     r3, r31

# Will be replaced by bl -> IOS_IoctlAsync
nop


## IMPORTANT: Perform replaced instruction before ending
# Injecting code at memory address 80230b8c replaces the below instruction
# Uncomment below line to restore original flow for insertion address 80230b8c:
#lwz    r0, 0x0024 (sp)
