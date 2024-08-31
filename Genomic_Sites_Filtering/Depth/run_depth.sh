#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=


## Depth

source activate snakemake

# Waterbuck:

python3 -m snakemake --use-conda \
  --configfile depth.config.yaml \
  --snakefile depth.snakefile \
  -p -c 48 --rerun-incomplete 