%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%    README (runfile) file explaining the purpose and order
%%%%    to use the scripts
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% constants for plots script
run("Script_ColorDatabase.m")
% this will produce matrices with RGB values for nice colors in the figures

%%%% Analysis of AR5 models
% 1)
run("Script_FitRafelskiModel.m")
% this run will load the historical emission and atmospheric CO2
% observations and will use the Rafelski model to fit this data.
% It outputs the optimized paramters using least squares, processed
% observations and atmospheric CO2 predictions

% 2)
run("Script_ErrorProcessAnalysis.m")
% this will analyze the error process, i.e. residuals of the Rafelski fit
% and output the values for AR1 process. Later this part will be outsourced
% to R

% 3)
run("Script_InterpolateMonthlyAR5emissions.m")
% this script reads the different AR5 2° and BAU scenarios and produces
% monthly interpolated versions of it

% 4)
run("Script_PredictionAtmosphericCO2_RafelskiModel.mat")
% this script uses the optimal parameters for the Rafelski model and will
% produce predicitions of the atmospheric CO2 from it for different AR5
% scenarios

% 5)
run("Script_DetectionTimeEstimates_AR5.mat")
% this script applies the detection time protocoll to the paired AR5
% scenarios and outputs the detection time and some statistics

%%%% Comparison of Peters et al and Schwartzman et al
% 1)
run("Script_DetectionTimeEstimates_AR5.mat")
% this script plots atmospheric growth rates from the Peters et al versus
% our observation versions to understand the discrepancy

% 2)
run("Script_ReproduceArminsResults.mat")
% this script reproduces the plots from Schwartzman et al in order to check
% that the code is working properly




