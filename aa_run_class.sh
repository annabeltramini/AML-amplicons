#!/bin/bash -l
#SBATCH --job-name=AA_class
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --partition=celgene
#SBATCH --ntasks=8
#SBATCH --mem=128G

conda activate AA_class_conda

mkdir /scratch/users/k1921453/cases/${SAMPLE}/AA_classifier
cd /scratch/users/k1921453/cases/${SAMPLE}/AA_classifier

/scratch/users/k1921453/AmpliconClassifier/make_input.sh /scratch/users/k1921453/cases/${SAMPLE}/AA_results/ ${SAMPLE}
python /scratch/users/k1921453/AmpliconClassifier/amplicon_classifier.py --ref GRCh38 --input /scratch/users/k1921453/cases/${SAMPLE}/AA_classifier/${SAMPLE}.input --plotstyle individual > classifier_stdout_${SAMPLE}.log

conda deactivate
