#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=

## PCA: ##

pcangsd=/PATH/TO/pcangsd.py
beagle=/PATH/TO/beagle.gz

source activate pcangsd

python3 $pcangsd -beagle $beagle -e 1 -o Pcangsd.PC1 -minMaf 0.05 -threads 20 

Rscript plot_PCA.R Pcangsd.PC1.cov pop_list.txt Pcangsd.PC1_Plot
