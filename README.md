# AML-amplicons
This contains all the code needed to run my BSc disseration project, which analyses the presence of amplicons in AML patients

## Setting up
### Rosalind
The first step is to create your Rosalind login, with instructions here: <a href="https://rosalind.kcl.ac.uk/hpc/access/"> Rosalind access </a>

### Setting up Amplicon Architect
The next step is to set up Amplicon Architect on your Rosalind account. The main instructions can be found here: <a href="https://github.com/virajbdeshpande/AmpliconArchitect"> Amplicon Architect Github Page </a> . However, it is important that you know that we cannot use "docker" on Rosalind (i.e. it cannot be installed in it because of some safety issues). Therefore, skip any step that mentions docker. Because of this, our steps for the "Prepare AA" script will also be slightly different. 

So, go to the AA github page and:
1. Get a mosek license
2. Download AA data repositories and set environment variable AA_DATA_REPO.

Then:
3. Load singularity
4. Source the AA code from github
5. Save the variable AA to contain the pact to the script

Code for steps 3-5:
```unix
#See what modules are available on rosalind
   35  module avail
#Load singularity
   36  module load apps/singularity/3.5.3 

#load the "docker" imge but use singlarity instead
   37  singularity pull docker://virajbdeshpande/ampliconarchitect
#Source the code from github
   39  git clone https://github.com/virajbdeshpande/AmpliconArchitect.git

#Save the variable AA to contain the path to the script
   41  echo export AA=/scratch/users/k1921453/AA_repo/AmpliconArchitect/docker/run_aa_docker.sh >> ~/.bashrc
   42  source ~/.bashrc
   43  echo $AA #check
```
