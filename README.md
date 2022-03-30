# AML-amplicons
This contains all the code needed to run my BSc disseration project, which analyses the presence of amplicons in AML patients

## Setting up
### Rosalind
The first step is to create your Rosalind login, with instructions here: <a href="https://rosalind.kcl.ac.uk/hpc/access/"> Rosalind access </a>

### Setting up Amplicon Architect
The next step is to set up Amplicon Architect on your Rosalind account. The main instructions can be found here: <a href="https://github.com/virajbdeshpande/AmpliconArchitect"> Amplicon Architect Github Page </a> . However, it is important that you know that we cannot use "docker" on Rosalind (i.e. it cannot be installed in it because of some safety issues). Therefore, skip any step that mentions docker. Because of this, our steps for the "Prepare AA" script will also be slightly different. 

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

Then: \n
3. Load singularity \n
4. Source the AA code from github \n
5. Save the variable AA to contain the path to the script \n

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
