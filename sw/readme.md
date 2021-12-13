STEPS TO RUN AFU_SIM
cd ThreadKraken/contrib/dma_loopback
afu_sim_setup -s hw/filelist.txt sim
cd sim
make 
make sim

OPEN ANOTHER TERMINAL
make bin/cload_sim
./bin/cload_sim