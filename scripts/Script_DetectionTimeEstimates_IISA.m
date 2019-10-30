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

load( strcat(path_data, 'Emissions_IIASA_FutureMontly.mat'))

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
rho   = 0.48;
sigma = 3;

% Compute threshold
IMBALANCE = cumsum( generate_AR( Msim, T, rho, sigma ) );
q = 0.05;
thresholdsF  = get_Thresholds( IMBALANCE, q );

% Simulate imbalance as error processes
IMBALANCE = cumsum( generate_AR(Msim, T, rho, sigma) );

%%%%%%%% Fixed start year
% Save detection time
detect_year = zeros([1 N1deg]);

for method = methodVec
    load(strcat(path_data,"AtmosphericCO2_IISAMontly_",method,".mat"))

    detectStart = repmat( 2010, [ 1 N1deg ] );

    times      = 1:size(COa_base,1);

    for scn = 2:N1deg+1
        if( ~isnan( category_1P5( scn - 1 ) ) )
            % Find cutting point
            index_cut1 = times(COa_base(:,1)==detectStart(scn-1));

            % Define drifts for base and 2deg scenario
            drift_base  = COa_base( index_cut1 : 12 : end, corBAU_1P5( 2, scn - 1 ) );
            drift_alter = COa_1deg( index_cut1 : 12 : end, scn );
            mT = length(drift_base);
            years = detectStart(scn-1):(detectStart(scn-1)+mT-1);

            % Plot the power plot from Armins method
            [probs, dyear,~] = get_Detection2( IMBALANCE( 1:mT, :),...
                                               [drift_base,drift_alter]'/gtonC_2_ppmC...
                                               * C2CO2,...
                                               thresholdsF( 1:mT ), q);
            plot_Detection( dyear, probs, detectStart(scn-1), q,...
                            strcat(path_pics,'detect_',...
                            method,'/Sc_',num2str(scn),...
                            '_detection_aCO2_IISSA_base2010_1deg_',method,'.png'));

            detect_year(scn-1)  = dyear;

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
            h = legend( namesBase{corBAU_1P5(2,scn-1)-1},...
                        names1deg{scn-1},...
                        'location','northwest');  set(h, 'Interpreter', 'latex');    grid
            set(gca, 'fontsize', 14);

            set(gcf,'papersize',[12 12])
            fig = gcf;
            fig.PaperPositionMode = 'auto';
            fig_pos = fig.PaperPosition;
            fig.PaperSize = [fig_pos(3) fig_pos(4)];
            print(strcat(path_pics,'detect_',method,'/Sc_',num2str(scn),...
                'DetectionTimes_aCO2_IISA_base2010_1deg_',method,'.png'), '-dpng')
            hold off
        end
    end

    save(strcat('workspaces/DetectionTimes_aCO2_IISA_base2010_1deg_',method,'.mat'), 'detect_year', 'detectStart')
end

% Save detection time
detect_year = zeros([1 N2deg]);

for method = methodVec(2)
    load(strcat(path_data,"AtmosphericCO2_IISAMontly_",method,".mat"))

    detectStart = repmat( 2010, [ 1 N2deg ] );

    times      = 1:size(COa_base,1);

    for scn = 2:N2deg+1
        if( ~isnan( category_2( scn - 1 ) ) )
            % Find cutting point
            index_cut1 = times(COa_base(:,1)==detectStart(scn-1));

            % Define drifts for base and 2deg scenario
            drift_base  = COa_base( index_cut1 : 12 : end, corBAU_2( 2, scn - 1 ) );
            drift_alter = COa_2deg( index_cut1 : 12 : end, scn );
            mT = length(drift_base);
            years = detectStart(scn-1):(detectStart(scn-1)+mT-1);

            % Plot the power plot from Armins method
            [probs, dyear,~] = get_Detection2( IMBALANCE( 1:mT, :),...
                                               [drift_base,drift_alter]'/gtonC_2_ppmC...
                                               * C2CO2,...
                                               thresholdsF( 1:mT ), q);
            plot_Detection( dyear, probs, detectStart(scn-1), q,...
                            strcat(path_pics,'detect_',...
                            method,'/Sc_',num2str(scn),'_detection_aCO2_IISSA_base2010_2deg_',method,'.png'));

            detect_year(scn-1)  = dyear;

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
            h = legend( namesBase{corBAU_2(2,scn-1)-1},...
                        names2deg{scn-1},...
                        'location','northwest');  set(h, 'Interpreter', 'latex');    grid
            set(gca, 'fontsize', 14);

            set(gcf,'papersize',[12 12])
            fig = gcf;
            fig.PaperPositionMode = 'auto';
            fig_pos = fig.PaperPosition;
            fig.PaperSize = [fig_pos(3) fig_pos(4)];
            print( strcat(path_pics,'detect_',method,'/Sc_',num2str(scn), ...
                   'DetectionTimes_aCO2_IISA_base2010_2deg_',method,'.png'), ...
                   '-dpng')
            hold off
        end
    end

    save(strcat('workspaces/DetectionTimes_aCO2_IISA_base2010_2deg_',method,'.mat'), 'detect_year', 'detectStart')
end


%%%%%%%% Variable start year
% Save detection time
detect_year = zeros([1 N1deg]);

for method = methodVec
    load(strcat(path_data,"AtmosphericCO2_IISAMontly_",method,".mat"))

    detectStart = detectStart1;
    times       = 1:size(COa_base,1);

    for scn = 2:N1deg+1
        if( ~isnan( category_1P5( scn - 1 ) ) )
            % Find cutting point
            index_cut1 = times(COa_base(:,1)==detectStart(scn-1));

            % Define drifts for base and 2deg scenario
            drift_base  = COa_base( index_cut1 : 12 : end, corBAU_1P5( 2, scn - 1 ) );
            drift_alter = COa_1deg( index_cut1 : 12 : end, scn );
            mT = length(drift_base);
            years = detectStart(scn-1):(detectStart(scn-1)+mT-1);

            % Plot the power plot from Armins method
            [probs, dyear,~] = get_Detection2( IMBALANCE( 1:mT, :),...
                                               [drift_base,drift_alter]'/gtonC_2_ppmC...
                                               * C2CO2,...
                                               thresholdsF( 1:mT ), q);
            plot_Detection( dyear, probs, detectStart(scn-1), q,...
                            strcat(path_pics,'detect_',...
                            method,'/Sc_',num2str(scn),...
                            '_detection_aCO2_IISSA_baseVar_1deg_',method,'.png'));

            detect_year(scn-1)  = dyear;

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
            h = legend( namesBase{corBAU_1P5(2,scn-1)-1},...
                        names1deg{scn-1},...
                        'location','northwest');  set(h, 'Interpreter', 'latex');    grid
            set(gca, 'fontsize', 14);

            set(gcf,'papersize',[12 12])
            fig = gcf;
            fig.PaperPositionMode = 'auto';
            fig_pos = fig.PaperPosition;
            fig.PaperSize = [fig_pos(3) fig_pos(4)];
            print(strcat(path_pics,'detect_',method,'/Sc_',num2str(scn),...
                'DetectionTimes_aCO2_IISA_baseVar_1deg_',method,'.png'), '-dpng')
            hold off
        end
    end

    save(strcat('workspaces/DetectionTimes_aCO2_IISA_baseVar_1deg_',method,'.mat'), 'detect_year', 'detectStart')
end

% Save detection time
detect_year = zeros([1 N2deg]);

for method = methodVec
    load(strcat(path_data,"AtmosphericCO2_IISAMontly_",method,".mat"))
    detectStart = detectStart2;
    times      = 1:size(COa_base,1);

    for scn = 2:N2deg+1
        if( ~isnan( category_2( scn - 1 ) ) )
            % Find cutting point
            index_cut1 = times(COa_base(:,1)==detectStart(scn-1));

            % Define drifts for base and 2deg scenario
            drift_base  = COa_base( index_cut1 : 12 : end, corBAU_2( 2, scn - 1 ) );
            drift_alter = COa_2deg( index_cut1 : 12 : end, scn );
            mT = length(drift_base);
            years = detectStart(scn-1):(detectStart(scn-1)+mT-1);

            % Plot the power plot from Armins method
            [probs, dyear,~] = get_Detection2( IMBALANCE( 1:mT, :),...
                                               [drift_base,drift_alter]'/gtonC_2_ppmC...
                                               * C2CO2,...
                                               thresholdsF( 1:mT ), q);
            plot_Detection( dyear, probs, detectStart(scn-1), q,...
                            strcat(path_pics,'detect_',...
                            method,'/Sc_',num2str(scn),'_detection_aCO2_IISSA_baseVar_2deg_'...
                            ,method,'.png'));

            detect_year(scn-1)  = dyear;

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
            h = legend( namesBase{corBAU_2(2,scn-1)-1},...
                        names2deg{scn-1},...
                        'location','northwest');  set(h, 'Interpreter', 'latex');    grid
            set(gca, 'fontsize', 14);

            set(gcf,'papersize',[12 12])
            fig = gcf;
            fig.PaperPositionMode = 'auto';
            fig_pos = fig.PaperPosition;
            fig.PaperSize = [fig_pos(3) fig_pos(4)];
            print( strcat(path_pics,'detect_',method,'/Sc_',num2str(scn), ...
                   'DetectionTimes_aCO2_IISA_baseVar_2deg_',method,'.png'), ...
                   '-dpng')
            hold off
        end
    end

    save( strcat('workspaces/DetectionTimes_aCO2_IISA_baseVar_2deg_',method,'.mat'),...
          'detect_year', 'detectStart')
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%                     Visualize the results
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baseVec  = ["2010" "Var"];
scenVec = ["1deg" "2deg"];

WidthFig  = 600;
HeightFig = 400;

%%%% simple histograms with mean
for method = methodVec
    for base = baseVec
        for scen = scenVec

        if strcmp(scen, "1deg")
            category = category_1P5;
        else
            category = category_2;
        end

        load( strcat( "workspaces/DetectionTimes_aCO2_IISA_base", base, "_",...
                      scen, "_", method,'.mat') )
        detect_year(detect_year==0) = NaN;
        save( strcat( "workspaces/DetectionTimes_aCO2_IISA_base", base, "_",...
                      scen, "_", method,'.mat'), 'detect_year', 'detectStart' )

        m_detect   = mean( detect_year( ~isnan( detect_year ) ) );
        std_detect = std( detect_year( ~isnan( detect_year ) ) );

        quantile(detect_year(~isnan(detect_year)), [0.05 0.25 0.5 0.75 0.95]);

        figure(1), clf, hold on
        set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');

        histogram(detect_year)
        plot( [m_detect m_detect] ,[0 25], 'LineWidth', 2)
        title(strcat("Detection Times ", scen, " vs Baseline"))
        xlim([0 50])
        ylim([0 25])

        h = xlabel('years until detection');  set(h, 'Interpreter', 'latex');
        h = ylabel('Frequency');  set(h, 'Interpreter', 'latex');
         set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'detect_',method,'/Hist_Detect_aCO2_IISA_base', base, "_",...
                      scen, "_", method,'.png'), '-dpng')
        hold off
        
        figure(2), clf, hold on
        set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');
        
        for k=1:6
            m_detect   = mean( detect_year( category==k ) );
            histogram(detect_year(category==k), 'FaceColor', ColScheme(k,:) )
            plot( [m_detect m_detect] ,[0 25], 'LineWidth', 2, 'Color', ColScheme(k,:))
        end
        title(strcat("Detection Times ", scen, " vs Baseline"))
        xlim([0 50])
        ylim([0 25])

        h = xlabel('years until detection');  set(h, 'Interpreter', 'latex');
        h = ylabel('Frequency');  set(h, 'Interpreter', 'latex');
         set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'detect_',method,'/Hist_Detect_aCO2_IISA_base', base, "_",...
                      scen, "_", method,'.png'), '-dpng')
        hold off
        end
    end
end

%%%% simple histograms with mean and boxplot for categories
for method = methodVec
    for base = baseVec
        detect_year_1P5below = [];
        detect_year_1P5lowOv = [];
        detect_year_1P5higOv = [];
        detect_year_2lower   = [];
        detect_year_2higher  = [];
        detect_year_2above   = [];

        for scen = scenVec
            if strcmp(scen, "1deg")
                category = category_1P5;
            else
                category = category_2;
            end

            load( strcat( "workspaces/DetectionTimes_aCO2_IISA_base", base, "_",...
                          scen, "_", method,'.mat') )


            detect_year_1P5below = [ detect_year_1P5below, ...
                                     detect_year( category == 1 ) ];
            detect_year_1P5lowOv = [ detect_year_1P5lowOv, ...
                                     detect_year( category == 2 ) ];
            detect_year_1P5higOv = [ detect_year_1P5higOv, ...
                                     detect_year( category == 3 ) ];
            detect_year_2lower   = [ detect_year_2lower, ...
                                     detect_year( category == 4 ) ];
            detect_year_2higher  = [ detect_year_2higher, ...
                                     detect_year( category == 5 ) ];
            detect_year_2above   = [ detect_year_2above, ...
                                     detect_year( category == 6 ) ];        
        end
        figure(2), clf, hold on
        set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');
        
        m_detect = mean( detect_year_1P5below );
        histogram(detect_year_1P5below, 'FaceColor', ColScheme(1,:) )
        plot( [m_detect m_detect] ,[0 25], 'LineWidth', 2, 'Color', ColScheme(1,:))

        m_detect = mean( detect_year_1P5lowOv );
        histogram(detect_year_1P5lowOv, 'FaceColor', ColScheme(2,:) )
        plot( [m_detect m_detect] ,[0 25], 'LineWidth', 2, 'Color', ColScheme(2,:))

        m_detect = mean( detect_year_1P5higOv );
        histogram(detect_year_1P5higOv, 'FaceColor', ColScheme(3,:) )
        plot( [m_detect m_detect] ,[0 25], 'LineWidth', 2, 'Color', ColScheme(3,:))

        m_detect = mean( detect_year_2lower );
        histogram(detect_year_2lower, 'FaceColor', ColScheme(4,:) )
        plot( [m_detect m_detect] ,[0 25], 'LineWidth', 2, 'Color', ColScheme(4,:))

        m_detect = mean( detect_year_2higher );
        histogram(detect_year_2higher, 'FaceColor', ColScheme(5,:) )
        plot( [m_detect m_detect] ,[0 25], 'LineWidth', 2, 'Color', ColScheme(5,:))

        m_detect = mean( detect_year_2above );
        histogram(detect_year_2above, 'FaceColor', ColScheme(6,:) )
        plot( [m_detect m_detect] ,[0 25], 'LineWidth', 2, 'Color', ColScheme(6,:))
        
        title(strcat("Detection Times ", scen, " vs Baseline"))
        xlim([0 50])
        ylim([0 25])

        h = xlabel('years until detection');  set(h, 'Interpreter', 'latex');
        h = ylabel('Frequency');  set(h, 'Interpreter', 'latex');
         set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'detect_',method,'/Hist_Detect_aCO2_IISA_base', base,...
                "_all_", method,'.png'), '-dpng')
        hold off
        
        figure(3), clf, hold on
        set(gcf, 'Position', [ 300 300 1.5*WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');
        
        x = [ detect_year_1P5below, detect_year_1P5lowOv, detect_year_1P5higOv, ...
              detect_year_2lower, detect_year_2higher, detect_year_2above];
          
        g1 = repmat( { '1.5C below' }, length( detect_year_1P5below ), 1 );
        g2 = repmat( { '1.5C low ov.' }, length( detect_year_1P5lowOv ), 1 );
        g3 = repmat( { '1.5C high ov.' }, length( detect_year_1P5higOv ), 1 );
        g4 = repmat( { '2C lower' }, length( detect_year_2lower ), 1 );
        g5 = repmat( { '2C higher' }, length( detect_year_2higher ), 1 );
        g6 = repmat( { '2C above' }, length( detect_year_2above ), 1 );
        
        g = [g1; g2; g3; g4; g5; g6];
        
        h = boxplot( x, g, 'Colors', ColScheme( 1 : end - 1, : ),...
                 'BoxStyle', 'filled',...
                 'MedianStyle', 'target',...
                 'PlotStyle', 'traditional',...%'compact',...
                 'Widths', 0.1);
        bp = gca;
        bp.XAxis.TickLabelInterpreter = 'latex';
             
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        t = get(a,'tag');   % List the names of all the objects 
        idx=strcmpi(t,'box');  % Find Box objects
        boxes=a(idx);          % Get the children you need
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
                "_all_", method,'.png'), '-dpng')
        hold off
        
        save( strcat( "workspaces/DetectionTimes_aCO2_IISA_base", base,...
                        "_all_", method,'.mat'),...
                        'detect_year_1P5below', ...
                        'detect_year_1P5lowOv', ...
                        'detect_year_1P5higOv', ...
                        'detect_year_2lower', ...
                        'detect_year_2higher', ...
                        'detect_year_2above' )
    end
end


%%%% simple histograms with mean and boxplot for categories
for method = methodVec
    for base = baseVec
        detect_year_1P5below = [];
        detect_year_low1P5lowOv = [];
        detect_year_hig1P5lowOv = [];
        detect_year_low1P5higOv = [];
        detect_year_hig1P5higOv = [];
        detect_year_2lower   = [];
        detect_year_2higher  = [];
        detect_year_2above   = [];

        for scen = scenVec
            if strcmp(scen, "1deg")
                category = sub_category_1P5;
            else
                category = sub_category_2;
            end

            load( strcat( "workspaces/DetectionTimes_aCO2_IISA_base", base, "_",...
                          scen, "_", method,'.mat') )


            detect_year_1P5below = [ detect_year_1P5below, ...
                                     detect_year( category == 2 ) ];
            detect_year_low1P5lowOv = [ detect_year_low1P5lowOv, ...
                                        detect_year( category == 3 ) ];
            detect_year_hig1P5lowOv = [ detect_year_hig1P5lowOv, ...
                                        detect_year( category == 4 ) ];
            detect_year_low1P5higOv = [ detect_year_low1P5higOv, ...
                                        detect_year( category == 5 ) ];
            detect_year_hig1P5higOv = [ detect_year_hig1P5higOv, ...
                                        detect_year( category == 6 ) ];
            detect_year_2lower   = [ detect_year_2lower, ...
                                     detect_year( category == 7 ) ];
            detect_year_2higher  = [ detect_year_2higher, ...
                                     detect_year( category == 8 ) ];
            detect_year_2above   = [ detect_year_2above, ...
                                     detect_year( category == 9 ) ];        
        end
        
        figure(2), clf, hold on
        set(gcf, 'Position', [ 300 300 3*WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');
        
        x = [ detect_year_1P5below, detect_year_low1P5lowOv, detect_year_hig1P5lowOv,...
              detect_year_low1P5higOv, detect_year_hig1P5higOv,...
              detect_year_2lower, detect_year_2higher, detect_year_2above ];
          
        g1 = repmat( { '1.5C below' }, length( detect_year_1P5below ), 1 );
        g2 = repmat( { 'low 1.5C low ov.' },   length( detect_year_low1P5lowOv ), 1 );
        g3 = repmat( { 'high 1.5C low ov.' },  length( detect_year_hig1P5lowOv ), 1 );
        g4 = repmat( { 'low 1.5C high ov.' },  length( detect_year_low1P5higOv ), 1 );
        g5 = repmat( { 'high 1.5C high ov.' }, length( detect_year_hig1P5higOv ), 1 );
        g6 = repmat( { '2C lower' },  length( detect_year_2lower ), 1 );
        g7 = repmat( { '2C higher' }, length( detect_year_2higher ), 1 );
        g8 = repmat( { '2C above' },  length( detect_year_2above ), 1 );
        
        g = [ g1; g2; g3; g4; g5; g6; g7; g8 ];
        
        h = boxplot( x, g, 'Colors', ColScheme( [1 2 2 3 3 4 5 6], : ),...
                 'BoxStyle', 'filled',...
                 'MedianStyle', 'target',...
                 'PlotStyle', 'traditional',...%'compact',...
                 'Widths', 0.1);
        bp = gca;
        bp.XAxis.TickLabelInterpreter = 'latex';
             
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        t = get(a,'tag');   % List the names of all the objects 
        idx=strcmpi(t,'box');  % Find Box objects
        boxes=a(idx);          % Get the children you need
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
                "_all_subcategories_", method,'.png'), '-dpng')
        hold off
        
        save( strcat( "workspaces/DetectionTimes_aCO2_IISA_base", base,...
                        "_all_subcategories_", method,'.mat'),...
                        'detect_year_1P5below', ...
                        'detect_year_1P5lowOv', ...
                        'detect_year_1P5higOv', ...
                        'detect_year_2lower', ...
                        'detect_year_2higher', ...
                        'detect_year_2above' )
    end
end
