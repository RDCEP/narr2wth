library( ncdf4)
library( raster)

world <- raster()
res( world) <- 5/60

tminNc <- nc_open( "data/nc/tmin/tmin_1979.nc")
tmin <- brick( "data/nc/tmin/tmin_1979.nc", varname="tmin")

tmaxNc <- nc_open( "data/nc/tmax/tmax_1979.nc")
tmax <- brick( "data/nc/tmax/tmax_1979.nc", varname="tmax")

xy <- c( lon=-82.75, lat=43.5)

newNcFn <- {
  rowCol <- as.list( rowColFromCell( world, cellFromXY( world, xy))[1,])
  sprintf( "data/nc/psims/%1$d/%1$d_%2$d.nc", rowCol$row, rowCol$col) 
}

cellCenter <- as.list( xyFromCell( world, cellFromXY( world, xy))[1,])

ncDims <- list(
  ncdim_def(
    name= "longitude",
    units= "degrees_east",
    vals= cellCenter$x),
  ncdim_def(
    name= "latitude",
    units= "degrees_north",
    vals= cellCenter$y),
  ncdim_def(
    name= "time",
    units= "seconds since 1970-01-01 00:00:00",
    vals= as.integer( seq( ISOdate( 1979, 1, 1), ISOdate( 1979, 12, 31), "days")),
    unlim= TRUE))
      
system.time(
  tminValues <-
  ncvar_get(
    tminNc,
    start= c(
      rev(
        rowColFromCell(
          tmin,
          cellFromXY(
            tmin,
            xy= xy + c( 360, 0))))
      ,1),
    count= c( 1, 1, -1)))

tmaxValues <-
  ncvar_get(
  tmaxNc,
  start= c(
    rev(
      rowColFromCell(
        tmax,
        cellFromXY(
          tmax,
          xy= xy  + c( 360, 0))))
    ,1),
  count= c( 1, 1, -1))

system.time( {
  newNc <- {
    dir.create( path= dirname( newNcFn), recursive= TRUE)
    nc_create(
      filename= newNcFn,
      vars= list(
        ncvar_def(
          name= "narr/tmin",
          units= "K",
          longname= "daily minimum temperature",
          dim= ncDims,
          compression= 5),
        ncvar_def(
          name= "narr/tmax",
          units= "K",
          longname= "daily maximum temperature",
          dim= ncDims,
          compression= 5)),
      force_v4= TRUE,
      verbose= TRUE)
  }

  ncvar_put( nc= newNc, varid= "narr/tmin", vals= tminValues, count= c( 1, 1, -1))
  ncvar_put( nc= newNc, varid= "narr/tmax", vals= tmaxValues, count= c( 1, 1, -1))

  nc_close( newNc)
})
