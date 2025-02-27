# ACRE - Automated CFD Characterisation for Low Temperature Kientics
## Author: Luke Driver (scldr@leeds.ac.uk) - University of Leeds PhD Student

## This is a MATLAB Toolbox to be run on Linux that uses Ansys and its respective scripting languages to automate the entire CFD workflow, this includes geometry, meshing, solution setup and data output. 
Note this toolbox only works with Linux, and requires Ansys 2021 R2 or later (ICEM and Fluent)

Users have the ability to change to change the following parameters:
- Boundary Conditions - Reservoir pressure, vacuum chamber pressure, temperature
- Bath Gas - Limited to Nitrogen, Helium and Argon at the moment
- Nozzle Geometry, a XY file of the nozzle coordinates has to be supplied.
- Chamber Geometry, the chamber length and radius can be changed.
- Reservoir Geometry, the reservoir length and radius can be changed.
- Inlet Size
- Outlet Size and Position in the reactor
  
The code will then take these parameters in and will alter the script files, effectively automating the entire CFD process for the user.
## How to Install the ACRE framework to the HPC
clone this repository onto your HPC using ```git clone https://github.com/sc1dr/ACRE.git ```  

## For a detailed guide on how to use the framework, look at the 'Detailed_User_Guide.pdf' doccument. but the short version is as follows:
Open up 'cfd_blackbox.m' and find the following line of code (there will be multiple of the same line):

```ScriptChanger(ICEM_Script_File, 270, ['ic_exec /apps/applications/ansys/2023R1/1/default/v212/icemcfd/linux64_amd/icemcfd/output-interfaces/fluent6 -dom $script_dir/Meshing/project1.uns -b $script_dir/Meshing/project1.fbc -dim2d $script_dir/' Solution_Folder '/Mesh']);```

You need to change ```/apps/applications/ansys/2023R1/1/default/v212/icemcfd/linux64_amd/icemcfd/output-interfaces/fluent6``` to match where fluent6 is on your HPC. Ensure that the versions are correct in the code. Once the file path is correct for your HPC you can save this file.

Open up 'nozzle_profile.txt' and input the XY coordiantes of the nozzle profile you are interested in. (X in the first column, Y in the second separated by a tab), save and close.

Open up 'Parametric_Study'm' and you can change the variables to match your specific case. Note you can input mulitple reservoir and chamber pressures for a particular nozzle. For more information read the user guide, save and close, In this please make sure you correctly input the nubmer of cores you will be using on your HPC as it wont work otherwise. Also remember to input the inlet (enterace) diameter of your nozzle to allow the nozzle formatter to work.

You need to make a submission script to run this on your particular HPC. You may need to ask your HPC department to help with this, on an ARC system, the code required to run both the nozzle_formatter.m and Parametric_Study.m is shown in ACRE_ARC4_run.sh

Note that these simulations take ~ 10 mins with the Leeds reservoir and the M2.25 Nozzle using 40 cores. 

## Additional Information
A series of benchmark cases have been added, these are there for you to run on your HPC before you conduct your own studies, please ensure you are getting identical results with the cases here.

For information about mesh dependence, please look in the folder 'Mesh_Independence', this contains the mesh indepdnence results with two different nozzles.

## Have you found a bug?
If you have found something wrong with the code and would like a fix, please report the problem using the issue tab above. Please be specific, if you have any further questions feel feel to email me at scldr@leeds.ac.uk.


