#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=


## Site Heterozygosity

source activate snakemake

python3 -m snakemake --use-conda \
  --configfile excess_het.yaml \
  --snakefile excess_het.snakefile \
  -p -c 48

