#!/software/R-2.15-el6-x86_64/bin/Rscript

library( doMC, quietly= TRUE)
registerDoMC()

## library( RCurl, quietly= TRUE)
library( stringr, quietly= TRUE)


existingGrbFiles <-
  list.files(
    "data/grb",
    full.names= TRUE,
    recursive= TRUE)

grbDateTimeRegex <-
  paste(
    "^data/grb/([0-9]{4})([0-9]{2})/[0-9]{8}",
    "narr-a_221_[0-9]{6}([0-9]{2})_([0-9]{2})00_000.grb$",
    sep= "/")

nextGrbDateTime <- 
  if( length( existingGrbFiles) == 0 &&
     !file.exists( "data/nextGrbToProcess")) {
    ISOdatetime( 1979, 1, 1, 0, 0, 0, "GMT")
  } else {
    nextGrbToProcess <-
      readLines( "data/nextGrbToProcess", n=1)
    nextGrbDateTime <-
      as.list( as.numeric( str_match_all(
        nextGrbToProcess,
        grbDateTimeRegex)[[1]][1, -1]))
    names( nextGrbDateTime) <-
      c( "year", "month", "day", "hour")
    do.call(
      ISOdatetime,
      append(
        nextGrbDateTime,
        list(min= 0, sec= 0, tz= "GMT")))
  }


grbsToDelete <-
  existingGrbFiles[ existingGrbFiles < nextGrbToProcess]

if( length( grbsToDelete) > 0) {
  grbsDeleted <- 
    foreach( fn=filesToDelete, .combine= c) %dopar% {
      if( file.remove( fn)) fn else NA
    }
  cat( "GRB files deleted:\n")
  cat( grbsDeleted[ !is.na( grbsDeleted)],
      sep= "\n")
}

grbUrlFormat <-
  paste( "ftp://nomads.ncdc.noaa.gov/NARR",
        "%Y%m/%Y%m%d/narr-a_221_%Y%m%d_%H00_000.grb",
        sep= "/")

pendingGrbUrls <-
  strftime(
    seq( from= nextGrbDateTime,
        to= Sys.time() - as.difftime( 1, units="weeks"),
        by= "3 hours"),
    tz= "GMT",
    format= grbUrlFormat)

pendingGrbFiles <-
  str_replace(
    string= pendingGrbUrls,
    pattern= "^ftp://nomads.ncdc.noaa.gov/NARR",
    replacement= "data/grb")

cat( pendingGrbFiles, file="data/pendingGrbFiles", sep= "\n")

grbToDownloadUrls <-
  pendingGrbUrls[ !pendingGrbFiles %in% existingGrbFiles]

grbToDownloadDests <- 
  pendingGrbFiles[ !pendingGrbFiles %in% existingGrbFiles]

options( cores= 5, internet.info= 0)

noClobber <- TRUE

log <- foreach(
  u= grbToDownloadUrls,
  d= grbToDownloadDests,
  .combine= c) %dopar%
{
  dir.create( dirname( d), recursive= TRUE)
  if( file.exists( d) && noClobber) {
    sprintf( "%s *EXISTS*", d)
  } else {
    ## if( !url.exists( u)) {
    ##   sprintf( "%s *NOT AVAILABLE*", d)
    ## } else {
    t <- try(
      download.file(
        url= u,
        destfile= d,
        ## method= "wget",
        ## extra= "--no-verbose --retry-connrefused",
        mode= "wb",
        cacheOK= FALSE,
        quiet= FALSE),
      silent= TRUE)
    ##   quiet= TRUE),
    ## silent= TRUE)
    if( inherits( t, "try-error") ||  t != 0) {
      file.remove( d)
      sprintf( "%s *FAILED* %s", d, t)
    } else {
      sprintf( "%s", d)
    }
  }
}

cat( log, sep= "\n")
warnings()
