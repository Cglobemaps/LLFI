# LLFI
R Package for VMS and VIIRS data combination and analysis
This package was created specifically for VMS data that was provided by the Indonesian Ministery of Fisheries and Maritime Affairs (KKP), VIIRS data obtained from NOAA through VBD (https://eogdata.mines.edu/vbd/)

# Publications
The following papers were published in scientific journals, based on data that was obtained through the usage of the LLFI package:
-  Analysis of Fishing with Led Lights in and around MPA and No Take Zones at Natuna Indonesia through VMS and VIIRS Data (https://www.sciencegate.app/app/document/download/10.1109/agers51788.2020.9452785)
- 

# Usage
`# Install the Package`

`devtools::install_github("Cglobemaps/LLFI")`

The package is designed to handle VMS data that was provided by KKP and VIIRS data from NOAA VBD. Therefore the functions only recognize columns that are provided in the standard format.
Therefore, before using the package, make sure that your vmsfile includes the following columns:
- The Ship or Transmitter name `TRANSMITTE)`
- Type of fishing gear used by the ship `NAMA_ALAT_)`
- The Lattitude column `LATITUDE)`
- The Longitude column `LONGITUDE)`
- The Time column `PING_TIME)`
- The Speed column `SPEED)`
- The Heading column `HEADING)`

If these column names differ, make sure to change them before you start using the functions.

The viirsfile depends on the following columns:
- First ID column `id`
- Second ID column `id_Key`
- The Date column `Date_Mscan`
- Latitude Column `Lat_DNB`
- Longitude Column `Lon_DNB`
- Vessel Type Column `QF_Detect` --> Filter this on QF1 for Fisheries Data (more info on https://eogdata.mines.edu/vbd/)

When these are all specified, you can run the following:
In this example `vmsfile` is the file holding the vms data and `VIIRS2018` is the file holding the VIIRS data. Both files should be added as a Shapefile.
`cliplaag` is a file you must create yourself that exclused land and harbours in your Region of Interest. This can be used to get rid of false data`.


`cliplaag <- rgdal::readOGR("cliplaag.shp")`

`# make sure both files have the same CRS`

`raster::crs(cliplaag) <- raster::crs(vmsfile)`

`vmsfile_noharbour <- vmsfile[cliplaag, ]`

`# filter out any data with a speed below 1 knots`

`vmsfilenoherbs <- subset(vmsfile_noharbour, SPEED < 1)`


`vmsfile_viirs <- subset(vmsfilenoherbs, NAMA_ALAT_ == "Purse Seine (Pukat Cincin) Pelagis Kecil" | NAMA_ALAT_ == "Bouke ami" | NAMA_ALAT_ == "Pukat cincin Pelagis Besar dengan satu kapal")
vmsfile_Purse_Seine_large <- subset(vmsfilenoherbs, NAMA_ALAT_ == "Pukat cincin Pelagis Besar dengan satu kapal")
vmsfile_Purse_Seine_small <- subset(vmsfilenoherbs, NAMA_ALAT_ == "Purse Seine (Pukat Cincin) Pelagis Kecil")
vmsfile_Bouke_ami <- subset(vmsfilenoherbs, NAMA_ALAT_ == "Bouke ami")`

`vmstoviirs_noharbour <- vms2viirs(VIIRS2018,vmsfile_noharbour)
vmstoviirs_viirs <- vms2viirs(VIIRS2018,vmsfile_viirs)
vmstoviirs_Purse_Seine_large <- vms2viirs(VIIRS2018,vmsfile_Purse_Seine_large)
vmstoviirs_Purse_Seine_small <- vms2viirs(VIIRS2018,vmsfile_Purse_Seine_small)
vmstoviirs_Bouke_ami <- vms2viirs(VIIRS2018,vmsfile_Bouke_ami)`

`vms2viirs2shpfile_noharbour <- vms2viirs2shp2(vmstoviirs_noharbour,ROI,"noharbour")
vms2viirs2shpfile_viirs <- vms2viirs2shp2(vmstoviirs_viirs,ROI,"noharbour")
vms2viirs2shpfile_Purse_Seine_large <- vms2viirs2shp2(vmstoviirs_Purse_Seine_large,ROI,"noharbour")
vms2viirs2shpfile_Purse_Seine_small <- vms2viirs2shp2(vmstoviirs_Purse_Seine_small,ROI,"noharbour")
vms2viirs2shpfile_Bouke_ami <- vms2viirs2shp2(vmstoviirs_Bouke_ami,ROI,"noharbour")`

For this tutorial a buffer distance of 5000 meter was used in the vms2viirsanalysis function. Look for more info on the buffer distance to the journals in the Publications section.

`vmsanalysisfile_noharbour <- vms2viirsanalysis(vms2viirs2shpfile_noharbour, VIIRS2018, vmsfile_noharbour)
rgdal::writeOGR(vmsanalysisfile_noharbour, "." , "VIIRS2018_Identified_noharbour", driver = "ESRI Shapefile")
vmsanalysisfile_viirs <- vms2viirsanalysis(vms2viirs2shpfile_viirs, VIIRS2018, vmsfile_viirs,5000)
rgdal::writeOGR(vmsanalysisfile_viirs, "." , "VIIRS2018_Identified_viirs", driver = "ESRI Shapefile")
vmsanalysisfile_Purse_Seine_large <- vms2viirsanalysis(vms2viirs2shpfile_Purse_Seine_large, VIIRS2018, vmsfile_Purse_Seine_large,5000)
rgdal::writeOGR(vmsanalysisfile_Purse_Seine_large, "." , "VIIRS2018_Identified_Purse_Seine_Large", driver = "ESRI Shapefile")
vmsanalysisfile_Purse_Seine_small <- vms2viirsanalysis(vms2viirs2shpfile_Purse_Seine_small, VIIRS2018, vmsfile_Purse_Seine_small,5000)
rgdal::writeOGR(vmsanalysisfile_Purse_Seine_small, "." , "VIIRS2018_Identified_Purse_Seine_Small", driver = "ESRI Shapefile")
vmsanalysisfile_Bouke_ami <- vms2viirsanalysis(vms2viirs2shpfile_Bouke_ami, VIIRS2018, vmsfile_Bouke_ami,5000)
vmsanalysisfile_Bouke_ami$RegionOfInterest <- sp::over(vmsanalysisfile_Bouke_ami,RegionOfInterest)
vmsanalysisfile_Bouke_ami$SZNKKP <- sp::over(vmsanalysisfile_Bouke_ami,SZNKKP)
rgdal::writeOGR(vmsanalysisfile_Bouke_ami, "." , "VIIRS2018_Identified_Bouke_ami", driver = "ESRI Shapefile")`


`vmstoviirsforpath_noharbour <- vms2viirs4path(vmsanalysisfile_noharbour,vmsfile_noharbour)
rgdal::writeOGR(vmstoviirsforpath_noharbour, "." , "vms4path_noharbour", driver = "ESRI Shapefile")
vmstoviirsforpath_viirs <- vms2viirs4path(vmsanalysisfile_viirs,vmsfile_viirs)
rgdal::writeOGR(vmstoviirsforpath_viirs, "." , "vms4path_viirs", driver = "ESRI Shapefile")
vmstoviirsforpath_Purse_Seine_large <- vms2viirs4path(vmsanalysisfile_Purse_Seine_large,vmsfile_Purse_Seine_large)
rgdal::writeOGR(vmstoviirsforpath_Purse_Seine_large, "." , "vms4path_Purse_Seine_Large", driver = "ESRI Shapefile")
vmstoviirsforpath_Purse_Seine_small <- vms2viirs4path(vmsanalysisfile_Purse_Seine_small,vmsfile_Purse_Seine_small)
rgdal::writeOGR(vmstoviirsforpath_Purse_Seine_small, "." , "vms4path_Purse_Seine_Small", driver = "ESRI Shapefile")
vmstoviirsforpath_Bouke_ami <- vms2viirs4path(vmsanalysisfile_Bouke_ami,vmsfile_Bouke_ami)
rgdal::writeOGR(vmstoviirsforpath_Bouke_ami, "." , "Filtered/vms4path_Bouke_ami", driver = "ESRI Shapefile")`

After these are all done, you can import the `vmstoviirsforpath` Shapefiles to a QGIS instance and run the `Points to Path` tool: select `Ping Time` as Order Column and select `sepprtr` as Group Expression.
