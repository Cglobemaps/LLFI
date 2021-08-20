#'vms 2 viirs 2 shp
#'
#'@param vms2viirs is the output of the earlier 'vms2viirs' function
#'@param ROIfile is a geospatial dataframe with a Region of Interest which determines the scope of your research area.
#'@return the output of vms2viirs in s4 format (can be exported to shapefile now)
#'@export
vms2viirs2shp <- function(vms2viirs,ROIfile) {
  vms2viirs$LATTITUDE <- as.numeric(vms2viirs$LATTITUDE)
  vms2viirs$LONGITUDE <- as.numeric(vms2viirs$LONGITUDE)
  vms2viirs <- na.omit(object = vms2viirs)
  vms2viirs <- SpatialPointsDataFrame(vms2viirs[,4:3],
                                       vms2viirs,
                                       proj4string = CRS("+init=epsg:4326"))
  raster::crs(ROIfile) <- raster::crs(vms2viirs)
  vms2viirsfilt <- vms2viirs[ROIfile, ]
  return(vms2viirsfilt)
}
