#!/bin/bash -l 

#SBATCH --account=pi-joshuaelliott
#SBATCH --qos=normal
#SBATCH --partition=westmere,sandyb,bigmem
# #SBATCH --partition=bigmem
#SBATCH --time=30  # max minutes per run, will help the scheduler to get your job to run faster
#SBATCH --exclusive

START=$(date)
scripts/cellNc.r ${stripe}
END=$(date)
echo "started at $START"
echo "ended at $END"
