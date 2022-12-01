%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%        This file reproduces results from Schwartzman & Keeling (2020)
%%%%
%%%%        Authors: Fabian Telschow
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

% set correct working directory
load( 'paths.mat' )
cd(path_PEDAC)

%%%% Constants
% convert constant from gton to ppm: 1 ppm CO2 = 2.31 gton CO2
gtonC_2_ppmC = 1 / 2.12; % Quere et al 2017
C2CO2        = 44.01 / 12.011;   % Is that correct?

%%%% standard color scheme for color blind and grey scale figures, cf.
%%%% 'https://personal.sron.nl/~pault/'
BrightCol  = [ [68 119 170];...    % blue
               [102 204 238];...   % cyan
               [34 136 51];...     % green
               [204 187 68];...    % yellow
               [238 102 119];...   % red
               [170 51 119];...    % purple
               [187 187 187] ] / 255; % grey
          
          
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = readtable( strcat( path_data, 'Misc/Peters2017_Fig2_past.txt' ) );
PetersPast = T.Variables;

%%%% Plot the atmospheric growth rate from Peters et al and from the data
%%%% used in this analysis
figure( 8 ), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig ] );
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig ] )
set(groot, 'defaultAxesTickLabelInterpreter', 'latex' );
set(groot, 'defaultLegendInterpreter', 'latex' );

plot( PetersPast( :, 1 ), PetersPast( :, 2 ), 'LineWidth', 1.5, 'Color',...
      BrightCol( 2, : ) )
plot( PetersPast( :, 1 ), PetersPast( :, 3 ), 'LineWidth', 1.5, 'Color',...
      BrightCol( 1, : ) )  
xlim( [ PetersPast( 1, 1 ) PetersPast( end, 1 ) ] )
h = title( 'Comparison of Atmospheric Growth Rate with Peters et al' );
set( h, 'Interpreter', 'latex' );
h = xlabel( 'years' );  set( h, 'Interpreter', 'latex' );
h = ylabel( 'growth rate [GtCO2/year]' );  set( h, 'Interpreter', 'latex' );
h = legend( 'Peters et al observed', 'Peters et al reconstructed',...
            'My observation', 'My Reconstruction', 'Output from Joos Model',...
            'location', 'northwest');  set( h, 'Interpreter', 'latex' );
grid
set( gca, 'fontsize', 14 );

set( gcf, 'papersize', [ 12 12 ] )
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
print( strcat( path_pics, 'AtmosphericGrowthRate_Comp_Peters.png' ), '-dpng' )
hold off

clear tmp tmp2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%% Analyze data from Peters et al and Armin
T = readtable( strcat( path_data, 'Misc/Peters2017_Fig2_past.txt' ) );
PetersPast = T.Variables;
T = readtable( strcat( path_data, 'Misc/Peters2017_Fig2_future2050.txt' ) );
PetersFuture = T.Variables;

% Parameters for AR process
Msim  = 1e5;
T     = size( PetersFuture, 1 );
rho   = 0.48;
sigma = 3;

q = [ 0.05; 0.95 ];

% Generate AR process for imbalance
IMBALANCE = generate_AR( Msim, T, rho, sigma );

drift0 = [ PetersFuture( :, 2 ), PetersFuture( :, 3 ) ];
drift1 = [ PetersFuture( :, 2 ), PetersFuture( :, 4 ) ];

%%%%%%%%% Reproduce Schwartzman Keeling (2020) plot
% Peter et al threshold
thresholds = 2 * sigma;
false_detect_Peter0 = get_Detection( IMBALANCE, zeros( [ T 2 ] ), -thresholds );
true_detect_Peter0  = get_Detection( IMBALANCE, drift0, -thresholds );
true_detect_Peter1  = get_Detection( IMBALANCE, drift1, -thresholds );

plot_Detection_cdf( [ false_detect_Peter0; true_detect_Peter0 ], 2017,...
                    [0.05, 0.5, 0.95 ], q,...
                    strcat( path_pics, 'reproduce/Reproduce_PeterR0_sd',...
                    num2str( sigma ), '.png' ) );
plot_Detection_cdf( [ false_detect_Peter0; true_detect_Peter1 ], 2017,...
                    [0.05, 0.5, 0.95 ], q,...
                    strcat( path_pics, 'reproduce/Reproduce_PeterR1_sd',...
                    num2str( sigma ), '.png' ) );

% Armin et al method
[ true_detect_SK0, thr_SK0 ] = DetectionDelay_SK( IMBALANCE, drift0, q );
[ true_detect_SK1, thr_SK1 ] = DetectionDelay_SK( IMBALANCE, drift1, q );
false_detect_SK0 = get_Detection( IMBALANCE, zeros( [ T 2 ] ), thr_SK0 );
false_detect_SK1 = get_Detection( IMBALANCE, zeros( [ T 2 ] ), thr_SK1 );
                             
plot_Detection_cdf( [ false_detect_SK0; true_detect_SK0 ], 2017,...
                    [0.05, 0.5, 0.95 ], q,...
                    strcat( path_pics, 'reproduce/Reproduce_SKR0_sd',...
                    num2str( sigma ), '.png' ) );
plot_Detection_cdf( [ false_detect_SK1; true_detect_SK1 ], 2017,...
                    [0.05, 0.5, 0.95 ], q,...
                    strcat( path_pics, 'reproduce/Reproduce_SKR1_sd',...
                    num2str( sigma ), '.png' ) );