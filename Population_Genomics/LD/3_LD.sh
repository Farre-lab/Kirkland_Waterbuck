#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=200G
#SBATCH --cpus-per-task=32

### 2 - Pairwise LD by chromosome:

angsd=/PATH/TO/ANGSD
ngsLD=/PATH/TO/ngsLD

FASTA=REF.fasta
FAI=REF.fasta.fai
SF=sites.regions
BAM=bam_list_common.txt
CHR=chrs.txt
NAME=Common_Pairwise
IND=52 ### no. individuals
RND=0.001  ### randomly sample X% SNP pairs

mkdir -p LD_"${NAME}"

while read FILE; do

"${angsd}" -bam "${BAM}" \
    -anc "${FASTA}" \
    -out LD_"${NAME}"/LD_"${NAME}"_"${FILE}" \
    -rf "${CHR}" \
    -sites "${SF}"  \
    -minMapQ 30 -minQ 20 -doCounts 1 \
    -GL 2 -doMajorMinor 1 -doMaf 1 -skipTriallelic 1 \
    -doGlf 2 -SNP_pval 1e-6 -nThreads 32 -remove_bads 1 -minMaf 0.05

zless LD_"${NAME}"/LD_"${NAME}"_"${FILE}".mafs.gz | cut -f1,2 > LD_"${NAME}"/LD_"${NAME}"_"${FILE}".mafs.pos ### get pos file

NSITES=$(zcat LD_"$NAME"/LD_"$NAME"_"$FILE".mafs.gz | tail -n+2 | wc -l) ### calculate the number of sites

echo "${NSITES}"

$ngsLD --geno LD_"${NAME}"/LD_"${NAME}"_"${FILE}".beagle.gz \
    --probs \
    --min_maf 0.05 \
    --max_kb_dist 0 \
    --posH LD_"${NAME}"/LD_"${NAME}"_"${FILE}".mafs.pos \
    --log_scale T \
    --n_threads 32 \
    --n_ind "${IND}" \
    --n_sites "${NSITES}" \
    --rnd_sample "${RND}" \
    --out ngsLD_"${NAME}"_"${FILE}".tsv

awk '{if ($3 != "inf" && $7 != "inf") {print}}' ngsLD_"${NAME}"_"${FILE}".tsv | sed "s/:/\t/g" > ngsLD_"${NAME}"_"${FILE}"_Updated.tsv

rm ngsLD_"${NAME}"_"${FILE}".tsv

Rscript LD_Windows_Pairwise.R ngsLD_"${NAME}"_"${FILE}"_Updated.tsv ngsLD_"${NAME}"_"${FILE}"_1000Kb_Windows_Mean

done < $CHR
