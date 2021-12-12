# ThreadKraken
ECE554 Group project


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
