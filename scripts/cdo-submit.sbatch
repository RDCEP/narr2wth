#!/bin/bash -l 
# '-l' causes this to be a login shell

# based directly on example provided by Dylan Hall (UofC RCC)

#### Uncomment / Change the below as necessary

#SBATCH --account=pi-joshuaelliott
#SBATCH --partition=westmere
#SBATCH --qos=normal

#source /etc/profile  #This is only needed if you use z-shell
module load cdo  #Load any mondules you need to run here

#ls -l ${in_file}    #Just a placeholder action
#echo -n "<<${year}>>"  #Another placeholder action


#### Uncomment / Change below to run your actions

cdo -f nc4 -O mergetime $(find data/nc/${year}* -type f -name narr-a_221_*00_000.single.nc) ${annual_file}


