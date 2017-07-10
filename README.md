# Pipeline for Millennium cohort accelerometer data

Pipeline for processing data collected with the GENEActiv accelerometer in adolescent members of the Millennium cohort study.

## 1 Conventional analyses
We use R package [GGIR](https://github.com/wadpac/GGIR) to analyse the accelerometer in the conventional way.

### 1.1 Extract raw data

Centre for Longitudinal Studies uses [R/applyGGIR.R](R/applyGGIR.R) with argument mode = 1 to extract raw data from the two specific days on which the accelerometer was worn. Here, the data is exported to RData files.

### 1.2 Encrypted data transfer and decryption
.RData files are received by Netherlands eScience Center in encrypted zipped folders. Command to extract them (password not included):
```bash
find . -name "*.zip" -type f| xargs -I {} 7z x {}
```

### 1.3 Put all RData files in one folder:
If the RData files are provided across multiple folders then put all of them in one folder:
```bash
mkdir raw
find . -name "*.RData" | xargs -I {} mv {} raw
```

### 1.4 Merge separate time use diaries files and wearcode files

The time use diary files and wearcode files are generated by the Centre for Longitudinal Studies. If these are provided in mulitple folder then merge them. For example, in R you could use a commands like this:
```R
# merge time use diary (tud):
tud = read.csv(paste0(path,"/tud.csv"))
tud2 = read.csv(paste0(path,"/tud2.csv"))
tud3 = merge(tud,tud2,all=TRUE)
write.csv(tud3,paste0(path,"/tud3.csv"),row.names = FALSE)

# merge wearcodes:
wc = read.csv(paste0(path,"/wc1.csv"))
wc2 = read.csv(paste0(path,"/wc2.csv"))
colnames_of_interest = c("Monitor","Day1","Day2","binFile","file","accSmallID")
wc = wc[,colnames_of_interest]
wc2 = wc2[,colnames_of_interest]
wc3 = merge(wc,wc2,all=TRUE)
write.csv(wc3,paste0(path,"/wc3.csv"),row.names = FALSE)
```

### 1.5 Generate basic reports and milestone data

We run applyGGIR.R with mode =c(1,2) and derive from this day specific reports as well as 10 minute window specific reports

### 1.6 Generate 5 second epoch time series

In preparation for  the Hidden semi-Markov Models we run [R/addheuristics_convert2csv.R](R/addheuristics_convert2csv.R) to generate csv-files with time series of aggregated data. Also this step generates an indicator of heuristic classes of behaviour (e.g. bouts of MVPA).

The heuristic categories are:
1 - sustained inactivity or sleep
2 - non-bouted inactivity
3 - >= 30 minute bouts of inactivity
4 - 10-19 minute bouts of inactivity
5 - non-bouted light activity
6 - >= 10 minunte bouts of light physical activity (LPA)
7 - > 1 minunte bouts of LPA
8 - non-bouted moderate or vigorous physical activity (MVPA)
9 - >= 10 minunte bouts of MVPA
10 - > 1 minunte bouts of MVPA

### 1.7 Merging in participant identifiers
We run mergewithID.R to merging in the participant identifier from the wearcodes.csv file and to tidy up the variable list


## 2 Explorative unsupervised analyses
Further, we use a Hidden semi-Markov model to explore unsupervised analyses of the data.


### 2.1 Train Hidden semi-Markov Model

Follow the steps as outlined [here](python/README.md)
In summary:

- Make sure you have Python 2.7
- Install the library [UKMovement Sensing](https://github.com/NLeSC/UKMovementSensing/)
- Adjust the config
- Run the scripts 0_prepare_data.py and 1_HSMM.py

### 2.2 Check which files did not pass through the pipeline and investigate
