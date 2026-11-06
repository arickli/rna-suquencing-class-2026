# rna-suquencing-class-2026


pwd: /data/users/arickli/rna-seq-class

containers used:
FastQC 	        /containers/apptainer/fastqc-0.12.1.sif                         fastqc v0.12.1
multiqc         /containers/apptainer/multiqc-1.19.sif                          multiqc v1.19
fastp           /containers/apptainer/fastp_0.24.1.sif                          fastp v0.24.1
ncbi blast      /containers/apptainer/blast_2.15.0.sif                          ncbi blast v2.15.0
Hisat2 	        /containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif      Container with samtools 1.20 and hisat2 2.2.1 installed
Samtools 	    /containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif      Container with samtools 1.20 and hisat2 2.2.1 installed
featureCounts 	/containers/apptainer/subread_2.0.6.sif                         subread v2.0.6


2026/11/03
Used fastqc.slurm and multiqc.slurm on the blood datasets

2026/11/06
Used fastp.slurm to preprocess the raw reads
Then again used fastqc.slurm and multiqc.slurm on the preprocessed reads
Blasted the overrepresented sequences from the multiqc on the ncbi website with blastn and filtered for the top 10 hits per sequence. 
    All but two sequences are hits for ribosomal rna
    seq_12 has different results but seems to be a virus
    seq_17 seems to be Apodemus sylvaticus 5'-aminolevulinate synthase 2 (Alas2) transcript variant 3 or 6
