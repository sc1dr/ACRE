#!/bin/bash

#$ -cwd

#$ -l h_rt=00:30:00

#$ -l nodes=1

#$ -l h_vmem=4G

module purge
module add test ansys/2023R1
module add matlab
module add user
export ANSYSLMD_LICENSE_FILE=1055@<license>

matlab -nodisplay -batch Parametric_Study > MATLAB_Output.txt
