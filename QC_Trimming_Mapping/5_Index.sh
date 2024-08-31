#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=

## Script 5 ##

# Variables:
WORKDIR= # working directory
GENOME=REF.fasta

# BWA - Index Genome:
source activate bwa

bwa index "${GENOME}"
