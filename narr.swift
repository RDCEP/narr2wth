type file;

// string ncDir     = "/project/joshuaelliott/narr/data/nc";
// string annualDir = "/project/joshuaelliott/narr/data/nc/annual";

file nc_table<"nc_table">;

string grbFiles[] = readData( "grbFiles.txt");

file grb[]<array_mapper; files=grbFiles>;

file grb2[] <structured_regexp_mapper;
  source=grb,
  match="^data/grb/(....../.*?)grb$",
  transform="data/grb2/\\1grb2">;

app (file grb2) cnvgrib (file grb) {
  cnvgrib "-g12" "-nv" @grb @grb2;
}

// foreach g,ix in grb {
//   grb2[ ix] = cnvgrib( g);
// }

file nc[] <structured_regexp_mapper;
  source=grb2,
  match="^data/grb2/(....../.*)grb2$",
  transform="data/nc/\\1nc">;

app (file n) wgrib2 ( file g2, file nc_table) {
  wgrib2 @g2 "-match ':(TMP:2 m |APCP:|CRAIN:|DSWRF:)' -new_grid_winds earth -new_grid_interpolation neighbor -new_grid latlon 220.041666666666:960:0.083333333333 20.041666666666:480:0.0833333333333 - | wgrib2 - -order we:sn -nc3 -nc_table" @nc_table "-netcdf" @n;
}

// foreach g2,ix in grb2 {
//   nc[ ix] = wgrib2( g2, nc_table);
// }

// wgrib2 puts the temperature in the first time step and the others
// in the second so we have to separate them before aggregating

file nc1[] <structured_regexp_mapper;
  source=nc,
  match="^(.*?).nc$",
  transform="\\1.1.nc">;

file nc2[] <structured_regexp_mapper;
  source=nc,
  match="^(.*?).nc$",
  transform="\\1.2.nc">;

app (file ofile) cdo( string op[], file ifile) {
  cdo op @ifile @ofile;
}

foreach n,ix in nc {
  nc1[ ix] = cdo( [ "selname,TMP", "-seltimestep,1"], n);
  nc2[ ix] = cdo( [ "selname,APCP,DSWRF,CRAIN", "-seltimestep,2"], n);
//  tracef( "nc[ %i] = %s\n", ix, @nc);
}

// app (file o) sh (string cmd) {  
//   sh "-c" cmd stdout=@o;
// }

// app (external eout) shf (file cmd) {
//   sh stdin=@cmd;
// }

// app shf1 (file cmd, external ein) {
//   sh stdin=@cmd;
// }

// app ( file out) cdo( string op[], file ifiles[]) {
//   cdo "-O" op @filenames( ifiles) @out; 
// }

// foreach year in [1979:2012] {
//   string find1     = @strcat("cd ", idir, "; find ", year, "?? -type f | fgrep .1.nc");
//   string find2     = @strcat("cd ", idir, "; find ", year, "?? -type f | fgrep .2.nc");
//   string fnames1[] = readData( sh( find1));
//   string fnames2[] = readData( sh( find2));
//   // string cdo1      = @strcat("cd ", idir, "; echo cdo -O mergetime ", @strjoin( fnames1, " "), " ", odir, "/merge.", year, ".1.nc");
//   // string cdo2      = @strcat("cd ", idir, "; echo cdo -O mergetime ", @strjoin( fnames2, " "), " ", odir, "/merge.", year, ".2.nc");
//   // file script1;
//   // file script2;
//   // script1 = writeData( cdo1);
//   // script2 = writeData( cdo2);
//   // shf( script1);
//   // shf( script2);
//   tmin[ year] = cdo( ["daymin", "-setname,tmin", "-selname,TMP"], a);
//   tmax[ year]= cdo( "-O daymax -setname,tmax -selname,TMP", a);
//   precip[ year]= cdo( "-O daysum -setname,precip -selname,APCP", a);
//   solar[ year]= cdo( "-O daymean -setname,solar -selname,DSWRF", a);
// }

// file annual1[]<simple_mapper;
//   location="data/nc/annual",
//   prefix= "merge."
//   suffix=".1.nc">;

// file annual2[]<simple_mapper;
//   location="data/nc/annual",
//   prefix= "merge."
//   suffix=".2.nc">;


// file tmin[]<simple_mapper;
//   location="data/nc/tmin",
//   prefix="tmin_",
//   suffix=".nc">;

// file tmax[]<simple_mapper;
//   location="data/nc/tmax",
//   prefix="tmax_",
//   suffix=".nc">;

// file precip[]<simple_mapper;
//   location="data/nc/precip",
//   prefix="precip_",
//   suffix=".nc">;

// file solar[]<simple_mapper;
//   location="data/nc/solar",
//   prefix="solar_",
//   suffix=".nc">;

// foreach a,year in annual1 {
//   tmin[ year]= cdo( "-O daymin -setname,tmin -selname,TMP", a);
//   tmax[ year]= cdo( "-O daymax -setname,tmax -selname,TMP", a);
// }

// foreach a,year in annual2 {
//   precip[ year]= cdo( "-O daysum -setname,precip -selname,APCP", a);
//   solar[ year]= cdo( "-O daymean -setname,solar -selname,DSWRF", a);
// }



