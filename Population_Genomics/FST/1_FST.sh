#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=
#SBATCH --array=

## FST - Script 1 ##

## Requires list of BAM file PATHS for each population: bam_list_"${POP}".txt
## Plus list of population names: pop_list.txt

angsd=/PATH/TO/angsd

fasta=REF.fasta
fai=REF.fasta.fai
sites_filtering=SITES.regions
POP=$(head -"$SLURM_ARRAY_TASK_ID" pop_list.txt | tail -1) # list of pops to run ANGSD on

mkdir -p "${POP}"

$angsd -P 10 -bam bam_list_"${POP}".txt -out "${POP}"/"${POP}" -doSaf 1 -anc $fasta \
    -sites $sites_filtering -minMapQ 30 -minQ 20 -GL 2
