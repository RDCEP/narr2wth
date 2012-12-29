type file;

string oneYearEarlier[] = readData( "oneYearEarlier.txt");

file inFiles[]<array_mapper; files= oneYearEarlier>;

file outFiles[]<structured_regexp_mapper;
  source=inFiles,
  match="^data/nc/2011(..)/narr-a_221_2011(...._..)00_000\\.(.)\\.nc$",
  transform="data/nc/2012\\1/narr-a_221_2012\\200_000.\\3.nc">;

app (file ofile) cdo( string op[], file ifile) {
  cdo op @ifile @ofile;
}

foreach inFile,ix in inFiles {
  outFiles[ ix] = cdo( [ "setyear,2012"], inFile);
//  tracef( "%i : %s --> %s\n", ix, @inFile, @outFiles[ ix]);
}
