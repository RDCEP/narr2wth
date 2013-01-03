// ./wth_gen/nc_wth_gen 1979 1981 data/nc data/wth GENERIC1.WTH 20 1

type file;

// file grid_hwsd<"/project/joshuaelliott/narr/data/grid_hwsd.txt">;

// string cells[] = readData( grid_hwsd);

app (file outFile, file errFile) nc_wth_gen( int start, int end, string dataPath, string wthPath, string fn, int nProc, int thisProc) {
  nc_wth_gen start end dataPath wthPath fn nProc thisProc stdout=@outFile stderr=@errFile;
}

// app nc_wth_gen( int start, int end, string dataPath, string wthPath, string fn, string cell) {
//   nc_wth_gen start end dataPath wthPath fn cell;
// }

file wthGenOut[]<simple_mapper;
  location="data/wth",
  prefix="wthGen.",
  suffix=".out">;

file wthGenErr[]<simple_mapper;
  location="data/wth",
  prefix="wthGen.",
  suffix=".err">;

int totProcs = 20;

foreach proc in [1:totProcs] {
  ( wthGenOut[ proc], wthGenErr[ proc]) = nc_wth_gen( 1979, 2012, "/project/joshuaelliott/narr/data/nc", "/project/joshuaelliott/narr/data/wth", "GENERIC1.WTH", totProcs, proc);
} 

// foreach cell in cells {
//   nc_wth_gen( 1979, 2012, "/project/joshuaelliott/narr/data/nc", "/project/joshuaelliott/narr/data/wth", "GENERIC1.WTH", cell);
// } 
