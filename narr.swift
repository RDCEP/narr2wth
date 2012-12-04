type file;

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

foreach g,ix in grb {
  grb2[ ix] = cnvgrib( g);
}

file nc[] <structured_regexp_mapper;
  source=grb2,
  match="^data/grb2/(....../.*)grb2$",
  transform="data/nc/\\1nc">;

app (file n) wgrib2 ( file g2, file nc_table) {
  wgrib2 @g2 "-match ':(TMP:2 m |APCP:|CRAIN:|DSWRF:)' -new_grid_winds earth -new_grid_interpolation neighbor -new_grid latlon 220.041666666666:960:0.083333333333 20.041666666666:480:0.0833333333333 - | wgrib2 - -order we:sn -nc3 -nc_table" @nc_table "-netcdf" @n;
}

foreach g2,ix in grb2 {
  nc[ ix] = wgrib2( g2, nc_table);
}
