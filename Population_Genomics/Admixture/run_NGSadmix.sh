#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --array=
#SBATCH --cpus-per-task=

### Admixture ###

ngsadmix=/PATH/TO/NGSadmix

kvalue=$SLURM_ARRAY_TASK_ID

beagle=beagle.gz # beagle file produced in "Genotype_Likelihood" folder

$ngsadmix -likes $beagle -K $kvalue -o admixture.$kvalue -minMaf 0.05 -P 20
grep "like=" admixture.$kvalue.log | cut -f2 -d " " | sed "s/like=/$kvalue\t/g" >> admixture.likes2

## Then plot in R (plot_Admixture.R)
