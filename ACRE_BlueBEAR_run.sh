#!/bin/bash

# Icelake nodes = 72 cores, 512GB RAM
# cascadelake nodes = 40  cores, 192GB RAM
# broadwell nodes = 20 cores, 121GB RAM

# This is the number of cores 
#SBATCH --ntasks=1

#This is the wait time (length you want to run for in hh:mm:ss) - The maximum on the website days 10 days (240 hrs)
#SBATCH --time=00:05:00 

#This sends out an email about events regarding job
#SNATCH --mail-type=ALL

# This makesthe script fail on the first error
set -e 

# To load ansys 2023R1 - module load bear-apps/2022a and module load ANSYS/2023R1
# To load ansys 2021R1 - module load ANSYS/2021R1
# To load MATLAB 2022a - module load MATLAB/2022a

# information on parallel fluent jobs
# module load slurm-helpers
# NODEFILE=$(make-nodelist)
# -cnf=${NODEFILE}

module purge; module load bluebear
module load ANSYS/2023R1
module load MATLAB/2022a


matlab -nodisplay -batch Parametric_Study > MATLAB_Output.txt

# to submit on blueBEAR you use sbatch <script name>
# to view status of job you use squeue -j <job number> or you can get more information using scontrol show job <job number>
# to cancel a job you use scancel <job number>
# Each user is limited to 864 cores and 6TB of memory
