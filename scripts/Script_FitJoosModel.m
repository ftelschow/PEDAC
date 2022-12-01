%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%    This file fits the Joos model to observed atmospheric CO2
%%%%    data.
%%%%
%%%%    Output: .mat containing the past total emissions interpolated to
%%%%            monthly resolution
%%%%            .mat file containing optimised parameters and predicted
%%%%            CO2 for the historical record
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear workspace
clear all
close all

%%%% load mat file containing the paths for output
load( 'paths.mat' )
cd(path_PEDAC)

% load color data base for plots
load( strcat( path_work, 'colors.mat' ) )

%%%% Constants
% convert constant from gton to ppm
gtonC_2_ppm = 1 / 2.124; % Quere et al 2017
% convert C to CO2
C2CO2 = 3.664; %44.01/12.011;

%%%% graphical paramters
sf   = 19;
figw = 650;
figh = 500;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Load available real atmospheric CO2 data and plot it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% loads observed CO2 data, Rafelski 2009, CO2a_obs in ppm CO2
load( strcat( path_data, 'AtmosphereCO2/dataObservedCO2.mat' ) );
CO2_Scripps = CO2a_obs;
% save minimal year in the observation data
CO2_Scripps( :, 1 ) = 1765 : 1/12 : 2016;
% remove unneccessary data
clear dpCO2a_obs dtdelpCO2a_obs CO2a_obs

%%%% read GCP historical data sheet,
%%%% 1750: 277 ± 3 ppm or 1870: 288 ± 3 ppm from GCP2018, p. 2154 can be used to 
%%%% estimate total CO2 in the atmosphere
CO2_GCP_hist_gr = readtable( strcat( path_data, 'Misc/GCP2018_historical_sheet.csv' ) );
CO2_GCP_hist_gr = CO2_GCP_hist_gr( :, [ 1, 4 ] );
CO2_GCP_hist_gr = CO2_GCP_hist_gr.Variables;
% compute atmospheric CO2 estimates
Ia = find( CO2_GCP_hist_gr( :, 1 ) == 1750 );
Ie = find( CO2_GCP_hist_gr( :, 1 ) == 2004 );
CO2_GCP_hist1750 = CO2_GCP_hist_gr( Ia : Ie, : );
CO2_GCP_hist1750( :, 2 ) = 277 + cumsum( CO2_GCP_hist_gr( Ia : Ie, 2 ) * gtonC_2_ppm );
% compute atmospheric CO2 estimates
Ia = find( CO2_GCP_hist_gr( :, 1 ) == 1870 );
Ie = find( CO2_GCP_hist_gr( :, 1 ) == 2004 );
CO2_GCP_hist1870 = CO2_GCP_hist_gr( Ia : Ie, : );
CO2_GCP_hist1870( :, 2 ) = 288 + cumsum( CO2_GCP_hist_gr( Ia : Ie, 2 ) * gtonC_2_ppm );

%%%% read GCP growth rate recent data sheet
CO2_GCP_recent_gr = readtable( strcat( path_data, 'Misc/GCP2018_recent_sheet.csv' ) );
CO2_GCP_recent_gr = CO2_GCP_recent_gr( :, [ 1, 4 ] );
CO2_GCP_recent_gr = CO2_GCP_recent_gr.Variables;

%%%% load the NOAA data
CO2_NOAA = readtable( strcat( path_data, 'AtmosphereCO2/Global_NOAA_CO2.txt' ) );
CO2_NOAA = table2array( CO2_NOAA( 1 : end, [ 1 2 ] ) );

%%%% plot the results
figure( 1 ), clf, hold on
set( gcf, 'Position', [ 300 300 figw figh ] );
set( gcf,'PaperPosition', [ 300 300 figw figh ] )
set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
set( groot, 'defaultLegendInterpreter', 'latex' );

% Plot the atmospheric CO2 observations
plot( CO2_Scripps( :, 1 ), CO2_Scripps( :, 2 ), 'color', BrightCol( 1, : ),...
      'LineWidth', 1.5, 'LineStyle', "-")
plot( CO2_NOAA( :, 1 ), CO2_NOAA( :, 2 ), 'color', BrightCol( 3, : ),...
      'LineWidth', 1.5, 'LineStyle', "-")
plot( CO2_GCP_hist1750( :, 1 ), CO2_GCP_hist1750( :, 2 ), 'color',...
      BrightCol( 5, : ), 'LineWidth', 1.5, 'LineStyle', "-")
plot( CO2_GCP_hist1870( :, 1 ), CO2_GCP_hist1870( :, 2 ), 'color',...
      BrightCol( 5, : ), 'LineWidth', 1.5, 'LineStyle', "--")  
xlim( [ 1950, 2020 ] )
h = title( 'Mean Atmospheric CO2' ); set( h, 'Interpreter', 'latex' );
h = xlabel( 'year' ); set( h, 'Interpreter', 'latex' );
h = ylabel( 'ppm/year' ); set( h, 'Interpreter', 'latex' );
h = legend( 'Rafelski (2009)',...
            'NOAA global annual mean',...
            'GCP 1750',...
            'GCP 1870',...
            'location','northwest' ); set( h, 'Interpreter', 'latex' );
set( gca, 'fontsize', sf );
hold off
  
set( gcf, 'papersize', [ 12 12 ] )
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
print( strcat( path_pics, strcat( ...
       'Observations_PastAtmosphericCO2_ppm_different_sources.png' ) ),...
       '-dpng')

clear fig h


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Load past CO2 emissions for land use and fossil fuel and
%%%% process them to be input into Joos model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load global carbon project data, data in GtC/year
GCP_historical = readtable( strcat( path_data,...
                            'Misc/GCP2018_historical_sheet.csv' ) );
GCP_historical = GCP_historical( :, 1:end-1 ).Variables;
GCP_historical( :, 2:end ) = GCP_historical( :, 2:end ) * gtonC_2_ppm;
FF_GCP = interpolData( 12, GCP_historical( 2:end, [ 1 2 ] ), 'pchip' );
I = find( GCP_historical( :, 1 ) == 1850 );
LU_GCP = interpolData( 12, [ [ FF_GCP( 1, 1 ), 0 ]; [ 1800, 0.06 ];...
                             [ 1820, 0.12 ]; GCP_historical( I:end, [ 1 3 ] ) ],...
                           'makima' );

% load Houghton and Boden emission data in GtC/year
FF_Boden = readtable( strcat( path_data, 'FossilFuel/dataFF_Boden_2016.csv' ) );
FF_Boden = FF_Boden( :, 1:end ).Variables;
FF_Boden(:,2) = FF_Boden( :, 2 ) * gtonC_2_ppm;

FF_Boden = interpolData( 12, FF_Boden, 'pchip' );

LU_Houghton = readtable( strcat( path_data,'LandUse/dataLU_Houghton_2016.csv' ) );
LU_Houghton = LU_Houghton( :, 1:end ).Variables;
LU_Houghton( :, 2 ) = LU_Houghton( :, 2 ) * gtonC_2_ppm;
I = find( LU_Houghton( :, 1 ) == 1959 );
LU_Houghton = interpolData( 12, [ [ FF_Boden( 1, 1 ), 0]; [ 1800, 0.06 ];...
                                [ 1820, 0.12 ];...
                                LU_Houghton( I:end, : ) ],...
                                'makima' );

figure(1), clf, hold on
set( gcf, 'Position', [ 300 300 figw figh ] );
set( gcf,'PaperPosition', [ 300 300 figw figh ] )
set( groot, 'defaultAxesTickLabelInterpreter','latex' );
set( groot, 'defaultLegendInterpreter','latex' );

% Plot past emissions
line( GCP_historical( :, 1 ), GCP_historical( :, 2 ), 'color',...
      BrightCol( 5, : ), 'LineWidth', 1.5 )
line( FF_Boden( :, 1 ), FF_Boden( :, 2 ), 'color',...
      BrightCol( 6, : ), 'LineWidth', 1.5 )
line( GCP_historical( :, 1 ), GCP_historical( :, 3 ),...
      'color', BrightCol( 3, : ), 'LineWidth', 1.5 )
line( LU_Houghton( :, 1 ), LU_Houghton( :, 2 ),...
      'color', BrightCol( 4, : ), 'LineWidth', 1.5 )
  
xlim( [ 1763 2017 ] )
h = title( 'Past CO2 Emissions' ); set( h, 'Interpreter', 'latex' );
h = xlabel( 'year' ); set( h, 'Interpreter', 'latex' );
h = ylabel( 'C [ppm/year]' ); set( h, 'Interpreter', 'latex' );
h = legend( 'fossil fuel Boden (2016)',...
            'fossil fuel GCP',...
            'land use GCP (Houghton 2017/Hansis)',...
            'land use Hansis(2016)',...
            'location','northwest'); set(h, 'Interpreter', 'latex' );
set( gca, 'fontsize', sf );
hold off

set( gcf, 'papersize', [ 12 12 ] )
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
print( strcat( path_pics, strcat( 'Observations_PastEmissions_varsources.png')), '-dpng')

clear fig h

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Compute total emissions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% total emissions used in the paper
PastTotalCO2emissionScripps = LU_Houghton;
PastTotalCO2emissionScripps( :, 2 ) = LU_Houghton( :, 2 ) + FF_Boden( :, 2 );
% total emissions from GCP data
PastTotalCO2emissionGCP = LU_GCP;
PastTotalCO2emissionGCP( :, 2 ) = LU_GCP( :, 2 ) + FF_GCP( :, 2 );

% plot the total emissions
figure( 2 ), clf, hold on
set( gcf, 'Position', [ 300 300 figw figh ] );
set( gcf, 'PaperPosition', [ 300 300 figw figh ] )
set( groot, 'defaultAxesTickLabelInterpreter','latex' );
set( groot, 'defaultLegendInterpreter', 'latex' );

% Plot past emissions
line( PastTotalCO2emissionScripps(:, 1 ), PastTotalCO2emissionScripps( :, 2 ),...
      'color', BrightCol( 1, : ), 'LineWidth', 1.5 )
line( PastTotalCO2emissionGCP(:, 1 ), PastTotalCO2emissionGCP( :, 2 ),...
      'color', BrightCol( 2, : ), 'LineWidth', 1.5 )
  
xlim( [ LU_GCP( 1, 1 ) 2017 ] )
h = title( 'Past CO2 Emissions' ); set( h, 'Interpreter', 'latex' );
h = xlabel( 'year' ); set( h, 'Interpreter', 'latex' );
h = ylabel( 'C [ppm/year]'); set( h, 'Interpreter', 'latex' );
h = legend( 'past total CO2 paper',...
            'past total CO2 GCP', 'location', 'northwest'...
          );
set( h, 'Interpreter', 'latex' );
set( gca, 'fontsize', sf );
hold off

set( gcf, 'papersize', [ 12 12 ] )
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
print( strcat( path_pics, strcat( 'Observations_PastTotalEmissionsGtCO2.png' ) ),...
       '-dpng')

clear h fig fig_pos startYear_obs I Ia Ie

save( strcat( path_data, 'Emissions_PastMontly.mat'),...
      'PastTotalCO2emissionScripps', 'PastTotalCO2emissionGCP', 'CO2_Scripps',...
       'CO2_NOAA' )
  

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Fit optimal parameters for Joos Model by least squares
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% used observations for fitting
CO2_obs = CO2_Scripps;
beta    = 0.287;

% start and end year for the period we want to optimize the LS fit for
opt_1765 = [ CO2_Scripps( 1, 1 ) 2010 ];
opt_1958 = [ 1958 2010 ];

%%%% NOAA and GCP minimization
% define the loss function for optimization
minLoss1765 = @(x) LSE_Params( [ x beta ], PastTotalCO2emissionScripps,...
                               CO2_obs, opt_1765( 1 ), opt_1765( 2 ) );
minLoss1958 = @(x) LSE_Params( [ x beta ], PastTotalCO2emissionScripps,...
                               CO2_obs, opt_1958( 1 ), opt_1958( 2 ) );
% optimize parameters
[ xoptScripps1765, ~, exitflag ] = fminsearch( minLoss1765, [ 278 0.77 ] );
exitflag
xoptScripps1765  = [ xoptScripps1765 beta ];

[ xoptScripps1958, ~, exitflag ] = fminsearch( minLoss1958, [ 278 0.77 ] );
exitflag
xoptScripps1958  = [ xoptScripps1958 beta ];

%%%% GCP minimization
% define the loss function for optimization

minLoss1765 = @(x) LSE_Params( [ x beta ], PastTotalCO2emissionGCP,...
                               CO2_obs, opt_1765( 1 ), opt_1765( 2 ) );
minLoss1958 = @(x) LSE_Params( [ x beta ], PastTotalCO2emissionGCP,...
                               CO2_obs, opt_1958( 1 ), opt_1958( 2 ) );
% optimize parameters
[ xoptGCP1765, ~, exitflag ] = fminsearch( minLoss1765, [ 278 0.77 ] );
exitflag
xoptGCP1765  = [ xoptGCP1765 beta ];

[ xoptGCP1958, ~, exitflag ] = fminsearch( minLoss1958, [ 278 0.77 ] );
exitflag
xoptGCP1958  = [ xoptGCP1958 beta ];

clear ans exitflag minLoss1765 minLoss1958

% save the fitted past atmospheric CO2
save( strcat(path_data, 'Fit_JoosModelOptim.mat'), 'xoptGCP1958',...
      'xoptGCP1765', 'xoptScripps1958', 'xoptScripps1765', 'PastTotalCO2emissionGCP',...
      'PastTotalCO2emissionScripps')
  
  
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Plot the fits of Joos Model against the observations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load( strcat( path_data, 'Fit_JoosModelOptim.mat') )
%%%% compute the fits with the optimised parameters
Ie1 = find( PastTotalCO2emissionScripps( :, 1 ) == 2010 );
Ie2 = find( PastTotalCO2emissionGCP( :, 1 ) == 2010 );
Ie3 = find( CO2_Scripps( :, 1 ) == 2010 );
aCO2_Scripps1765 = JoosModel( PastTotalCO2emissionScripps( 1:Ie1, : ),...
                              xoptScripps1765 );
aCO2_Scripps1958 = JoosModel( PastTotalCO2emissionScripps( 1:Ie1, : ),...
                              xoptScripps1958 );
aCO2_GCP1765 = JoosModel( PastTotalCO2emissionGCP( 1:Ie2, : ), xoptGCP1765 );
aCO2_GCP1958 = JoosModel( PastTotalCO2emissionGCP( 1:Ie2, : ), xoptGCP1958 );

figure(2),clf, hold on
set( gcf, 'Position', [ 300 300 figw figh ] );
set( gcf, 'PaperPosition', [ 300 300 figw figh ] )
set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
set( groot, 'defaultLegendInterpreter', 'latex' );

% plot values
line( aCO2_Scripps1765( :, 1 ), aCO2_Scripps1765( :, 2 ),...
      'Color', colMat( 1, : ), 'LineWidth', 1.2, 'LineStyle', '-');
line( aCO2_Scripps1958( :, 1 ), aCO2_Scripps1958( :, 2 ),...
      'Color', colMat( 2, : ), 'LineWidth', 1.2, 'LineStyle', '-');
line( aCO2_GCP1765( :, 1 ), aCO2_GCP1765( :, 2 ), 'Color', colMat( 3, : ),...
      'LineWidth', 1.2, 'LineStyle', '-' );
line( aCO2_GCP1958( :, 1 ), aCO2_GCP1958( :, 2 ), 'Color', colMat( 4, : ),...
      'LineWidth', 1.2, 'LineStyle', '-' );
line( CO2_obs( 1:Ie3, 1 ), CO2_obs( 1:Ie3,2), 'Color', [ 0 0 0 ],...
      'LineWidth', 1.5 );

% define axis and labels
ylim( [ 260 450 ] )
xlim( [ 1765, 2020 ] )
h = legend( '1765-2015, Boden/Houghton',...
            '1958-2015, Boden/Houghton',...
            '1765-2015, GCP',...
            '1958-2015, GCP',...
            'observed Scripps',...
            'location','northwest' ); set( h, 'Interpreter', 'latex' );
h = ylabel( 'Atmospheric ${\rm CO_2}$ [ppm]' ); set( h, 'Interpreter', 'latex' );
h = xlabel( 'year' ); set(h, 'Interpreter', 'latex' );
h = title( 'Modeled vs. Observed CO2' ); set( h, 'Interpreter', 'latex' );
grid
set( gca, 'fontsize', sf );

% print options
fig = gcf;
set( gcf, 'papersize', [ figw * 2.25 figh * 2.25 ] );
fig.InvertHardcopy = 'off';
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
print( strcat( path_pics, "JoosFit_variousSourcesBeta34.png" ), '-dpng' )
hold off