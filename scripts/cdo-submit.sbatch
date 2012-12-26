#!/bin/bash -l 
# '-l' causes this to be a login shell

# based directly on example provided by Dylan Hall (UofC RCC)

#### Uncomment / Change the below as necessary

#SBATCH --account=pi-joshuaelliott
# #SBATCH --partition=westmere
#SBATCH --qos=normal
### Suggestions :
#SBATCH --partition=sandyb
#SBATCH --time=20  # max minutes per run, will help the scheduler to get your job to run faster
# #SBATCH --mem-per-cpu=15000
# OR
#SBATCH --exclusive

#source /etc/profile  #This is only needed if you use z-shell
module load cdo  #Load any mondules you need to run here


cdo -f nc4 -O mergetime $(find data/nc/${year}* \( -type f -o -type l \) -name narr-a_221_*00_000.${step}.nc) ${annual_file}
