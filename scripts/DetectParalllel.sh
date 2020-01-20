#!/bin/bash
########################################################################
####  script for paralization of 
########################################################################
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [1 5], 2010, "interpolation", 1 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [6 10], 2010, "interpolation", 2 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [11 15], 2010, "interpolation", 3 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [16 20], 2010, "interpolation", 4 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [21 25], 2010, "interpolation", 5 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [26 30], 2010, "interpolation", 6 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [31 35], 2010, "interpolation", 7 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [36 40], 2010, "interpolation", 8 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [41 45], 2010, "interpolation", 9 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [46 50], 2010, "interpolation", 10 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [51 55], 2010, "interpolation", 11 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [56 60], 2010, "interpolation", 12 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [61 65], 2010, "interpolation", 13 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [66 70], 2010, "interpolation", 14 ); exit" &
matlab -nodesktop -nosplash -r "load(paths.mat'); addpath(path); Script_IIASA_Detection_all( [71 74], 2010, "interpolation", 15 ); exit" &