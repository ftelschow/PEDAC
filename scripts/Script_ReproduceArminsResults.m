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
path      = '/home/drtea/Research/Projects/CO2policy/PEDAC';
path_pics = '/home/drtea/Research/Projects/CO2policy/pics/';
path_data = '/home/drtea/Research/Projects/CO2policy/PEDAC/data/';
cd( path )
clear path

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

% %% %%%%%%%%%%%%%%%%%%%%%%% New proposed method %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Check whether control is kept and plot the results
% %q = [ ( 1/30 : 1/30 : 1 ) * 0.05, 0.05 + (( 1/29 : 1/29 : 1 ) * 0.02) ];
% IMBALANCE = generate_AR( Msim, T, rho, sigma );
% thresholdsF  = get_Thresholds( IMBALANCE, 0.05 );
% 
% % generate AR process for imbalance
% IMBALANCE = generate_AR( Msim, T, rho, sigma );
% 
% FalseReject   = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 2 ) ]', thresholdsF );
% TrueRejectFT0 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 3 ) ]', thresholdsF );
% TrueRejectFT1 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 4 ) ]', thresholdsF );
%                             
% plot_Detection_cdf( [ FalseReject; TrueRejectFT0 ]', 2017, [0.05, 0.5, 0.95],...
%                     0.05, strcat( path_pics,...
%                     '/studyNewMethod/NaiveControlR0_sd', num2str( sigma ), '.png' ) )
% plot_Detection_cdf( [ FalseReject; TrueRejectFT1 ]', 2017, [0.05, 0.5, 0.95],...
%                     0.05, strcat( path_pics,...
%                     '/studyNewMethod/NaiveControlR1_sd', num2str( sigma ), '.png' ) )
% %% %
% IMBALANCE = generate_AR( Msim, T, rho, sigma );
% 
% thresholdsA0 = -repmat( thresholdArmin0, [1 T] );
% 
% FalseRejectA0 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 2 ) ]', thresholdsA0 );
% TrueRejectA0  = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 3 ) ]', thresholdsA0 );
%                             
% plot_Detection_cdf( [ FalseRejectA0; TrueRejectA0 ]', 2017, [0.05, 0.5, 0.95],...
%                     0.05, strcat( path_pics,...
%                     '/studyNewMethod/ArminTestR0_sd', num2str( sigma ), '.png' ) )
% 
% %% % Check performance against similar calibration
% dy = dyearArmin0 ;
% q0 = [ ( 1 / dy : 1 / dy : 1 ) * 0.05, 0.05 + ...
%        ( ( 1 / ( T - dy ) : 1 / ( T - dy ) : 1 ) ) ...
%        * ( probsArmin0( end, 1 ) - 0.05 ) ];
% dy = dyearArmin1;
% q1 = [ ( 1 / dy : 1 / dy : 1 ) * 0.05, 0.05 + ...
%        ( 1 / ( T - dy ) : 1 / ( T - dy ) : 1 ) ...
%        * ( probsArmin1( end, 1 ) - 0.05 ) ];
% 
% IMBALANCE    = generate_AR( Msim, T, rho, sigma );
% thresholdsF0 = get_Thresholds_sim( IMBALANCE, q0 );
% thresholdsF1 = get_Thresholds_sim( IMBALANCE, q1 );
% 
% % generate AR process for imbalance
% IMBALANCE = generate_AR( Msim, T, rho, sigma );
% FalseRejectFT0   = get_Detection_NewMethod( IMBALANCE, zeros( [ 2, T ] ),...
%                                             thresholdsF0 );
% TrueRejectFT0 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 3 ) ]', thresholdsF0 );
% FalseRejectFT1   = get_Detection_NewMethod( IMBALANCE, zeros( [ 2, T ] ),...
%                                             thresholdsF1 );
% TrueRejectFT1 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 4 ) ]', thresholdsF1 );
% 
% % 
% plot_Detection_cdf( [ FalseRejectFT0; TrueRejectFT0 ]', 2017, [0.05, 0.5, 0.95],...
%                     0.05, strcat( path_pics,...
%                     '/studyNewMethod/SimilarControlR0_sd', num2str( sigma ), '.png' ) )
% plot_Detection_cdf( [ FalseRejectFT1; TrueRejectFT1 ]', 2017, [0.05, 0.5, 0.95],...
%                     0.05, strcat( path_pics,...
%                     '/studyNewMethod/SimilarControlR1_sd', num2str( sigma ), '.png' ) )
% 
% %% % Check performance against squareroot
% dy = dyearArmin0 + 1;
% q0 = [ sqrt( 1 / dy : 1 / dy : 1 ) * 0.05, 0.05 + ...
%        sqrt( ( 1 / ( T - dy ) : 1 / ( T - dy ) : 1 ) )...
%        * ( probsArmin0( end, 1 ) - 0.05 ) ];
% dy = dyearArmin1 + 1;
% q1 = [ sqrt( 1 / dy : 1 / dy : 1 ) * 0.05, 0.05 + ...
%        sqrt( 1 / ( T - dy ) : 1 / ( T - dy ) : 1 ) ...
%        * ( probsArmin1( end, 1 ) - 0.05 ) ];
% IMBALANCE = generate_AR( Msim*5, T, rho, sigma );
% thresholdsF0  = get_Thresholds_sim( IMBALANCE, q0 );
% thresholdsF1  = get_Thresholds_sim( IMBALANCE, q1 );
% 
% figure(1), clf, hold on
% plot(thresholdsF0)
% plot(thresholdsA0)
% 
% % generate AR process for imbalance
% IMBALANCE = generate_AR( Msim, T, rho, sigma );
% FalseRejectFT0   = get_Detection_NewMethod( IMBALANCE, zeros( [ 2, T ] ),...
%                                             thresholdsF0 );
% TrueRejectFT0 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 3 ) ]', thresholdsF0 );
% FalseRejectFT1   = get_Detection_NewMethod( IMBALANCE, zeros( [ 2, T ] ),...
%                                             thresholdsF1 );
% TrueRejectFT1 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 4 ) ]', thresholdsF1 );
% 
% % 
% plot_Detection_cdf( [ FalseRejectFT0; TrueRejectFT0 ]', 2017, [0.05, 0.5, 0.95],...
%                     0.05, strcat( path_pics,...
%                     '/studyNewMethod/RootQControlR0_sd', num2str( sigma ), '.png' ) )
% plot_Detection_cdf( [ FalseRejectFT1; TrueRejectFT1 ]', 2017, [0.05, 0.5, 0.95],...
%                     0.05, strcat( path_pics,...
%                     '/studyNewMethod/RootQControlR1_sd', num2str( sigma ), '.png' ) )
% 
% %% % Check performance against square
% dy = dyearArmin0 + 1;
% q0 = [ ( 1 / dy : 1 / dy : 1 ).^2 * 0.05, 0.05 + ...
%        ( ( 1 / ( T - dy ) : 1 / ( T - dy ) : 1 ) ).^2 ...
%        * ( probsArmin0( end, 1 ) - 0.05 ) ];
% dy = dyearArmin1 + 1;
% q1 = [ ( 1 / dy : 1 / dy : 1 ).^2 * 0.05, 0.05 + ...
%        ( 1 / ( T - dy ) : 1 / ( T - dy ) : 1 ).^2 ...
%        * ( probsArmin1( end, 1 ) - 0.05 ) ];
% IMBALANCE = generate_AR( Msim*5, T, rho, sigma );
% thresholdsF0  = get_Thresholds_sim( IMBALANCE, q0 );
% thresholdsF1  = get_Thresholds_sim( IMBALANCE, q1 );
% 
% figure( 1 ), clf, hold on
% plot( thresholdsF0 )
% plot( thresholdsA0 )
% 
% 
% % generate AR process for imbalance
% IMBALANCE = generate_AR( Msim, T, rho, sigma );
% FalseRejectFT0   = get_Detection_NewMethod( IMBALANCE, zeros( [ 2, T ] ),...
%                                             thresholdsF0 );
% TrueRejectFT0 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 3 ) ]', thresholdsF0 );
% FalseRejectFT1   = get_Detection_NewMethod( IMBALANCE, zeros( [ 2, T ] ),...
%                                             thresholdsF1 );
% TrueRejectFT1 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 4 ) ]', thresholdsF1 );
% 
% % 
% plot_Detection_cdf( [ FalseRejectFT0; TrueRejectFT0 ]', 2017, [0.05, 0.5, 0.95],...
%                     0.05, strcat( path_pics,...
%                     '/studyNewMethod/SquareQControlR0_sd', num2str( sigma ), '.png' ) )
% plot_Detection_cdf( [ FalseRejectFT1; TrueRejectFT1 ]', 2017, [0.05, 0.5, 0.95],...
%                     0.05, strcat( path_pics,...
%                     '/studyNewMethod/SquareQControlR1_sd', num2str( sigma ), '.png' ) )
% 
% %% % Check performance against square
% IMBALANCE = generate_AR( Msim, T, rho, sigma );
% thresholdsF0  = get_Thresholds( IMBALANCE, 0.05 );
% 
% % generate AR process for imbalance
% IMBALANCE = generate_AR( Msim, T, rho, sigma );
% FalseRejectFT0   = get_Detection_NewMethod( IMBALANCE, zeros( [ 2, T ] ),...
%                                             thresholdsF0 );
% TrueRejectFT0 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 3 ) ]', thresholdsF0 );
% FalseRejectFT1   = get_Detection_NewMethod( IMBALANCE, zeros( [ 2, T ] ),...
%                                             thresholdsF1 );
% TrueRejectFT1 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 4 ) ]', thresholdsF0 );
% 
% % 
% plot_Detection_cdf( [ FalseRejectFT0; TrueRejectFT0 ]', 2017, [0.05, 0.5, 0.95],...
%                     0.05, strcat( path_pics,...
%                     '/studyNewMethod/test.png' ) )
% plot_Detection_cdf( [ FalseRejectFT1; TrueRejectFT1 ]', 2017, [0.05, 0.5, 0.95],...
%                     0.05, strcat( path_pics,...
%                     '/studyNewMethod/test.png' ) )
% 
%                 
% %%
%             
% 
% dyFT0 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 3 ) ]', thresholdsF );
% 
% [ get_Quants( dyFT0', [0.25, 0.5, 0.75, 0.95] ),...
%   get_Quants( probsArmin0(:,2), [0.25, 0.5, 0.75, 0.95] ) ]
% 
% dyFT1 = get_Detection_NewMethod( IMBALANCE, [ PetersFuture( :, 2 ),...
%                                 PetersFuture( :, 4 ) ]', thresholdsF );
% [ get_Quants( dyFT1', [0.25, 0.5, 0.75, 0.95] ),...
% get_Quants( probsArmin1(:,2), [0.25, 0.5, 0.75, 0.95] ) ]