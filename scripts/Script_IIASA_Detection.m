%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%        This file applies Armins procedure for detection
%%%%        times to ahmeds new data
%%%%
%%%%        Authors: Fabian Telschow
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

%%%% load mat file containing the paths for output
load( 'paths.mat' )
cd(path_PEDAC)

%%%% load color data base for plots
load( strcat( path_work, 'colors.mat' ) )
% choose main color scheme for this script 
ColScheme  = Categories;

methodVec = ["direct" "interpolation"];

%%%% Constants
% convert constant from gton to ppm
gtonC_2_ppmC = 1 / 2.124; % Quere et al 2017
% convert C to CO2
C2CO2       = 44.01 / 12.011;

quants = [ 0.05 0.5 0.95 ];

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Apply detection method to the Models using atmospheric CO2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate AR process for imbalance
Msim  = 1e5;
T     = length( 2000 : 2100 );
rho   = 0.44;
sigma = 3;

% calibration condition
q = [ 0.05, 0.95 ];

% Simulate imbalance as error processes
IMBALANCE = cumsum( generate_AR( Msim, T, rho, sigma ) );

baseVec  = [ 2000 2005 2010];

for test_start = baseVec

    %%%%%%%% Fixed start year
    for method = methodVec
        % load the CO2 in atmosphere predicted using the Joos model
        load( strcat( path_data, "AtmosphericCO2_IISA_", method, ".mat" ) )

        % Year we start to search for an detection
        detectStart = repmat( test_start, [ 1 Nalt ] );

        % detection time container
        detect_year     = zeros( [ T Nalt ] );
        thresholds_year = zeros( [ 1 Nalt ] );

        % define the times
        times      = 1 : size( COa_bau, 1 );

        for scn = 1 : Nalt
                % Find cutting point
                I_cut1 = times( COa_bau( :, 1 ) == detectStart( scn ) );

                % Define drifts for base and 2deg scenario
                drift_base  = COa_bau( I_cut1 : 12 : end, corBAU( scn ) + 1 );
                drift_alter = COa_alt( I_cut1 : 12 : end, scn + 1 );

                % get length of the future prediction after start time
                mT = length( drift_base );
                years = detectStart( scn ) : ( detectStart( scn ) + mT - 1 );

                % Plot the power plot
                [ cdf_dyears, thresh ] = DetectionDelay_SK(...
                                                IMBALANCE( 1 : mT, : ),...
                                                [ drift_base, drift_alter ]...
                                                     / gtonC_2_ppmC * C2CO2,...
                                                q );
                false_detect = get_Detection( IMBALANCE( 1 : mT, : ),...
                                              zeros( [ length(1 : mT) 2 ] ),...
                                              thresh );

                detect_year( 1 : mT, scn ) = cdf_dyears;
                thresholds_year( scn ) = thresh;

%                 plot_Detection_cdf( [ false_detect; cdf_dyears ], test_start,...
%                                     [0.05, 0.5, 0.95 ], q,...
%                                     strcat( path_pics, 'detect_',...
%                                         method, '/Sc_', num2str(scn),...
%                                         '_detection_aCO2_IISA_base', num2str(test_start), '_',...
%                                         method, '.png' ) );
% 
%                 dyear = get_Quants( detect_year( 1 : mT, scn ), [ 0.05 0.5, 0.95 ] );
% 
%                 figure( 2 ), clf, hold on
%                 WidthFig  = 500 * 1.1;
%                 HeightFig = 400 * 1.1;
%                 set( gcf, 'Position', [ 300 300 WidthFig HeightFig ] );
%                 set( gcf, 'PaperPosition', [ 300 300 WidthFig HeightFig ] )
%                 set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
%                 set( groot, 'defaultLegendInterpreter', 'latex' );
%                         plot( years, drift_base, 'LineWidth', 1.5, 'Color',...
%                               ColScheme( 1, : ) )
%                         plot( years, drift_alter, 'LineWidth', 1.5, 'Color',...
%                               ColScheme( 3, : ) )
%                         plot( [ years( dyear(1) ) years( dyear(1) ) ], [ -2000, 2000 ],...
%                               'k--' )
%                         plot( [ years( dyear(2) ) years( dyear(2) ) ], [ -2000, 2000 ],...
%                               'k-', 'LineWidth', 1.5 )
%                         plot( [ years( dyear(3) ) years( dyear(3) ) ], [ -2000, 2000 ],...
%                               'k--' )
%                         title( 'atmospheric CO2' )
%                 h = xlabel( 'years' );  set( h, 'Interpreter', 'latex' );
%                 h = ylabel( 'atmospheric CO2 [ppm/year]' );
%                 set( h, 'Interpreter', 'latex' );
%                 ylim( [ 350 550 ] )
%                 xlim( [ 2000 2050 ] )
%                 h = legend( namesBAU{ corBAU( scn ) },...
%                             namesAlt{ scn },...
%                             'location', 'northwest' );
%                 set( h, 'Interpreter', 'latex' );
%                 grid
%                 set( gca, 'fontsize', 14 );
% 
%                 set( gcf, 'papersize', [ 12 12 ] )
%                 fig = gcf;
%                 fig.PaperPositionMode = 'auto';
%                 fig_pos = fig.PaperPosition;
%                 fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
%                 print( strcat( path_pics, 'detect_', method, '/Sc_', num2str( scn ),...
%                        'DetectionTimes_aCO2_IISA_base', num2str(test_start), '_',...
%                        method, '.png' ), '-dpng' )
%                 hold off

        end

        save( strcat(path_work, 'Detection_aCO2_IISA_2_base',...
                      num2str( test_start ), '_', method,'.mat'),...
                'detect_year', 'detectStart', 'category', 'sub_category',...
                'namesAlt', 'namesBAU', 'start_year_alt', 'start_year_bau',...
                'Nbau', 'Nalt', 'names_category', 'names_sub_category',...
                'thresholds_year' )
    end
end