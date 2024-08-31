#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --array=
#SBATCH --cpus-per-task=

## Calculate heterozygosity per individual:

SAMPLE=$(head -"$SLURM_ARRAY_TASK_ID" Sample_List_All.tsv | tail -1)

angsd=/PATH/TO/angsd
realSFS=/PATH/TO/realSFS

fasta=REF.fasta
fai=REF.fasta.fai
sites_filtering=noSexAndScaff_norep_het_dep_map.regions

## All Sites:

mkdir -p All/

grep "/$SAMPLE\." bam_list_all.txt > All/"$SAMPLE"_bam_list.txt

$angsd -P 8 -bam All/"$SAMPLE"_bam_list.txt -out All/"$SAMPLE" -doSaf 1 -anc $fasta \
    -sites $sites_filtering -minMapQ 30 -minQ 20 -GL 2

$realSFS All/"$SAMPLE".saf.idx -P 8 -fold 1 > All/"$SAMPLE".saf.idx.folded.sfs

sed "s/^/"${SAMPLE}" /" All/"${SAMPLE}".saf.idx.folded.sfs > All/"${SAMPLE}".saf.idx.folded_updated.sfs

# Then cat all .saf.idx.folded_updated.sfs files

## Transversion Sites:

mkdir -p All_No_Transitions/

grep "/$SAMPLE\." bam_list_all.txt > All_No_Transitions/"$SAMPLE"_bam_list.txt

$angsd -P 8 -bam All_No_Transitions/"$SAMPLE"_bam_list.txt -out All_No_Transitions/"$SAMPLE" -doSaf 1 -anc $fasta \
    -sites $sites_filtering -minMapQ 30 -minQ 20 -GL 2 -noTrans 1

$realSFS All_No_Transitions/"$SAMPLE".saf.idx -P 8 -fold 1 > All_No_Transitions/"$SAMPLE".saf.idx.folded.sfs

sed "s/^/"${SAMPLE}" /" All_No_Transitions/"${SAMPLE}".saf.idx.folded.sfs > All_No_Transitions/"${SAMPLE}".saf.idx.folded_updated.sfs

rm All_No_Transitions/"${SAMPLE}".saf.gz All_No_Transitions/"${SAMPLE}".saf.pos.gz

# Then cat all .saf.idx.folded_updated.sfs files

## Output files modified with metadata and plotted with R (ggplot2)