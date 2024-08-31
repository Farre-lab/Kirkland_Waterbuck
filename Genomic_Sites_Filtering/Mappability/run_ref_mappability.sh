#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=

## Reference Mappability

source activate snakemake

python3 -m snakemake --use-conda \
  --configfile Refmappability.config.yaml \
  --snakefile Refmappability.snakefile \
  -p -c 48