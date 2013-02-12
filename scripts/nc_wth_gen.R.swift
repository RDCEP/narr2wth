type file;

file tmin[]<simple_mapper;
  location="data/nc/tmin",
  prefix="tmin_",
  suffix=".nc">;

file tmax[]<simple_mapper;
  location="data/nc/tmax",
  prefix="tmax_",
  suffix=".nc">;

file precip[]<simple_mapper;
  location="data/nc/precip",
  prefix="precip_",
  suffix=".nc">;

file solar[]<simple_mapper;
  location="data/nc/solar",
  prefix="solar_",
  suffix=".nc">;

file wthFiles[][]<ext;
  exec="/project/joshuaelliott/narr/missingWthMapperYear.R",
  d= "/project/joshuaelliott/narr/data/wth",
  f= "GENERIC1.WTH",
  l= "/project/joshuaelliott/narr/data/grid_hwsd.txt">;

// tracef( "length( wthFiles) = %i\nfirst wthFile = %s\n", @length( wthFiles), @filenames(wthFiles)[1]);
//tracef( "length( wthFiles) = %i\n", @length( wthFiles));


string cellsMissingWthFile[] = readData( "data/cellsMissingWthFile.txt");

tracef( "length( cellsMissingWthFile) = %i\n", @length( cellsMissingWthFile));

app (file wthFile) nc_wth_gen( file precipFile, file tminFile, file tmaxFile, file solarFile, string cell) {
  nc_wth_gen @precipFile @tminFile @tmaxFile @solarFile cell stdout=@wthFile;
}

foreach cell in cellsMissingWthFile {
  foreach year in [1981:1984] { 
  wthFiles[ @toint( cell)][ year] = nc_wth_gen( precip[ year], tmin[ year], tmax[ year], solar[ year], cell);
  }
} 
