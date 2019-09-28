%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%	This script predicts the future atmospheric CO2 using the Rafelski
%%%%    model.
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

% convert C to CO2
C2CO2       = 44.01/12.011;

% load color data base for plots
load(strcat(path_data,'colors.mat'))

% load the true past emission data. Note it must be in ppm C as input of
% Rafelski, but it is CO2 right now! 
load(strcat(path_data, 'Emissions_PastMontly.mat'))
% scale to C
PastTotalCO2emission(:,2) = PastTotalCO2emission(:,2) / C2CO2;

% load the predicted future emission data . Note it must be in ppm C as input of
% Rafelski, but it is CO2 right now!  
load(strcat(path_data, 'Emissions_FutureAR5Montly.mat'))
% scale to C
data_AR5base(:,2:end) = data_AR5base(:,2:end) / C2CO2;
data_AR52deg(:,2:end) = data_AR52deg(:,2:end) / C2CO2;

%%%% Specify the optimisation periods of Rafelski model, which needs to be
%%%% loaded
% years used for LSE
opt_years = [1958 2005];

% load fit of Rafelski model from the historical record of atmospheric CO2
load(strcat(path_data, 'Fit_RafelskiModelAtmosphericCO2', num2str(opt_years(1)),'_',...
      num2str(opt_years(2)),'.mat'))

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot the AR5 data emission trajectories and compare to reported
%%%%    historical emission trajectories 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop over different ways to glue past emissions with future emissions
for method = ["direct" "continuous"]
    %%%% initialize containers for atmospheric CO2 predicted in the different
    % models
    times = 1765:1/12:2100;
    Nt    = length(times);

    COa_base      = zeros([Nt size(data_AR5base,2)])*NaN;
    COa_base(:,1) = times;

    COa_2deg      = zeros([Nt size(data_AR52deg,2)])*NaN;
    COa_2deg(:,1) = times;

    %%%% use Rafelski model to get the COa curves for BAU scenarios
    for scenarioNum = 2:size(data_AR5base,2)
        % concatenate past and future emissions to yield a full world
        % future history
        tmp = concatinateTimeseries( PastTotalCO2emission,...
                                     [data_AR5base(:,1) data_AR5base(:,scenarioNum)],...
                                     cut_yearbase(scenarioNum-1),...
                                     method);
        % remove NaNs. This is neccessary since the Rafelski model somehow
        % predicts to far... (ask Ralph about it. Is it a bug?)
        tmp = tmp(~isnan(tmp(:,2)),:);
        % predict atmospheric CO2 using rafelski model
        tmp = JoosModelFix( tmp, xopt );
        COa_base(1:size(tmp,1),scenarioNum) = tmp(:,2);
    end
    
    %%%% use Rafelski model to get the COa curves for 2° scenarios
    for scenarioNum = 2:size(data_AR52deg,2)
        % concatenate past and future emissions to yield a full world
        % future history
        tmp = concatinateTimeseries( PastTotalCO2emission,...
                                     [data_AR52deg(:,1) data_AR52deg(:,scenarioNum)],...
                                     cut_year2deg(scenarioNum-1),...
                                     method);
        % remove NaNs. This is neccessary since the Rafelski model somehow
        % predicts to far... (ask Ralph about it. Is it a bug?)
        tmp = tmp(~isnan(tmp(:,2)),:);
        % predict atmospheric CO2 using rafelski model
        tmp = JoosModelFix( tmp, xopt );
        COa_2deg(1:size(tmp,1),scenarioNum) = tmp(:,2);
    end
    %%%% produce output .mat
    save( strcat(path_data, 'AtmosphericCO2_AR5Montly_',method,'.mat'),...
                                        'COa_base', 'COa_2deg',...
                                        'names2deg', 'namesBase',...
                                        'cut_yearbase', 'cut_year2deg',...
                                        'deg_Base_correspondence')
end

% Clear workspace
clear tmp Nt CO2a

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot the predicted atmospheric CO2 records 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output figure width and height
WidthFig  = 550;
HeightFig = 450;

% loop over methods
for method = ["direct" "continuous"]
    % load the correct atmospheric CO2 data
    load( strcat(path_data, 'AtmosphericCO2_AR5Montly_',method,'.mat'))
    
    % plot all the BAU scenarios
    figure(1), clf, hold on
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    % plot the actual curves
    for scenarioNum = 2:size(COa_base,2)
        plot(COa_base(:, 1 ), COa_base(:, scenarioNum ))
    end
    xlim([2000 2102])
    ylim([250 1150])
    h = xlabel('years');  set(h, 'Interpreter', 'latex');
    h = ylabel('C02 [ppm]');  set(h, 'Interpreter', 'latex');
    h = title('Predictions for atmospheric CO2 for BAU scenarios');  set(h, 'Interpreter', 'latex');
    line([2005 2005],[-10, 1e4],'Color','black','LineStyle','--')
    grid
    set(gca, 'fontsize', 14);

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,strcat('AtmosphericCO2_AR5_base_',method,'.png')), '-dpng')
    hold off

    % plot all the 2° scenarios
    figure(2), clf, hold on
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');

    for scenarioNum = 2:size(COa_2deg,2)
        Index_NoNmissing     = find(COa_2deg(:,scenarioNum)~=0);
        plot(COa_2deg( Index_NoNmissing, 1 ), COa_2deg( Index_NoNmissing, scenarioNum ))
    end
    line([2005 2005],[-10, 1e4],'Color','black','LineStyle','--')
    xlim([2000 2102])
    ylim([250 1150])
    h = title('Predictions for atmospheric CO2 for 2$^\circ$ scenarios');  set(h, 'Interpreter', 'latex');
    h = xlabel('years');  set(h, 'Interpreter', 'latex');
    h = ylabel('C02 [ppm]');  set(h, 'Interpreter', 'latex');
    grid
    set(gca, 'fontsize', 14);

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,strcat('AtmosphericCO2_AR5_2deg_',method,'.png')), '-dpng')
    hold off
end