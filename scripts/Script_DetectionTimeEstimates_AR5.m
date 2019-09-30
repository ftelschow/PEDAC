%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%	This script implements the detection protcol for pairs of AR5
%%%%	models
%%%%
%%%%    Output: .mat with predicted atmospheric CO2 for BAU and 2deg
%%%%            emission scenarios
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear workspace
clear all
close all

% set correct working directory
path      = '/home/drtea/Research/Projects/CO2policy/PEDAC';
path_pics = '/home/drtea/Research/Projects/CO2policy/pics/';
path_data = '/home/drtea/Research/Projects/CO2policy/PEDAC/data/';
cd(path)
clear path

%%%% Constants for figures
% load color data base for plots
load(strcat(path_data,'colors.mat'))

WidthFig  = 550;
HeightFig = 450;

%%%% parameters for analysis
methodVec = ["direct", "continuous"];
q = 0.05;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Apply detection method to the Models using atmospheric CO2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% AR process parameters for imbalance
Msim  = 1e5;
T     = length(2005:2050);
% load the parameters from analysis file
load(strcat(path_data,'ErrorProcess_Rafelski_aCO2.mat'))

%%%% initialize detection time
detect_year  = struct();

%%%% loop over methods for glueing
for method = methodVec
    % load predicted atmospheric CO2 for AR5 models
    load(strcat(path_data, 'AtmosphericCO2_AR5Montly_',method,'.mat') )
    % get number of scenarios
    Nscenario = size(COa_2deg,2)-1;
    % initialize detection time container for current method
    dyears = NaN*ones([1, Nscenario]);
    
    % compute threshold
    IMBALANCE   = generate_AR(Msim, T, rho, stdRes);
    thresholdsF = get_Thresholds(IMBALANCE, q);

    % simulate imbalance as error processes
    IMBALANCE = generate_AR(Msim, T, rho, stdRes);
    
    % loop over scenarios
    for scenario = 2:Nscenario+1    
        % find cut year of scenarios
        cut_year1 = cut_year2deg(scenario-1)+1;
        cut_year2 = 2050;
        years     = (cut_year1-1):cut_year2;

        % Find cutting point
        times      = 1:size(COa_base,1);
        index_cut1 = times(COa_base(:,1)==cut_year1);
        index_cut2 = times(COa_base(:,1)==cut_year2);

        % Define drifts for base and 2deg scenario
        drift_base  = [COa_base(index_cut1-12,deg_Base_correspondence(scenario-1)+1 );...
                            COa_base(index_cut1:12:index_cut2,deg_Base_correspondence(scenario-1)+1)];
        drift_alter = [COa_2deg(index_cut1-12,scenario);...
                            COa_2deg(index_cut1:12:index_cut2,scenario)];

        % Plot the power plot from Armins method
        [probs, dyear,~] = get_Detection2( ...
                            IMBALANCE(1:size(drift_base,1),:),...
                            [drift_base,drift_alter]',...
                            thresholdsF, q);
        plot_Detection( dyear, probs, cut_year1-1, q, strcat(path_pics,'detect_',...
                        method,'/Sc_',num2str(scenario),'_detection_aCO2.png'));

        dyears(scenario-1)  = dyear;
        figure(2), clf, hold on
        set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');
            plot(years, drift_base, 'LineWidth', 1.5, 'Color', BrightCol(1,:))
            plot(years, drift_alter, 'LineWidth', 1.5, 'Color', BrightCol(3,:))
%            plot( years, drift_base  + thresholdsF(dyear), 'LineWidth', 1, 'Color', BrightCol(1,:), 'LineStyle', ':' )
%            plot( years, drift_alter - thresholdsF(dyear), 'LineWidth', 1, 'Color', BrightCol(3,:), 'LineStyle', ':' )
            plot([years(dyear) years(dyear)], [-2000, 2000], 'k--')
            title('atmospheric CO2')
        h = xlabel('years');  set(h, 'Interpreter', 'latex');
        h = ylabel('atmospheric CO2 [ppm/year]');  set(h, 'Interpreter', 'latex');
        ylim([350 550])
        xlim([2005 2050])
        h = legend( namesBase{deg_Base_correspondence(scenario-1)},...
                    names2deg{scenario-1},...
                    'location','northwest');  set(h, 'Interpreter', 'latex');    grid
        set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'detect_',method,'/Sc_',num2str(scenario),'_aCO2.png'), '-dpng')
        hold off
    end
    detect_year.(method) = dyears;
    
    %%%% plot histogram and compute decriptive statistics
    stats.(method).mean = mean(dyears);
    stats.(method).std  = std(dyears);
    stats.(method).qunatiles = quantile(dyears, [0.05 0.25 0.5 0.75 0.95]);
    
    figure(3), clf, hold on
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');

    histogram(dyears)
    h = title('Detection Times 2$^\circ$ vs BAU');  set(h, 'Interpreter', 'latex');
    xlim([0 50])
    ylim([0 30])
    
    h = xlabel('years until detection');  set(h, 'Interpreter', 'latex');
    h = ylabel('frequency');  set(h, 'Interpreter', 'latex');
     set(gca, 'fontsize', 14);

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,'detect_',method,'/Hist_Detect_aCO2.png'), '-dpng')
    hold off
end

% save the detection times
save( strcat('workspaces/DetectionTimes_aCO2_AR5_',method,'.mat'),...
      'detect_year', 'stats')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Apply detection method to the models using atmospheric CO2 growth rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% AR process parameters for imbalance
Msim  = 1e5;
T     = length(2005:2050)-1;
% load the parameters from analysis file
load(strcat(path_data,'ErrorProcess_Rafelski_aCO2.mat'))


% initialize detection time
detect_year  = struct();

% loop over methods for glueing
for method = methodVec
    % load predicted atmospheric CO2 for AR5 models
    load(strcat(path_data, 'AtmosphericCO2_AR5Montly_',method,'.mat') )
    % get number of scenarios
    Nscenario = size(COa_2deg,2)-1;
    % initialize detection time container for current method
    dyears = NaN*ones([1, Nscenario]);
    
    % compute threshold
    IMBALANCE   = generate_AR(Msim, T, rho, stdRes);
    thresholdsF = get_Thresholds(IMBALANCE, q);

    % simulate imbalance as error processes
    IMBALANCE = generate_AR(Msim, T, rho, stdRes);
    
    % loop over scenarios
    for scenario = 2:Nscenario+1    
        % find cut year of scenarios
        cut_year1 = cut_year2deg(scenario-1)+1;
        cut_year2 = 2050;
        years     = (cut_year1-1):cut_year2;

        % Find cutting point
        times      = 1:size(COa_base,1);
        index_cut1 = times(COa_base(:,1)==cut_year1);
        index_cut2 = times(COa_base(:,1)==cut_year2);

        % Define drifts for base and 2deg scenario
        drift_base  = diff(...
                            [COa_base(index_cut1-12,deg_Base_correspondence(scenario-1)+1 );...
                            COa_base(index_cut1:12:index_cut2,deg_Base_correspondence(scenario-1)+1)]...
                       );
        drift_alter = diff(...
                            [COa_2deg(index_cut1-12,scenario);...
                            COa_2deg(index_cut1:12:index_cut2,scenario)]...
                        );

        % Plot the power plot from Armins method
        [probs, dyear,~] = get_Detection2( ...
                            IMBALANCE(1:size(drift_base,1),:),...
                            [drift_base,drift_alter]',...
                            thresholdsF, q);
        plot_Detection( dyear, probs, cut_year1-1, q, strcat(path_pics,'detect_',...
                        method,'/Sc_',num2str(scenario),'_detection_agrCO2.png'));

        dyears(scenario-1)  = dyear;
        figure(2), clf, hold on
        set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');
            plot(years(1:end-1), drift_base, 'LineWidth', 1.5, 'Color', BrightCol(1,:))
            plot(years(1:end-1), drift_alter, 'LineWidth', 1.5, 'Color', BrightCol(3,:))
%            plot( years, drift_base  + thresholdsF(dyear), 'LineWidth', 1, 'Color', BrightCol(1,:), 'LineStyle', ':' )
%            plot( years, drift_alter - thresholdsF(dyear), 'LineWidth', 1, 'Color', BrightCol(3,:), 'LineStyle', ':' )
            plot([years(dyear) years(dyear)], [-2000, 2000], 'k--')
            title('atmospheric CO2')
        h = xlabel('years');  set(h, 'Interpreter', 'latex');
        h = ylabel('atmospheric CO2 [ppm/year]');  set(h, 'Interpreter', 'latex');
        ylim([-5 10])
        xlim([2005 2050])
        h = legend( namesBase{deg_Base_correspondence(scenario-1)},...
                    names2deg{scenario-1},...
                    'location','northwest');  set(h, 'Interpreter', 'latex');    grid
        set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'detect_',method,'/Sc_',num2str(scenario),'_agrCO2.png'), '-dpng')
        hold off
    end
    detect_year.(method) = dyears;
    
    %%%% plot histogram and compute decriptive statistics
    stats.(method).mean = mean(dyears);
    stats.(method).std  = std(dyears);
    stats.(method).qunatiles = quantile(dyears, [0.05 0.25 0.5 0.75 0.95]);
    
    figure(3), clf, hold on
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');

    histogram(dyears)
    h = title('Detection Times 2$^\circ$ vs BAU');  set(h, 'Interpreter', 'latex');
    xlim([0 50])
    ylim([0 30])
    
    h = xlabel('years until detection');  set(h, 'Interpreter', 'latex');
    h = ylabel('frequency');  set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,'detect_',method,'/Hist_Detect_agrCO2mean.png'), '-dpng')
    hold off
end

% save the detection times
save( strcat('workspaces/DetectionTimes_agrCO2_AR5_',method,'.mat'),...
      'detect_year', 'stats')