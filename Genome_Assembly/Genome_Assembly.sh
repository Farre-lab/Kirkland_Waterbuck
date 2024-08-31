#!/bin/bash

#SBATCH --partition=
#SBATCH --time=UNLIMITED
#SBATCH --mem=
#SBATCH --cpus-per-task=

### Pipeline for HiFi Long-Read Genome Assembly
# Edit parameters for your genome.

BAM1= # HiFi reads (e.g. Waterbuck_1.bam)
BAM2= # HiFi reads (e.g. Waterbuck_2.bam)
NAME1= # Output name (e.g. Waterbuck_1)
NAME2= # Output name (e.g. Waterbuck_2)
ASSEMBLY= # Output name of assembly (e.g. Waterbuck)
THREADS= # no. of threads / cpus-per-task

# Samtools: BAM to FASTQ

source activate samtools 

samtools fastq -0 "${NAME1}".fastq "${BAM1}"
samtools fastq -0 "${NAME2}".fastq "${BAM2}"

# QC

mkdir -p FASTQC

fastqc "${NAME1}".fastq -o FASTQC
fastqc "${NAME2}".fastq -o FASTQC

mkdir -p NanoPlot

source activate NanoPlot

NanoPlot -t "${THREADS}" --N50 --fastq "${NAME1}".fastq \
    "${NAME2}".fastq -o NanoPlot

# Cutadapt - Adapter trimming

source activate cutadapt

cutadapt -u 20 -m 5000 -M 30000 -O 35 -e 0.1 --discard-trimmed \
    -b ATCTCTCTCAACAACAACAACGGAGGAGGAGGAAAAGAGAGAGAT \
    -b ATCTCTCTCTTTTCCTCCTCCTCCGTTGTTGTTGTTGAGAGAGAT \
    -o "${NAME1}"_trimmed.fastq.gz \
    "${NAME1}".fastq

cutadapt -u 20 -m 5000 -M 30000 -O 35 -e 0.1 --discard-trimmed \
    -b ATCTCTCTCAACAACAACAACGGAGGAGGAGGAAAAGAGAGAGAT \
    -b ATCTCTCTCTTTTCCTCCTCCTCCGTTGTTGTTGTTGAGAGAGAT \
    -o "${NAME2}"_trimmed.fastq.gz \
    "${NAME2}".fastq

# QC - Trim

mkdir -p FASTQC_Trimmed

fastqc "${NAME1}"_trimmed.fastq.gz -o FASTQC_Trimmed
fastqc "${NAME2}"_trimmed.fastq.gz -o FASTQC_Trimmed

mkdir -p NanoPlot_Trimmed

source activate NanoPlot

NanoPlot -t 2 --N50 --fastq "${NAME1}"_trimmed.fastq.gz \
    "${NAME2}"_trimmed.fastq.gz -o NanoPlot_Trimmed

# Genome profilie analysis (estimating genome size)
# Meryl - generate K-mer profile

source activate Meryl

meryl union-sum \
    output Meryl_union-sum \
    [count k=32 "${NAME1}"_trimmed.fastq.gz output Meryl_"${NAME1}"_trimmed] \
    [count k=32 "${NAME2}"_trimmed.fastq.gz output Meryl_"${NAME2}"_trimmed]

meryl histogram Meryl_union-sum > Meryl_Histogram.tsv

# GenomeScope2 - genome profiling

mkdir -p GenomeScope2

source activate GenomeScope2

genomescope.R -i Meryl_Histogram.tsv -o GenomeScope2 -k 32 --testing

# Estimated Genome Size: summary.txt file (Genome Size Haploid, Max)
# Estimated Max Read Depth: take column 3 in the testing.tsv file, times value by 1.5, and then times by 3
# Tranition parameter (between diploid and haploid coverage depths): take column 3 in the testing.tsv file and times value by 1.5

# Genome Assembly - Hifiasm

hifiasm -o "${ASSEMBLY}" -t 32 -l 0 \
    --purge-max 45 --primary -z 20 \
    "${NAME1}"_trimmed.fastq.gz \
    "${NAME2}"_trimmed.fastq.gz 

# Convert to FASTA:
awk '/^S/{print ">"$2;print $3}' "${ASSEMBLY}".a_ctg.gfa > "${ASSEMBLY}".a_ctg.fasta

awk '/^S/{print ">"$2;print $3}' "${ASSEMBLY}".p_ctg.gfa > "${ASSEMBLY}".p_ctg.fasta

# QUAST:

mkdir QUAST

source activate QUAST

python quast --memory-efficient  --threads 10 --eukaryote \
    --large --est-ref-size 3062577681 -o QUAST \
    "${ASSEMBLY}".p_ctg.fasta "${ASSEMBLY}".a_ctg.fasta

# BUSCO:

source activate BUSCO

busco -i "${ASSEMBLY}".p_ctg.fasta -l mammalia_odb10 \
    -o BUSCO_Primary1 -m genome --cpu 10 -f --tar ;

# Merqury:

source activate Merqury

./merqury.sh Meryl_union-sum.meryl \
    "${ASSEMBLY}".p_ctg.fasta \
    "${ASSEMBLY}".a_ctg.fasta \
    merqury
