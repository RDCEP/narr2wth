type file;

file nc_table<"nc_table">;

string grbFiles[] = readData( "grbFilesRedo.txt");

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

// wgrib2 adds an empty second timestep so we have to select the first timestep

file nc1[] <structured_regexp_mapper;
  source=nc,
  match="^(.*?)nc$",
  transform="\\1single.nc">;

// app (file n1) cdo( file n, string op) {
//   cdo op @n @n1;
// }

app (file n1) cdo( string op, file n[]) {
  cdo op @filenames(n) @n1;
}

// foreach n,ix in nc {
//   nc1[ ix] = cdo( n, "seltimestep,1");
// }


app (string list) find( string args) {
  find args stdout=list;
}

string ncList[];

file annual[]<simple_mapper;
  location="data/nc/annual",
  suffix=".nc">;

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


foreach year in [1979:2011] {
  ncList[ year] = @filenames( 
    file foo[]<structured_regexp_mapper;
      source= nc1,
      match= @strcat( "^data/nc/", year, "../narr-a_221_", year, "...._..00_000.single.nc$");>)
  annual[ year]= cdo( "-O mergetime", ncList[ year]);
  tmin[ year]= cdo( "-O daymin -selname,TMP", @annual[ year]);
  tmax[ year]= cdo( "-O daymax -selname,TMP", @annual[ year]);
  precip[ year]= cdo( "-O daysum -selname,APCP", @annual[ year]);
  solar[ year]= cdo( "-O daymean -selname,DSWRF", @annual[ year]);
}


