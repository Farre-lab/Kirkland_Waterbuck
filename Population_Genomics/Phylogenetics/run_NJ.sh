#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=

## NJ Tree

bam=bam_list.txt
angsd=/PATH/TO/angsd
sites_filtering=noSexAndScaff_norep_het_dep_map.regions

$angsd -bam $bam -sites $sites_filtering -out all.outgroup.singleReadSampling -minMapQ 30 \
    -minQ 20 -GL 2 -doMajorMinor 1 -doMaf 1 -SNP_pval 1e-6 -doIBS 1 -doCounts 1 -doCov 1 \
    -makeMatrix 1 -minMaf 0.05 -P 30

## Then run plot_NJ.R
