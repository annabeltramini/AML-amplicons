# AML-amplicons
This contains all the code needed to run my BSc disseration project, which analyses the presence of amplicons in AML patients

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

## Setting up Amplicon Classifier
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
## Setting up CNVkit
Here is its github page: <a href="https://github.com/etal/cnvkit"> CNVkit </a> with precise instructions. Here is the code that I ran.
```shell
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda create --name cnvkit
source activate cnvkit
conda install cnvkit
```

## Wrapping up
This is all the code you need to have pre-installed run my pipeline on Rosalind. Most likely, when you run it for the first time, it will not run. The reason is that I do not think you have the permission (yet) to access some of the files you need. When you do run it for the first time, whenever you get the error message "FileNotFound" or "PemissionDenied" check:
1. That you changed the path to the one in your folders instead of mine (whenever it starts with /scratch/users/k1921453, replace the K number to yours). If that is not the case:
2. Message Nogay and tell him what file you need access to. Thankfully he has endless patience. I had to do this around 10 times.
