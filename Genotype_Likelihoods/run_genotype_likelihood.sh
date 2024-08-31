#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=10

## Genotype Likelihood:

source activate snakemake

## All filtered sites:
python3 -m snakemake --use-conda \
  --configfile genotype_likelihood.config.yaml \
  --snakefile genotype_likelihood.snakefile \
  -p -c 10

## Transversion sites:
python3 -m snakemake --use-conda \
  --configfile genotype_likelihood_transversions.config.yaml \
  --snakefile genotype_likelihood_transversions.snakefile \
  -p -c 10