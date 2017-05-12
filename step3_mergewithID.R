rm(list=ls())
#============================================================================
# Declare functions:
extractbinname = function(x) {
  # extract binary accelerometer filename by splitting the RData filname in two
  # and taking the first part
  return(unlist(strsplit(x,"_day"))[1])
}
moveID2front = function(x) {
  col_idx <- grep("accSmallID", names(x))
  x <- x[, c(col_idx, (1:ncol(x))[-col_idx])]
}
#============================================================================
# Start script:
path = "/media/windows-share/London/data_spring2017"
wearcodes = read.csv(paste0(path,"/wearcodes_2017May2.csv")) # load content of wearcodes file
#============================================================================
# merge accSmallID from wearcodes file with part2_daysummary file
# load
ds = read.csv(paste0(path,"/output_RDAfiles/results/part2_daysummary.csv"))
ds$binFile = sapply(as.character(ds$filename),extractbinname)
heuristic = read.csv(paste0(path,"/output_RDAfiles/results/part2_time_in_heuristic_classes.csv"))
# extract name of binary accelerometer datafile
heuristic$binFile = sapply(as.character(heuristic$binFile),extractbinname)
# merging by binary filename, because this is what connects accelerometer files with accSmallID
ds_wearcodes = merge(wearcodes,ds,by="binFile",all = TRUE)
ds_wearcodes = merge(ds_wearcodes,heuristic,by="binFile",all = TRUE)
# ommit some irrelevant variables
ds_wearcodes = ds_wearcodes[,-which(colnames(ds_wearcodes) %in% c("id","bodylocation","filename","measurmentday") == TRUE)]
ds_wearcodes = ds_wearcodes[,-(29:34)]
# re-order to have accSmall in the front
ds_wearcodes = moveID2front(ds_wearcodes)
write.csv(ds_wearcodes,paste0(path,"/output_RDAfiles/results/mcs_mc_accvars_perday.csv"),row.names = FALSE)

#============================================================================
# merge accSmallID from wearcodes file with part2_windowsummary file (per 10 minutes)
# load
ws = read.csv(paste0(path,"/output_RDAfiles/results/part2_windowsummary.csv"))
# only interested in first 40 variables for now (the rest maybe later??)
ws = ws[,1:40]
# extract name of binary accelerometer datafile
ws$binFile = sapply(as.character(ws$filename),extractbinname)
# merging by binary filename, because this is what connects accelerometer files with accSmallID
ws_wearcodes = merge(wearcodes,ws,by="binFile",all = TRUE)
# ommit some irrelevant variables
ws_wearcodes = ws_wearcodes[,-which(colnames(ws_wearcodes) %in% c("id","bodylocation","filename","measurmentday") == TRUE)]
ds_wearcodes = ds_wearcodes[,-c(17:23)]
# re-order to have accSmall in the front
ws_wearcodes = moveID2front(ws_wearcodes)
write.csv(ws_wearcodes,paste0(path,"/output_RDAfiles/results/mcs_mc_accvars_per10min.csv"),row.names = FALSE)



