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
C2CO2       = 44.01 / 12.011;
gtonC_2_ppm = 1 / 2.124;

%%%% load color data base for plots
load( strcat( path_data, 'colors.mat' ) )
% choose main color scheme for this script 
ColScheme  = Categories;

% colors
backgroundCol = [255, 255, 255] / 255;
gridCol = [ 112, 128, 144 ] / 255;
bauCol = [ 128, 128, 128 ] / 255;
histCol = BrightCol( 4, : );

% defaultfigure scale
scale = 1;
figw = scale * 600;
figh = scale * 500;

% line widths
lwdObs = 2;
lwdProj = 1.1;

% global changes for x-axis labels
xvec       = [ 1975, 2000, 2025, 2050, 2075, 2100 ];
xtickcell  = { '\textbf{1975}', '\textbf{2000}', '\textbf{2025}',...
               '\textbf{2050}', '\textbf{2075}', '\textbf{2100}' };
           
% global fontsize
sf = 19;

% legend in plots on or of?
legend_on = 1;
outside   = 0;

method = "interpolation"

%% Figure 1
% load past emissions
load( strcat( path_data, 'Emissions_PastMontly.mat' ) )
% load future emissions
load( strcat( path_data, 'Emissions_IIASA_FutureMontly.mat' ) )

path_pics = strcat( path1, 'pics/' );

PastTotalCO2emission = PastTotalCO2emissionScripps;

% output file name
if legend_on
    outname = strcat( path_pics, 'article/fig1_emissions_legend' );
else
    outname = strcat( path_pics, 'article/fig1_emissions' );
end

if legend_on
    if outside
        loc = "eastoutside";
        lsf = sf - 4;
        scale = 1;
        % figure scale
        figw = scale * 800;
        figh = scale * 500;
    else
        loc = "northwest";
        lsf = sf - 4;
        scale = 1;
        % figure scale
        figw = scale * 600;
        figh = scale * 500;
    end
end


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
    
    if legend_on
        % just for the legend
        plot( [0 1], [1 1], 'color', histCol, 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', bauCol, 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(6,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(5,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(4,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(3,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(2,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(1,:), 'LineWidth', lwdObs )
    end
   % plot the BAU emission scenarios
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
    
    %%%% plot alternative emission scenarios
    %%%% plot 2°C emission scenarios
    data    = data_alt;
    scnVec  = 1:(size(data,2)-1);
    cutyear = start_year_alt;
    scns    = strcmp(category, names_category(4) ) | ...
              strcmp(category, names_category(5) ) | ...
              strcmp(category, names_category(6) );

    for scn = scnVec( scns )
        % get correct color
        if strcmp( names_category(4), category(scn) )
            colo = Categories(4,:);
        elseif strcmp( names_category(5), category(scn) )
            colo = Categories(5,:);
        elseif strcmp( names_category(6), category(scn) )
            colo = Categories(6,:);
        end

        % years for the interpolation
        cyear = [ cutyear( scn ) - 5 cutyear( scn ) ];

        % interpolate and concatinate future and past emissions
        data_tmp = concatinateTimeseries( PastTotalCO2emission,...
                                          data(:, [ 1, scn + 1 ] ),...
                                          cyear,...
                                          method);
        % plot emissions
        plot( data_tmp( :, 1 ), data_tmp( :, 2 ) / gtonC_2_ppm,...
              'color', colo, 'LineWidth', lwdProj )    
    end

    %%%% plot 1.5°C emission scenarios
    data    = data_alt;
    scnVec  = 1:(size(data,2)-1);
    cutyear = start_year_alt;
    scns    = strcmp(category, names_category(1) ) | ...
              strcmp(category, names_category(2) ) | ...
              strcmp(category, names_category(3) );

    for scn = scnVec( scns )
        % get correct color
        if strcmp( names_category(1), category(scn) )
            colo = Categories(1,:);
        elseif strcmp( names_category(2), category(scn) )
            colo = Categories(2,:);
        elseif strcmp( names_category(3), category(scn) )
            colo = Categories(3,:);
        end
        
        % years for the interpolation
        cyear = [ cutyear( scn ) - 5 cutyear( scn ) ];

        % interpolate and concatinate future and past emissions
        data_tmp = concatinateTimeseries( PastTotalCO2emission,...
                                          data(:, [ 1, scn + 1 ] ),...
                                          cyear,...
                                          method );                           
        % plot emissions
        plot( data_tmp( :, 1 ), data_tmp( :, 2 ) / gtonC_2_ppm,...
              'color', colo, 'LineWidth', lwdProj )    
    end
        
    %%%% plot the past CO2 emissions
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission( :, 2 ) / ...
          gtonC_2_ppm, 'color', histCol, 'LineWidth', lwdObs )   

    % change axis style
    xlim( [ xvec(1) - 10, xvec( end ) ] )
    xticks( xvec )
    xticklabels( xtickcell )

    % change y-label and axis
    ylim( ylims )
    yticks( yvec )
    yticklabels( ytickcell )
    h = ylabel('\textbf{CO}$_2$ \textbf{emissions [GtC/year]}');
    set(h, 'Interpreter', 'latex');

    % change fontsize
    set(gca, 'fontsize', sf);

    % set background color
    set( gca, 'color', backgroundCol )
    set( gcf, 'color', [1, 1, 1] )

    % activate grid and modify properties
    grid
    ax = gca;
    ax.GridLineStyle = '-';
    ax.GridColor = gridCol;
    ax.GridAlpha = 0.7;
    
    % legend
    if legend_on
        if outside
            loc = "eastoutside";
            lsf = sf;
        else
            loc = "northwest";
            lsf = sf-4;
        end
        h = legend( "\textbf{historical}",...
                "\textbf{BAU}",...
                "\textbf{above 2$^\circ$C}",...
                "\textbf{higher 2$^\circ$C}",...        
                "\textbf{lower 2$^\circ$C}",...
                "\textbf{1.5$^\circ$C high ov.}",...
                "\textbf{1.5$^\circ$C low ov.}",...
                "\textbf{below 1.5$^\circ$C}",...
                "location", loc );
        set( h, 'Interpreter', 'latex' );
        set( h, 'color', [1 1 1] );
        set( h, 'FontSize', lsf );
    end
        
    fig = gcf;
    set(gcf,'papersize',[figw*2.25 figh*2.25]);
    fig.InvertHardcopy = 'off';
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
print( strcat( outname, ".png" ), '-dpng' )


%% %%%% Figure 2
%%%% load the correct atmospheric CO2 data
% predicted future values
load( strcat( path_data, 'AtmosphericCO2_IISA_', method, '.mat' ) );
% observed values
load( strcat( path_data, 'AtmosphereCO2/dataObservedCO2.mat' ) );
% remove unneccessary data
clear dpCO2a_obs dtdelpCO2a_obs

path_pics = strcat( path1, 'pics/' );


% output file name
if legend_on
    outname = strcat( path_pics, 'article/fig2_atmosphericCO2_legend' );
else
    outname = strcat( path_pics, 'article/fig2_atmosphericCO2' );
end

PastTotalCO2emission = PastTotalCO2emissionScripps;

% change for y-lim
ylims      = [ 290 1e3 ];
yvec       = ( 3 : 10 ) * 100;
ytickcell  = { '\textbf{300}', '\textbf{400}', '\textbf{500}',...
               '\textbf{600}', '\textbf{700}', '\textbf{800}'...
               '\textbf{900}', '\textbf{1000}' };

% plot the predicted atmospheric CO2 from Joos Model
figure(2), clf, hold on
    set(gcf, 'Position', [ 300 300 figw figh ] );
    set(gcf, 'PaperPosition', [ 300 300 figw figh ] )
    set(groot, 'defaultAxesTickLabelInterpreter', 'latex' );
    set(groot, 'defaultLegendInterpreter', 'latex' );

    % just for the legend
    plot( [0 1], [1 1], 'color', histCol, 'LineWidth', lwdObs )
    if legend_on
        plot( [0 1], [1 1], 'color', bauCol, 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(6,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(5,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(4,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(3,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(2,:), 'LineWidth', lwdObs )
        plot( [0 1], [1 1], 'color', Categories(1,:), 'LineWidth', lwdObs )
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
    plot( CO2a_obs(:,1), CO2a_obs(:,2), 'Color', histCol, 'LineWidth', lwdObs )

    % change x axis style
    xlim( [ xvec(1) - 10, xvec( end ) ] )
    xticks( xvec )
    xticklabels( xtickcell )

    % change y label and axis
    ylim( ylims )
    yticks( yvec )
    yticklabels( ytickcell )
    h = ylabel('\textbf{atmospheric CO}$_2$ \textbf{[ppm]}');
    set(h, 'Interpreter', 'latex');

    % change fontsize
    set(gca, 'fontsize', sf);
    
    % introduce legend
    if legend_on
        h = legend( "\textbf{historical}",...
                    "\textbf{BAU}",...
                    "\textbf{above 2$^\circ$C}",...
                    "\textbf{higher 2$^\circ$C}",...        
                    "\textbf{lower 2$^\circ$C}",...
                    "\textbf{1.5$^\circ$C high ov.}",...
                    "\textbf{1.5$^\circ$C low ov.}",...
                    "\textbf{below 1.5$^\circ$C}",...
                    "location", "northwest" );
        set( h, 'Interpreter', 'latex' );
        set( h, 'FontSize', sf-4 );
    end

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
    set(gcf,'papersize',[figw*2.25 figh*2.25]);
    fig.InvertHardcopy = 'off';
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
print( strcat( outname, ".png" ), '-dpng' )


%% Figure 3 histograms of detection time
for base = [ "2000", "2005", "2010" ]
    % load the results of detection
    load( strcat('workspaces/Detection_aCO2_IISA_base', base, '_',method,'.mat') )
    quants = [ 0.05, 0.5, 0.95 ];
    quants_detect_year = get_Quants( detect_year, quants );

    for l = 1:3
    % output file name
    outname = strcat( path_pics, 'article/fig3_detectionResults_base', num2str( base ),...
                      '_quant', num2str( 100*quants( l ) ) );
    scale = 1.2;
    figw = scale*900;
    figh = scale*400;

    % change for y-lim
    if strcmp( base, "2000" )
        ylims      = [ 13 47 ];
        yvec       = [ 15 20 25 30 35 40 45 ];
        ytickcell  = { '\textbf{15}', '\textbf{20}', '\textbf{25}',...
                   '\textbf{30}', '\textbf{35}', '\textbf{40}', '\textbf{45}' };
    elseif strcmp( base, "2000" )
        ylims      = [ 5 42 ];
        yvec       = [ 10 15 20 25 30 35 40 ];
        ytickcell  = { '\textbf{10}', '\textbf{15}', '\textbf{20}', '\textbf{25}',...
                   '\textbf{30}', '\textbf{35}', '\textbf{40}' };
    else
        ylims      = [ 0 37 ];
        yvec       = [ 5 10 15 20 25 30 35 ];
        ytickcell  = { '\textbf{5}', '\textbf{10}', '\textbf{15}', '\textbf{20}', '\textbf{25}',...
                   '\textbf{30}', '\textbf{35}' };
    end

    BoxPos = 0.5*1:6;

    %%%% simple histograms with mean
        figure(3), clf, hold on
        set( gcf, 'Position', [ 300 300 figw figh ] );
        set( gcf, 'PaperPosition', [ 300 300 figw figh ] )

        I1 = strcmp( names_category( 1 ), category );
        I2 = strcmp( names_category( 2 ), category );
        I3 = strcmp( names_category( 3 ), category );
        I4 = strcmp( names_category( 4 ), category );
        I5 = strcmp( names_category( 5 ), category );
        I6 = strcmp( names_category( 6 ), category );

        x = [ quants_detect_year( l, I6 ), quants_detect_year( l, I5 ),...
              quants_detect_year( l, I4 ), quants_detect_year( l, I3 ),...
              quants_detect_year( l, I2 ), quants_detect_year( l, I1 ) ];

        g1 = repmat( { '\begin{tabular}{c} \textbf{1.5$^\circ$C} \\ \textbf{below}\end{tabular}' }, sum( I1 ), 1 );
        g2 = repmat( { '\begin{tabular}{c} \textbf{1.5$^\circ$C} \\ \textbf{low ov.}\end{tabular}' }, sum( I2 ), 1 );
        g3 = repmat( { '\begin{tabular}{c} \textbf{1.5$^\circ$C} \\ \textbf{high ov.}\end{tabular}' }, sum( I3 ), 1 );
        g4 = repmat( { '\begin{tabular}{c} \textbf{2$^\circ$C} \\ \textbf{lower}\end{tabular}' }, sum( I4 ), 1 );
        g5 = repmat( { '\begin{tabular}{c} \textbf{2$^\circ$C} \\ \textbf{higher}\end{tabular}' }, sum( I5 ), 1 );
        g6 = repmat( { '\begin{tabular}{c} \textbf{2$^\circ$C} \\ \textbf{above}\end{tabular}' }, sum( I6 ), 1 );

        g = [g6; g5; g4; g3; g2; g1];

        set(groot,'defaultAxesTickLabelInterpreter','latex');  
        h = boxplot( x, g, 'Colors', ColScheme( (end - 1):-1:1, : ),...
                 'BoxStyle', 'filled',...
                 'MedianStyle', 'line',...
                 'PlotStyle', 'traditional',...%'compact',...
                 'Widths', 0.1,...
                 'Positions', BoxPos...
             );
        set( h, { 'linew' }, { lwdObs } );

        bp = gca;
        bp.XAxis.TickLabelInterpreter = 'latex';
        bp.YAxis.TickLabelInterpreter = 'latex';

        a = get( get( gca, 'children' ), 'children' );   % Get the handles of all the objects
        t = get( a, 'tag' );           % List the names of all the objects 
        idx = strcmpi( t, 'box' );     % Find Box objects
        boxes = a( idx );              % Get the children you need
        set( boxes, 'linewidth', 20 ); % Set width

        dx = 0.15;
        med = median( quants_detect_year( l, I1 ) );
        errorbar( BoxPos( 6 ), med, dx, 'horizontal',...
                  'LineWidth', lwdObs, 'Color', Categories( 1, : ) )
            med = median( quants_detect_year( l, I2 ) );
        errorbar( BoxPos( 5 ), med, dx, 'horizontal',...
                  'LineWidth', lwdObs, 'Color', Categories( 2, : ) )
        med = median( quants_detect_year( l, I3 ) );
        errorbar( BoxPos( 4 ), med, dx, 'horizontal',...
                  'LineWidth', lwdObs, 'Color', Categories( 3, : ) )
        med = median( quants_detect_year( l, I4 ) );
        errorbar( BoxPos( 3 ), med, dx, 'horizontal',...
                  'LineWidth', lwdObs, 'Color', Categories( 4, : ) )
        med = median( quants_detect_year( l, I5 ) );
        errorbar( BoxPos( 2 ), med, dx, 'horizontal',...
                  'LineWidth', lwdObs, 'Color', Categories( 5, : ) )
        med = median( quants_detect_year( l, I6 ) );
        errorbar( BoxPos( 1 ), med, dx, 'horizontal',...
                  'LineWidth', lwdObs, 'Color', Categories( 6, : ) )
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
        set( gca, 'XGrid', 'off' )
        set( gca, 'YGrid', 'on' )
        ax = gca;
        ax.GridLineStyle = '-';
        ax.GridColor = gridCol;
        ax.GridAlpha = 0.7;
        hold off        

        % set background color
        set( gcf, 'color', [ 1, 1, 1 ] )

        fig = gcf;
        set( gcf, 'papersize', [figw figh * 1.1 ] )
        fig.InvertHardcopy = 'off';
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
    print( strcat( outname, ".png" ), '-dpng' )
    end
end