#!/usr/bin/env bash

#SBATCH --job-name=mapping_array
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=25G
#SBATCH --time=04:00:00
#SBATCH --array=0-14

#SBATCH --partition=pibu_el8
#SBATCH --mail-user=andrin.rickli@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/arickli/rna-seq-class/output/mapping/output_mapping_%A_%a.o
#SBATCH --error=/data/users/arickli/rna-seq-class/output/mapping/error_mapping_%A_%a.e

READDIR="/data/users/arickli/rna-seq-class/output/fastp"
OUTDIR="/data/users/arickli/rna-seq-class/output/mapping"
INDEX_BASE="/data/users/arickli/rna-seq-class/ref-genome/Mus_musculus.GRCm39"

mkdir -p "$OUTDIR"

# Grab all R1 cleaned files into a bash array and select the one for this task ID
R1_FILES=(${READDIR}/*_1.clean.fastq.gz)
MATE1=${R1_FILES[$SLURM_ARRAY_TASK_ID]}
MATE2=${MATE1/_1.clean.fastq.gz/_2.clean.fastq.gz}

# Extract sample name (e.g., SRR7821949)
SAMPLE=$(basename "$MATE1" _1.clean.fastq.gz)

apptainer exec --bind /data/,$SCRATCH /containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif /bin/bash -c "hisat2 \
    -p $SLURM_CPUS_PER_TASK \
    -x $INDEX_BASE \
    -1 $MATE1 \
    -2 $MATE2 \
    --rna-strandness RF \
    | samtools sort \
    -m 4G -@ $SLURM_CPUS_PER_TASK \
    -T ${SCRATCH}/${SAMPLE}_tmp \
    -o ${OUTDIR}/${SAMPLE}.sorted.bam##idx##${OUTDIR}/${SAMPLE}.sorted.bam.bai \
    --write-index"