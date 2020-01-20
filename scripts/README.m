%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%    README (runfile) file explaining the purpose and order
%%%%    to use the scripts
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% script constructs .mat containing the paths for saving the images and
%%%% results. Please change accordingly to your path before running!
run("/home/drtea/Research/Projects/CO2policy/PEDAC/scripts/Script_Paths.m")

%%%% script saving global color schemes and constants for plots
run("/home/drtea/Research/Projects/CO2policy/PEDAC/scripts/Script_ColorDatabase.m")

%%%% Preparing the data and getting fitting parameters
% 1)
% this run will load the historical emission and atmospheric CO2
% observations and will use the Joos model to fit this data.
% It outputs the optimized parameters using least squares, processed
% observations of emissions and atmospheric CO2 predictions
run("/home/drtea/Research/Projects/CO2policy/PEDAC/scripts/Script_FitJoosModel.m")

% 2)
% this script reads the different emission scenarios and returns a .mat file
% containing the monthly interpolated scenarios
run("/home/drtea/Research/Projects/CO2policy/PEDAC/scripts/Script_IIASA_emissions.m")

% 3)
% this script uses the optimal parameters for the Rafelski model and will
% produce predicitions of the atmospheric CO2 from it for different AR5
% scenarios
run("/home/drtea/Research/Projects/CO2policy/PEDAC/scripts/Script_IIASA_ProjectionAtmosphericCO2_JoosModel.m")

% 4)
% this script applies the detection time protocoll to the paired AR5
% scenarios and outputs the detection time and some statistics
run("/home/drtea/Research/Projects/CO2policy/PEDAC/scripts/Script_IIASA_Detection.m")


% %%%% Comparison of Peters et al and Schwartzman et al
% % 1)
% run("Script_DetectionTimeEstimates_AR5.m")
% % this script plots atmospheric growth rates from the Peters et al versus
% % our observation versions to understand the discrepancy
% 
% % 2)
% run("Script_ReproduceArminsResults.mat")
% % this script reproduces the plots from Schwartzman et al in order to check
% % that the code is working properly
% 



