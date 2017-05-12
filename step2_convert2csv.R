rm(list=ls())
graphics.off()
# In this script we convert the output from GGIR to csv files
# that will be the input for the unsupervised segmentation algorithm
#==================================================================
# INPUT NEEDED:
# path = "/media/sf_VBox_Shared/London/run_05-10/"
path = "/media/windows-share/London/data_spring2017"

setwd(path)
studyname = "RDAfiles"

#===================================================
library(GGIR)
# Define output directories:
outdir = "accelerometer_5second" # epoch data
newdir = paste0(path,"/output_",studyname,"/",outdir)
if (file.exists(newdir) == FALSE) dir.create(newdir)
# Define which files need to beprocessed:
# ufn = unique file names
ufn = unique(dir(paste0(path,"/output_",studyname,"/meta/ms2.out"))) 
#---------------------------------------------------
# Extract unique person identifiers of indiduals from filenames:
rm.dayfromname = function(x) {
  return(unlist(strsplit(x,"_day"))[1])
}
ufn2 = unique(unlist(lapply(ufn,rm.dayfromname)))
rm.RDatafromname = function(x) {
  return(unlist(strsplit(x,"[.]RDa"))[1])
}
path2 = paste0("output_",studyname,"/meta/ms2.out")
fnames = dir(path2)
fnames2 = unique(unlist(lapply(fnames,rm.RDatafromname)))
#
heuristic = c()
cnt = 1
print("Load and export epoch data")
for (i in 1:length(fnames2)) { # loop through oroginal accelerometer filenames
  fnames2_withday = fnames2
  fnames2_withoutday = unlist(lapply(fnames2,rm.dayfromname))
  file2read = fnames2_withday[which(fnames2_withoutday == ufn2[i])] # maximum 2 days of data per files
  if (length(file2read) > 0) {
    for (j in 1:length(file2read)) { # loop through days available per accelerometer file
      load(paste0(path2,"/",file2read[j],".RData"))
      # Extract time series to indicater which segments are invalid (cannot be trusted)
      invalid = IMP$rout[,5]
      invalid = rep(invalid,each=(IMP$windowsizes[2]/IMP$windowsizes[1]))
      NR = nrow(IMP$metashort)
      if (length(invalid) > NR) {
        invalid = invalid[1:NR]
      } else if (length(invalid) < NR) {
        invalid = c(invalid,rep(0,(NR-length(invalid))))
      }
      output = cbind(IMP$metashort,invalid)
      # Extract time series of acceleration
      names(output)[2] = "acceleration"
      output$acceleration = as.numeric(as.character(output$acceleration))
      # Extract conventional heuristic approach
      # For convenience we classify them in numbers
      output$heuristic = 0 # initialize variable with zeros (this is not a real class)
      # Detect sustained inactivity bouts
      abs_delta_angle = abs(diff(as.numeric(as.character(output$anglez))))
      ch = which(abs_delta_angle > 5) # index
      sl = which(diff(ch) > 12*5) # ch[index]
      if (length(sl) > 1) {
        for (g in 1:(length(sl)-1)) {
          output$heuristic[ch[sl[g]]:ch[sl[g]+1]] = 1 #sleep or SIB
          
        }
        # Acceleration during the sustained inactivity bouts is turned to zero,
        # because we do not trust the accelerometer to sense acceleration during the
        # sustained absense of rotation
        output$acceleration[which(output$heuristic == 1)] = 0
      }
      # Extract inactivity, light and moderate or vigours physical activities
      OIN = which(output$acceleration < 0.040 & output$heuristic != 1)
      if (length(OIN) > 0) output$heuristic[OIN] = 2
      LIG = which(output$acceleration >= 0.040 & output$acceleration < 0.120 & output$heuristic != 1)
      if (length(LIG) > 0) output$heuristic[LIG] = 3
      MVPA = which(output$acceleration >= 0.120 & output$heuristic != 1)
      if (length(MVPA) > 0) output$heuristic[MVPA] = 4
      # 10 minute bouts of MVPA
      LN = nrow(output)
      rr1 = rep(0,LN)
      rr1[MVPA] = 1
      out1 = g.getbout(x=rr1,boutduration=10*12,boutcriter=0.8,
                       closedbout=FALSE,bout.metric=4,ws3=5)
      output$heuristic[which(out1$x == 1)] = 5
      # 1 minute bouts of MVPA
      rr1 = rep(0,LN)
      p = which(output$heuristic == 4)
      rr1[p] = 1
      out1 = g.getbout(x=rr1,boutduration=1*12,boutcriter=0.8,
                       closedbout=FALSE,bout.metric=4,ws3=5)
      output$heuristic[which(out1$x == 1)] = 6
      # 30 minute bouts of Inactivity
      rr1 = rep(0,LN)
      p = which(output$heuristic == 2)
      rr1[p] = 1
      out1 = g.getbout(x=rr1,boutduration=30*12,boutcriter=0.9,
                       closedbout=FALSE,bout.metric=4,ws3=5)
      output$heuristic[which(out1$x == 1)] = 7
      day1 = output[1:(1440*12),]
      write.csv(day1,file=paste0(newdir,"/",file2read[j],".csv"),row.names = FALSE)
      # derive summary to be stored in seperate file at the end:
      Duration_alldata = length(day1$invalid) /12
      if (length(which(day1$invalid == 1) > 0)) day1 = day1[-which(day1$invalid == 1),]
      heuristic$binFile[cnt] = file2read[j]
      heuristic$sustained_inactivity_min[cnt] = length(which(day1$heuristic == 1)) / 12
      heuristic$inactivity_min[cnt] = length(which(day1$heuristic == 2)) / 12
      heuristic$light_activity_min[cnt] = length(which(day1$heuristic == 3)) /12
      heuristic$allmvpa_min[cnt] = length(which(day1$heuristic == 4)) /12
      heuristic$MVPAbouts_D10M80perc_E5T100_ENMO[cnt] = length(which(day1$heuristic == 5)) /12
      heuristic$MVPAbouts_D1_10M80perc_E5T100_ENMO[cnt] = length(which(day1$heuristic == 6)) /12
      heuristic$Inacitivtybouts_D30M80perc_E5T100_ENMO[cnt] = length(which(day1$heuristic == 7 )) /12
      heuristic$Duration_validdata[cnt] = length(day1$heuristic) /12
      heuristic$Duration_alldata[cnt] = Duration_alldata
    }
  }
}
write.csv(heuristic,file=paste0(path,"/output_",studyname,"/results/part2_time_in_heuristic_classes.csv"),row.names = FALSE)
