#!/software/R-2.15-el6-x86_64/bin/Rscript --default-packages=stats,getopt

##options( error= recover)

##options(error=quote(dump.frames( to.file=TRUE)))

spec <- matrix(
  c(  "wthDir", "d", "1", "character",
    "path to top of gridded WTH file tree",
     "wthFile", "f", "1", "character",
    "name of WTH files found in wthDir",
    "gridList", "l", "1", "character",
    "path to list of grid cell IDs to be found in wthDir",
    "refresh", "r", "0", "",
    "force scan of wthDir and rewrite of memoized results"),
  byrow=TRUE, ncol=5)

opt = getopt( spec)

if( is.null( opt$wthDir))
  opt$wthDir <- "/project/joshuaelliott/narr/data/wth"
if( is.null( opt$wthFile))
  opt$wthFile <- "GENERIC1.WTH"
if( is.null( opt$gridList))
  opt$gridList <- "/project/joshuaelliott/narr/data/grid_hwsd.txt"

if( is.null( opt$refresh)) {
  system( "cat data/missingWthMap.txt")
} else {

  ##stop( "got past -r check")
  
  gridList <-
    readLines( opt$gridList)

  allWthFiles <-
    paste(
      opt$wthDir,
      substr( gridList, 1, 3),
      gridList,
      opt$wthFile,
      sep= "/")

  lengthWth <- function( wthFile) {
    sub( sprintf( "[ ]*([0-9]+)[ ]%s", wthFile),"\\1",
        system( sprintf( "wc -l %s", wthFile), intern=TRUE))
  }

  isValid <- function( wthFile) {
    lengthWth( wthFile) == "12400"
  }

  validWthFiles <-
    sapply(
      system(
        sprintf(
          "find data/wth -name %s",
          opt$wthFile),
        intern= TRUE),
      isValid)

  validWthFiles <-
    names( validWthFiles)[ validWthFiles]

  missingWthFiles <-
    allWthFiles[ !allWthFiles %in% validWthFiles]

  ## missingWthYearFiles <-
  ##   outer( missingWthFiles, 1979:2012, paste, sep=".")

  ## df <- as.data.frame(
  ##   missingWthYearFiles,
  ##   row.names= gridList[ !allWthFiles %in% validWthFiles],
  ##   stringsAsFactors= FALSE)
  ## df$cell <- rownames( df)
  ## colnames( df) <- 1979:2012


  ## swiftMapping <-
  ##   melt( df, id.vars= "cell", variable_name= "year", )

  missingWthYearPairs <-
    expand.grid(
      year= 1981:1984, ##:2012,
      cell= gridList[ !allWthFiles %in% validWthFiles],
      stringsAsFactors= FALSE)


  swiftMapping <-
    with(
      missingWthYearPairs,
      mapply(
        function( cell, year) {
          sprintf( "[%s][%s] %s/%s/%s/%s.%s",
                  ## sprintf( "%s/%s/%s/%s.%s",
                  cell, year,
                  opt$wthDir,
                  substr( cell, 1, 3), cell,
                  opt$wthFile, year)
        },
        cell, year,
        USE.NAMES= FALSE))

  ## cat( gridList[ !allWthFiles %in% validWthFiles],
  ##     sep= "\n",
  ##     file= "data/cellsMissingWthFile.txt")

  cat( swiftMapping, file= "data/missingWthMap.txt", sep= "\n")
  ## cat( swiftMapping, sep= "\n")
}
