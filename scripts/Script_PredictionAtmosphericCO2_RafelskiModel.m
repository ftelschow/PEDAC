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

% load color data base for plots
load(strcat(path_data,'colors.mat'))

% load the true past emission data. Note it must be in ppm C! 
load(strcat(path_data, 'Emissions_PastMontly.mat'))

% load the predicted future emission data . Note it must be in ppm C! 
load(strcat(path_data, 'Emissions_FutureAR5Montly.mat'))

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
%%%% initialize containers for atmospheric CO2 predicted in the different
% models
times = 1765:1/12:2100;
Nt    = length(times);

COa_base      = zeros([Nt size(data_AR5base,2)])*NaN;
COa_base(:,1) = times;

COa_2deg      = zeros([Nt size(data_AR52deg,2)])*NaN;
COa_2deg(:,1) = times;

% loop over different ways to glue past emissions with future emissions
for method = ["direct" "continuous"]  
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
end

% Clear workspace
clear tmp Nt CO2a

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot the predicted atmospheric CO2 records 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure_counter = figure_counter +1;
figure(figure_counter), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

for scenarioNum = 2:size(COa_base,2)
    plot(COa_base(:, 1 ), COa_base(:, scenarioNum ))
end
xlim([2000 2102])
ylim([250 1150])
h = xlabel('years');  set(h, 'Interpreter', 'latex');
h = ylabel('C02 [ppm]');  set(h, 'Interpreter', 'latex');
h = title('Baseline Predictions for CO2 in Atmosphere (AR5)');  set(h, 'Interpreter', 'latex');
line([2005 2005],[-10, 1e4],'Color','black','LineStyle','--')
grid
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('AtmosphericCO2_AR5_base_',glue,'.png')), '-dpng')
hold off


figure_counter = figure_counter +1;
figure(figure_counter), clf, hold on
WidthFig  = 600;
HeightFig = 400;
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
h = title('2 Degree Predictions for CO2 in Atmosphere (AR5)');  set(h, 'Interpreter', 'latex');
h = xlabel('years');  set(h, 'Interpreter', 'latex');
h = ylabel('C02 [ppm]');  set(h, 'Interpreter', 'latex');
grid
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('AtmosphericCO2_AR5_2deg_',glue,'.png')), '-dpng')
hold off
