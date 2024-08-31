### Quality Control  

**1_FASTQC.sh** - runs FASTQC on FASTQ files

**2_MultiQC.sh** - combines FASTQC results with MultiQC

### Adapter Trimming  

**3_Adapter_Removal.sh** - removes Illumina adapters, low quality bases from FASTQ files, and collapses mates. FASTQC rerun on trimmed files.

**4_MultiQC_Trim.sh** - MutltiQC of trimmed files.

### Mapping Pipeline  

**5_Index.sh** - Indexes reference FASTA file.

**6_Mapping.sh** - Mapping pipeline. Paired-end and collapsed mates are mapped separately and then merged at the end.
