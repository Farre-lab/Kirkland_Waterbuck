#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=200G
#SBATCH --cpus-per-task=32

### 1 - LD:

angsd=/PATH/TO/ANGSD
ngsLD=/PATH/TO/ngsLD

FASTA=REF.fasta
FAI=REF.fasta.fai
SF=SITES.regions
BAM=bam_list_common.txt
CHR=chrs.txt
NAME=Common
IND=52 # no. individuals
RND=0.01  ### randomly sample X% of SNP pairs

mkdir -p LD_"${NAME}"

while read FILE; do

"${angsd}" -bam "${BAM}" \
    -anc "${FASTA}" \
    -out LD_"${NAME}"/LD_"${NAME}"_"${FILE}" \
    -r "${FILE}" \
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
    --max_kb_dist 1000 \
    --posH LD_"${NAME}"/LD_"${NAME}"_"${FILE}".mafs.pos \
    --log_scale T \
    --n_threads 32 \
    --n_ind "${IND}" \
    --n_sites "${NSITES}" \
    --rnd_sample "${RND}" \
    --out ngsLD_"${NAME}"_"${FILE}"

Rscript LD_Windows.R ngsLD_"${NAME}"_"${FILE}" "${FILE}" ngsLD_"${NAME}"_"${FILE}"_100Kb_Windows # mean LD (r2) in 100 Kb windows

tail -n +2 ngsLD_"${NAME}"_"${FILE}"_100Kb_Windows.tsv >> ngsLD_"${NAME}"_Combined_100Kb_Windows.tsv # all chrs

done < $CHR
