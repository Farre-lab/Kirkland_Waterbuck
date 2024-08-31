#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=

## Script 4 - MultiQC (Trim) ##

# Variables:
WORKDIR= # PATH to working directory

# MultiQC:
source activate MultiQC

mkdir -p "${WORKDIR}"/MultiQC_Trim/

multiqc "${WORKDIR}"/FastQC_Trim/ -o "${WORKDIR}"/MultiQC_Trim/

###
echo "MultiQC_Trim Completed"
###

