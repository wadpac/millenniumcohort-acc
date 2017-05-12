# milleniumcohort-acc
Scripts for processing data collected with the GENEActiv accelerometer from adolescent members of the Millenium cohort study.

The scripts mainly depend on R package [GGIR](https://github.com/wadpac/GGIR) and produce time series which are stored in csv files. These csv files are then used for further processing.

## Current pipeline:

### 1 Extract raw data 

Centre for Longitudinal Studies extracts raw data from the two specific days in the binary file and exports them as RData files using `applyGGIR.R` with argument mode = 1

### 2 Encrypted data transfer and decryption
.RData files are received by Netherlands eScience Center in encrypted zipped folders. Command to extract them (password not included):
```bash
find . -name "*.zip" -type f| xargs -I {} 7z x {}
```

### 3 Put all RData files in one folder:
```bash
mkdir raw
find . -name "*.RData" | xargs -I {} mv {} raw
```

### 4 Merge separate time use diaries files and wearcode files as follows

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

### 5 Generate basic reports and milestone data

We run applyGGIR.R with mode =c(1,2) and derive from this dayspecific reports as well as 10 minute window specific reports

### 6 Generate 5 second epoch time series

We run convert2csv.R to generate csv-files with time series of aggregated data to be used for unsupervised segmentation

### 7 Merging in participant identifiers
We run mergewithID.R to merging in the participant identifier from the wearcodes.csv file and to tidy up the variable list

### 8 Check which files did not pass through the pipeline and investigate