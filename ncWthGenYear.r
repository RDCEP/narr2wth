#!/home/nbest/local/bin/r

library( raster, quietly= TRUE)
library( ncdf4)


precipFile <- argv[ 1]
tminFile <- argv[ 2]
tmaxFile <- argv[ 3]
solarFile <- argv[ 4]
cell <- as.numeric( argv[ 5])

## wthFile <- args[ 6]

## precipFile <- "data/nc/precip/precip_1979.nc"
## tminFile <- "data/nc/tmin/tmin_1979.nc"
## tmaxFile <- "data/nc/tmax/tmax_1979.nc"
## solarFile <- "data/nc/solar/solar_1979.nc"
## cell <- 2109179

## if( is.null( wthFile)) wthFile <- ""

shiftYears <- -16

world <- raster()
resWorld <- 5/60
res( world) <- resWorld

gridLonLat <-
  as.list( xyFromCell( world, cell)[1,])

precip <-
  raster( precipFile, varname= "precip")

precipExtent <-
  extent( precip)

lonsGt180 <-
  precipExtent@xmax > 180


## thisWthFn <- sprintf(
##   "%s/%d/%d/%s",
##   wthDir,
##   cell %/% 10000,
##   cell,
##   wthFn)

## if( !file.exists( dirname( thisWthFn))) {
##   dir.create( dirname( thisWthFn), recursive= TRUE)
## }

## cat(
##   c( paste( "*WEATHER DATA : cell", cell, "years", startYear, "--", endYear),
##     ## "",
##     "@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT",
##     paste( "    CI",
##           paste(format( xyFromCell( world, cell)[1,2:1],
##                        digits=5, nsmall=4, width=9),
##                 collapse=""),
##           "   -99   -99   -99   -99   -99",
##           sep=""),
##     "@DATE  SRAD  TMAX  TMIN  RAIN"),
##   sep= "\n") ##,
## ##  file= thisWthFn)


ncLon <- gridLonLat$x + ifelse( lonsGt180 && gridLonLat$x < 0, 360, 0)
ncLat <- gridLonLat$y

ncLons <-
  seq(
    from= precipExtent@xmin + res( precip)[ 1] /2, 
    to=   precipExtent@xmax - res( precip)[ 1] /2,
    by=   res( precip)[ 1])

ncLats <-
  seq(
    from= precipExtent@ymin + res( precip)[ 1] /2, 
    to=   precipExtent@ymax - res( precip)[ 1] /2,
    by=   res( precip)[ 1])

lonIndex <- which( abs(ncLons - ncLon) < resWorld/2)[ 1]
latIndex <- which( abs(ncLats - ncLat) < resWorld/2)[ 1]


precipNc <- nc_open( precipFile)
tminNc <- nc_open( tminFile)
tmaxNc <- nc_open( tmaxFile)
solarNc <- nc_open( solarFile)

dates <- as.POSIXlt(
  ncvar_get( precipNc, "time"),
  origin="1970-01-01", tz="GMT")
dates <- sprintf(
  "%d%s",
  dates$year + shiftYears,
  format( dates, "%j"))

precip <- ncvar_get(
  precipNc,
  varid= "precip",
  start= c( lonIndex, latIndex, 1),
  count= c( 1, 1, -1)) 
tmin <- ncvar_get(
  tminNc,
  varid= "tmin",
  start= c( lonIndex, latIndex, 1),
  count= c( 1, 1, -1)) 
tmax <- ncvar_get(
  tmaxNc,
  varid= "tmax",
  start= c( lonIndex, latIndex, 1),
  count= c( 1, 1, -1)) 
solar <- ncvar_get(
  solarNc,
  varid= "solar",
  start= c( lonIndex, latIndex, 1),
  count= c( 1, 1, -1))

solar <- solar *86400 /1000000 # Change units to MJ /m^2 /day
tmin <- tmin -273.15    # change K to C
tmax <- tmax -273.15

##browser()

data <-
  sprintf( "%5s %5.1f %5.1f %5.1f %5.1f",
          dates[ -length( dates)],
          solar[ -length( solar)],
          tmax, tmin,
          precip[ -length( precip)])

cat( data, sep= "\n")
