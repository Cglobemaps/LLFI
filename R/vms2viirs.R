#'vms 2 viirs
#'
#'@param viirsfile is a geospatial dataframe with viirs data obtained from https://eogdata.mines.edu/vbd/
#'@param vmsfile is a geospatial dataframe with VMS data over a certain period of time obtained via KKP (the Fisheries Ministrie of Indonesia)
#'@param is a geospatial dataframe with a Region of Interest which determines the scope of your research area.
#'@return a dataframe with positions of vessels that were included in the VMS dataset at the time of overpass of the VIIRS satellite.
#'@export
vms2viirs <- function(viirsfile, vmsfile, ROI) {
  vmstoviirs <- data.frame(matrix(ncol = 6, nrow = 0))
  x <- c("TRANSMITTE","NAMA_ALAT_","LATTITUDE","LONGITUDE","DAY","ROI")
  colnames(vmstoviirs) <- x
  viirsfile$Date_Mscan <- as.POSIXct(viirsfile$Date_Mscan)
  viirsfile$day <- as.Date(viirsfile$Date_Mscan)
  vmsfile$PING_TIME <- as.POSIXct(vmsfile$PING_TIME)
  vmsfile$day <- as.Date(vmsfile$PING_TIME)
  vmsfile$LAT <- as.numeric(vmsfile$LATITUDE)
  vmsfile$LONG <- as.numeric(vmsfile$LONGITUDE)
  daysviirs <- unique(viirsfile$day)
  daysvms <- unique(vmsfile$day)
  rois <- unique(ROI$id)
  for (i in daysviirs) {
    viirsdatum <- subset(viirsfile, day == i)
    vmsdatum <- subset(vmsfile, day == i)
    if (nrow(vmsdatum)<1) {
      next
    }
    dagen <- i
    for (i in rois) {
      roidid <- i
      ROII <- subset(ROI, id == i)
      raster::crs(ROII) <- raster::crs(viirsdatum)
      raster::crs(vmsdatum) <- raster::crs(viirsdatum)
      viirsinroi <- viirsdatum[ROII, ]
      if (nrow(viirsinroi)<1) {
        next
      }
      vmsinroi <- vmsdatum[ROII, ]
      if (nrow(vmsinroi)<2) {
        next
      }
      overpasstime <- mean(viirsinroi$Date_Mscan)
      upperborder <- overpasstime + 3600
      lowerborder <- overpasstime - 3600
      catchtech <- unique(vmsinroi$NAMA_ALAT_)
      for (i in catchtech) {
        vmstechinroi <- subset(vmsinroi, NAMA_ALAT_ == i)
        if (nrow(vmstechinroi)<2) {
          next
        }
        alat <- i

        uniqueids <- unique(vmstechinroi$TRANSMITTE)
        for (i in uniqueids) {
          jahoor <- subset(vmstechinroi, TRANSMITTE == i)
          if (nrow(jahoor)<2) {
            next
          }
          clip1 <- subset(jahoor, PING_TIME < upperborder)
          clip2 <- subset(jahoor, PING_TIME > lowerborder)
          if (nrow(clip2)<2) {
            next
          }
          maxi <- max(clip2$PING_TIME)
          mini <- min(clip2$PING_TIME)
          dataset <- as.data.frame(clip2)
          dataset$LAT <- as.numeric(dataset$LATITUDE)
          dataset$LONG <- as.numeric(dataset$LONGITUDE)
          maxiset <- subset(dataset, PING_TIME == maxi)
          maxiset$LAT <- as.numeric(maxiset$LATITUDE)
          maxiset$LONG <- as.numeric(maxiset$LONGITUDE)
          miniset <- subset(dataset, PING_TIME == mini)
          miniset$LAT <- as.numeric(miniset$LATITUDE)
          miniset$LONG <- as.numeric(miniset$LONGITUDE)
          minimumlat <- mean(miniset$LATITUDE)
          minimumlat <- as.numeric(minimumlat)
          maximumlat <- mean(maxiset$LATITUDE)
          maximumlat <- as.numeric(maximumlat)
          minimumlon <- mean(miniset$LONGITUDE)
          minimumlon <- as.numeric(minimumlon)
          maximumlon <- mean(maxiset$LONGITUDE)
          maximumlon <- as.numeric(maximumlon)
          inbetweentime <- as.numeric(maxi - mini, units="hours")
          inbetweenlat <- maximumlat - minimumlat
          inbetweenlat <- as.numeric(inbetweenlat)
          inbetweenlon <- maximumlon - minimumlon
          inbetweenlon <- as.numeric(inbetweenlon)
          inbetweenminandmean <- as.numeric(meandate - mini, units="hours")
          addlat <- (inbetweenminandmean*inbetweenlat)/inbetweentime
          addlat <- as.numeric(addlat)
          addlon <- (inbetweenminandmean*inbetweenlon)/inbetweentime
          addlon <- as.numeric(addlon)
          newlat <- minimumlat + addlat
          newlat <- as.numeric(newlat)
          newlon <- minimumlon + addlon
          newlon <- as.numeric(newlon)
          vmstoviirs <- tibble::add_row(vmstoviirs,TRANSMITTE = i,NAMA_ALAT_ = alat,LATTITUDE = newlat, LONGITUDE = newlon, DAY = dagen, ROI = roidid)
          vmstoviirs$DAY <- as.numeric(as.Date(vmstoviirs$DAY, origin="1970-01-01"))
        }
      }



    }
  }
  vmstoviirs$DAY <- as.POSIXct.Date(vmstoviirs$DAY)
  vmstoviirs$DAY <- as.Date(vmstoviirs$DAY, format = "%Y/%M/%D")

  return(vmstoviirs)
}


