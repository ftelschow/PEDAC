%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%	This script predicts the future atmospheric CO2 from AR5 emission
%%%%    scenarios using the Rafelski model.
%%%%
%%%%    Output: .mat with predicted atmospheric CO2 for BAU and 2deg
%%%%            emission scenarios
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear workspace
clear all
close all

%%%% load mat file containing the paths for output
load( strcat( path_data, 'paths.mat' ) )
cd(path)
clear path
%%%% load color data base for plots
load( strcat( path_data, 'colors.mat' ) )
% choose main color scheme for this script 
ColScheme  = Categories;

%%%% load the true past emission data. Note it must be in ppm C as input of
% Rafelski! 
load( strcat( path_data, 'Emissions_PastMontly.mat' ) )
PastTotalCO2emission = PastTotalCO2emissionScripps;

%%%% load the predicted future emission data . Note it must be in ppm C as input of
% Rafelski, but it is CO2 right now!  
load( strcat( path_data, 'Emissions_IIASA_FutureMontly.mat' ) )

%%%% load optimised Joos model parameters
load( strcat( path_data, 'Fit_JoosModelOptim.mat' ) )

%%%% analysis choices
% methods to be used for emission concationation
methodVec = [ "direct", "interpolation" ];
xopt = xoptScripps1958;

clear ffer fas dtdelpCO2a Aoc

%%%% constants
% convert C to CO2
C2CO2       = 44.01 / 12.011;

% output figure width and height
WidthFig  = 550;
HeightFig = 450;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot the IISA data emission trajectories and compare to reported
%%%%    historical emission trajectories 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop over different ways to glue past emissions with future emissions
for method = methodVec
    %%%% initialize containers for atmospheric CO2 predicted in the different
    % models
    times = PastTotalCO2emission( 1, 1 ) : 1/12 : 2100;
    Nt    = length( times );

    COa_bau      = zeros( [ Nt size( data_bau, 2 ) ] ) * NaN;
    COa_bau(:,1) = times;

    COa_alt      = zeros( [ Nt size( data_alt, 2 ) ] ) * NaN;
    COa_alt(:,1) = times;    

    %%%% use Rafelski model to get the COa curves for BAU scenarios
    for scn = 2 : size( data_bau, 2 )
        if ~strcmp( method, "interpolation" )
            cyear = start_year_bau( scn - 1 );
        else
            if start_year_bau( scn - 1 ) ~= 2010
                cyear = [ start_year_bau( scn - 1 ) - 5 ...
                          start_year_bau( scn - 1 ) ];
            else
                cyear = [ 2009 2010 ];
            end
        end
        % concatenate past and future emissions to yield a full world
        % future history
        tmp = concatinateTimeseries( PastTotalCO2emission,...
                                     data_bau( :, [ 1 scn ] ),...
                                     cyear,...
                                     method );
        % remove NaNs. This is neccessary since the Rafelski model somehow
        % predicts to far... (ask Ralph about it. Is it a bug?)
        tmp = tmp( ~isnan( tmp( :, 2 ) ), : );
        % predict atmospheric CO2 using rafelski model
        tmp = JoosModel( tmp, xopt );
        COa_bau( 1:size( tmp, 1), scn ) = tmp( :, 2 );
    end
    
    %%%% use Rafelski model to get the COa curves for 2° scenarios
    for scn = 2:size( data_alt, 2 )
        if ~strcmp( method, "interpolation" )
            cyear = start_year_alt( scn - 1 );
        else
            if start_year_alt(scn-1)~=2010
                cyear = [ start_year_alt( scn - 1 ) - 5 ...
                          start_year_alt( scn - 1 ) ];
            else
                cyear = [ 2009 2010 ];
            end
        end
        % concatenate past and future emissions to yield a full world
        % future history
        tmp = concatinateTimeseries( PastTotalCO2emission,...
                                     data_alt( :, [ 1 scn ] ),...
                                     cyear,...
                                     method );

        % predict atmospheric CO2 using rafelski model
        tmp = JoosModel( tmp, xopt );
        COa_alt( 1:size( tmp, 1 ), scn ) = tmp( :, 2 );
    end
    
    %%%% produce output .mat
    save( strcat( path_data, 'AtmosphericCO2_IISA_', method, '.mat'),...
                             'COa_bau', 'COa_alt',...
                             'start_year_bau', 'start_year_alt',...
                             'corBAU', 'sub_category', 'category',...
                             'category_a', 'names_category', 'names_sub_category',...
                             'namesAlt', 'namesBAU', 'Nbau', 'Nalt', 'detectStart')
end

% Clear workspace
clear tmp Nt CO2a

% %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%    Plot the predicted atmospheric CO2 records 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close all
% % loop over methods
% for method = methodVec
%     % load the correct atmospheric CO2 data
%     load( strcat( path_data, 'AtmosphericCO2_IISA_', method, '.mat' ) )
%     
%     % plot all the BAU scenarios
%     figure(1), clf, hold on
%     set(gcf, 'Position', [ 300 300 WidthFig HeightFig ] );
%     set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig ] )
%     set(groot, 'defaultAxesTickLabelInterpreter','latex');
%     set(groot, 'defaultLegendInterpreter','latex');
%     % plot the actual curves
%     for scn = 2:size(COa_bau,2)
%         plot(COa_bau(:, 1 ), COa_bau(:, scn ),...
%                   'LineWidth', 1.5, 'Color', Categories(7,:))
%     end
%     xlim( [ 2000 2102 ] )
%     ylim( [ 250 1150 ] )
%     h = xlabel( 'years' );  set( h, 'Interpreter', 'latex' );
%     h = ylabel( 'C02 [ppm]' );  set( h, 'Interpreter', 'latex' );
%     h = title( 'Predictions for atmospheric CO2 for BAU scenarios' );
%     set( h, 'Interpreter', 'latex' );
%     line( [ 2005 2005 ], [ -10, 1e4 ], 'Color', 'black', 'LineStyle', '--' )
%     grid
%     set( gca, 'fontsize', 14 );
% 
%     set( gcf, 'papersize', [ 12 12 ] )
%     fig = gcf;
%     fig.PaperPositionMode = 'auto';
%     fig_pos = fig.PaperPosition;
%     fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
%     print( strcat( path_pics, strcat( 'AtmosphericCO2_IISA_bau_',...
%                    method, '.png' ) ), '-dpng' )
%     hold off
% 
%     sty = [ "-.", "-.", "-", "--", "-", "--" ];
% 
%     % plot all the 2° scenarios
%     figure( 2 ), clf, hold on
%     set( gcf, 'Position', [ 300 300 WidthFig HeightFig ] );
%     set( gcf,'PaperPosition', [ 300 300 WidthFig HeightFig ] )
%     set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
%     set( groot, 'defaultLegendInterpreter', 'latex' );
% 
%     for scn = 2:size( COa_alt, 2 )
%             if strcmp( names_category( 1 ), category( scn - 1 ) )
%                 colo = Categories( 1, : );
%             elseif strcmp( names_category( 2 ), category( scn - 1 ) )
%                 colo = Categories( 2, : );
%             elseif strcmp( names_category( 3 ), category( scn - 1 ) )
%                 colo = Categories( 3, : );
%             elseif strcmp( names_category( 4 ), category( scn - 1 ) )
%                 colo = Categories( 4, : );
%             elseif strcmp( names_category( 5 ), category( scn - 1 ) )
%                 colo = Categories( 5, : );
%             elseif strcmp( names_category( 6 ), category( scn - 1 ) )
%                 colo = Categories( 6, : );
%             end
%                 
%             plot( COa_alt( :, 1 ), COa_alt( :, scn ),...
%                   'Color',  colo,...
%                   'LineStyle', "-",...
%                   'LineWidth', 1.5 )
%     end
%     line( [ 2005 2005 ], [ -10, 1e4 ], 'Color', 'black', 'LineStyle', '--' )
%     xlim( [ 2000 2102 ] )
%     ylim( [ 250 550 ] )
%     h = title( 'Predictions for atmospheric CO2 for alternative scenarios' );
%     set( h, 'Interpreter', 'latex' );
%     h = xlabel( 'years' );  set( h, 'Interpreter', 'latex' );
%     h = ylabel( 'C02 [ppm]' );  set( h, 'Interpreter', 'latex' );
%     grid
%     set( gca, 'fontsize', 14 );
% 
%     set( gcf, 'papersize', [ 12 12 ] )
%     fig = gcf;
%     fig.PaperPositionMode = 'auto';
%     fig_pos = fig.PaperPosition;
%     fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
%     print( strcat( path_pics,strcat( 'AtmosphericCO2_IISA_alternative_',...
%                    method, '.png' ) ), '-dpng' )
%     hold off
% end
%  
% close all
% %%
% 
% % loop over methods
% for method = methodVec
% for cat = [2 3]
%     % load the correct atmospheric CO2 data
%     load( strcat(path_data, 'AtmosphericCO2_IISA_',method,'.mat'))
% 
%     % plot all the 2° scenarios 1.5°C high overshoot
%     figure(2), clf, hold on
%     set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
%     set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
%     set(groot, 'defaultAxesTickLabelInterpreter','latex');
%     set(groot, 'defaultLegendInterpreter','latex');
% 
%     for scn = 2:size( COa_alt, 2 )
%             if strcmp( names_category( 1 ), category( scn - 1 ) )
%                 colo = Categories(1,:);
%             elseif strcmp( names_category( 2 ), category( scn - 1 ) )
%                 colo = Categories( 2, : );
%                 ll   = '-';
%             elseif strcmp( names_category( 3 ), category( scn - 1 ) )
%                 colo = Categories( 3, : );
%                 ll   = '-';
%             elseif strcmp( names_category( 4 ), category( scn - 1 ) )
%                 colo = Categories( 4, : );
%                 ll   = '--';
%             elseif strcmp( names_category( 5 ), category( scn - 1 ) )
%                 colo = Categories( 5, : );
%             elseif strcmp( names_category( 6 ), category( scn - 1) )
%                 colo = Categories( 6, : );
%             end
%             plot( [ -20 20 ], [ -100, -100 ], 'Color', Categories( cat, : ) );
%             plot( [ -20 20 ], [ -100, -100 ], 'Color', Categories( 4, : ),...
%                   'LineStyle', '--' );
%             
%             if strcmp( names_category( cat ), category( scn - 1 ) ) || ...
%                     strcmp( names_category( 4 ), category( scn - 1 ) )
%                 plot( COa_alt( :, 1 ), COa_alt( :, scn ),...
%                       'Color',  colo,...
%                       'LineStyle', ll,...
%                       'LineWidth', 1.5)
%             end
%     end
%     line( [ 2020 2020 ], [ -10, 1e4 ], 'Color', 'black', 'LineStyle', '--')
%     line( [ 2035 2035 ], [ -10, 1e4 ], 'Color', 'black', 'LineStyle', '--')
%     xlim( [ 2000 2070 ] )
%     ylim( [ 250 550 ] )
%     h = title( 'Predictions for atmospheric CO2' );
%     set( h, 'Interpreter', 'latex' );
%     h = xlabel( 'years' );  set( h, 'Interpreter', 'latex' );
%     h = ylabel( 'C02 [ppm]' );  set( h, 'Interpreter', 'latex' );
%     h = legend( names_category( cat ),...
%                 names_category( 4 ),...
%                 'location', 'southeast' );
%     set( h, 'Interpreter', 'latex' );
%     grid
%     set( gca, 'fontsize', 14 );
% 
%     set( gcf, 'papersize', [ 12 12 ] )
%     fig = gcf;
%     fig.PaperPositionMode = 'auto';
%     fig_pos = fig.PaperPosition;
%     fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
%     print( strcat( path_pics, strcat( 'AtmosphericCO2_IISA_',...
%            num2str( cat ), '_low2C_', method, '.png' ) ), '-dpng' )
%     hold off
% end
% end
% %%
% for methodi = method
% % load the correct atmospheric CO2 data
% ll = '-';
% load( strcat( path_data, 'AtmosphericCO2_IISA_', methodi, '.mat' ) )
% 
% % plot all the lower 1.5°C low scenarios versus higher 1.5°C low
% figure(1), clf, hold on
% set( gcf, 'Position', [ 300 300 WidthFig HeightFig ] );
% set( gcf,'PaperPosition', [ 300 300 WidthFig HeightFig ] )
% set( groot, 'defaultAxesTickLabelInterpreter', 'latex' ); 
% set( groot, 'defaultLegendInterpreter', 'latex' );
% 
% l15lov = strcmp( names_sub_category( 2 ), sub_category );
% h15lov = strcmp( names_sub_category( 3 ), sub_category );
% 
%         plot( [ -20 20 ], [ -100, -100 ], 'Color', Categories( 2, : ), 'LineWidth', 1.5 );
%         plot( [ -20 20 ], [ -100, -100 ], 'Color', Categories( 4, : ), 'LineWidth', 1.5 );
%         plot( COa_alt( :, 1 ), COa_alt( :, l15lov ),...
%               'Color',  Categories( 2, : ),...
%               'LineStyle', ll,...
%               'LineWidth', 1.5 )
%         plot( COa_alt( :, 1 ), COa_alt( :, h15lov ),...
%               'Color',  Categories( 4, : ),...
%               'LineStyle', ll,...
%               'LineWidth', 1.5 )
% 
% line( [ 2020 2020 ], [ -10, 1e4 ], 'Color', 'black', 'LineStyle', '--' )
% line( [ 2035 2035 ], [ -10, 1e4 ], 'Color', 'black', 'LineStyle', '--' )
% xlim( [ 2000 2070 ] )
% ylim( [ 250 550 ] )
% h = title( 'Predictions for atmospheric CO2' );  set( h, 'Interpreter', 'latex' );
% h = xlabel( 'years' );  set( h, 'Interpreter', 'latex' );
% h = ylabel( 'C02 [ppm]' );  set( h, 'Interpreter', 'latex' );
% h = legend( names_sub_category( 2 ),...
%             names_sub_category( 3 ),...
%             'location', 'southeast' );
% set( h, 'Interpreter', 'latex' );
% grid
% set( gca, 'fontsize', 14);
% set( gcf, 'papersize', [ 12 12 ] )
% fig = gcf;
% fig.PaperPositionMode = 'auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
% print( strcat( path_pics, strcat( 'AtmosphericCO2_IISA_l15low_h15low_',...
%                method, '.png' ) ), '-dpng' )
% hold off
% 
% % plot all the lower 1.5°C low scenarios versus higher 1.5°C low
% figure( 2 ), clf, hold on
% set( gcf, 'Position', [ 300 300 WidthFig HeightFig ] );
% set( gcf, 'PaperPosition', [ 300 300 WidthFig HeightFig ] )
% set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
% set( groot, 'defaultLegendInterpreter', 'latex');
% 
% l15lov = strcmp( names_sub_category( 4 ), sub_category );
% h15lov = strcmp( names_sub_category( 5 ), sub_category );
% 
%         plot( [ -20 20 ], [ -100, -100 ], 'Color', Categories( 2, : ), 'LineWidth', 1.5 );
%         plot( [ -20 20 ], [ -100, -100 ], 'Color', Categories( 4, : ), 'LineWidth', 1.5 );
%         plot( COa_alt( :, 1 ), COa_alt( :, l15lov ),...
%               'Color',  Categories( 2, : ),...
%               'LineStyle', ll,...
%               'LineWidth', 1.5 )
%         plot( COa_alt( :, 1 ), COa_alt( :, h15lov ),...
%               'Color',  Categories( 4, : ),...
%               'LineStyle', ll,...
%               'LineWidth', 1.5 )
% 
% 
% line( [ 2020 2020 ], [ -10, 1e4 ], 'Color', 'black', 'LineStyle', '--')
% line( [ 2035 2035 ], [ -10, 1e4 ], 'Color', 'black', 'LineStyle', '--')
% xlim( [ 2000 2070 ] )
% ylim( [ 250 550 ] )
% h = title( 'Predictions for atmospheric CO2' );
% set( h, 'Interpreter', 'latex' );
% h = xlabel( 'years' );  set( h, 'Interpreter', 'latex' );
% h = ylabel( 'C02 [ppm]' );  set( h, 'Interpreter', 'latex' );
% h = legend( names_sub_category( 4 ),...
%             names_sub_category( 5 ),...
%             'location', 'southeast' );
% set( h, 'Interpreter', 'latex' );
% grid
% set( gca, 'fontsize', 14);
% set( gcf, 'papersize', [ 12 12 ] )
% fig = gcf;
% fig.PaperPositionMode = 'auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
% print( strcat( path_pics, strcat( 'AtmosphericCO2_IISA_l15high_h15high_',...
%                methodi, '.png' ) ), '-dpng' )
% hold off
% end