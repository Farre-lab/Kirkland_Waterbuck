#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=
#SBATCH --array=

## Script 1 - FASTQC ##

# Variables:
WORKDIR= # working directory
FDIR= # FASTA file directory
SAMPLE=$(head -"$SLURM_ARRAY_TASK_ID" Sample_List.tsv | tail -1 | cut -f 1) 

# FastQC:
mkdir -p "${WORKDIR}"/FastQC/

fastqc "${FDIR}"/"${SAMPLE}"_1.fq.gz "${FDIR}"/"${SAMPLE}"_2.fq.gz -o "${WORKDIR}"/FastQC/

###
echo "FastQC Completed"
###
