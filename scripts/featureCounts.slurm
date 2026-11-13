#!/usr/bin/env bash

#SBATCH --job-name=featureCount
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=1000M
#SBATCH --time=02:00:00

#SBATCH --partition=pibu_el8
#SBATCH --mail-user=andrin.rickli@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/arickli/rna-seq-class/output/counts/output_featureCount_%j.o
#SBATCH --error=/data/users/arickli/rna-seq-class/output/counts/error_featureCount_%j.e



mkdir -p output/counts


apptainer exec -B /data /containers/apptainer/subread_2.0.6.sif \
  featureCounts \
  -T $SLURM_CPUS_PER_TASK \
  -p \
  --countReadPairs \
  -s 2 \
  -t exon \
  -g gene_id \
  -a ref-genome/Mus_musculus.GRCm39.116.gtf.gz \
  -o output/counts/gene_counts.txt \
  output/mapping/*.sorted.bam