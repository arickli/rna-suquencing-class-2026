#!/usr/bin/env bash

#SBATCH --job-name=fastp_array

#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=1000M
#SBATCH --time=01:00:00
#SBATCH --array=0-14

#SBATCH --partition=pibu_el8
#SBATCH --mail-user=andrin.rickli@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/arickli/rna-seq-class/output/fastp/output_fastp_%A_%a.o
#SBATCH --error=/data/users/arickli/rna-seq-class/output/fastp/error_fastp_%A_%a.e


DATASTORE="/data/courses/rnaseq_course/toxoplasma_de/reads_Blood"
OUTDIR="/data/users/arickli/rna-seq-class/output/fastp/"

mkdir -p "$OUTDIR"

# 1. Populate Bash array of Read 1 files
FILES_1=(${DATASTORE}/*_1.fastq.gz)

# 2. Select the current task's Read 1 file
R1="${FILES_1[$SLURM_ARRAY_TASK_ID]}"

# 3. Extract the sample prefix (e.g. SRR7821949 from SRR7821949_1.fastq.gz)
SAMPLE=$(basename "$R1" _1.fastq.gz)

# 4. Construct the matching Read 2 file path
R2="${DATASTORE}/${SAMPLE}_2.fastq.gz"

echo "Task ID $SLURM_ARRAY_TASK_ID: Processing sample ${SAMPLE}"

# 5. Run fastp inside Apptainer
apptainer exec \
  --bind /data \
  /containers/apptainer/fastp_0.24.1.sif \
  fastp \
  -i "$R1" \
  -I "$R2" \
  -o "${OUTDIR}/${SAMPLE}_1.clean.fastq.gz" \
  -O "${OUTDIR}/${SAMPLE}_2.clean.fastq.gz" \
  --thread "${SLURM_CPUS_PER_TASK}" \
  --detect_adapter_for_pe \
  -h "${OUTDIR}/${SAMPLE}_fastp.html" \
  -j "${OUTDIR}/${SAMPLE}_fastp.json"

echo "Finished sample ${SAMPLE}"