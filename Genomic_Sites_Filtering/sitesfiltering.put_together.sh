#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=


## Genomic Sites Filtering - Combine into single BED file

ANGSD=/PATH/TO/angsd
BEDTOOLS=/PATH/TO/bedtools

mkdir -p results
# Create BED file containing only autosome sites
grep -w -f selected_chr.txt results/beds/all.bed > results/autosomes_all.bed
cut -f1 results/autosomes_all.bed > results/autosomes_all_list.txt

rep=repeats.bed # Repetitive sites!!
het=good_e0.bed # "Passed" heterozyosity sites
dep=all_keep.bed # "Passed" depth sites
map=mappability_m1_k150_e2.bed # "Passed" mappability sites

# Remove repetitive sites from autosome BED file
$BEDTOOLS subtract -a results/autosomes_all.bed -b $rep > NEW_results/noSexAndScaff_norep.bed 
# Only include sites that passed heterozygosity filter
$BEDTOOLS intersect -a NEW_results/noSexAndScaff_norep.bed -b $het > NEW_results/noSexAndScaff_norep_het.bed
# Only include sites that passed depth filter
$BEDTOOLS intersect -a NEW_results/noSexAndScaff_norep_het.bed -b $dep > NEW_results/noSexAndScaff_norep_het_dep.bed
# Only include sites that passed mappability filter
$BEDTOOLS intersect -a NEW_results/noSexAndScaff_norep_het_dep.bed -b $map > NEW_results/noSexAndScaff_norep_het_dep_map.bed

awk '{print $1"\t"$2+1"\t"$3}' NEW_results/noSexAndScaff_norep_het_dep_map.bed > NEW_results/noSexAndScaff_norep_het_dep_map.regions

# Index BED file
$ANGSD sites index NEW_results/noSexAndScaff_norep_het_dep_map.regions

# Calculate number of sites in each BED file
cat "${rep}" | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print "Rep:" SUM}'
cat "${het}" | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print "Het:" SUM}'
cat "${dep}" | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print "Dep:" SUM}'
cat "${map}" | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print "Map:" SUM}'

cat results/noSexAndScaff_norep.bed | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print "noSexAndScaff_norep.bed:" SUM}'
cat results/noSexAndScaff_norep_het.bed | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print "noSexAndScaff_norep_het.bed:" SUM}'
cat results/noSexAndScaff_norep_het_dep.bed | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print "noSexAndScaff_norep_het_dep.bed:" SUM}'
cat results/noSexAndScaff_norep_het_dep_map.bed | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print "noSexAndScaff_norep_het_dep_map.bed:" SUM}'
