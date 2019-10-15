%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%    This file fits the Rafelski model to observed atmospheric CO2
%%%%    data.
%%%%
%%%%    Output: .mat file containing optimised parameters and predicted
%%%%            CO2 for the historical record
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

%%%% Constants
% convert constant from gton to ppm
gtonC_2_ppm = 1/2.124; % Quere et al 2017
% convert C to CO2
C2CO2        = 3.664; %44.01/12.011;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Load available real atmospheric CO2 data and plot it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% loads observed CO2 data, ADD REFERENCE, CO2a_obs in ppm CO2
load(strcat(path_data,'dataObservedCO2.mat'));

% remove unneccessary data
clear dpCO2a_obs dtdelpCO2a_obs

% save minimal year in the observation data
CO2a_obs(:,1) = 1765:1/12:2016;

CO2_obs = readtable(strcat(path_data,'Global_2018_Co2.txt'));
CO2_obs = table2array(CO2_obs(1:end, [1 5]));
tmp = 1980:1/12:2019
CO2_obs(:,1) = tmp(1:end-1);

CO2_obs = readtable(strcat(path_data,'globalCO2a_NOAA.txt'));
CO2_obs = table2array(CO2_obs(1:end, [1 2]));
CO2_obs = interpolData( 12, CO2_obs, 'linear');

%CO2_obs = concatinateTimeseries(CO2a_obs, CO2_obs, 1980, 'direct');

figure(1), clf, hold on
set(gcf, 'Position', [ 300 300 550 450]);
set(gcf,'PaperPosition', [ 300 300 550 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% Plot the atmospheric CO2 observations
plot(CO2_obs(:,1),CO2_obs(:,2), 'color', BrightCol(3,:),...
      'LineWidth', 1.5, 'LineStyle', "-")
plot(CO2a_obs(:,1),CO2a_obs(:,2), 'color', BrightCol(4,:),...
      'LineWidth', 1.5, 'LineStyle', "-")
xlim([1950, 2020])
h = title('Mean Atmospheric CO2'); set(h, 'Interpreter', 'latex');
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = ylabel('ppm/year'); set(h, 'Interpreter', 'latex');
h = legend( 'NOAA global annual mean',...
            'Old data from 1 year ago',...
            'location','northwest'); set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off
  
set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('Observations_PastAtmosphericCO2_ppm_different_sources.png')),...
    '-dpng')


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Load past CO2 emissions for land use and fossil fuel and
%%%% process them to be input into Rafelski model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load global carbonproject data, data in GtC/year
GCP = readtable(strcat(path_data,'GCP_2018.txt'));
GCP = GCP.Variables;
% transform into GtCO2/year
GCP(:,2:end) = GCP(:,2:end)*gtonC_2_ppm;

FFgcp = GCP(:, [1 2]);
LUgcp = GCP(:, [1 3]);

% https://cdiac.ess-dive.lbl.gov/ftp/ndp030/global.1751_2014.ems
% tC/year
FFboden2017 = readtable(strcat(path_data,'Boden_2017.txt'));
FFboden2017 = table2array(FFboden2017(2:end, 1:2));
FFboden2017(:,2) = FFboden2017(:,2) / 1000*gtonC_2_ppm; % ppm/y

% Load the emission data from Boden 2016 and Houghton 2016 and convert to ppm
FFboden2016    = csvread(strcat(path_data,'dataFF_Boden_2016.csv'));   % in 10^12C /year (gtC/year) 
LUhoughton2016 = csvread(strcat(path_data,'dataLU_Houghton_2016.csv'));% in 10^12C /year (gtC/year)
% convert to ppm
FFboden2016(:,2)    = FFboden2016(:,2)*gtonC_2_ppm;
LUhoughton2016(:,2) = LUhoughton2016(:,2)*gtonC_2_ppm;

% houghton all data
LUhoughton1850 = readtable(strcat(path_data,'Houghtin_v5_FRA2015_netflux_globe.csv'));
LUhoughton1850 = LUhoughton1850(:,2:3).Variables;

% LUhoughton1850 = readtable(strcat(path_data,'LUflux_1850_2005.txt'));
% LUhoughton1850 = table2array(LUhoughton1850(1:end, 1:2));
LUhoughton1850(:,2) = LUhoughton1850(:,2)*gtonC_2_ppm/1e3;


figure(1), clf, hold on
set(gcf, 'Position', [ 300 300 550 450]);
set(gcf,'PaperPosition', [ 300 300 550 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% Plot past emissions
line( FFboden2017(:, 1 ), FFboden2017(:,2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
line( FFgcp(:, 1 ), FFgcp(:,2), 'color',...
      BrightCol(1,:), 'LineWidth', 1.5, 'LineStyle', "--")
line( FFboden2016(:, 1 ), FFboden2016(:,2), 'color',...
      BrightCol(2,:), 'LineWidth', 1.5, 'LineStyle', "--")

line( LUgcp(:, 1 ), LUgcp(:,2), 'color', BrightCol(3,:), 'LineWidth', 1.5)
line( LUhoughton2016(2:end, 1 ), LUhoughton2016(2:end,2), 'color', BrightCol(3,:),...
      'LineWidth', 1.5, 'LineStyle', ":")
line( LUhoughton1850(:, 1 ), LUhoughton1850(:,2), 'color', BrightCol(6,:),...
      'LineWidth', 1.5, 'LineStyle', "- -")
  
xlim([1763 2017])
h = title('Past CO2 Emissions'); set(h, 'Interpreter', 'latex');
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = ylabel('C [ppm/year]'); set(h, 'Interpreter', 'latex');
h = legend( 'fossil fuel GCP', 'fossil fuel Boden 2016', 'fossil fuel Boden 2017',...
            'land use GCP (Houghton 2017/Hansis)',...
            'land use GCP Houghton 2016',...
            'location','northwest'); set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('Observations_PastEmissions_ppm_different_sources.png')), '-dpng')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Choose the correct input data of emissions an compute total emissions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FF = interpolData( 12, concatinateTimeseries(FFboden2017, FFgcp, FFgcp(1,1), 'direct'),...
                    'pchip' );

LU = interpolData( 12, [ [FFboden2017(1,1), 0 ]; LUhoughton1850;...
                         LUhoughton2016(end,:)], 'linear' );

plot(LU(:,1), LU(:,2))


% interpolate land use to yield values between startYear_obs and 1959
LU = interpolData( 1, LU);

% interpolate land use and ff to a monthly grid
FF  =  FF(1:end-12,:);
LU  =  interpolData( 12, LU, 'spline');

%%%% Compute past total emissions. Note that Rafelski model is linear in
%%%% land use and fossil fuel emissions and 
PastTotalCO2emission = LU;
PastTotalCO2emission(:,2) = LU(:,2) + FF(:,2);

figure(1), clf, hold on
set(gcf, 'Position', [ 300 300 550 450]);
set(gcf,'PaperPosition', [ 300 300 550 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% Plot past emissions
line( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(1,:), 'LineWidth', 1.5)
line( LU(:, 1 ), LU(:,2), 'color', BrightCol(3,:), 'LineWidth', 1.5)
line( FF(:, 1 ), FF(:,2), 'color', BrightCol(5,:), 'LineWidth', 1.5)
% line( GCP(:, 1 ), GCP(:,2) + GCP(:,3), 'color',...
%       BrightCol(4,:), 'LineWidth', 1.5)
% line( GCP(:, 1 ), GCP(:,2), 'color',...
%       BrightCol(6,:), 'LineWidth', 1.5)
% line( GCP(:, 1 ), GCP(:,3), 'color',...
%       BrightCol(6,:), 'LineWidth', 1.5)
  
xlim([LU(1, 1 ) 2017])
h = title('Past CO2 Emissions'); set(h, 'Interpreter', 'latex');
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = ylabel('C [ppm/year]'); set(h, 'Interpreter', 'latex');
h = legend('past total CO2',...
       'CO2 from land use',...
       'CO2 from fossil fuel','location','northwest'); set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('Observations_PastEmissionsGtCO2.png')), '-dpng')

clear h fig fig_pos startYear_obs

save( strcat(path_data, 'Emissions_PastMontly.mat'), 'PastTotalCO2emission')


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Fit optimal parameters for Rafelski Model by least squares
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the loss function depending on the real observed atmospheric CO2
% find data until 2005, it seems to be assumed in the Rafelski model that
% the emissions are in carbon and the atmospheric CO2 is in CO2.
PastTotalCemission = PastTotalCO2emission;

% start and end year for the period we want to optimize the LS fit for
opt_years = [1958 2005];

% define the loss function for optimization
minLoss = @(x) LSE_Params( x, PastTotalCemission, CO2a_obs, opt_years(1), opt_years(2) );

% value of minLoss for starting parameters
minLoss([278  0.85])

% optimize parameters
[xopt, fval, exitflag] = fminsearch(minLoss, [278 0.85]);

% xopt  = [285.1693    0.8047];  % loss minimized 1958-2016
% xopt1 = [284.1945    0.7647];  % loss minimized 1765-2016

xopt = [ 277.2731 0.7591];  % loss minimized 1958-2005
xopt1  = [279.8667 0.7948];  % loss minimized 1765-2005

% Loss after minimisation
minLoss(xopt)
minLoss(xopt1)

% Check that the optimal fit makes sense, up to 2004
[CO2a, ~, fas, ffer, Aoc, dtdelpCO2a] = JoosModelFix( PastTotalCemission, xopt );
% Check that the optimal fit makes sense, up to 2016
CO2a2 = JoosModelFix( PastTotalCemission, xopt1 );

% save the fitted past atmospheric CO2
save( strcat(path_data, 'Fit_RafelskiModelAtmosphericCO2', num2str(opt_years(1)),'_',...
      num2str(opt_years(2)),'.mat'), 'CO2a', 'xopt', 'fas', 'ffer', 'Aoc', 'dtdelpCO2a',...
      'PastTotalCO2emission')

clear minLoss ans

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Plot the fits of Rafelski Model against the observations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2),clf, hold on
set(gcf, 'Position', [ 300 300 550 450]);
set(gcf,'PaperPosition', [ 300 300 550 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% plot values
line(CO2a(:,1),CO2a(:,2), 'Color', colMat(4,:), 'LineWidth',2);
line(CO2a2(:,1),CO2a2(:,2), 'Color', BrightCol(4,:), 'LineWidth',2);
line(CO2a_obs(:,1),CO2a_obs(:,2), 'Color', colMat(1,:), 'LineWidth',2);

% define axis and labels
ylim([260 450])
h = legend( 'fit optimised from 1958',...
            'fit optimised from 1765',...
            'observations','location','northwest'); set(h, 'Interpreter', 'latex');
h = ylabel('Atmospheric ${\rm CO_2}$ [ppm]'); set(h, 'Interpreter', 'latex');
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = title('Modeled vs. Observed CO2'); set(h, 'Interpreter', 'latex');
grid
set(gca, 'fontsize', 14);

% print options
set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,"RafelskiFit_AtmosphericCO2.png"), '-dpng')
hold off

%%%% Plot sinks and emissions
figure(3), clf, hold on,
set(gcf, 'Position', [ 300 300 550 450]);
set(gcf,'PaperPosition', [ 300 300 550 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

plot( FF(:,1),FF(:,2),...
      fas(:,1),Aoc*fas(:,2),...
      ffer(:,1),ffer(:,2),...
      LU(:,1),LU(:,2),...
      dtdelpCO2a(:,1),dtdelpCO2a(:,2), 'LineWidth', 2);
h = legend('fossil fuel','air-sea flux','land sink','land use','change in atmospheric CO2','location','northwest');
set(h, 'Interpreter', 'latex');
h = ylabel('ppm/yr');  set(h, 'Interpreter', 'latex');
h = xlabel('year');  set(h, 'Interpreter', 'latex');
h = title('Sources and Sinks');  set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
grid on

% print options
set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,"RafelskiFit_Emissions_AllSinks.png"), '-dpng')
hold off

clear h fig fig_pos