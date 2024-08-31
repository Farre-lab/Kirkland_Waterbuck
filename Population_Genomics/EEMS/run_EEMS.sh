#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=

## EEMS Analysis: ##

source activate EEMS2

angsd=/PATH/TO/angsd
sites_filtering=noSexAndScaff_norep_het_dep_map.regions
bam=bam_list_all.txt

$angsd -bam $bam -sites $sites_filtering -out all.SingleReadSampling.ForEEMS \
    -minMapQ 30 -minQ 20 -GL 2 -doMajorMinor 1 -doMaf 1 -SNP_pval 1e-6 -doIBS 1 \
    -doCounts 1 -doCov 1 -makeMatrix 1 -minMaf 0.05 -P 30

# .ibsMAT file copied to input directory (.diffs)

/PATH/TO/runeems_snps --params params_eems1
/PATH/TO/runeems_snps --params params_eems2
/PATH/TO/runeems_snps --params params_eems3

## Output files plotted with plot_EEMS.R