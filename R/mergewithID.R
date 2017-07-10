rm(list=ls())
#============================================================================
# Declare functions:
extractbinname = function(x) {
  # extract binary accelerometer filename by splitting the RData filname in two
  # and taking the first part
  return(unlist(strsplit(x,"_day"))[1])
}
extractday = function(x) {
  # extract binary accelerometer filename by splitting the RData filname in two
  # and taking the first part
  return(unlist(strsplit(x,"_day"))[2])
}
moveID2front = function(x) {
  col_idx <- grep("accSmallID", names(x))
  x <- x[, c(col_idx, (1:ncol(x))[-col_idx])]
}
removecolwithna = function(x) {
  cut = which(is.na(x[1,])==TRUE)
  cut = cut[which(colSums(x[,cut],na.rm = TRUE) == 0)]
  if (length(cut) > 0) x = x[,-cut]
  return(x)
    
}
#============================================================================
# Start script:
path = "/media/windows-share/London/data_500"
wearcodes = read.csv(paste0(path,"/wearcodes.csv")) # load content of wearcodes file
# remove Day1 and Day 2 because there are duplicates because format is different
# between different iterations of the preprocessing
# resulting in duplicates that wear not removed when merging wearcode files
wearcodes = wearcodes[,-which(colnames(wearcodes) %in% c("Day1","Day2") == TRUE)] 
wearcodes = unique(wearcodes)
inactivity_threshold = 40 # inactivity threshold for metric ENMO in mg units
moderate_threshold = 120 # moderate activity threshold for metric ENMO in mg units



#===================================================
thresholdconfig_name = paste0("_thresholds",inactivity_threshold,"_",moderate_threshold)

#============================================================================
# merge accSmallID from wearcodes file with part2_daysummary file
# load
ds = read.csv(paste0(path,"/output_data500/results/part2_daysummary.csv"))
ds$binFile = sapply(as.character(ds$filename),extractbinname)
heuristic = read.csv(paste0(path,"/output_data500/results/part2_time_in_heuristic_classes",thresholdconfig_name,".csv"))
heuristic$RDFile = paste0(heuristic$binFile,heuristic$day,".RData")
# merging by binary filename, because this is what connects accelerometer files with accSmallID
ds_wearcodes = merge(wearcodes,ds,by="binFile")
# merge in heuristic variables
ds_wearcodes$filename = as.character(ds_wearcodes$filename)
ds_wearcodes = merge(ds_wearcodes,heuristic,by.x="filename",by.y="RDFile",all = FALSE)
# ommit some irrelevant variables
ds_wearcodes = ds_wearcodes[,-which(colnames(ds_wearcodes) %in% c("id","bodylocation","filename","measurmentday") == TRUE)]
ds_wearcodes = ds_wearcodes[,-c(13,21:32)]

# re-order to have accSmall in the front
ds_wearcodes = moveID2front(ds_wearcodes)
ds_wearcodes = removecolwithna(ds_wearcodes)
# remove binFile.y column and rename binFile.x to binFile
ds_wearcodes = ds_wearcodes[,-21]
colnames(ds_wearcodes)[which(colnames(ds_wearcodes) == "binFile.x")] = "binFile"

ds_wearcodes$quality_atleast10hours_WearTime = 0
ds_wearcodes$quality_atleast10hours_WearTime[which(ds_wearcodes$Duration_validdata > 10*60)] = 1

ds_wearcodes$meets_PArecommendation = 0
ds_wearcodes$meets_PArecommendation[which((ds_wearcodes$MVPAbouts_D10M80perc_E5T100_ENMO +
                                             ds_wearcodes$MVPAbouts_D1_10M80perc_E5T100_ENMO) > 60)] = 1

write.csv(ds_wearcodes,paste0(path,"/output_data500/results/mcs_mc_accvars_perday.csv"),row.names = FALSE)

#============================================================================
# merge accSmallID from wearcodes file with part2_windowsummary file (per 10 minutes)
# load
ws = read.csv(paste0(path,"/output_data500/results/part2_windowsummary.csv"))
# only interested in first 40 variables for now (the rest maybe later??)
ws = ws[,1:40]
# extract name of binary accelerometer datafile
ws$binFile = sapply(as.character(ws$filename),extractbinname)
# merging by binary filename, because this is what connects accelerometer files with accSmallID
ws_wearcodes = merge(wearcodes,ws,by="binFile",all = TRUE)
# ommit some irrelevant variables
ws_wearcodes = ws_wearcodes[,-which(colnames(ws_wearcodes) %in% c("id","bodylocation","filename","measurmentday") == TRUE)]
ws_wearcodes = ws_wearcodes[,-c(17:23)]
# re-order to have accSmall in the front
ws_wearcodes = moveID2front(ws_wearcodes)
ws_wearcodes = removecolwithna(ws_wearcodes)
write.csv(ws_wearcodes,paste0(path,"/output_data500/results/mcs_mc_accvars_per10min.csv"),row.names = FALSE)



