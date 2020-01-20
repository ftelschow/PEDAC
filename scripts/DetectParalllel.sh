#!/bin/bash
########################################################################
####  script for paralization of 
########################################################################
matlab -nodesktop -nosplash -r "Script_IIASA_Detection_all( [1 10], 2010, "interpolation", 1 ); exit" &
matlab -nodesktop -nosplash -r "Script_IIASA_Detection_all( [11 20], 2010, "interpolation", 2 ); exit" &
matlab -nodesktop -nosplash -r "Script_IIASA_Detection_all( [21 30], 2010, "interpolation", 3 ); exit" &
matlab -nodesktop -nosplash -r "Script_IIASA_Detection_all( [31 40], 2010, "interpolation", 4 ); exit" &
matlab -nodesktop -nosplash -r "Script_IIASA_Detection_all( [41 50], 2010, "interpolation", 5 ); exit" &
matlab -nodesktop -nosplash -r "Script_IIASA_Detection_all( [51 60], 2010, "interpolation", 6 ); exit" &
matlab -nodesktop -nosplash -r "Script_IIASA_Detection_all( [61 74], 2010, "interpolation", 7 ); exit" &
