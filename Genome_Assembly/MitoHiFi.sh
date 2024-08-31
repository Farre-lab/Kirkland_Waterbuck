#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=

## MitoHiFi - Example script

source activate MitoHiFi

python mitohifi.py -f NC_020715.1.fasta -g NC_020715.1.gb \
    -r cat_"${ASSEMBLY}"_trimmed.fastq.gz \
    -t 8 -o 2 -d -p 90