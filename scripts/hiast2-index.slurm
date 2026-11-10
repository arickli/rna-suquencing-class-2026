#!/usr/bin/env bash

#SBATCH --job-name=hisat2_index
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8000M
#SBATCH --time=03:00:00
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=andrin.rickli@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/arickli/rna-seq-class/output/mapping/output_hisat2-index_%j.o
#SBATCH --error=/data/users/arickli/rna-seq-class/output/mapping/error_hisat2-index_%j.e

REFDIR="/data/users/arickli/rna-seq-class/ref-genome"
FASTA_GZ="${REFDIR}/Mus_musculus.GRCm39.dna.primary_assembly.fa.gz"
FASTA="${REFDIR}/Mus_musculus.GRCm39.dna.primary_assembly.fa"
INDEX_BASE="${REFDIR}/Mus_musculus.GRCm39"

# 1. Unzip FASTA if not already unzipped (-k keeps the original .gz file)
if [ ! -f "$FASTA" ]; then
    gunzip -k "$FASTA_GZ"
fi

# 2. Build HISAT2 index
apptainer exec --bind /data/ /containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif \
    hisat2-build -p "$SLURM_CPUS_PER_TASK" "$FASTA" "$INDEX_BASE"