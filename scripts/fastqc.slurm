#!/usr/bin/env bash

#SBATCH --job-name=fastqc

#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1000M
#SBATCH --time=01:00:00

#SBATCH --partition=pibu_el8
#SBATCH --mail-user=andrin.rickli@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/arickli/rna-seq-class/output/fastqc/output_fastqc_%j_%x.o
#SBATCH --error=/data/users/arickli/rna-seq-class/output/fastqc/error_fastqc_%j_%x.e


DATASTORE="/data/courses/rnaseq_course/toxoplasma_de/reads_Blood"
OUTDIR="/data/users/arickli/rna-seq-class/output/fastqc/"

mkdir -p "$OUTDIR"

apptainer exec \
  --bind /data \
  /containers/apptainer/fastqc-0.12.1.sif \
  fastqc \
  --threads 1 \
  --outdir "$OUTDIR" \
  "$DATASTORE"/*.fastq.gz