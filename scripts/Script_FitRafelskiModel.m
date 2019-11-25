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
C2CO2 = 3.664; %44.01/12.011;


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
tmp = 1980:1/12:2019;
CO2_obs(:,1) = tmp(1:end-1);

CO2_obs = readtable(strcat(path_data,'globalCO2a_NOAA.txt'));
CO2_obs = table2array(CO2_obs(1:end, [1 2]));
CO2_obs = interpolData( 12, CO2_obs, 'linear');

I1a = find(CO2_obs==1980);
I1e = find(CO2_obs==2010);
tmp1 = CO2_obs(I1a:I1e,:);

I2a = find(CO2a_obs==1980);
I2e = find(CO2a_obs==2010);
tmp2 = CO2a_obs(I2a:I2e,:);

dppm = mean( tmp1(:,2)-tmp2(:,2) );
CO2a_obs(:,2) = CO2a_obs(:,2) + dppm;

%CO2_obs = concatinateTimeseries(CO2a_obs, CO2_obs, 1980, 'direct');

figure(1), clf, hold on
set(gcf, 'Position', [ 300 300 550 450]);
set(gcf,'PaperPosition', [ 300 300 550 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% Plot the atmospheric CO2 observations
plot(CO2_obs(:,1), CO2_obs(:,2), 'color', BrightCol(3,:),...
      'LineWidth', 1.5, 'LineStyle', "-")
plot(CO2a_obs(:,1), CO2a_obs(:,2), 'color', BrightCol(4,:),...
      'LineWidth', 1.5, 'LineStyle', "-")
plot(CO2a_obs(:,1), CO2a_obs(:,2)-dppm, 'color', BrightCol(4,:),...
      'LineWidth', 1.5, 'LineStyle', "--")  
xlim([1950, 2020])
h = title('Mean Atmospheric CO2'); set(h, 'Interpreter', 'latex');
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = ylabel('ppm/year'); set(h, 'Interpreter', 'latex');
h = legend( 'NOAA global annual mean',...
            'Rafelski (2009) corrected by mean of overlap',...
            'Rafelski (2009)',...
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
GCP_historical = readtable(strcat(path_data,'GCP_historical.csv'));
GCP_historical = GCP_historical(:,1:end-1).Variables;
GCP_historical(:,2:end) = GCP_historical(:,2:end)*gtonC_2_ppm;

figure(1), clf, hold on
set(gcf, 'Position', [ 300 300 550 450]);
set(gcf,'PaperPosition', [ 300 300 550 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% Plot past emissions
line(  GCP_historical(:,1), GCP_historical(:, 2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
line(GCP_historical(:,1), GCP_historical(:, 3), 'color', BrightCol(3,:), 'LineWidth', 1.5)
  
xlim([1763 2017])
h = title('Past CO2 Emissions'); set(h, 'Interpreter', 'latex');
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = ylabel('C [ppm/year]'); set(h, 'Interpreter', 'latex');
h = legend( 'fossil fuel GCP',...
            'land use GCP (Houghton 2017/Hansis)',...
            'location','northwest'); set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('Observations_PastEmissions_ppm_GCPhist_sources.png')), '-dpng')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Choose the correct input data of emissions an compute total emissions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FF = interpolData( 12, GCP_historical(2:end,[1 2]), 'pchip' );

I = find( GCP_historical(:,1) == 1850 );

LU = interpolData( 12, [ [FF(1,1), 0]; [1800, 0.06]; [1820, 0.12] ; GCP_historical(I:end,[1 3]) ],...
                         'makima' );                  
figure(1), clf, hold on                     
plot( LU(:,1), LU(:,2) )
plot([1750, 2050], [0,0], 'k--')
hold off

%%%% Compute past total emissions. Note that Rafelski model is linear in
%%%% land use and fossil fuel emissions and 
PastTotalCO2emission = LU;
PastTotalCO2emission(:,2) = LU(:,2) + FF(:,2);

figure(2), clf, hold on
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
%%%%  CO2 obs from global Carbon Project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I   = find(CO2a_obs(1,1)==GCP_historical(:,1));
tmp = cumsum(GCP_historical( I:end,4));
I2  = find(2017==GCP_historical(I:end,1));

CO2a_obs2 = tmp + 405 - tmp(I2);

figure(1), clf, hold on
plot(CO2_obs(:,1), CO2_obs(:,2))
plot(GCP_historical(I:end,1), CO2a_obs2)
plot(CO2a_obs(:,1), CO2a_obs(:,2))

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Fit optimal parameters for Rafelski Model by least squares
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start and end year for the period we want to optimize the LS fit for
opt_years = [1765 2016];

%%%% NOAA and GCP minimization
% define the loss function for optimization
minLoss = @(x) LSE_Params( [x 0.287], PastTotalCO2emission, CO2a_obs, opt_years(1), opt_years(2) );
% optimize parameters
[ xopt, ~, exitflag ] = fminsearch(minLoss, [278 0.77]);
xoptAll  = [xopt 0.287]; % loss minimized GCP emission input and NOAA
                          %opt_years = [1980 2017]; [269.7511    0.7942
                          %0.2870}

%%%% NOAA and GCP minimization
opt_years = [1958 2016];
% define the loss function for optimization
minLoss = @(x) LSE_Params( [x 0.287], PastTotalCO2emission, CO2a_obs, opt_years(1), opt_years(2) );
% optimize parameters
[ xopt, ~, exitflag ] = fminsearch(minLoss, [278 0.77]);
xoptNew  = [xopt 0.287]; % loss minimized GCP emission input and NOAA, opt_years = [1980 2017];

clear xopt exitflag

% save the fitted past atmospheric CO2
save( strcat(path_data, 'Fit_RafelskiModelAtmosphericCO2Final.mat'), 'xoptAll', 'xoptNew',...
      'PastTotalCO2emission')

clear minLoss ans

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Plot the fits of Rafelski Model against the observations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% compute the fits with the optimised parameters
% Check that the optimal fit makes sense, up to 2004
[aCO2_All, ~, fas, ffer, Aoc, dtdelpCO2a] = JoosModel( PastTotalCO2emission, xoptAll );
% Check that the optimal fit makes sense, up to 2016
aCO2_New = JoosModelFix( PastTotalCO2emission, xoptNew );

figure(2),clf, hold on
set(gcf, 'Position', [ 300 300 550 450]);
set(gcf,'PaperPosition', [ 300 300 550 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% plot values
line(CO2a_obs(:,1),CO2a_obs(:,2), 'Color', BrightCol(5,:), 'LineWidth',1.5, 'LineStyle', '-');
line(aCO2_All(:,1), aCO2_All(:,2), 'Color', colMat(1,:), 'LineWidth',1.5, 'LineStyle', '-');
%line(CO2_obs(:,1),CO2_obs(:,2), 'Color', colMat(4,:), 'LineWidth',1.5);
line(aCO2_New(:,1), aCO2_New(:,2), 'Color', colMat(1,:), 'LineWidth',1.5);
%line(CO2a2(:,1),CO2a2(:,2), 'Color', BrightCol(4,:), 'LineWidth',2);

% define axis and labels
ylim([260 450])
xlim([1765, 2020])
h = legend( 'Rafelski (2009) shifted atmospheric CO2','Fit optimized on 1850-2010',...
            'Fit optimized on 1958-2010','Fit to NOAA (1980-2015)',...
            'location','northwest'); set(h, 'Interpreter', 'latex');
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
print(strcat(path_pics,"RafelskiFit2_AtmosphericCO2.png"), '-dpng')
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
xlim([1765, 2020])
% print options
set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,"RafelskiFit_Emissions_AllSinks.png"), '-dpng')
hold off

clear h fig fig_pos