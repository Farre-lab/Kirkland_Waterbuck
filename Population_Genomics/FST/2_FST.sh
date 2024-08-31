#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=
#SBATCH --array=

## FST - Script 2 ##
# Requires two column tab-del table for each pairwise FST: pop_list_pairwise.txt

realSFS=/PATH/TO/realSFS
POP1=$(head -"$SLURM_ARRAY_TASK_ID" pop_list_pairwise.txt | tail -1 | cut -f 1)
POP2=$(head -"$SLURM_ARRAY_TASK_ID" pop_list_pairwise.txt | tail -1 | cut -f 2)

## Added -fold 1 as using the reference as ancestral state.

mkdir -p Pairwise

$realSFS -P 20 "${POP}"/"${POP1}".saf.idx "${POP}"/"${POP2}".saf.idx -fold 1 > \
    Pairwise/"${POP1}"_"${POP2}".folded.sfs

$realSFS fst index -P 20 -whichFst 1 -fold 1 "${POP}"/"${POP1}".saf.idx "${POP}"/"${POP2}".saf.idx \
    -sfs Pairwise/"${POP1}"_"${POP2}".folded.sfs -fstout Pairwise/"${POP1}"_"${POP2}".folded

$realSFS fst stats  Pairwise/"${POP1}"_"${POP2}".folded.fst.idx

$realSFS fst stats2 Pairwise/"${POP1}"_"${POP2}".folded.fst.idx -win 10000 -step 10000 > \
    Pairwise/"${POP1}"_"${POP2}".folded.fst.win10K

