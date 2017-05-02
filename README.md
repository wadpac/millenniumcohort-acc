# milleniumcohort-acc
Scripts for processing data collected with the GENEActiv accelerometer from adolescent members of the Millenium cohort study.

The scripts mainly depend on R package [GGIR](https://github.com/wadpac/GGIR) and produce time series which are stored in csv files. These csv files are then used for further processing.

### Current pipeline:

A. Centre for Longitudinal Studies generates .RData files with GGIR using step1_applyGGIR.R with argument mode = 1

B. .RData files are received by Netherlands eScience Center in encrypted zipped folders. Command to extract them (password not included):
```bash
find . -name "*.zip" -type f| xargs -I {} 7z x {}
```

C. We put all RData files in one folder

D. We merge the seperate time use diaries files and wearcode files as follows
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

E. We run step1_applyGGIR.R with mode =c(1,2) to generate basic reports and milestone data

F. We run step2_convert2csv.R to generate csv-files with time series of aggregated data to be used for unsupervised segmentation
