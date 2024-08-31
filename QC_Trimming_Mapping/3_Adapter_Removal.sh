#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=
#SBATCH --array=

## Script 3 - AdapterRemoval and FASTQC ##

# Variables:
WORKDIR= # working directory
FDIR= # FASTA file directory
SAMPLE=$(head -"$SLURM_ARRAY_TASK_ID" Sample_List.tsv | tail -1 | cut -f 1) 

# AdapterRemoval
source activate AdapterRemoval

mkdir -p "${WORKDIR}"/Adapter_Removal

AdapterRemoval --file1 "${FDIR}"/"${SAMPLE}"_1.fq.gz --file2 "${FDIR}"/"${SAMPLE}"_2.fq.gz --adapter1 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT --adapter2 GATCGGAAGAGCACACGTCTGAACTCCAGTCACGGATGACTATCTCGTATGCCGTCTTCTGCTTG --mm 3 --collapse --collapse-conservatively --trimns --trimqualities --basename Adapter_Removal_"${SAMPLE}"

mv Adapter_Removal_"${SAMPLE}"* "${WORKDIR}"/Adapter_Removal
 
# FastQC after trimming:
mkdir -p "${WORKDIR}"/FastQC_Trim

fastqc "${WORKDIR}"/Adapter_Removal/Adapter_Removal_"${SAMPLE}".pair1.truncated.gz "${WORKDIR}"/Adapter_Removal/Adapter_Removal_"${SAMPLE}".pair2.truncated.gz "${WORKDIR}"/Adapter_Removal/Adapter_Removal_"${SAMPLE}".collapsed.gz -o "${WORKDIR}"/FastQC_Trim/

###
echo "Adapter Removal and FastQC Completed"
###
