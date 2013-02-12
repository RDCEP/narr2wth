#!/home/nbest/local/bin/r

library( raster, quietly= TRUE)
library( ncdf4)

ncArgs <- argv[ 1:4]
names( ncArgs) <- c( "precip", "tmin", "tmax", "solar")

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

scratchDir <- "/scratch/local/nbest"

copyToScratch <- function( ncFile, scratch= scratchDir) {
  fn <- basename( ncFile)
  ncCopy <- paste( scratch, fn, sep="/")
  ncLock <- paste( ncCopy, "lock", sep=".")
  if( !file.exists( scratch)) dir.create( scratch, recursive= TRUE)
  if( file.exists( ncCopy)) {
    if( file.exists( ncLock)) {
      return( 0)
    } else return( 1)
  } else {
    dd <- sprintf( "touch %s; dd if=%s of=%s bs=8M; rm %1$s",
                  ncLock, ncFile, ncCopy)
    system( dd, wait= FALSE)
    return( 0)
  }
}

ncFiles <-
  c( precipFile, tminFile, tmaxFile, solarFile)
done <- 0
repeat {
  done <-
    sum(
      sapply(
        ncFiles,
        copyToScratch))
  if( done == 4) break else Sys.sleep( 3)
}

precipFile <- paste( scratchDir, basename( precipFile), sep= "/")
tminFile <- paste( scratchDir, basename( tminFile), sep= "/")
tmaxFile <- paste( scratchDir, basename( tmaxFile), sep= "/")
solarFile <- paste( scratchDir, basename( solarFile), sep= "/")

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
