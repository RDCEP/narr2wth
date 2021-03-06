#!/bin/bash

# based directly on example provided by Dylan Hall (UofC RCC)

printf "Submitting :: %10s | %+10s | %10s | %10s | %s\n"\
  "<job name>" "<output file> " "<error file>  " "<sbatch file>  " "<job id>"
#for year in {1979..2012};
for year in 2012;
do
    for step in 1 2;
    do
	job_name="sbatch.${year}.${step}"  #name I came up with
	out_file=./data/nc/annual/${job_name}.out  #puts the slurm output into this file
	err_file=./data/nc/annual/${job_name}.err  #error output from slurm goes here

	sbatch_file=cdo-submit.sbatch  #The way this is written this file should be the same every time you run
	annual_file=data/nc/annual/sbatch.${year}.${step}.nc  #use this if you want to specify the input file for the sbatch file to run
                      #These were just some arbitrary files I put in the base directory to test

	export annual_file  #Send the name of the result to the sbatch file
	export year     #Sends the ${year} var to the sbatch file
	export step
	printf "Submitting :: %10s | %10s | %10s | %10s | "\
    ${job_name} ${out_file} ${err_file} ${sbatch_file}
	sbatch --job-name=${job_name} --output=${out_file} --error=${err_file} ${sbatch_file}
    done
done
