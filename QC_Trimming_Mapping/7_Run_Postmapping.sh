#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=

source activate PostMapping

snakemake -s Snakefile -j 30 -p
