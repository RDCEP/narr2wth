#!/bin/bash

# based directly on an example provided by Dylan Hall (UofC RCC)

printf "Submitting :: %10s | %+10s | %10s | %10s | %s\n"\
  "<job name>" "<output file> " "<error file>  " "<sbatch file>  " "<job id>"
for stripe in {1..192};
do
    job_name="cellNc.r.${stripe}"  #name I came up with
    out_file=./logs/${job_name}.out  #puts the slurm output into this file
    err_file=./logs/${job_name}.err  #error output from slurm goes here
    sbatch_file=scripts/cellNc.sbatch  #The way this is written this file should be the same every time you run
    export stripe
    printf "Submitting :: %10s | %10s | %10s | %10s | " \
	${job_name} ${out_file} ${err_file} ${sbatch_file}
    sbatch --job-name=${job_name} --output=${out_file} --error=${err_file} ${sbatch_file}
done

