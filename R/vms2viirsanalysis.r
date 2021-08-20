#'vms 2 viirs
#'
#'@param vmstooviirshp is the output of the 'vms2viirs2shp' function.
#'@param viirsfile is a geospatial dataframe with viirs data obtained from https://eogdata.mines.edu/vbd/
#'@param vmsfile is a geospatial dataframe with VMS data over a certain period of time obtained via KKP (the Fisheries Ministrie of Indonesia)
#'@return a geopsatial dataframe with all detected vessels through VIIRS satellite that could be connected to VMS vessel data.
#'@export
vms2viirsanalysis <- function(vmstoviirshp,viirsfile,vmsfile) {
  dagen <- unique(vmstoviirshp$DAY)
  viirsfile$Date_Mscan <- as.POSIXct(viirsfile$Date_Mscan)
  viirsfile$day <- as.Date(viirsfile$Date_Mscan)
  vmsfile$PING_TIME <- as.POSIXct(vmsfile$PING_TIME)
  vmsfile$day <- as.Date(vmsfile$PING_TIME)
  outfile <- viirsfile[0,]
  outfile <- as.data.frame(outfile)
  for (i in dagen) {
    dayn <- i
    vmstoviirshperday <- subset(vmstoviirshp, DAY == dayn)
    viirsfileperday <- subset(viirsfile, day == dayn)
    vmsfileperday <- subset(vmsfile, day == dayn)
    transmitters <- unique(vmstoviirshperday$TRANSMITTE)
    for (i in transmitters) {
      transnr <- i
      vmstoviirshperdaytransmitte <- subset(vmstoviirshperday, TRANSMITTE == transnr)
      if (nrow(vmstoviirshperdaytransmitte)<1) {
        next
      }
      bufferdistance <- 500 #knot2kph/2
      buvver <- function(x,y) {
        requireNamespace("sp")
        buv1 <- x[,-(2:8)]
        buv2 <- sp::spTransform(buv1, sp::CRS('+init=epsg:3857'))
        requireNamespace("rgeos")
        buv3 <- rgeos::gBuffer(buv2, byid=TRUE, widt=y)
        buv4 <- sp::spTransform(buv3, sp::CRS('+init=epsg:4326'))
        return(buv4)
      }
      vmstoviirsbuffer <- buvver(vmstoviirshperdaytransmitte,bufferdistance)
      overlayer <- function(y,z) {
        x <- sp::over(y,z,returnlist = TRUE)
        x[x == "list(id = numeric(0))"] <- "NA"
        x[x == "list(id = integer(0))"] <- "NA"
      }
      raster::crs(viirsfileperday) <- raster::crs(vmstoviirsbuffer)
      planka <- viirsfileperday[vmstoviirsbuffer, ]
      if (nrow(planka)<1) {
        next
      }
      planka$TRANSMITTE <- rep(transnr,length(planka))
      planka <- as.data.frame(planka)
      outfile <- rbind2(outfile,planka)
    }

  }
  haron <- dplyr::select(outfile, dplyr::contains("id_Key"), dplyr::contains("TRANSMITTE"))
  texigo <- sp::merge(viirsfile, haron, by = 'id_Key' , duplicateGeoms = TRUE)
  texigo$TRANSMITTE[is.na(texigo$TRANSMITTE)] <- "unidentified"
  return(texigo)
}
