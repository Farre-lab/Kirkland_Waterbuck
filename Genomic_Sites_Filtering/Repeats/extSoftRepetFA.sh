#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=

# Extracts soft repeats (capital letters from masked genome)

python extSoftRepetFA.py REF_MASKED.fasta

# Outputs as slurm-* - so moved and renamed repeats.bed