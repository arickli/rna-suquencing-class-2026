# rna-suquencing-class-2026


pwd: /data/users/arickli/rna-seq-class

containers used:
FastQC 	        /containers/apptainer/fastqc-0.12.1.sif                         fastqc v0.12.1
multiqc         /containers/apptainer/multiqc-1.19.sif                          multiqc v1.19
fastp           /containers/apptainer/fastp_0.24.1.sif                          fastp v0.24.1
Hisat2 	        /containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif      Container with samtools 1.20 and hisat2 2.2.1 installed
Samtools 	    /containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif      Container with samtools 1.20 and hisat2 2.2.1 installed
featureCounts 	/containers/apptainer/subread_2.0.6.sif                         subread v2.0.6

-----------
Data from the README of the reads folder:
Tissue: Blood
Table describing experimental groups for each sample. Samples are either from wildtype (WT) mice or from double-knockout (DKO) mice. 
Since the reads were produced in paired-end mode, there are 2 files per sample, with read 1 and read 2 respectively.

Sample = ID as it is in the fastq file name
Case = Infected
Control = Uninfected
WT = Wildtype
DKO = Double-Knockout

Sample  Group
SRR7821949      Blood_WT_Case   0
SRR7821950      Blood_WT_Case   1
SRR7821951      Blood_WT_Case   2
SRR7821952      Blood_WT_Case   3
SRR7821953      Blood_WT_Case   4
SRR7821968      Blood_WT_Control    5
SRR7821969      Blood_WT_Control    6
SRR7821970      Blood_WT_Control    7
SRR7821954      Blood_DKO_Case  8
SRR7821955      Blood_DKO_Case  9
SRR7821956      Blood_DKO_Case  10
SRR7821957      Blood_DKO_Case  11
SRR7821971      Blood_DKO_Control   12
SRR7821972      Blood_DKO_Control   13
SRR7821973      Blood_DKO_Control   14
-----------


2026/11/03
Used fastqc.slurm and multiqc.slurm on the blood datasets

2026/11/06
Used fastp.slurm to preprocess the raw reads
Then again used fastqc.slurm and multiqc.slurm on the preprocessed reads
Blasted the overrepresented sequences from the multiqc on the ncbi website with blastn (standart parameters) and filtered for the top 10 hits per sequence. 
    All but two sequences are hits for ribosomal rna
    seq_12 has different results but seems to be a virus
    seq_17 seems to be Apodemus sylvaticus 5'-aminolevulinate synthase 2 (Alas2) transcript variant 3 or 6

2026/11/10
downloaded the reference files (.fa.gz and .gtf.gz) and tested them for completeness (sum of the files)
Used hisat2-index.slurm to index the downloaded mouse reference genome with the downloaded .gtf.gz file
Used mapping-and-sorting.slurm to map all the files to the reference sequence (hisat2) and then converted it to a .bam file (samtools), then sorted the reads by genomic coordinates (samtools) and then indexed the reads (samtools).
The error files from the mapping-and-sorting.slurm were copied into a summary table using the scripts sort_mapping_statistics.sh

2026/11/13
performed the counting of the reads using the featureCounts.slurm script