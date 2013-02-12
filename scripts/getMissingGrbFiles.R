
library(doMPI)

# create and register a doMPI cluster if necessary
if (!identical(getDoParName(), 'doMPI')) {
  cl <- startMPIcluster()
  registerDoMPI(cl)
}

library( stringr)

urlsToFetch <- readLines( "data/missingGrbFiles.txt")

destFiles <- str_replace(
  urlsToFetch,
  "^ftp://nomads.ncdc.noaa.gov/NARR",
  "data/grb")

noClobber <- FALSE

foreach(
  u= urlsToFetch,
  d= destFiles,
  .combine= append) %dopar% {
    dir.create( dirname( d), recursive= TRUE)
    if( file.exists( d) && noClobber) {
      sprintf( "%s *EXISTS*", d)
    } else {
      t <- try(
        download.file(
          url= u,
          destfile= d,
          quiet= TRUE))
      if( inherits( t, "try-error") ||  t != 0) {
        sprintf( "%s *FAILED* : %s", d, t)
      } else d
    }
  }

