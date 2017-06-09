# Python code for millenium cohort
This part of the repository contains python scripts and notebooks to run the 
[UKMovementSensing](https://github.com/NLeSC/UKMovementSensing/) code on the Millenium Cohort data set.
It finds states in the accelerometer data with the unsupervised Hidden Semi-Markov Models.

## Prerequisites
* Python 2.7
* For the notebooks: iPython
* Python package [UKMovementSensing](https://github.com/NLeSC/UKMovementSensing/) (see GitHub page for installation instructions)
* packages from requirements.txt

## Config file
The file `config.yml` defines the directory in which data is stored, as well as all parameters for the HSMM models.

## Scripts
**0_prepare_data.py**: This script does the following things:
* joins wearcodes with the TUD (Time Use Diary) file
* removes accelerometer data where the data is invalid
* mirrors accelerometer data that seems to be of devices worn upside-down
* joins accelerometer data with TUD files.

**1_HSMM** This file trains the HSMM on all data in the *merged* folder

## Notebooks
The notebooks are for analysis of the outcomes of the HSMM model.

**1_HSMM.ipynb** has the same functionality as the script, but shows a few plots.

**2_AnalyseResults.ipynb** shows plots and tables that describe the distribution of the variables and states, 
as well as a comparison to the reported activities from the diary.

**3_AnalyzeModel.ipynb** shows the distributions learned by the model

**4_3dVisualization.ipynb** shows a 3D visualization of the angles and states.