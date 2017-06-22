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
The file `config.yml` defines the directory in which data is stored, as well as all parameters for the HSMM models. The scripts will create subdirectories under the data directory, assuming the following directory structure:
```
<data_path>
├── accelerometer_5second
│   ├── <output files of R code>
├── merged
│   ├── <output files of step 0-Preprocess>
├── results
│   ├── mod_<n>st_<b>b_<r>r_<t>t_<colnames>
│   │   ├── model.pkl
│   │   ├── config.yml
│   │   ├── datawithstates
│   │   │   ├── <output files of step 1-HSMM>
│   │   └── images
│   │   │   ├── <output files of notebooks>
├── subsets
│   ├── <output files of step 0-Preprocess>
```


## Scripts
**0_prepare_data.py**: This script does the following things:
* joins wearcodes with the TUD (Time Use Diary) file
* removes accelerometer data where the data is invalid
* mirrors accelerometer data that seems to be of devices worn upside-down
* joins accelerometer data with TUD files.

**1_HSMM.py** This script trains the HSMM on all data in the *merged* folder, it ouputs the data with states in the *datawithstates* folder.

**5_apply_model.py** This script is to apply the model to all data in the *merged* folder.

## Notebooks
The notebooks are for analysis of the outcomes of the HSMM model.

**1_HSMM.ipynb** has the same functionality as the script, but shows a few plots.

**2_AnalyseResults.ipynb** shows plots and tables that describe the distribution of the variables and states,
as well as a comparison to the reported activities from the diary.

**3_AnalyzeModel.ipynb** shows the distributions learned by the model

**4_3dVisualization.ipynb** shows a 3D visualization of the angles and states.
