#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=
#SBATCH --array=

set -e
set -u
set -o pipefail

### Script 6 - Mapping ###

## NOTE: script will stop at Picard ValidateSamFile steps if warnings/errors found

# Requires: sequencing files (FASTQ) and genome file (FASTA and index)

## Variables:
WORKDIR= # PATH to working directory
SAMPLE=$(head -"$SLURM_ARRAY_TASK_ID" Sample_List.tsv | tail -1 | cut -f 1) 
ID=$(head -"$SLURM_ARRAY_TASK_ID" Sample_List.tsv | tail -1 | cut -f 2 | cut -f 2-3 -d "_")
LB=$(head -"$SLURM_ARRAY_TASK_ID" Sample_List.tsv | tail -1 | cut -f 2 | cut -f 1 -d "_")
GENOME="${WORKDIR}"/REF.fasta
THREADS= # number of threads (cpus-per-task)

## BWA - Mapping reads to reference genome:
source activate bwa

mkdir -p "${WORKDIR}"/BWA-MEM/

# For -R (Read Group) the ID is Flowcell and Lane (from CSS Report), the SM is sample name, and the LB is library

# Paired-end:
bwa mem \
  -t "${THREADS}" \
  -R "$(echo "@RG\tID:$ID\tSM:$SAMPLE\tLB:$LB")" \
  "${GENOME}" \
  "${WORKDIR}"/Adapter_Removal/Adapter_Removal_"${SAMPLE}".pair1.truncated.gz \
  "${WORKDIR}"/Adapter_Removal/Adapter_Removal_"${SAMPLE}".pair2.truncated.gz \
  | samtools sort \
  -@ "${THREADS}" \
  -n \
  -O bam \
  -o "${WORKDIR}"/BWA-MEM/"${SAMPLE}"_PE_Alignment_nsort.bam -

# Collapsed:
bwa mem \
  -t "${THREADS}" \
  -R "$(echo "@RG\tID:$ID\tSM:$SAMPLE\tLB:$LB")" \
  "${GENOME}" \
  "${WORKDIR}"/Adapter_Removal/Adapter_Removal_"${SAMPLE}".collapsed.gz \
  | samtools sort \
  -@ "${THREADS}" \
  -n \
  -O bam \
  -o "${WORKDIR}"/BWA-MEM/"${SAMPLE}"_COL_Alignment_nsort.bam -

## Picard - FixMateInformation and ValidateSamFile:
source activate Picard

# Paired-end:
mkdir -p "${WORKDIR}"/Picard/

picard FixMateInformation \
  -I "${WORKDIR}"/BWA-MEM/"${SAMPLE}"_PE_Alignment_nsort.bam \
  -O "${WORKDIR}"/Picard/"${SAMPLE}"_PE_Alignment_FixMateInfo.bam \
  --ADD_MATE_CIGAR true \
  --ASSUME_SORTED true \
  --SORT_ORDER coordinate \
  --CREATE_INDEX true

picard ValidateSamFile \
  -I "${WORKDIR}"/Picard/"${SAMPLE}"_PE_Alignment_FixMateInfo.bam \
  -O "${WORKDIR}"/Picard/"${SAMPLE}"_PE_Alignment_FixMateInfo_ValidateSamFile.txt \
  -MODE SUMMARY \
  -INDEX_VALIDATION_STRINGENCY EXHAUSTIVE \

# Collapsed:
picard FixMateInformation \
  -I "${WORKDIR}"/BWA-MEM/"${SAMPLE}"_COL_Alignment_nsort.bam \
  -O "${WORKDIR}"/Picard/"${SAMPLE}"_COL_Alignment_FixMateInfo.bam \
  --ADD_MATE_CIGAR true \
  --ASSUME_SORTED true \
  --SORT_ORDER coordinate \
  --CREATE_INDEX true

picard ValidateSamFile \
  -I "${WORKDIR}"/Picard/"${SAMPLE}"_COL_Alignment_FixMateInfo.bam \
  -O "${WORKDIR}"/Picard/"${SAMPLE}"_COL_Alignment_FixMateInfo_ValidateSamFile.txt \
  -MODE SUMMARY \
  -INDEX_VALIDATION_STRINGENCY EXHAUSTIVE

## Samtools - calmd:
source activate samtools

mkdir -p "${WORKDIR}"/Samtools/

# Paired-end:
samtools calmd \
  -@ "${THREADS}" \
  -b "${WORKDIR}"/Picard/"${SAMPLE}"_PE_Alignment_FixMateInfo.bam \
  "${GENOME}" \
  > "${WORKDIR}"/Samtools/"${SAMPLE}"_PE_Alignment_calmd.bam

# Collapsed:
samtools calmd \
  -@ "${THREADS}" \
  -b "${WORKDIR}"/Picard/"${SAMPLE}"_COL_Alignment_FixMateInfo.bam \
  "${GENOME}" \
  > "${WORKDIR}"/Samtools/"${SAMPLE}"_COL_Alignment_calmd.bam


## Picard - MarkDuplicates (Paired-End):
source activate Picard

picard MarkDuplicates \
  -I "${WORKDIR}"/Samtools/"${SAMPLE}"_PE_Alignment_calmd.bam \
  -O "${WORKDIR}"/Picard/"${SAMPLE}"_PE_Alignment_MarkDuplicates.bam \
  -M "${WORKDIR}"/Picard/"${SAMPLE}"_PE_Alignment_MarkDuplicates_Metrics.txt \
  --REMOVE_DUPLICATES TRUE \
  --ASSUME_SORT_ORDER coordinate


## Paleomix - Remove duplicate collapsed reads (Collapsed):
mkdir -p "${WORKDIR}"/Paleomix/

paleomix rmdup_collapsed \
  --remove-duplicates \
  < "${WORKDIR}"/Samtools/"${SAMPLE}"_COL_Alignment_calmd.bam \
  > "${WORKDIR}"/Paleomix/"${SAMPLE}"_COL_Alignment_rmdup_collapsed.bam 


## Samtools - Index
source activate samtools

# Paired-end:
samtools index -@ "${THREADS}" "${WORKDIR}"/Picard/"${SAMPLE}"_PE_Alignment_MarkDuplicates.bam

# Collapsed:
samtools index -@ "${THREADS}" "${WORKDIR}"/Paleomix/"${SAMPLE}"_COL_Alignment_rmdup_collapsed.bam


## mapDamage:
source activate mapDamage2

mkdir -p "${WORKDIR}"/mapDamage/

# Paired-end:
mapDamage \
  -i "${WORKDIR}"/Picard/"${SAMPLE}"_PE_Alignment_MarkDuplicates.bam \
  -r "${GENOME}" \
  --rescale \
  -d "${WORKDIR}"/mapDamage/"${SAMPLE}"_PE_mapDamage 

mkdir -p "${WORKDIR}"/mapDamage/Stats_out_MCMC_post_pred_plots/

cp "${WORKDIR}"/mapDamage/"${SAMPLE}"_PE_mapDamage/Stats_out_MCMC_post_pred.pdf "${WORKDIR}"/mapDamage/Stats_out_MCMC_post_pred_plots/"${SAMPLE}"_PE_Stats_out_MCMC_post_pred.pdf

# Collapsed:
mapDamage \
  -i "${WORKDIR}"/Paleomix/"${SAMPLE}"_COL_Alignment_rmdup_collapsed.bam \
  -r "${GENOME}" \
  --rescale \
  -d "${WORKDIR}"/mapDamage/"${SAMPLE}"_COL_mapDamage 

cp "${WORKDIR}"/mapDamage/"${SAMPLE}"_COL_mapDamage/Stats_out_MCMC_post_pred.pdf "${WORKDIR}"/mapDamage/Stats_out_MCMC_post_pred_plots/"${SAMPLE}"_COL_Stats_out_MCMC_post_pred.pdf

## Samtools View and Index:
source activate samtools

# Paired-end:
samtools view -f 0x2 -b "${WORKDIR}"/mapDamage/"${SAMPLE}"_PE_mapDamage/*.rescaled.bam  > "${WORKDIR}"/Samtools/"${SAMPLE}"_PE_mapDamage_view.rescaled.bam

samtools index -@ "${THREADS}" "${WORKDIR}"/Samtools/"${SAMPLE}"_PE_mapDamage_view.rescaled.bam

# Collapsed:
samtools index -@ "${THREADS}" "${WORKDIR}"/mapDamage/"${SAMPLE}"_COL_mapDamage/*.rescaled.bam


## Picard - ValidateSamFile
source activate Picard

# Paired-end:
picard ValidateSamFile \
  -I "${WORKDIR}"/Samtools/"${SAMPLE}"_PE_mapDamage_view.rescaled.bam \
  -O "${WORKDIR}"/Picard/"${SAMPLE}"_PE_Alignment_view_rescaled_ValidateSamFile.txt \
  -MODE SUMMARY \
  -INDEX_VALIDATION_STRINGENCY EXHAUSTIVE

# Collapsed:
picard ValidateSamFile \
  -I "${WORKDIR}"/mapDamage/"${SAMPLE}"_COL_mapDamage/*.rescaled.bam \
  -O "${WORKDIR}"/Picard/"${SAMPLE}"_COL_Alignment_rescaled_ValidateSamFile.txt \
  -MODE SUMMARY \
  -INDEX_VALIDATION_STRINGENCY EXHAUSTIVE


## Samtools - Merge paired-end and collapsed BAM files:
source activate samtools

mkdir -p "${WORKDIR}"/Final_BAM/

samtools merge \
  -@ "${THREADS}" \
  "${WORKDIR}"/Final_BAM/"${SAMPLE}"_merged_final.bam \
  "${WORKDIR}"/Samtools/"${SAMPLE}"_PE_mapDamage_view.rescaled.bam \
  "${WORKDIR}"/mapDamage/"${SAMPLE}"_COL_mapDamage/*.rescaled.bam 

## Samtools - Index merged BAM file:
source activate samtools

samtools index -@ "${THREADS}" "${WORKDIR}"/Final_BAM/"${SAMPLE}"_merged_final.bam

# Samtools - Depth and Stats
samtools depth \
  -a "${WORKDIR}"/Final_BAM/"${SAMPLE}"_merged_final.bam \
  | awk '{c++;s+=$3}END{print s/c}' \
  > "${WORKDIR}"/Samtools/"${SAMPLE}"_merged_final_samtools_depth.txt

samtools stats \
  -@ "${THREADS}" \
  "${WORKDIR}"/Final_BAM/"${SAMPLE}"_merged_final.bam \
  > "${WORKDIR}"/Samtools/"${SAMPLE}"_merged_final_samtools_stats.txt

## Qualimap:
source activate Qualimap

mkdir -p "${WORKDIR}"/Qualimap/

qualimap bamqc \
  -bam "${WORKDIR}"/Final_BAM/"${SAMPLE}"_merged_final.bam \
  -outdir "${WORKDIR}"/Qualimap/ \
  -outfile "${SAMPLE}"_Qualimap 


## Remove mapDamage rescaled BAM files (comment out if needed)

#rm "${WORKDIR}"/mapDamage/"${SAMPLE}"_PE_mapDamage/*.rescaled.bam
#rm "${WORKDIR}"/mapDamage/"${SAMPLE}"_COL_mapDamage/*.rescaled.bam

### End of Pipeline: ###
echo "5X_Mapping: Completed"
