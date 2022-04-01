# AML-amplicons
This contains all the code needed to run my BSc disseration project, which analyses the presence of amplicons in AML patients

#### Table of contents

  * [Explaining the scripts](#explaining-the-scripts---in-progress)
  * [Understanding the outputs](#understanding-the-outputs)
    + [Creating the final table](#creating-the-final-table)
  * [Setting up](#setting-up)
    + [Rosalind](#rosalind)
    + [Setting up Amplicon Architect](#setting-up-amplicon-architect)
    + [Setting up Amplicon Classifier](#setting-up-amplicon-classifier)
    + [Setting up CNVkit](#setting-up-cnvkit)
    + [Wrapping up](#wrapping-up)

## Explaining the scripts - in progress
In this repository, you should find 5 files. these are the ones I ran in my pipeline. You can submit them as slurm job by using *sbatch -p celgene /path/to/file.sh SAMPLE_NAME*. In order to run these, you will need to have completed the "setting up" steps below.

- **aa_run_cnv.sh**: This file takes as an input the name of the sample to analyse, and performs CNVkit first, and Amplicon Architect second. It is probably good to start by running this file, as most bugs will probably be at this stage, before AA classifier.
- **aa_run_nocnv.sh**: This file takes as an input the name of the sample to analyse, and performs the Amplicon Architect algorithm. It is useful for when you have already performed CNVkit and just want to tweak the AA parameters (as CNVkit adds considerable time).
- **aa_run_class.sh**: This file runs only amplicon classifier. It takes less than a minute to run, so you can copy its code and use it on the command line without submitting it as a slurm job if you wish. It takes as an argument the name of the sample
- **aa_run_cnv_class.sh**: This file contains the *final and total pipeline*. I have never run it so do check it for bugs. It takes as an input the name of the sample to analyse and runs CNVkit, AA, and AA classifier. For each sample it creates a folder containing two folders, one called AA_results and the other AA_classifier.

## Understanding the outputs
The ones you most likely are interested in are 
- **SAMPLE-summary.txt** as the output of Amplicon Architect. This has information on all the amplicons identified, including the oncogenes amplified within them and what segments of the genomic DNA they contian, and how many of these amplicons were identified in a sample.
- **SAMPLE-profiles.tsv** ad the output of Amplicon Classifier. This has information on the structure of each amplicon (linear/circular) and it says whether an amplification was invalid. 

### Creating the final table
This table contains the following information:
SAMPLE_ID Total_Amplicons Total_Valid_Amplicons Cyclic_Amplicons  Linear_Amplicons  Complex_Amplicons Invalid_Amplicons Oncogenes 
```shell
echo SAMPLE_ID "\t" Total_Ampicons "\t" Total_Valid_Amplicons "\t" Cyclic_Amplicons "\t" Linear_Amplicons "\t" Complex_Amplicons "\t" Invalid_Amplicons "\t" Oncogenes > amplicon_table.csv
for SAMPLE in $(ls /scratch/users/k1921453/cases | grep -v "TNP")
do
Total_Amplicons=$(grep "Amplicons =" /scratch/users/k1921453/cases/${SAMPLE}/*summary.txt | cut -d "=" -f 2)
Oncogenes=$(grep "Oncogenes" /scratch/users/k1921453/cases/${SAMPLE}/*summary.txt | grep -v "= ,"| cut -d "=" -f 2)
Linear_Amplicons=$(cut -f 3 cases/${SAMPLE}/AA_classifier/*profiles.tsv | sort | uniq -c | grep "Linear amplification" | sed 's/Linear amplification//g')
Cyclic_Amplicons=$(cut -f 3 cases/${SAMPLE}/AA_classifier/*profiles.tsv | sort | uniq -c | grep "Cyclic" | sed 's/Cyclic//g')
Invalid_Amplicons=$(cut -f 3 cases/${SAMPLE}/AA_classifier/*profiles.tsv | sort | uniq -c | grep "No amp/Invalid" | sed 's:No amp/Invalid::g')
Complex_Amplicons=$(cut -f 3 cases/${SAMPLE}/AA_classifier/*profiles.tsv | sort | uniq -c | grep "Complex non-cyclic" | sed 's/Complex non-cyclic//g')
Total_Valid_Amplicons=$(($Linear_Amplicons + $Cyclic_Amplicons + $Complex_Amplicons))
echo -e $SAMPLE "\t" $Total_Ampicons "\t" $Total_Valid_Amplicons "\t" $Cyclic_Amplicons "\t" $Linear_Amplicons "\t" $Complex_Amplicons "\t" $Invalid_Amplicons "\t" $Oncogenes >> my_table_test.csv
```
This will remove the ones that end in -TNP. If you want to keep them you might delete the "grep" step in the for loop line

## Setting up
### Rosalind
The first step is to create your Rosalind login, with instructions here: <a href="https://rosalind.kcl.ac.uk/hpc/access/"> Rosalind access </a>

### Setting up Amplicon Architect
The next step is to set up Amplicon Architect on your Rosalind account. The main instructions can be found here: <a href="https://github.com/virajbdeshpande/AmpliconArchitect"> Amplicon Architect Github Page </a> . However, it is important that you know that we cannot use "docker" on Rosalind (i.e. it cannot be installed in it because of some safety issues). Therefore, skip any step that mentions docker, and we will instead use Singularity. Because of this, our steps for the "Prepare AA" script will also be slightly different. 

So, go to the AA github page and:
1. Get a mosek license

My code:
(make sure to change my K number to yours, and to change any other paths to the files
```shell
#ON MY LAPTOP (NOT ROSALIND)
#Move the licence file from my laptop to Rosalind - change the paths to your own
scp -i ~/.ssh/id_rsa /home/Users/annab/mosek/mosek.lic k1921453@login.rosalind.kcl.ac.uk:/scratch/users/k1921453

#ON ROSALIND
cd /scratch/users/k1921453
mkdir mosek
mv mosek.lic mosek/mosek.lic
export MOSEKLM_LICENCE_FILE=/scratch/users/k1921453/mosek >> ~/.bashrc && source ~/.bashrc 
#^save the path to the parent directory of the licence file as a variable called MOSEKLM_LICENCE FILE
echo $MOSEKLM_LICENCE_FILE
#Echo the variable to check it works
```

2. Download AA data repositories and set environment variable AA_DATA_REPO.
```shell
#ON MY LAPTOP
#Move the GCHr19 file to my rosalind folder
scp -i ~/.ssh/id_rsa /home/Users/annab/Downloads/GChR19.tar.gz k1921453@login.rosalind.kcl.ac.uk:/scratch/users/k1921453

#ON ROSALIND
cd /scratch/users/k1921453
mkdir AA_repo
mv GRCh38.tar.gz AA_repo/

#Unzip the files
cd AA_repo/
gunzip GRCh38.tar.gz #first round of unzipping
tar -xvf GRCh38.tar #second round of unzipping

#save the variable AA_DATA_REPO to contain the path to AA_repo
echo export AA_DATA_REPO=$PWD >> ~/.bashrc
source ~/.bashrc
echo $AA_DATA_REPO #check the variable
```

Then: <br>
3. Load singularity  <br>
4. Source the AA code from github  <br>
5. Save the variable AA to contain the path to the script  <br>

Code for steps 3-5:
```shell
#See what modules are available on rosalind
module avail
#Load singularity
module load apps/singularity/3.5.3 

#load the "docker" imge but use singlarity instead
singularity pull docker://virajbdeshpande/ampliconarchitect
#Source the code from github
git clone https://github.com/virajbdeshpande/AmpliconArchitect.git

#Save the variable AA to contain the path to the script
echo export AA=/scratch/users/k1921453/AA_repo/AmpliconArchitect/docker/run_aa_docker.sh >> ~/.bashrc
source ~/.bashrc
echo $AA #check
```

6. Fix the run_aa_docker.sh file.
This script needs to be modified because it uses a docker image instead of singularity.Therefore open the file: 
```shell
cd PrepareAA/AmpliconArchitect/docker
nano run_aa_docker.sh
```
And comment out the line that starts with "docker" , and instead add the following lines at the end of the file to run singularity:
```shell
#docker run -rm -e AA_DATA_REPO etc. etc.......
SINGULARITYENV_AA_DATA_REPO=/home/data_repo \
SINGULARITYENV_argstring="$argstring" \
singularity exec --bind $AA_DATA_REPO:/home/data_repo \
--bind $BAM_DIR:/home/bam_dir \
--bind $BED_DIR:/home/bed_dir \
--bind $OUT_DIR:/home/output \
--bind $MOSEKLM_LICENSE_FILE:/home/programs/mosek/8/licenses \
/scratch/users/k1921453/AA_repo/ampliconarchitect_latest.sif \
bash /scratch/users/k1921453/AA_repo/AmpliconArchitect/docker/run_aa_script.sh
```
(This is how the end of your file should look like, I am not super sure that I had to add the last couple of lines myself)

### Setting up Amplicon Classifier
Here is its github page: <a href="https://github.com/jluebeck/AmpliconClassifier"> Amplicon Classifier </a> This is a little easier, because we have already downloaded the AA_DATA_REPO. Therefore we only need to clone the github repository and create a conda environment which contains all the python libraries you need. Firstly, however, you need to install conda on ROsalind
```shell
#This creates a folder called AmpliconClassifier in the directory I was in (make sure it's the appropriate one)
git clone https://github.com/jluebeck/AmpliconClassifier.git

#Install conda
module avail
module load devtools/anaconda/2019.3-python3.7.3
conda init

#Create my conda environemnt
conda create --name AA_class_conda
conda install -n AA_class_conda intervaltree
conda install -n AA_class_conda matplotlib

#Whever I need to use amplicon classifier, I need to activate it
conda activate AA_class_conda
```
### Setting up CNVkit
Here is its github page: <a href="https://github.com/etal/cnvkit"> CNVkit </a> with precise instructions. Here is the code that I ran.
```shell
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda create --name cnvkit
source activate cnvkit
conda install cnvkit
```

### Wrapping up
This is all the code you need to have pre-installed run my pipeline on Rosalind. Most likely, when you run it for the first time, it will not run. The reason is that I do not think you have the permission (yet) to access some of the files you need. When you do run it for the first time, whenever you get the error message "FileNotFound" or "PemissionDenied" check:
1. That you changed the path to the one in your folders instead of mine (whenever it starts with /scratch/users/k1921453, replace the K number to yours). If that is not the case:
2. Message Nogay and tell him what file you need access to. Thankfully he has endless patience. I had to do this around 10 times.
