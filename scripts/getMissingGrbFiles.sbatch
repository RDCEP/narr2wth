#!/bin/bash

#SBATCH --job-name=getGrb

#SBATCH --workdir=/project/joshuaelliott/narr

#SBATCH --time=20

#SBATCH --output=getMissingGrbFiles.out

#SBATCH --nodes=4

#SBATCH --tasks-per-node=5

#SBATCH --exclusive

# --constraint=ib must be give to guarantee a job is allocated 
# nodes with Infiniband
# #SBATCH --constraint=ib

module load openmpi

# Run the process with mpirun. Notice -n is not required. mpirun will
# automatically figure out how many processes to run from the slurm options
mpirun R --slave -f scripts/getMissingGrbFiles.R


