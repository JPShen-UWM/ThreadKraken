# ThreadKraken
ECE554 Group project

ThreadKraken project is trying to explore a way to use fine-grained multi-threading processor to minimize cycle per instruction. The ThreadKraken processor support a self-designed 32-bit RISC ISA Thread Kraken Basic (TKB ISA). The processor can support up to 8 thread running in fine-grained. The thread controller in Instruction fetch stage will select next thread in a round robin order except "atomic instruction" is indicated. As the result, when running in multi-thread, we can minimize the chance of read after write. Also there is not need for branch prediction because we don't need to flush pipeline while other pipelines are in different thread. During cache miss, the thread that caused the miss will go to sleep for a spesific cycles and other thread can keep running, so the processor don't need to stall for a long time during cache miss. The modelsim simulation shows that when running in multithread, the processor can have maximum 40% improvement when running in long loops.

Jianping Shen: group leader, processor design and implementation

Zhengzhen Chen: Software engineer, assembler, simulator implementation

Tommy Yee: DMA, MMU implementation

## Content

Zedboard: zedboard config

rtl/main: RTL immplementation

rtl/testbench: SystemVerilog testbench

sw: assembler, assembly test cases, simulator

## Assembler guide:

Add assembly .asm to test_cases or thread_test_cases.

```sh
cd sw
python make.py clean
python make.py
```
## ISA:
Except exception, multi thread instruction, other instruction can add a "a" at the end to transfer to atomic operation.

For example addi r5 r6 5 -->  addia r5 r6 5 means that the next instruction being fetched must be in the same thread.

![image](https://user-images.githubusercontent.com/67498771/146317622-8a69fec3-a1cf-4eb2-b7f1-fbe5e3c9432d.png)

## Zedboard demo:
1. Move the Zedboard/sd_card/boot.bin to your zedboard SD card

2. Select the jumper for boot from SD card.

3. Connect uart to a serial port with baud rate 115200

4. If correctly booted, LED0 should twinkle.

5. Select 1~6 on serial terminal to choose the demo.

6. reset to start a new test.

7. Demo 6 should print HELLO WORLD! in ascii.

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
