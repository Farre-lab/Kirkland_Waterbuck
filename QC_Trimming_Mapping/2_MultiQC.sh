#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=

## Script 2 - MultiQC ##

# Variables:
WORKDIR= # PATH to working directory

# MultiQC:
source activate MultiQC

mkdir -p "${WORKDIR}"/MultiQC/

multiqc "${WORKDIR}"/FastQC/ -o "${WORKDIR}"/MultiQC/

###
echo "MultiQC Completed"
###

