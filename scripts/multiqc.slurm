#!/usr/bin/env bash

#SBATCH --job-name=multiqc

#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1000M
#SBATCH --time=02:00:00

#SBATCH --partition=pibu_el8
#SBATCH --mail-user=andrin.rickli@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/arickli/rna-seq-class/output/multiqc/output_fastqc_%j_%x.o
#SBATCH --error=/data/users/arickli/rna-seq-class/output/multiqc/error_fastqc_%j_%x.e


OUTDIR="/data/users/arickli/rna-seq-class/output/fastqc_20261106"
MULTIQC_DIR="/data/users/arickli/rna-seq-class/output/multiqc_20261106"

mkdir -p "$MULTIQC_DIR"

apptainer exec \
  --bind /data \
  /containers/apptainer/multiqc-1.19.sif \
  multiqc "$OUTDIR" -o "$MULTIQC_DIR"