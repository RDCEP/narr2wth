#!/software/R-2.15-el6-x86_64/bin/Rscript --default-packages=stats,getopt

##options( error= recover)

spec <- matrix(
  c(  "wthDir", "d", "1", "character",
    "path to top of gridded WTH file tree",
     "wthFile", "f", "1", "character",
    "name of WTH files found in wthDir",
    "gridList", "l", "1", "character",
    "path to list of grid cell IDs to be found in wthDir"),
  byrow=TRUE, ncol=5)

opt = getopt(spec)

## if( is.null( opt$wthDir))
##   opt$wthDir <- "/project/joshuaelliott/narr/data/wth"
## if( is.null( opt$wthFile))
##   opt$wthFile <- "GENERIC1.WTH"
## if( is.null( opt$gridList))
##   opt$gridList <- "/project/joshuaelliott/narr/data/GRID_hwsd.txt"


##composeWthFileNames <- function( wthDir= opt$wthDir, gridList= opt$gridList) {

gridList <-
  readLines( opt$gridList)

allWthFiles <-
  paste(
    opt$wthDir,
    substr( gridList, 1, 3),
    gridList,
    opt$wthFile,
    sep= "/")

isValid <- function( wthFile) {
##  file.exists( wthFile) && length( readLines( wthFile)) == 12400
  file.exists( wthFile) &&
    sub( sprintf( "[ ]*([0-9]+)[ ]%s", wthFile),"\\1",
        system( sprintf( "wc -l %s", wthFile), intern=TRUE)) == "12400"
}

validWthFiles <- sapply( allWthFiles, isValid)

swiftMapping <-
  sprintf(
    "[%s] %s",
    gridList[ !validWthFiles],
    allWthFiles[ !validWthFiles])

cat( swiftMapping, sep= "\n")
