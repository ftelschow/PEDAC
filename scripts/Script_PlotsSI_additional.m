%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%        This script reproduces certain figures for the article <<INSERT>>
%%%%
%%%%        Authors: Fabian Telschow
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear workspace
clear all
close all

% set correct working directory
load( 'paths.mat' )
cd(path_PEDAC)

% convert C to CO2
C2CO2        = 44.01/12.011;
gtonC_2_ppmC = 1 / 2.124;


%%%% load color data base for plots
load(strcat(path_work,'colors.mat'))
% choose main color scheme for this script 
ColScheme  = Categories;

% colors
backgroundCol = [255, 255, 255] / 255;
gridCol = [ 112, 128, 144 ] / 255;
bauCol = [ 128, 128, 128 ] / 255;
histCol = BrightCol(4,:);

% defaultfigure scale
scale = 1;
figw = scale*600;
figh = scale*500;

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

method = "interpolation";

%% Figure 1: Example of future atmospheric CO2
% generate AR process for imbalance
Msim  = 5e2;
T     = length( 2000 : 2100 );
rho   = 0.44;
sigma = 3;

% calibration condition
q = [ 0.05, 0.95 ];

baseVec  = [ 2000 2005 2010];
test_start = baseVec(3);
correct_dt = test_start - 2000;

% Simulate imbalance as error processes
ARsamples = generate_AR( Msim, T-correct_dt, rho, sigma ) * gtonC_2_ppmC / C2CO2;
IMBALANCE = cumsum( ARsamples );

figure(1), clf, hold on,
    set( gcf, 'Position', [ 300 300 figw figh ] );
    set( gcf, 'PaperPosition', [ 300 300 figw figh ] );
    set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
    set( groot, 'defaultLegendInterpreter', 'latex' );
    
    % plot resiudal values
    line( 1:size(IMBALANCE,1), IMBALANCE(:,1:4),...
          'Color', colMat( 1, : ), 'LineWidth', 1.2, 'LineStyle', '-');

    % change x-label
    h = xlabel('\textbf{Year}');
    set(h, 'Interpreter', 'latex');
    
    % change y-label
    h = ylabel('\textbf{Atmospheric \textbf{CO}$_2$  [ppm]}');
    set(h, 'Interpreter', 'latex');

    % change fontsize
    set(gca, 'fontsize', sf);

    % set background color
    set( gca, 'color', backgroundCol )
    set( gcf, 'color', [1, 1, 1] )

    % add title
    h = title("\textbf{Residual error according to cumAR(1)}");
    set(h, 'Interpreter', 'latex');
    hold off
        
    fig = gcf;
    set(gcf,'papersize',[figw*2.25 figh*2.25]);
    fig.InvertHardcopy = 'off';
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print( strcat(path_pics, "ResidualError_cumAR1Model.png"), '-dpng' )

% Load the atmospheric CO2 data
load( strcat( path_data, "AtmosphericCO2_IISA_", method, ".mat" ) )

% Year we start to search for an detection
detectStart = repmat( test_start, [ 1 Nalt ] );

% detection time container
detect_year     = zeros( [ T Nalt ] );
thresholds_year = zeros( [ 1 Nalt ] );

% define the times
times      = 1 : size( COa_bau, 1 );

% Chosen scenario
scn = 2;

% Find cutting point
I_cut1 = times( COa_bau( :, 1 ) == detectStart( scn ) );

% Define drifts for base and 2deg scenario
drift_base  = COa_bau( 1 : 12 : end, corBAU( scn ) + 1 );
drift_alter = COa_alt( 1 : 12 : end, scn + 1 );

% Define the perturbed processes
tstart = size(drift_base, 1) - T + correct_dt + 1;
Samples_base  = repmat(drift_base, [1, Msim]);
Samples_base(tstart:end,:) = Samples_base(tstart:end,:) + IMBALANCE;
Samples_alter  = repmat(drift_alter, [1, Msim]);
Samples_alter(tstart:end,:) = Samples_alter(tstart:end,:) + IMBALANCE;

figure(2), clf, hold on,
    set( gcf, 'Position', [ 300 300 figw figh ] );
    set( gcf, 'PaperPosition', [ 300 300 figw figh ] );
    set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
    set( groot, 'defaultLegendInterpreter', 'latex' );
    plot(2000:2100, Samples_base(250:end,:))

    % change x-label
    h = xlabel('\textbf{Year}');
    set(h, 'Interpreter', 'latex');
    
    % change y-label
    h = ylabel('\textbf{Atmospheric \textbf{CO}$_2$  [ppm]}');
    set(h, 'Interpreter', 'latex');

    % change fontsize
    set(gca, 'fontsize', sf);

    % set background color
    set( gca, 'color', backgroundCol )
    set( gcf, 'color', [1, 1, 1] )

    % add title
    h = title("\textbf{Projections with Uncertainty}");
    set(h, 'Interpreter', 'latex');
    
    % activate grid and modify properties
    grid
    ax = gca;
    ax.GridLineStyle = '-';
    ax.GridColor = gridCol;
    ax.GridAlpha = 0.7;
    hold off
        
    fig = gcf;
    set(gcf,'papersize',[figw*2.25 figh*2.25]);
    fig.InvertHardcopy = 'off';
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print( strcat(path_pics, "BAU_projection_uncertainty.png"), '-dpng' )

    
    figure(3), clf, hold on,
    set( gcf, 'Position', [ 300 300 figw figh ] );
    set( gcf, 'PaperPosition', [ 300 300 figw figh ] );
    set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
    set( groot, 'defaultLegendInterpreter', 'latex' );
    plot(2000:2100, Samples_alter(250:end,:) )

    % change x-label
    h = xlabel('\textbf{Year}');
    set(h, 'Interpreter', 'latex');
    
    % change y-label
    h = ylabel('\textbf{Atmospheric \textbf{CO}$_2$  [ppm]}');
    set(h, 'Interpreter', 'latex');

    % change fontsize
    set(gca, 'fontsize', sf);

    % set background color
    set( gca, 'color', backgroundCol )
    set( gcf, 'color', [1, 1, 1] )

    % add title
    h = title("\textbf{Projections with Uncertainty}");
    set(h, 'Interpreter', 'latex');
    
    % activate grid and modify properties
    grid
    ax = gca;
    ax.GridLineStyle = '-';
    ax.GridColor = gridCol;
    ax.GridAlpha = 0.7;
    hold off
        
    fig = gcf;
    set(gcf,'papersize',[figw*2.25 figh*2.25]);
    fig.InvertHardcopy = 'off';
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print( strcat(path_pics, "ALT_projection_uncertainty.png"), '-dpng' )
    
figure(4), clf, hold on,
    set( gcf, 'Position', [ 300 300 figw figh ] );
    set( gcf, 'PaperPosition', [ 300 300 figw figh ] );
    set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
    set( groot, 'defaultLegendInterpreter', 'latex' );
    plot(2000:2040, Samples_base(250:290,:), 'col', [200, 200, 200]/255 )
    plot(2000:2040, Samples_alter(250:290,:), 'col', [100, 100, 100]/255 )

    % change x-label
    h = xlabel('\textbf{Year}');
    set(h, 'Interpreter', 'latex');
    
    % change y-label
    h = ylabel('\textbf{Atmospheric \textbf{CO}$_2$  [ppm]}');
    set(h, 'Interpreter', 'latex');

    % change fontsize
    set(gca, 'fontsize', sf);

    % set background color
    set( gca, 'color', backgroundCol )
    set( gcf, 'color', [1, 1, 1] )

    % add title
    h = title("\textbf{Projections with Uncertainty}");
    set(h, 'Interpreter', 'latex');
    
    % activate grid and modify properties
    grid
    ax = gca;
    ax.GridLineStyle = '-';
    ax.GridColor = gridCol;
    ax.GridAlpha = 0.7;
    hold off
        
    fig = gcf;
    set(gcf,'papersize',[figw*2.25 figh*2.25]);
    fig.InvertHardcopy = 'off';
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print( strcat(path_pics, "Projection_uncertainty.png"), '-dpng' )

%% Plot the Histograms of results seperately
for method = ["direct", "interpolation"]
for base = [ "2000", "2005", "2010" ]
    % load the results of detection
    load( strcat(path_work, 'Detection_aCO2_IISA_2_base', base, '_',method,'.mat') )
    quants = [ 0.25, 0.5, 0.75 ];
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
end