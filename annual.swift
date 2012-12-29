type file;

file annual1[]<simple_mapper;
  location="data/nc/annual",
  prefix="sbatch.",
  suffix=".1.nc">;

file annual2[]<simple_mapper;
  location="data/nc/annual",
  prefix="sbatch.",
  suffix=".2.nc">;

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

app (file n1) cdo( string op, file ifile) {
  cdo op @ifile @n1;
}

file selnameTMP[];
file selnameAPCP[];
file selnameDSWRF[];
file daymax[];
file daymin[];
file daysum[];
file daymean[];

foreach a,year in annual1 {
  selnameTMP[ year] = cdo( "selname,TMP", a);
  daymax[ year] = cdo( "daymax", selnameTMP[ year]);
  daymin[ year] = cdo( "daymin", selnameTMP[ year]);
  tmax[ year] = cdo( "setname,tmax", daymax[ year]);
  tmin[ year] = cdo( "setname,tmin", daymin[ year]);
  // tmin[ year]= cdo( "-O daymin -setname,tmin -selname,TMP", a);
  // tmax[ year]= cdo( "-O daymax -setname,tmax -selname,TMP", a);
}

foreach a,year in annual2 {
  selnameAPCP[ year] = cdo( "selname,APCP", a);
  selnameDSWRF[ year] = cdo( "selname,DSWRF", a);
  daysum[ year] = cdo( "daysum", selnameAPCP[ year]);
  daymean[ year] = cdo( "daymean", selnameDSWRF[ year]);
  precip[ year] = cdo( "setname,precip", daysum[ year]);
  solar[ year] = cdo( "setname,solar", daymean[ year]);
  // precip[ year]= cdo( "-O daysum -setname,precip -selname,APCP", a);
  // solar[ year]= cdo( "-O daymean -setname,solar -selname,DSWRF", a);
}
