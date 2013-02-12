#!/bin/bash

#SBATCH --job-name=downloadAndDeleteGrbs

#SBATCH --workdir=/project/joshuaelliott/narr

#SBATCH --time=8:00:00

#SBATCH --output=logs/downloadAndDeleteGrbs-%j.out

#SBATCH --nodes=1

#SBATCH --exclusive

sbatch --begin=tomorrow scripts/downloadAndDeleteGrbs.sbatch
R --slave -f scripts/downloadAndDeleteGrbs.R


