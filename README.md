# ThreadKraken
ECE554 Group project
Jianping Shen: group leader, processor design and implementation
Zhengzhen Chen: Software engineer, assembler, simulator implementation
Tommy Yee: DMA, MMU implementation

## Zedboard demo:
Move the Zedboard/sd_card/boot.bin to your zedboard SD card
Select the jumper for boot from SD card.
Connect uart to a serial port with baud rate 115200
If correctly booted, LED0 should twinkle.
Select 1~6 on serial terminal to choose the demo.
reset to start a new test.

## Afu_sim_ase guide:

```sh
cd ThreadKraken/contrib/dma_loopback  
afu_sim_setup -s hw/filelist.txt sim       (if not working try first:   . ~/opae/bin/tools_setup.sh) 
cd sim    
make      
make sim  

OPEN ANOTHER TERMINAL 
make bin/cload_sim  
./bin/cload_sim   
```
