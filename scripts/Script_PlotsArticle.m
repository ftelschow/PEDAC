%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%        This script reproduces all figures for the article <<INSERT>>
%%%%
%%%%        Authors: Fabian Telschow
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear workspace
clear all
close all

% set correct working directory
path1     = strcat( '/home/drtea/Research/Projects/CO2policy/' );
path      = strcat( path1, 'PEDAC' );
path_pics = strcat( path1, 'pics/' );
path_data = strcat( path1, 'PEDAC/data/' );
cd(path)
clear path

% convert C to CO2
C2CO2       = 44.01/12.011;
gtonC_2_ppm = 1 / 2.124;

%%%% load color data base for plots
load(strcat(path_data,'colors.mat'))
% choose main color scheme for this script 
ColScheme  = Categories;

% colors
backgroundCol = [255, 255, 255] / 255;
gridCol = [ 112, 128, 144 ] / 255;
bauCol = [ 128, 128, 128 ] / 255;

% line widths
lwdObs = 2;
lwdProj = 1.1;

% global changes for x-axis labels
xvec       = [ 1975, 2000, 2025, 2050, 2075, 2100 ];
xtickcell  = { '\textbf{1975}', '\textbf{2000}', '\textbf{2025}',...
               '\textbf{2050}', '\textbf{2075}', '\textbf{2100}' };
           
% global fontsize
sf = 19;

method = "interpolation"
%% Figure 1
% load past emissions
load( strcat(path_data, 'Emissions_PastMontly.mat') )
% load future emissions
load( strcat(path_data, 'Emissions_IIASA_FutureMontly.mat') )

% output file name
outname = strcat(path_pics,'article/fig1_emissions');
scale = 1;
figw = scale*600;
figh = scale*500;

% changes for y axis
ylims      = [ -10 40 ];
yvec       = [ -10, 0, 10, 20, 30, 40 ];
ytickcell  = { '\textbf{-10}', '\textbf{0}', '\textbf{10}',...
               '\textbf{20}', '\textbf{30}', '\textbf{40}' };


% plot emissions for BAU and alternative scenarios          
figure(1), clf, hold on,
    set( gcf, 'Position', [ 300 300 figw figh ] );
    set( gcf, 'PaperPosition', [ 300 300 figw figh ] );
    set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
    set( groot, 'defaultLegendInterpreter', 'latex' );

%    subplot( 1, 3, 1 ); hold on;
        data = data_bau;
        scnVec = 1:(size(data,2)-1);
        cutyear  = start_year_bau;
                
        for scn = scnVec( cutyear == 2005 )
            if cutyear( scn ) ~= 2010
                cyear = [ cutyear( scn ) - 5 cutyear( scn ) ];
            else
                cyear = [ 2009 2010 ];
            end

            data_tmp = concatinateTimeseries( PastTotalCO2emission,...
                                              data(:, [ 1, scn + 1 ] ),...
                                              cyear,...
                                              method);
            plot( data_tmp( :, 1 ), data_tmp( :, 2 ) / gtonC_2_ppm,...
                  'color', bauCol, 'LineWidth', lwdProj )    
        end
        plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission( :, 2 ) / ...
              gtonC_2_ppm, 'color', [ 0 0 0 ], 'LineWidth', lwdObs )

        % change axis style
        xlim( [ xvec(1) - 10, xvec( end ) ] )
        xticks( xvec )
        xticklabels( xtickcell )
        
        % change y label and axis
        ylim( ylims )
        yticks( yvec )
        yticklabels( ytickcell )
        h = ylabel('\textbf{CO}$_2$ \textbf{emissions [GtC/year]}');
        set(h, 'Interpreter', 'latex');
                
        % change fontsize
        set(gca, 'fontsize', sf);

        % set background color
        set( gca, 'color', backgroundCol )
        
        % activate grid and modify properties
        grid
        ax = gca;
        ax.GridLineStyle = '-';
        ax.GridColor = gridCol;
        ax.GridAlpha = 0.7;
%    hold off
    
%    subplot( 1, 3, 2 ); hold on;
        % just for the legend
        plot( [0 1], [1 1], 'color', [ 0 0 0 ], 'LineWidth', lwdObs )

        data    = data_alt;
        scnVec  = 1:(size(data,2)-1);
        cutyear = start_year_alt;
        scns    = strcmp(category, names_category(4) ) | ...
                  strcmp(category, names_category(5) ) | ...
                  strcmp(category, names_category(6) );
        
        for scn = scnVec( scns )
            if cutyear( scn ) ~= 2010
                cyear = [ cutyear( scn ) - 5 cutyear( scn ) ];
            else
                cyear = [ 2009 2010 ];
            end

            data_tmp = concatinateTimeseries( PastTotalCO2emission,...
                                              data(:, [ 1, scn + 1 ] ),...
                                              cyear,...
                                              method);
            plot( data_tmp( :, 1 ), data_tmp( :, 2 ) / gtonC_2_ppm,...
                  'color', Categories(5,:), 'LineWidth', lwdProj )    
        end
        plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission( :, 2 ) / ...
              gtonC_2_ppm, 'color', [ 0 0 0 ], 'LineWidth', lwdObs )

%         % change axis style
%         xlim( [ xvec(1) - 10, xvec( end ) ] )
%         xticks( xvec )
%         xticklabels( xtickcell )
%         
%         % change y label and axis
%         ylim( ylims )
%         yticks( yvec )
%         yticklabels( ytickcell )
%        
%         % change fontsize
%         set(gca, 'fontsize', sf);
%         
%        % introduce legend
%         h = legend( "\textbf{historical CO$_2$ emissions}", 'location', 'northwest' );
%         set( h, 'Interpreter', 'latex' );
%         set( h, 'color', 'none' );
%         legend boxoff
% 
%         % set background color
%         set( gca, 'color', backgroundCol )
%         
%         % activate grid and modify properties
%         grid
%         ax = gca;
%         ax.GridLineStyle = '-';
%         ax.GridColor = gridCol;
%         ax.GridAlpha = 0.7;
%     hold off        
%         
%     subplot(1,3,3); hold on;
        data    = data_alt;
        scnVec  = 1:(size(data,2)-1);
        cutyear = start_year_alt;
        scns    = strcmp(category, names_category(1) ) | ...
                  strcmp(category, names_category(2) ) | ...
                  strcmp(category, names_category(3) );
        
        % just for the legend
        plot( [0 1], [1 1], 'color', [ 0 0 0 ], 'LineWidth', lwdObs )
        
        for scn = scnVec( scns )
            if cutyear( scn ) ~= 2010
                cyear = [ cutyear( scn ) - 5 cutyear( scn ) ];
            else
                cyear = [ 2009 2010 ];
            end

            data_tmp = concatinateTimeseries( PastTotalCO2emission,...
                                              data(:, [ 1, scn + 1 ] ),...
                                              cyear,...
                                              method );
            plot( data_tmp( :, 1 ), data_tmp( :, 2 ) / gtonC_2_ppm,...
                  'color', Categories(2,:), 'LineWidth', lwdProj )    
        end
        plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission( :, 2 ) / ...
              gtonC_2_ppm, 'color', [ 0 0 0 ], 'LineWidth', lwdObs )

%         % change axis style
%         xlim( [ xvec(1) - 10, xvec( end ) ] )
%         xticks( xvec )
%         xticklabels( xtickcell )
%         
%         % change y label and axis
%         ylim( ylims )
%         yticks( yvec )
%         yticklabels( ytickcell )
%                 
%         % change fontsize
%         set(gca, 'fontsize', sf);
% 
%         % set background color
%         set( gca, 'color', backgroundCol )
%         
%         % activate grid and modify properties
%         grid
%         ax = gca;
%         ax.GridLineStyle = '-';
%         ax.GridColor = [ 112, 128, 144 ]/255;
%         ax.GridAlpha = 0.7;
%     hold off        

    % set background color
    set( gcf, 'color', [1, 1, 1] )
        
    fig = gcf;
    set(gcf,'papersize',[figw*1.05 figh*1.05])
    fig.InvertHardcopy = 'off';
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
print( strcat( outname, ".pdf" ), '-dpdf' )

%% %%%% Figure 2
%%%% load the correct atmospheric CO2 data
% predicted future values
load( strcat( path_data, 'AtmosphericCO2_IISA_', method, '.mat' ) );
% observed values
load( strcat( path_data, 'dataObservedCO2.mat' ) );
% remove unneccessary data
clear dpCO2a_obs dtdelpCO2a_obs

% output file name
outname = strcat( path_pics, 'article/fig2_atmosphericCO2' );
scale = 1;
figw = scale*600;
figh = scale*500;

% change for y-lim
ylims      = [ 290 1e3 ];
yvec       = ( 3 : 10 ) * 100;
ytickcell  = { '\textbf{300}', '\textbf{400}', '\textbf{500}',...
               '\textbf{600}', '\textbf{700}', '\textbf{800}'...
               '\textbf{900}', '\textbf{1000}' };
test = 1;

% plot the predicted atmospheric CO2 from Joos Model
figure(2), clf, hold on
    set(gcf, 'Position', [ 300 300 figw figh]);
    set(gcf,'PaperPosition', [ 300 300 figw figh])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');

    % just for the legend
    plot( [0 1], [1 1], 'color', '0 0 0', 'LineWidth', lwdObs )
    if test
        plot( [0 1], [1 1], 'color', Categories(1,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(2,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(3,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(4,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(5,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(6,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', bauCol, 'LineWidth', lwdObs )
    end
        
    % plot the actual curves
    for scn = 2:size(COa_bau,2)
        plot( COa_bau(:, 1 ), COa_bau(:, scn ),...
              'LineWidth', lwdProj, 'Color', bauCol )
    end

    for scn = 2:size(COa_alt,2)
            if strcmp( names_category(1), category(scn-1) )
                colo = Categories(1,:);
            elseif strcmp( names_category(2), category(scn-1) )
                colo = Categories(2,:);
            elseif strcmp( names_category(3), category(scn-1) )
                colo = Categories(3,:);
            elseif strcmp( names_category(4), category(scn-1) )
                colo = Categories(4,:);
            elseif strcmp( names_category(5), category(scn-1) )
                colo = Categories(5,:);
            elseif strcmp( names_category(6), category(scn-1) )
                colo = Categories(6,:);
            end

            plot( COa_alt( :, 1 ), COa_alt( :, scn ),...
                  'Color',  colo,...
                  'LineStyle', "-",...
                  'LineWidth', lwdProj)
    end
    % plot observed CO2
    plot( CO2a_obs(:,1), CO2a_obs(:,2), '-k', 'LineWidth', lwdObs )

    % change x axis style
    xlim( [ xvec(1) - 10, xvec( end ) ] )
    xticks( xvec )
    xticklabels( xtickcell )

    % change y label and axis
    ylim( ylims )
    yticks( yvec )
    yticklabels( ytickcell )
    h = ylabel('\textbf{CO}$_2$ \textbf{emissions [GtC/year]}');
    set(h, 'Interpreter', 'latex');

    % change fontsize
    set(gca, 'fontsize', sf);
    
    % introduce legend
    if ~test
        h = legend( "\textbf{historical atmospheric CO$_2$}", 'location','northwest' );
    else
                h = legend( "\textbf{historical atmospheric CO$_2$}",...
                            "\textbf{below 1.5$^\circ$C}",...
                            "\textbf{1.5$^\circ$C low ov.}",...
                            "\textbf{1.5$^\circ$C high ov.}",...
                            "\textbf{lower 2$^\circ$C}",...
                            "\textbf{higher 2$^\circ$C}",...
                            "\textbf{above 2$^\circ$C}",...                          
                            "\textbf{BAU}",...
                    'location','northwest' );
    end

    set( h, 'Interpreter', 'latex' );
    set( h, 'color', 'none' );
    legend boxoff

    % set background color
    set( gca, 'color', backgroundCol )

    % activate grid and modify properties
    grid
    ax = gca;
    ax.GridLineStyle = '-';
    ax.GridColor = gridCol;
    ax.GridAlpha = 0.7;
    hold off        

    % set background color
    set( gcf, 'color', [1, 1, 1] )

    fig = gcf;
    set(gcf,'papersize',[figw*1.05 figh])
    fig.InvertHardcopy = 'off';
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
print( strcat( outname, ".pdf" ), '-dpdf' )


%% Figure 3 histograms of detection time
% load the results of detection
base  = "2010";
load( strcat('workspaces/Detection_aCO2_IISA_base', base, '_',method,'.mat') )

% output file name
outname = strcat( path_pics, 'article/fig3_detectionResults' );
scale = 1.4;
figw = scale*1400;
figh = scale*400;

% change for y-lim
ylims      = [ 10 47 ];
yvec       = [ 15 20 25 30 35 40 45 ];
ytickcell  = { '\textbf{15}', '\textbf{20}', '\textbf{25}',...
               '\textbf{30}', '\textbf{35}', '\textbf{40}', '\textbf{45}' };

%%%% simple histograms with mean
    figure(3), clf, hold on
    set(gcf, 'Position', [ 300 300 figw figh]);
    set(gcf,'PaperPosition', [ 300 300 figw figh])

    I1 = strcmp(names_category(1), category);
    I2 = strcmp(names_category(2), category);
    I3 = strcmp(names_category(3), category);
    I4 = strcmp(names_category(4), category);
    I5 = strcmp(names_category(5), category);
    I6 = strcmp(names_category(6), category);

    x = [ detect_year( I1 ), detect_year( I2 ), detect_year( I3 ),...
          detect_year( I4 ), detect_year( I5 ), detect_year( I6 ) ];

    g1 = repmat( { '\textbf{1.5$^\circ$C below}' }, sum( I1 ), 1 );
    g2 = repmat( { '\textbf{1.5$^\circ$C low ov.}' }, sum( I2 ), 1 );
    g3 = repmat( { '\textbf{1.5$^\circ$C high ov.}' }, sum( I3 ), 1 );
    g4 = repmat( { '\textbf{2$^\circ$C lower}' }, sum( I4 ), 1 );
    g5 = repmat( { '\textbf{2$^\circ$C higher}' }, sum( I5 ), 1 );
    g6 = repmat( { '\textbf{2$^\circ$C above}' }, sum( I6 ), 1 );

    g = [g1; g2; g3; g4; g5; g6];
    
    set(groot,'defaultAxesTickLabelInterpreter','latex');  
    h = boxplot( x, g, 'Colors', ColScheme( 1 : end - 1, : ),...
             'BoxStyle', 'filled',...
             'MedianStyle', 'line',...
             'PlotStyle', 'traditional',...%'compact',...
             'Widths', 0.01 );
    set( h, { 'linew' }, { lwdObs } );

    bp = gca;
    bp.XAxis.TickLabelInterpreter = 'latex';
    bp.YAxis.TickLabelInterpreter = 'latex';

    a = get( get( gca, 'children' ), 'children' );   % Get the handles of all the objects
    t = get( a, 'tag' );           % List the names of all the objects 
    idx = strcmpi( t, 'box' );     % Find Box objects
    boxes = a( idx );              % Get the children you need
    set( boxes, 'linewidth', 40 ); % Set width
   
    dx = 0.15;
    med = median(detect_year( I1 ));
    errorbar( 1, med, dx, 'horizontal',...
              'LineWidth', lwdObs, 'Color', Categories(1,:) )
        med = median(detect_year( I2 ));
    errorbar( 2, med, dx, 'horizontal',...
              'LineWidth', lwdObs, 'Color', Categories(2,:) )
    med = median(detect_year( I3 ));
    errorbar( 3, med, dx, 'horizontal',...
              'LineWidth', lwdObs, 'Color', Categories(3,:) )
    med = median(detect_year( I4 ));
    errorbar( 4, med, dx, 'horizontal',...
              'LineWidth', lwdObs, 'Color', Categories(4,:) )
    med = median(detect_year( I5 ));
    errorbar( 5, med, dx, 'horizontal',...
              'LineWidth', lwdObs, 'Color', Categories(5,:) )
    med = median(detect_year( I6 ));
    errorbar( 6, med, dx, 'horizontal',...
              'LineWidth', lwdObs, 'Color', Categories(6,:) )
    % change y label and axis
    ylim( ylims )
    yticks( yvec )
    yticklabels( ytickcell )
    
    h = ylabel( '\textbf{ detection delay [years]}' );
    set( h, 'Interpreter', 'latex' );

    % change fontsize
    set( gca, 'fontsize', sf );

    % set background color
    set( gca, 'color', backgroundCol )

    % activate grid and modify properties
    set(gca,'XGrid','off')
    set(gca,'YGrid','on')
    ax = gca;
    ax.GridLineStyle = '-';
    ax.GridColor = gridCol;
    ax.GridAlpha = 0.7;
    hold off        

    % set background color
    set( gcf, 'color', [1, 1, 1] )

    fig = gcf;
    set(gcf,'papersize',[figw*1.1 figh*1.1])
    fig.InvertHardcopy = 'off';
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
print( strcat( outname, ".pdf" ), '-dpdf' )