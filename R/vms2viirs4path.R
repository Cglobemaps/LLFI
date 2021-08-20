#'vms 2 viirs 4 path
#'
#'@param vmsanalysisfile is the output of the 'vms2viirsanalysis' function.
#'@param vmsfile is a geospatial dataframe with VMS data over a certain period of time obtained via KKP (the Fisheries Ministrie of Indonesia)
#'@return a daily path file for all detected vessels of the vms2viirsanalysis function.
#'@export
vms2viirs4path <- function(vmsanalysisfile,vmsfile) {
  # if clipfile
  outfile <- vmsfile
  outfile$sepparator <- NA
  outfile <- vmsfile[0,]
  vmsanalysisfile <- subset(vmsanalysisfile, TRANSMITTE != "unidentified")
  dagn <- unique(vmsanalysisfile$day)
  for (i in dagn) {
    dayn <- i
    vmsanalysisperday <- subset(vmsanalysisfile, day == dayn)
    vmsperday <- subset(vmsfile, day == dayn)
    transnummers <- unique(vmsanalysisperday$TRANSMITTE)
    for (i in transnummers) {
      numtrans <- i
      vmsperdaynr <- subset(vmsperday, TRANSMITTE == numtrans)
      vmsperdaynr$sepparator <- paste(vmsperdaynr$TRANSMITTE,vmsperdaynr$day,sep = "_")
      outfile <- rbind(outfile, vmsperdaynr)
    }
  }
  return(outfile)
}

