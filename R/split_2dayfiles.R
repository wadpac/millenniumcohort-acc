rm(list=ls())
# script to split a milestone files produced by part1 containing two concatenated days of data

pathold = "/media/windows-share/London/test16June/output_wthRt61/meta/basic_2days"
pathnew = "/media/windows-share/London/test16June/output_wthRt61/meta/basic"
fnames = dir(pathold,full.names = TRUE)
for (i in 1:length(fnames)) {
  print(fnames[i])
  tmp = unlist(strsplit(fnames[i],"/"))
  tmp = tmp[length(tmp)]
  tmp2 = unlist(strsplit(tmp,"[.]bin"))
  filename_day1 = paste0(tmp2[1],".bin_day1",tmp2[2])
  filename_day2 = paste0(tmp2[1],".bin_day2",tmp2[2])
  load(fnames[i])
  if (M$filetooshort == TRUE | M$filecorrupt == TRUE) {
    save(C,filefoldername,filename_dir,I,M,file=paste0(pathnew,"/",filename_day1))
    save(C,filefoldername,filename_dir,I,M,file=paste0(pathnew,"/",filename_day2))
  } else {
    if (nrow(M$metalong) == 192) { # 48 hours
      ML1 = M$metalong[1:96,]
      ML2 = M$metalong[97:192,]
      MS1 = M$metashort[1:17280,]
      MS2 = M$metashort[17281:34560,]
      M$metalong = ML1
      M$metashort = MS1
      save(C,filefoldername,filename_dir,I,M,file=paste0(pathnew,"/",filename_day1))
      M$metalong = ML2
      M$metashort = MS2
      save(C,filefoldername,filename_dir,I,M,file=paste0(pathnew,"/",filename_day2))
    } else { # less than 48 hours
      LtimesPOSIX = as.POSIXlt(M$metalong[,1],format="%Y-%m-%dT%H:%M:%S%z",tz="Europe/London")
      time4am = which(LtimesPOSIX$hour == 4 & LtimesPOSIX$minutes == 0)
      if (length(time4am) == 0) { # only 1 day
        filename_day1 = paste0(tmp2[1],".bin_day1",tmp2[2])
        save(C,filefoldername,filename_dir,I,M,file=paste0(pathnew,"/",filename_day1))
      } else { # two days
        kkk
      }
      
    }
  
  }
  
}