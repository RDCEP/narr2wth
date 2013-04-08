library( ncdf4)
library( raster)
library( abind)
library( doMC)

registerDoMC( multicore:::detectCores())

vars <- c( "tmin", "tmax", "precip", "solar")
## names( vars) <- vars

years <- 1979:2012


## function getNcByVarYear( var, year)
## computes file name of input netCDF file by variable name and year
## and opens it

getNcByVarYear <- function( var, year) {
  ncFn <- sprintf( "data/nc/%1$s/%1$s_%2$d.nc", var, year)
  list( nc_open( ncFn))
}

narr <- raster( getNcByVarYear( "tmin", 1979)[[1]]$filename)
xmin( narr) <- xmin( narr) - 360
xmax( narr) <- xmax( narr) - 360


narrAnchorPoints <-
  cbind(
    lon= seq(
      from= xmin( narr),
      to= xmax( narr)- res( narr)[1],
      by= res( narr)[1] * 10),
    lat= ymax( narr))

## function readNarrValues( xy, var, year, n)

readNarrValues <- function(  xy, var= "tmin", year= 1979, n=10) {
  nc <- getNcByVarYear( var, year)[[1]]
  r <- raster( nc$filename)
  column <-
    rowColFromCell(
      r, cellFromXY(
        r, xy= xy + c( 360, 0)))[ 2]
  start <- c( column, 1, 1)
  days <- as.integer( strftime( ISOdate( year, 12, 31), "%j"))
  m <- ncvar_get(
    nc,
    varid= var,
    start= start,
    count= c( n, -1, days),
    collapse_degen= FALSE)              # collapse_degen seems to have
  narrDays <-                           # no effect
    seq(
      as.Date( sprintf( "%d-01-01", year)),
      by= "day", length.out= days
      ) - as.Date( "1978-12-31")
  dn <- list(
    longitude= nc$dim$longitude$vals[ column:(column +n -1)],
    latitude=  nc$dim$latitude$vals[],
    time= narrDays)
  if( length( dim( 1)) == 2)
    dim(m) <- c( 1, dim(m))             # to compensate for apparent
  dimnames( m) <- dn                    # collapse_degen bug
  m
}



system.time({
  narrValues <-
    foreach(
      var= vars,
      ## var= "tmin",
      .inorder= TRUE) %:%
        foreach(
          year= years,
          .combine= abind,
          .inorder= TRUE,
          .multicombine= TRUE,
          .packages= "ncdf4") %dopar% {
            readNarrValues( narrAnchorPoints[ 40,], var= var, year= year)
          }
  names( narrValues) <- vars
  for( var in vars)
    names( dimnames( narrValues[[ var]])) <-
      c( "longitude", "latitude", "time")
})

## would plyr do a better job of preserving names than foreach while
## also providing parallelism?


ncDimsFunc <- function( xy, narrDays) {
  list(
    ncdim_def(
      name= "longitude",
      units= "degrees_east",
      vals= xy[[ "lon"]]),
    ncdim_def(
      name= "latitude",
      units= "degrees_north",
      vals= xy[[ "lat"]]),
    ncdim_def(
      name= "narr/time",
      units= "days since 1978-12-31 00:00:00",
      vals= narrDays,
      unlim= TRUE))
}

ncVarsFunc <- function( xy, narrDays, compression= 5) {
  list(
    ncvar_def(
      name= "narr/tmin",
      units= "K",
      longname= "daily minimum temperature",
      dim= ncDimsFunc( xy, narrDays),
      compression= 5),
    ncvar_def(
      name= "narr/tmax",
      units= "K",
      longname= "daily maximum temperature",
      dim= ncDimsFunc( xy, narrDays),
      compression= 5),
    ncvar_def(
      name= "narr/precip",
      units= "mm",
      longname= "daily total precipitation",
      dim= ncDimsFunc( xy, narrDays),
      compression= 5),
    ncvar_def(
      name= "narr/solar",
      units= "W/m^2",
      longname= "daily average downward short-wave radiation flux",
      dim= ncDimsFunc( xy, narrDays),
      compression= 5))
}

psimsNcFromXY <- function( xy, narrDays, resWorld= 5/60) {
  if( xy[[ "lon"]] > 180) {
    xy[[ "lon"]] <- xy[[ "lon"]] - 360
  }
  world <- raster()
  res( world) <- resWorld
  rowCol <- as.list( rowColFromCell( world, cellFromXY( world, xy))[1,])
  ncFile <- sprintf( "data/nc/psims/%1$d/%2$d/%1$d_%2$d.nc", rowCol$row, rowCol$col) 
  if( !file.exists( dirname( ncFile))) {
    dir.create( path= dirname( ncFile), recursive= TRUE)
  }
  ## if( !file.exists( ncFile)) {
  ##   nc_create(
  ##     filename= ncFile,
  ##     vars= ncVarsFunc( xy, narrDays),
  ##     force_v4= TRUE,
  ##     verbose= TRUE)
  ## } else {
  ##   nc_open( filename= ncFile, write=TRUE)
  ## }
  if( file.exists( ncFile)) file.remove( ncFile)
  nc_create(
    filename= ncFile,
    vars= ncVarsFunc( xy, narrDays),
    force_v4= TRUE,
    verbose= FALSE)
}

inNarrMask <- function( xy, file= "gridLists/data/narr4326.tif") {
  narrMask <- raster( file)
  !is.na( extract( narrMask, rbind( xy)))
}

writePsimsNc <- function( narrValues, col, row) {
  xy <- c(
    lon= as.numeric( dimnames( narrValues[[ "tmin"]])$longitude[ col]),
    lat= as.numeric( dimnames( narrValues[[ "tmin"]])$latitude[  row]))
  if( !inNarrMask( xy -c( 360, 0))) return( NA)
  psimsNc <- psimsNcFromXY(
    xy, narrDays= as.integer( dimnames( narrValues[[ "tmin"]])$time))
  for( var in names( narrValues)) 
    ncvar_put(
      nc= psimsNc,
      varid= sprintf( "narr/%s", var),
      vals= narrValues[[ var]][ col, row,],
      count= c( 1, 1, -1))
  nc_close( psimsNc)
  psimsNc$filename
}


system.time(
  psimsNcFile <- writePsimsNc( narrValues, 1, 1))

psimsNcFile <- writePsimsNc( narrValues, 10, 240)

system.time(
  psimsNcFile <-
    foreach( col= 1:10) %:%
      foreach( row= 1:480) %dopar% {
        writePsimsNc( narrValues, col, row)
  })
