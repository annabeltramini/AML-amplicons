#!/bin/bash -l
#SBATCH --job-name=AA_len
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --partition=celgene
#SBATCH --ntasks=8
#SBATCH --mem=128G

#condanf
#conda activate cnvkit
module load apps/singularity/3.5.3

SAMPLE=$1
mkdir -p /scratch/users/k1921453/cases/${SAMPLE}/AA_results/
mkdir -p /scratch/users/k1921453/cases/${SAMPLE}/AA_results/cnvkit

#cnvkit.py batch /scratch/groups/celgene/SAM-AML/data/cases/${SAMPLE}/${SAMPLE}.bam -n \
#--targets /scratch/groups/celgene/khp_bms/resources/hg38/genome/wgs_calling_regions.hg38.bed \
#--method wgs \
#--annotate /scratch/groups/celgene/SAM-AML/analysis/cases/aa_test/manual_cnvkit/refFlat.txt \
#--fasta /scratch/groups/celgene/khp_bms/resources/hg38/genome/Homo_sapiens_assembly38.fasta \
#--output-dir /scratch/groups/celgene/SAM-AML/analysis/cases/${SAMPLE}/AA_results/cnvkit \
#-p 8

#cd /scratch/groups/celgene/SAM-AML/analysis/cases/${SAMPLE}/AA_results/cnvkit/

#python /scratch/groups/celgene/sys/scripts/bioinformatics/PrepareAA/scripts/convert_cns_to_bed.py \
#--cns_file /scratch/groups/celgene/SAM-AML/analysis/cases/${SAMPLE}/AA_results/cnvkit/${SAMPLE}.cns

awk '{if($5 > 4.5 && $3-$2 > 20000) print $0}' /scratch/groups/celgene/SAM-AML/analysis/cases/${SAMPLE}/AA_results/cnvkit/${SAMPLE}_ESTIMATED_PLOIDY_CORRECTED_CN.bed > \
/scratch/users/k1921453/cases/${SAMPLE}/AA_results/cnvkit/${SAMPLE}_CNfiltered.bed

$AA --bam /scratch/groups/celgene/SAM-AML/data/cases/${SAMPLE}/${SAMPLE}.bam \
--bed /scratch/users/k1921453/cases/${SAMPLE}/AA_results/cnvkit/${SAMPLE}_CNfiltered.bed \
--ref GRCh38 \
--out /scratch/users/k1921453/cases/${SAMPLE}/AA_results/${SAMPLE}

#conda deactivate
