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
load( 'scripts/paths.mat' )
cd( path )
clear path
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

                plot_Detection_cdf( [ false_detect; cdf_dyears ], test_start,...
                                    [0.05, 0.5, 0.95 ], q,...
                                    strcat( path_pics, 'detect_',...
                                        method, '/Sc_', num2str(scn),...
                                        '_detection_aCO2_IISA_base', num2str(test_start), '_',...
                                        method, '.png' ) );

                dyear = get_Quants( detect_year( 1 : mT, scn ), [ 0.05 0.5, 0.95 ] );

                figure( 2 ), clf, hold on
                WidthFig  = 500 * 1.1;
                HeightFig = 400 * 1.1;
                set( gcf, 'Position', [ 300 300 WidthFig HeightFig ] );
                set( gcf, 'PaperPosition', [ 300 300 WidthFig HeightFig ] )
                set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
                set( groot, 'defaultLegendInterpreter', 'latex' );
                        plot( years, drift_base, 'LineWidth', 1.5, 'Color',...
                              ColScheme( 1, : ) )
                        plot( years, drift_alter, 'LineWidth', 1.5, 'Color',...
                              ColScheme( 3, : ) )
                        plot( [ years( dyear(1) ) years( dyear(1) ) ], [ -2000, 2000 ],...
                              'k--' )
                        plot( [ years( dyear(2) ) years( dyear(2) ) ], [ -2000, 2000 ],...
                              'k-', 'LineWidth', 1.5 )
                        plot( [ years( dyear(3) ) years( dyear(3) ) ], [ -2000, 2000 ],...
                              'k--' )
                        title( 'atmospheric CO2' )
                h = xlabel( 'years' );  set( h, 'Interpreter', 'latex' );
                h = ylabel( 'atmospheric CO2 [ppm/year]' );
                set( h, 'Interpreter', 'latex' );
                ylim( [ 350 550 ] )
                xlim( [ 2000 2050 ] )
                h = legend( namesBAU{ corBAU( scn ) },...
                            namesAlt{ scn },...
                            'location', 'northwest' );
                set( h, 'Interpreter', 'latex' );
                grid
                set( gca, 'fontsize', 14 );

                set( gcf, 'papersize', [ 12 12 ] )
                fig = gcf;
                fig.PaperPositionMode = 'auto';
                fig_pos = fig.PaperPosition;
                fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
                print( strcat( path_pics, 'detect_', method, '/Sc_', num2str( scn ),...
                       'DetectionTimes_aCO2_IISA_base', num2str(test_start), '_',...
                       method, '.png' ), '-dpng' )
                hold off

        end

        save( strcat('workspaces/Detection_aCO2_IISA_2_base',...
                      num2str( test_start ), '_', method,'.mat'),...
                'detect_year', 'detectStart', 'category', 'sub_category',...
                'namesAlt', 'namesBAU', 'start_year_alt', 'start_year_bau',...
                'Nbau', 'Nalt', 'names_category', 'names_sub_category',...
                'thresholds_year' )
    end
end

% %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%
% %%%                     Visualize the results
% %%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baseVec  = [ "2000"; "2005"; "2010"]; %["2010" "Var"];
% 
% WidthFig  = 600;
% HeightFig = 400;
% 
% %%%% simple histograms with mean
% for method = methodVec
%     for k = 1:length(baseVec)
%         base = baseVec(k);
%         % load the results of the 
%         load( strcat('workspaces/Detection_aCO2_IISA_2_base', base, '_',method,'.mat') )
%         
%         quants = [ 0.25, 0.5, 0.75 ];
%         quants_detect_year = get_Quants( detect_year, quants );
%         
%         for l = 1:length(quants)
%             figure(l), clf, hold on
%             set(gcf, 'Position', [ 300 300 1.5 * WidthFig HeightFig]);
%             set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
%             set(groot, 'defaultAxesTickLabelInterpreter','latex');
%             set(groot, 'defaultLegendInterpreter','latex');
% 
%             I1 = strcmp(names_category(1), category);
%             I2 = strcmp(names_category(2), category);
%             I3 = strcmp(names_category(3), category);
%             I4 = strcmp(names_category(4), category);
%             I5 = strcmp(names_category(5), category);
%             I6 = strcmp(names_category(6), category);
% 
%             x = [ quants_detect_year( l, I1 ), quants_detect_year( l, I2 ), quants_detect_year( l, I3 ),...
%                   quants_detect_year( l, I4 ), quants_detect_year( l, I5 ), quants_detect_year( l, I6 ) ];
% 
%             g1 = repmat( { '1.5C below' }, sum( I1 ), 1 );
%             g2 = repmat( { '1.5C low ov.' }, sum( I2 ), 1 );
%             g3 = repmat( { '1.5C high ov.' }, sum( I3 ), 1 );
%             g4 = repmat( { '2C lower' }, sum( I4 ), 1 );
%             g5 = repmat( { '2C higher' }, sum( I5 ), 1 );
%             g6 = repmat( { '2C above' }, sum( I6 ), 1 );
% 
%             g = [g1; g2; g3; g4; g5; g6];
% 
%             boxplot( x, g, 'Colors', ColScheme( 1 : end - 1, : ),...
%                      'BoxStyle', 'filled',...
%                      'MedianStyle', 'target',...
%                      'PlotStyle', 'traditional',...%'compact',...
%                      'Widths', 0.1 );
%             grid
%             bp = gca;
%             bp.XAxis.TickLabelInterpreter = 'latex';
% 
%             a = get( get( gca, 'children' ), 'children' );   % Get the handles of all the objects
%             t = get( a, 'tag' );          % List the names of all the objects 
%             idx = strcmpi( t, 'box' );    % Find Box objects
%             boxes = a( idx );            % Get the children you need
%             set( boxes, 'linewidth', 20 ); % Set width
%             
%             ylim( [ 0 50 ] )
% 
%             title( strcat( "Detection Times vs Baseline" ) )
% 
%             h = ylabel( 'years');  set( h, 'Interpreter', 'latex' );
%             h = xlabel( 'category');  set( h, 'Interpreter', 'latex' );
%             set( gca, 'fontsize', 14 );
% 
%             set( gcf, 'papersize', [ 12 12 ] )
%             fig = gcf;
%             fig.PaperPositionMode = 'auto';
%             fig_pos = fig.PaperPosition;
%             fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
%             print( strcat( path_pics, 'detect_', method,...
%                    '/Box_Detect_aCO2_IISA_base', base,...
%                    "_cats_", method,'_quant_', num2str( quants( l ) ),'.png'),...
%                    '-dpng' )
%             hold off    
%         end
%     end
% end
% 
% % %%%% stratification into starting year
% % baseVec  = ["2010" "Var"];
% % 
% % WidthFig  = 600;
% % HeightFig = 400;
% % 
% % %%%% simple histograms with mean
% % for method = methodVec
% %         for base = baseVec
% %         % load the results of the 
% %         load( strcat('workspaces/Detection_aCO2_IISA_base', base, '_',method,'.mat') )
% %               
% %         figure(1), clf, hold on
% %         set(gcf, 'Position', [ 300 300 3*WidthFig  3*HeightFig]);
% %         set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
% %         set(groot, 'defaultAxesTickLabelInterpreter','latex');
% %         set(groot, 'defaultLegendInterpreter','latex');
% %         
% %         starts = sort(unique(detectStart));
% %         for i = 1:length(starts)
% %             I1 = strcmp(names_category(1), category) & detectStart==starts(i);
% %             I2 = strcmp(names_category(2), category) & detectStart==starts(i);
% %             I3 = strcmp(names_category(3), category) & detectStart==starts(i);
% %             I4 = strcmp(names_category(4), category) & detectStart==starts(i);
% %             I5 = strcmp(names_category(5), category) & detectStart==starts(i);
% %             I6 = strcmp(names_category(6), category) & detectStart==starts(i);
% % 
% %             x = [ detect_year( I1 ), detect_year( I2 ), detect_year( I3 ),...
% %                   detect_year( I4 ), detect_year( I5 ), detect_year( I6 ) ];
% % 
% %             g1 = repmat( { '1.5C below' }, sum( I1 ), 1 );
% %             g2 = repmat( { '1.5C low ov.' }, sum( I2 ), 1 );
% %             g3 = repmat( { '1.5C high ov.' }, sum( I3 ), 1 );
% %             g4 = repmat( { '2C lower' }, sum( I4 ), 1 );
% %             g5 = repmat( { '2C higher' }, sum( I5 ), 1 );
% %             g6 = repmat( { '2C above' }, sum( I6 ), 1 );
% % 
% %             g = [g1; g2; g3; g4; g5; g6];
% %             colo = [];
% %             if isempty(g1) > 0
% %                 colo = [ colo; ColScheme( 1, : ) ];
% %             end
% %             if isempty(g2) > 0
% %                 colo = [ colo; ColScheme( 2, : ) ];
% %             end
% %             if isempty(g3) > 0
% %                 colo = [ colo; ColScheme( 3, : ) ];
% %             end
% %             if isempty(g4) > 0
% %                 colo = [ colo; ColScheme( 4, : ) ];
% %             end            
% %             if isempty(g5) > 0
% %                 colo = [ colo; ColScheme( 5, : ) ];
% %             end
% %             if isempty(g6) > 0
% %                 colo = [ colo; ColScheme( 6, : ) ];
% %             end
% %             
% %             subplot(2,2,i)
% %             boxplot( x, g, 'Colors', colo,...
% %                      'BoxStyle', 'filled',...
% %                      'MedianStyle', 'target',...
% %                      'PlotStyle', 'traditional',...%'compact',...
% %                      'Widths', 0.1);
% %             grid
% %             bp = gca;
% %             bp.XAxis.TickLabelInterpreter = 'latex';
% % 
% %             a = get(get(gca,'children'),'children');   % Get the handles of all the objects
% %             t = get(a,'tag');          % List the names of all the objects 
% %             idx = strcmpi(t,'box');    % Find Box objects
% %             boxes = a(idx);            % Get the children you need
% %             set(boxes,'linewidth',20); % Set width
% % 
% %             title( strcat( "Detection Times vs Baseline" ) )
% % 
% %             h = ylabel( 'years' );  set( h, 'Interpreter', 'latex' );
% %             h = xlabel( 'category' );  set( h, 'Interpreter', 'latex' );
% %             set( gca, 'fontsize', 14 );
% %         end
% % 
% %         set( gcf, 'papersize', [ 12 12 ] )
% %         fig = gcf;
% %         fig.PaperPositionMode = 'auto';
% %         fig_pos = fig.PaperPosition;
% %         fig.PaperSize = [fig_pos(3) fig_pos(4)];
% %         print(strcat(path_pics,'detect_',method,'/Box_Detect_aCO2_IISA_base', base,...
% %                 "_cats_detectStart_", method,'.png'), '-dpng')
% %         hold off
% %         end
% % 
% %         
% %         figure(2), clf, hold on
% %         set(gcf, 'Position', [ 300 300 2.3*WidthFig HeightFig]);
% %         set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
% %         set(groot, 'defaultAxesTickLabelInterpreter','latex');
% %         set(groot, 'defaultLegendInterpreter','latex');
% %         
% %         I1 = strcmp( names_sub_category(1), sub_category );
% %         I2 = strcmp( names_sub_category(2), sub_category );
% %         I3 = strcmp( names_sub_category(3), sub_category );
% %         I4 = strcmp( names_sub_category(4), sub_category );
% %         I5 = strcmp( names_sub_category(5), sub_category );
% %         I6 = strcmp( names_sub_category(6), sub_category );
% %         I7 = strcmp( names_sub_category(7), sub_category );
% %         I8 = strcmp( names_sub_category(8), sub_category );
% %         
% %         x = [ detect_year( I1 ), detect_year( I2 ), detect_year( I3 ),...
% %               detect_year( I4 ), detect_year( I5 ), detect_year( I6 ),...
% %               detect_year( I7 ), detect_year( I8 )];
% %           
% %         g1 = repmat( { '1.5C below' },     sum( I1 ), 1 );
% %         g2 = repmat( { 'l1.5C low ov.' },  sum( I2 ), 1 );
% %         g3 = repmat( { 'h1.5C low ov.' },  sum( I3 ), 1 );
% %         g4 = repmat( { 'l1.5C high ov.' }, sum( I4 ), 1 );
% %         g5 = repmat( { 'h1.5C high ov.' }, sum( I5 ), 1 );
% %         g6 = repmat( { '2C lower' },       sum( I6 ), 1 );
% %         g7 = repmat( { '2C higher' },      sum( I7 ), 1 );
% %         g8 = repmat( { '2C above' },       sum( I8 ), 1 );
% %         
% %         g = [ g1; g2; g3; g4; g5; g6; g7; g8 ];
% %         
% %         h = boxplot( x, g, 'Colors', ColScheme( [1 2 2 3 3 4 5 6], : ),...
% %                  'BoxStyle', 'filled',...
% %                  'MedianStyle', 'target',...
% %                  'PlotStyle', 'traditional',...%'compact',...
% %                  'Widths', 0.1);
% %         bp = gca;
% %         bp.XAxis.TickLabelInterpreter = 'latex';
% %              
% %         a = get(get(gca,'children'),'children');   % Get the handles of all the objects
% %         t = get(a,'tag');          % List the names of all the objects 
% %         idx = strcmpi(t,'box');    % Find Box objects
% %         boxes = a(idx);            % Get the children you need
% %         set(boxes,'linewidth',20); % Set width
% %       
% %         title(strcat("Detection Times vs Baseline"))
% % 
% %         h = ylabel('years');  set(h, 'Interpreter', 'latex');
% %         h = xlabel('category');  set(h, 'Interpreter', 'latex');
% %         set(gca, 'fontsize', 14);
% % 
% %         set(gcf,'papersize',[12 12])
% %         fig = gcf;
% %         fig.PaperPositionMode = 'auto';
% %         fig_pos = fig.PaperPosition;
% %         fig.PaperSize = [fig_pos(3) fig_pos(4)];
% %         print(strcat(path_pics,'detect_',method,'/Box_Detect_aCO2_IISA_base', base,...
% %                 "_sub_cats_", method,'.png'), '-dpng')
% %         hold off
% %end
% % 
% % %% Numbers within categories
% % Ncategories = [ sum(strcmp(names_category(1), category)),...
% %                 sum(strcmp(names_category(2), category)),...
% %                 sum(strcmp(names_category(3), category)),...
% %                 sum(strcmp(names_category(4), category)),...
% %                 sum(strcmp(names_category(5), category)),...
% %                 sum(strcmp(names_category(6), category)),...
% %     ]
% % 
% % Nsubcategories = [ sum(strcmp(names_sub_category(1), sub_category)),...
% %                 sum(strcmp(names_sub_category(2), sub_category)),...
% %                 sum(strcmp(names_sub_category(3), sub_category)),...
% %                 sum(strcmp(names_sub_category(4), sub_category)),...
% %                 sum(strcmp(names_sub_category(5), sub_category)),...
% %                 sum(strcmp(names_sub_category(6), sub_category)),...
% %                 sum(strcmp(names_sub_category(7), sub_category)),...
% %                 sum(strcmp(names_sub_category(8), sub_category)),...
% %     ]
