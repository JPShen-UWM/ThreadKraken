# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: F:\Xilinx\Project\ThreadKraken\ThreadKraken_system\_ide\scripts\systemdebugger_threadkraken_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source F:\Xilinx\Project\ThreadKraken\ThreadKraken_system\_ide\scripts\systemdebugger_threadkraken_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent Zed 210248B1874E" && level==0 && jtag_device_ctx=="jsn-Zed-210248B1874E-23727093-0"}
fpga -file F:/Xilinx/Project/ThreadKraken/ThreadKraken/_ide/bitstream/design_1_wrapper_3.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw F:/Xilinx/Project/ThreadKraken/design_1_wrapper/export/design_1_wrapper/hw/design_1_wrapper_3.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source F:/Xilinx/Project/ThreadKraken/ThreadKraken/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow F:/Xilinx/Project/ThreadKraken/ThreadKraken/Debug/ThreadKraken.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con
