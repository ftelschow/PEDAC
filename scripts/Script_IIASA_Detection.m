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

% set correct working directory
path      = '/home/drtea/Research/Projects/CO2policy/PEDAC';
path_pics = '/home/drtea/Research/Projects/CO2policy/pics/';
path_data = '/home/drtea/Research/Projects/CO2policy/PEDAC/data/';

addpath '/home/drtea/Research/Projects/HermiteProjector'
cd(path)
clear path

%%%% load color data base for plots
load(strcat(path_data,'colors.mat'))
% choose main color scheme for this script 
ColScheme  = Categories;

methodVec = ["direct" "interpolation"];

%%%% Constants
% convert constant from gton to ppm
gtonC_2_ppmC = 1/2.124; % Quere et al 2017
% convert C to CO2
C2CO2       = 44.01/12.011;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Apply detection method to the Models using atmospheric CO2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate AR process for imbalance
Msim  = 1e5;
T     = length( 2000 : 2100 );
rho   = 0.44;
sigma = 3;

% Compute threshold
IMBALANCE = cumsum( generate_AR( Msim, T, rho, sigma ) );
q = 0.05;
thresholdsF  = get_Thresholds( IMBALANCE, q );

% Simulate imbalance as error processes
IMBALANCE = cumsum( generate_AR( Msim, T, rho, sigma ) );

%%%%%%%% Fixed start year
for method = methodVec
    % load the CO2 in atmosphere predicted using the Joos model
    load(strcat(path_data,"AtmosphericCO2_IISA_",method,".mat"))

    % detection time container
    detect_year = zeros( [ 1 Nalt ] );
    
    % Year we start to search for an detection
    detectStart = repmat( 2010, [ 1 Nalt ] );

    % define the times
    times      = 1:size(COa_bau,1);

    for scn = 1 : Nalt
            % Find cutting point
            I_cut1 = times( COa_bau( :, 1 ) == detectStart( scn ) );

            % Define drifts for base and 2deg scenario
            drift_base  = COa_bau( I_cut1 : 12 : end, corBAU( scn )+1 );
            drift_alter = COa_alt( I_cut1 : 12 : end, scn+1 );
            
            % get length of the future prediction after start time
            mT = length( drift_base );
            years = detectStart(scn):(detectStart(scn)+mT-1);

            % Plot the power plot from Armins method
            [probs, dyear,~] = get_Detection2( IMBALANCE( 1:mT, :),...
                                               [drift_base,drift_alter]'/gtonC_2_ppmC...
                                               * C2CO2,...
                                               thresholdsF( 1:mT ), q);
            plot_Detection( dyear, probs, detectStart(scn), q,...
                            strcat(path_pics,'detect_',...
                            method,'/Sc_',num2str(scn),...
                            '_detection_aCO2_IISA_base2010_',method,'.png'));

            detect_year(scn)  = dyear;

            figure(1), clf, hold on
            WidthFig  = 500*1.1;
            HeightFig = 400*1.1;
            set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
            set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
            set(groot, 'defaultAxesTickLabelInterpreter','latex');
            set(groot, 'defaultLegendInterpreter','latex');
                    plot(years, drift_base, 'LineWidth', 1.5, 'Color', ColScheme(1,:))
                    plot(years, drift_alter, 'LineWidth', 1.5, 'Color', ColScheme(3,:))
                    plot([years(dyear) years(dyear)], [-2000, 2000], 'k--')
                    title('atmospheric CO2')
            h = xlabel('years');  set(h, 'Interpreter', 'latex');
            h = ylabel('atmospheric CO2 [ppm/year]');  set(h, 'Interpreter', 'latex');
            ylim([350 550])
            xlim([2005 2050])
            h = legend( namesBAU{corBAU(scn)},...
                        namesAlt{scn},...
                        'location','northwest');  set(h, 'Interpreter', 'latex');    grid
            set(gca, 'fontsize', 14);

            set(gcf,'papersize',[12 12])
            fig = gcf;
            fig.PaperPositionMode = 'auto';
            fig_pos = fig.PaperPosition;
            fig.PaperSize = [fig_pos(3) fig_pos(4)];
            print(strcat(path_pics,'detect_',method,'/Sc_',num2str(scn),...
                'DetectionTimes_aCO2_IISA_base2010_',method,'.png'), '-dpng')
            hold off
    end

    save(strcat('workspaces/Detection_aCO2_IISA_base2010_',method,'.mat'),...
            'detect_year', 'detectStart', 'category', 'sub_category',...
            'namesAlt', 'namesBAU', 'start_year_alt', 'start_year_bau',...
            'Nbau', 'Nalt', 'names_category', 'names_sub_category')
end

%%%%%%%% Variable start year
% Save detection time
detect_year = zeros([1  Nalt]);

for method = methodVec
    load(strcat(path_data,"AtmosphericCO2_IISA_",method,".mat"))

    times       = 1:size(COa_bau,1);

    for scn = 1 : Nalt
            % Find cutting point
            I_cut1 = times(COa_bau(:,1)==detectStart(scn));

            % Define drifts for base and 2deg scenario
            drift_base  = COa_bau( I_cut1 : 12 : end, corBAU( scn )+1 );
            drift_alter = COa_alt( I_cut1 : 12 : end, scn+1 );
            mT = length(drift_base);
            years = detectStart(scn):(detectStart(scn)+mT-1);

            % Plot the power plot from Armins method
            [probs, dyear,~] = get_Detection2( IMBALANCE( 1:mT, :),...
                                               [drift_base,drift_alter]'/gtonC_2_ppmC...
                                               * C2CO2,...
                                               thresholdsF( 1:mT ), q);
            plot_Detection( dyear, probs, detectStart(scn), q,...
                            strcat(path_pics,'detect_',...
                            method,'/Sc_',num2str(scn),...
                            '_detection_aCO2_IISA_baseVar_',method,'.png'));

            detect_year(scn)  = dyear;

            figure(1), clf, hold on
            WidthFig  = 500*1.1;
            HeightFig = 400*1.1;
            set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
            set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
            set(groot, 'defaultAxesTickLabelInterpreter','latex');
            set(groot, 'defaultLegendInterpreter','latex');
                    plot(years, drift_base, 'LineWidth', 1.5, 'Color', ColScheme(1,:))
                    plot(years, drift_alter, 'LineWidth', 1.5, 'Color', ColScheme(3,:))
                    plot([years(dyear) years(dyear)], [-2000, 2000], 'k--')
                    title('atmospheric CO2')
            h = xlabel('years');  set(h, 'Interpreter', 'latex');
            h = ylabel('atmospheric CO2 [ppm/year]');  set(h, 'Interpreter', 'latex');
            ylim([350 550])
            xlim([2005 2050])
            h = legend( namesBAU{corBAU(scn)},...
                        namesAlt{scn},...
                        'location','northwest');  set(h, 'Interpreter', 'latex');    grid
            set(gca, 'fontsize', 14);

            set(gcf,'papersize',[12 12])
            fig = gcf;
            fig.PaperPositionMode = 'auto';
            fig_pos = fig.PaperPosition;
            fig.PaperSize = [fig_pos(3) fig_pos(4)];
            print(strcat(path_pics,'detect_',method,'/Sc_',num2str(scn),...
                'DetectionTimes_aCO2_IISA_baseVar_',method,'.png'), '-dpng')
            hold off
    end

    save(strcat('workspaces/Detection_aCO2_IISA_baseVar_',method,'.mat'),...
            'detect_year', 'detectStart', 'category', 'sub_category',...
            'namesAlt', 'namesBAU', 'start_year_alt', 'start_year_bau',...
            'Nbau', 'Nalt', 'names_category', 'names_sub_category')
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%                     Visualize the results
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baseVec  = ["2010" "Var"];

WidthFig  = 600;
HeightFig = 400;

%%%% simple histograms with mean
for method = methodVec
    for base = baseVec
        % load the results of the 
        load( strcat('workspaces/Detection_aCO2_IISA_base', base, '_',method,'.mat') )
              
        figure(1), clf, hold on
        set(gcf, 'Position', [ 300 300 1.5*WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');
        
        I1 = strcmp(names_category(1), category);
        I2 = strcmp(names_category(2), category);
        I3 = strcmp(names_category(3), category);
        I4 = strcmp(names_category(4), category);
        I5 = strcmp(names_category(5), category);
        I6 = strcmp(names_category(6), category);
        
        x = [ detect_year( I1 ), detect_year( I2 ), detect_year( I3 ),...
              detect_year( I4 ), detect_year( I5 ), detect_year( I6 ) ];
          
        g1 = repmat( { '1.5C below' }, sum( I1 ), 1 );
        g2 = repmat( { '1.5C low ov.' }, sum( I2 ), 1 );
        g3 = repmat( { '1.5C high ov.' }, sum( I3 ), 1 );
        g4 = repmat( { '2C lower' }, sum( I4 ), 1 );
        g5 = repmat( { '2C higher' }, sum( I5 ), 1 );
        g6 = repmat( { '2C above' }, sum( I6 ), 1 );
        
        g = [g1; g2; g3; g4; g5; g6];
        
        h = boxplot( x, g, 'Colors', ColScheme( 1 : end - 1, : ),...
                 'BoxStyle', 'filled',...
                 'MedianStyle', 'target',...
                 'PlotStyle', 'traditional',...%'compact',...
                 'Widths', 0.1);
        grid
        bp = gca;
        bp.XAxis.TickLabelInterpreter = 'latex';
             
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        t = get(a,'tag');          % List the names of all the objects 
        idx = strcmpi(t,'box');    % Find Box objects
        boxes = a(idx);            % Get the children you need
        set(boxes,'linewidth',20); % Set width
      
        title(strcat("Detection Times vs Baseline"))

        h = ylabel('years');  set(h, 'Interpreter', 'latex');
        h = xlabel('category');  set(h, 'Interpreter', 'latex');
        set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'detect_',method,'/Box_Detect_aCO2_IISA_base', base,...
                "_cats_", method,'.png'), '-dpng')
        hold off

        
        figure(2), clf, hold on
        set(gcf, 'Position', [ 300 300 2.3*WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');
        
        I1 = strcmp( names_sub_category(1), sub_category );
        I2 = strcmp( names_sub_category(2), sub_category );
        I3 = strcmp( names_sub_category(3), sub_category );
        I4 = strcmp( names_sub_category(4), sub_category );
        I5 = strcmp( names_sub_category(5), sub_category );
        I6 = strcmp( names_sub_category(6), sub_category );
        I7 = strcmp( names_sub_category(7), sub_category );
        I8 = strcmp( names_sub_category(8), sub_category );
        
        x = [ detect_year( I1 ), detect_year( I2 ), detect_year( I3 ),...
              detect_year( I4 ), detect_year( I5 ), detect_year( I6 ),...
              detect_year( I7 ), detect_year( I8 )];
          
        g1 = repmat( { '1.5C below' },     sum( I1 ), 1 );
        g2 = repmat( { 'l1.5C low ov.' },  sum( I2 ), 1 );
        g3 = repmat( { 'h1.5C low ov.' },  sum( I3 ), 1 );
        g4 = repmat( { 'l1.5C high ov.' }, sum( I4 ), 1 );
        g5 = repmat( { 'h1.5C high ov.' }, sum( I5 ), 1 );
        g6 = repmat( { '2C lower' },       sum( I6 ), 1 );
        g7 = repmat( { '2C higher' },      sum( I7 ), 1 );
        g8 = repmat( { '2C above' },       sum( I8 ), 1 );
        
        g = [ g1; g2; g3; g4; g5; g6; g7; g8 ];
        
        h = boxplot( x, g, 'Colors', ColScheme( [1 2 2 3 3 4 5 6], : ),...
                 'BoxStyle', 'filled',...
                 'MedianStyle', 'target',...
                 'PlotStyle', 'traditional',...%'compact',...
                 'Widths', 0.1);
        grid
        bp = gca;
        bp.XAxis.TickLabelInterpreter = 'latex';
             
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        t = get(a,'tag');          % List the names of all the objects 
        idx = strcmpi(t,'box');    % Find Box objects
        boxes = a(idx);            % Get the children you need
        set(boxes,'linewidth',20); % Set width
      
        title(strcat("Detection Times vs Baseline"))

        h = ylabel('years');  set(h, 'Interpreter', 'latex');
        h = xlabel('category');  set(h, 'Interpreter', 'latex');
        set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'detect_',method,'/Box_Detect_aCO2_IISA_base', base,...
                "_sub_cats_", method,'.png'), '-dpng')
        hold off
    end
end


%%%% add startyear
for method = methodVec
    for base = baseVec
        % load the results of the 
        load( strcat('workspaces/Detection_aCO2_IISA_base', base, '_',method,'.mat') )
              
        figure(1), clf, hold on
        set(gcf, 'Position', [ 300 300 1.5*WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');
        
        I1 = strcmp(names_category(1), category);
        I2 = strcmp(names_category(2), category);
        I3 = strcmp(names_category(3), category);
        I4 = strcmp(names_category(4), category);
        I5 = strcmp(names_category(5), category);
        I6 = strcmp(names_category(6), category);
        
        x = [ detect_year( I1 ) + detectStart( I1 ),...
              detect_year( I2 ) + detectStart( I2 ),...
              detect_year( I3 ) + detectStart( I3 ),...
              detect_year( I4 ) + detectStart( I4 ),...
              detect_year( I5 ) + detectStart( I5 ),...
              detect_year( I6 ) + detectStart( I6 ), ];
          
        g1 = repmat( { '1.5C below' }, sum( I1 ), 1 );
        g2 = repmat( { '1.5C low ov.' }, sum( I2 ), 1 );
        g3 = repmat( { '1.5C high ov.' }, sum( I3 ), 1 );
        g4 = repmat( { '2C lower' }, sum( I4 ), 1 );
        g5 = repmat( { '2C higher' }, sum( I5 ), 1 );
        g6 = repmat( { '2C above' }, sum( I6 ), 1 );
        
        g = [g1; g2; g3; g4; g5; g6];
        
        h = boxplot( x, g, 'Colors', ColScheme( 1 : end - 1, : ),...
                 'BoxStyle', 'filled',...
                 'MedianStyle', 'target',...
                 'PlotStyle', 'traditional',...%'compact',...
                 'Widths', 0.1);
        grid
        bp = gca;
        bp.XAxis.TickLabelInterpreter = 'latex';
             
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        t = get(a,'tag');          % List the names of all the objects 
        idx = strcmpi(t,'box');    % Find Box objects
        boxes = a(idx);            % Get the children you need
        set(boxes,'linewidth',20); % Set width
      
        title(strcat("Detection Times vs Baseline"))

        h = ylabel('years');  set(h, 'Interpreter', 'latex');
        h = xlabel('category');  set(h, 'Interpreter', 'latex');
        set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'detect_',method,'/Box_Detect_aCO2_IISA_base', base,...
                "_cats_", method,'_addStartYear.png'), '-dpng')
        hold off

        
        figure(2), clf, hold on
        set(gcf, 'Position', [ 300 300 2.3*WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');
        
        I1 = strcmp( names_sub_category(1), sub_category );
        I2 = strcmp( names_sub_category(2), sub_category );
        I3 = strcmp( names_sub_category(3), sub_category );
        I4 = strcmp( names_sub_category(4), sub_category );
        I5 = strcmp( names_sub_category(5), sub_category );
        I6 = strcmp( names_sub_category(6), sub_category );
        I7 = strcmp( names_sub_category(7), sub_category );
        I8 = strcmp( names_sub_category(8), sub_category );
        
        x = [ detect_year( I1 ), detect_year( I2 ), detect_year( I3 ),...
              detect_year( I4 ), detect_year( I5 ), detect_year( I6 ),...
              detect_year( I7 ), detect_year( I8 )];
          
        g1 = repmat( { '1.5C below' },     sum( I1 ), 1 );
        g2 = repmat( { 'l1.5C low ov.' },  sum( I2 ), 1 );
        g3 = repmat( { 'h1.5C low ov.' },  sum( I3 ), 1 );
        g4 = repmat( { 'l1.5C high ov.' }, sum( I4 ), 1 );
        g5 = repmat( { 'h1.5C high ov.' }, sum( I5 ), 1 );
        g6 = repmat( { '2C lower' },       sum( I6 ), 1 );
        g7 = repmat( { '2C higher' },      sum( I7 ), 1 );
        g8 = repmat( { '2C above' },       sum( I8 ), 1 );
        
        g = [ g1; g2; g3; g4; g5; g6; g7; g8 ];
        
        h = boxplot( x, g, 'Colors', ColScheme( [1 2 2 3 3 4 5 6], : ),...
                 'BoxStyle', 'filled',...
                 'MedianStyle', 'target',...
                 'PlotStyle', 'traditional',...%'compact',...
                 'Widths', 0.1);
        grid
        bp = gca;
        bp.XAxis.TickLabelInterpreter = 'latex';
             
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        t = get(a,'tag');          % List the names of all the objects 
        idx = strcmpi(t,'box');    % Find Box objects
        boxes = a(idx);            % Get the children you need
        set(boxes,'linewidth',20); % Set width
      
        title(strcat("Detection Times vs Baseline"))

        h = ylabel('years');  set(h, 'Interpreter', 'latex');
        h = xlabel('category');  set(h, 'Interpreter', 'latex');
        set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'detect_',method,'/Box_Detect_aCO2_IISA_base', base,...
                "_sub_cats_", method,'.png'), '-dpng')
        hold off
    end
end

%%%% stratification into starting year
baseVec  = ["2010" "Var"];

WidthFig  = 600;
HeightFig = 400;

%%%% simple histograms with mean
for method = methodVec
        for base = baseVec
        % load the results of the 
        load( strcat('workspaces/Detection_aCO2_IISA_base', base, '_',method,'.mat') )
              
        figure(1), clf, hold on
        set(gcf, 'Position', [ 300 300 3*WidthFig  3*HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');
        
        starts = sort(unique(detectStart));
        for i = 1:length(starts)
            I1 = strcmp(names_category(1), category) & detectStart==starts(i);
            I2 = strcmp(names_category(2), category) & detectStart==starts(i);
            I3 = strcmp(names_category(3), category) & detectStart==starts(i);
            I4 = strcmp(names_category(4), category) & detectStart==starts(i);
            I5 = strcmp(names_category(5), category) & detectStart==starts(i);
            I6 = strcmp(names_category(6), category) & detectStart==starts(i);

            x = [ detect_year( I1 ), detect_year( I2 ), detect_year( I3 ),...
                  detect_year( I4 ), detect_year( I5 ), detect_year( I6 ) ];

            g1 = repmat( { '1.5C below' }, sum( I1 ), 1 );
            g2 = repmat( { '1.5C low ov.' }, sum( I2 ), 1 );
            g3 = repmat( { '1.5C high ov.' }, sum( I3 ), 1 );
            g4 = repmat( { '2C lower' }, sum( I4 ), 1 );
            g5 = repmat( { '2C higher' }, sum( I5 ), 1 );
            g6 = repmat( { '2C above' }, sum( I6 ), 1 );

            g = [g1; g2; g3; g4; g5; g6];
            colo = [];
            if length(g1) > 0
                colo = [ colo; ColScheme( 1, : ) ];
            end
            if length(g2) > 0
                colo = [ colo; ColScheme( 2, : ) ];
            end
            if length(g3) > 0
                colo = [ colo; ColScheme( 3, : ) ];
            end
            if length(g4) > 0
                colo = [ colo; ColScheme( 4, : ) ];
            end            
            if length(g5) > 0
                colo = [ colo; ColScheme( 5, : ) ];
            end
            if length(g6) > 0
                colo = [ colo; ColScheme( 6, : ) ];
            end
            
            subplot(2,2,i)
            h = boxplot( x, g, 'Colors', colo,...
                     'BoxStyle', 'filled',...
                     'MedianStyle', 'target',...
                     'PlotStyle', 'traditional',...%'compact',...
                     'Widths', 0.1);
            grid
            bp = gca;
            bp.XAxis.TickLabelInterpreter = 'latex';

            a = get(get(gca,'children'),'children');   % Get the handles of all the objects
            t = get(a,'tag');          % List the names of all the objects 
            idx = strcmpi(t,'box');    % Find Box objects
            boxes = a(idx);            % Get the children you need
            set(boxes,'linewidth',20); % Set width

            title(strcat("Detection Times vs Baseline"))

            h = ylabel('years');  set(h, 'Interpreter', 'latex');
            h = xlabel('category');  set(h, 'Interpreter', 'latex');
            set(gca, 'fontsize', 14);
        end

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'detect_',method,'/Box_Detect_aCO2_IISA_base', base,...
                "_cats_detectStart_", method,'.png'), '-dpng')
        hold off
        end
% 
%         
%         figure(2), clf, hold on
%         set(gcf, 'Position', [ 300 300 2.3*WidthFig HeightFig]);
%         set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
%         set(groot, 'defaultAxesTickLabelInterpreter','latex');
%         set(groot, 'defaultLegendInterpreter','latex');
%         
%         I1 = strcmp( names_sub_category(1), sub_category );
%         I2 = strcmp( names_sub_category(2), sub_category );
%         I3 = strcmp( names_sub_category(3), sub_category );
%         I4 = strcmp( names_sub_category(4), sub_category );
%         I5 = strcmp( names_sub_category(5), sub_category );
%         I6 = strcmp( names_sub_category(6), sub_category );
%         I7 = strcmp( names_sub_category(7), sub_category );
%         I8 = strcmp( names_sub_category(8), sub_category );
%         
%         x = [ detect_year( I1 ), detect_year( I2 ), detect_year( I3 ),...
%               detect_year( I4 ), detect_year( I5 ), detect_year( I6 ),...
%               detect_year( I7 ), detect_year( I8 )];
%           
%         g1 = repmat( { '1.5C below' },     sum( I1 ), 1 );
%         g2 = repmat( { 'l1.5C low ov.' },  sum( I2 ), 1 );
%         g3 = repmat( { 'h1.5C low ov.' },  sum( I3 ), 1 );
%         g4 = repmat( { 'l1.5C high ov.' }, sum( I4 ), 1 );
%         g5 = repmat( { 'h1.5C high ov.' }, sum( I5 ), 1 );
%         g6 = repmat( { '2C lower' },       sum( I6 ), 1 );
%         g7 = repmat( { '2C higher' },      sum( I7 ), 1 );
%         g8 = repmat( { '2C above' },       sum( I8 ), 1 );
%         
%         g = [ g1; g2; g3; g4; g5; g6; g7; g8 ];
%         
%         h = boxplot( x, g, 'Colors', ColScheme( [1 2 2 3 3 4 5 6], : ),...
%                  'BoxStyle', 'filled',...
%                  'MedianStyle', 'target',...
%                  'PlotStyle', 'traditional',...%'compact',...
%                  'Widths', 0.1);
%         bp = gca;
%         bp.XAxis.TickLabelInterpreter = 'latex';
%              
%         a = get(get(gca,'children'),'children');   % Get the handles of all the objects
%         t = get(a,'tag');          % List the names of all the objects 
%         idx = strcmpi(t,'box');    % Find Box objects
%         boxes = a(idx);            % Get the children you need
%         set(boxes,'linewidth',20); % Set width
%       
%         title(strcat("Detection Times vs Baseline"))
% 
%         h = ylabel('years');  set(h, 'Interpreter', 'latex');
%         h = xlabel('category');  set(h, 'Interpreter', 'latex');
%         set(gca, 'fontsize', 14);
% 
%         set(gcf,'papersize',[12 12])
%         fig = gcf;
%         fig.PaperPositionMode = 'auto';
%         fig_pos = fig.PaperPosition;
%         fig.PaperSize = [fig_pos(3) fig_pos(4)];
%         print(strcat(path_pics,'detect_',method,'/Box_Detect_aCO2_IISA_base', base,...
%                 "_sub_cats_", method,'.png'), '-dpng')
%         hold off
end

%% Numbers within categories
Ncategories = [ sum(strcmp(names_category(1), category)),...
                sum(strcmp(names_category(2), category)),...
                sum(strcmp(names_category(3), category)),...
                sum(strcmp(names_category(4), category)),...
                sum(strcmp(names_category(5), category)),...
                sum(strcmp(names_category(6), category)),...
    ]

Nsubcategories = [ sum(strcmp(names_sub_category(1), sub_category)),...
                sum(strcmp(names_sub_category(2), sub_category)),...
                sum(strcmp(names_sub_category(3), sub_category)),...
                sum(strcmp(names_sub_category(4), sub_category)),...
                sum(strcmp(names_sub_category(5), sub_category)),...
                sum(strcmp(names_sub_category(6), sub_category)),...
                sum(strcmp(names_sub_category(7), sub_category)),...
                sum(strcmp(names_sub_category(8), sub_category)),...
    ]
