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
gtonC_2_ppmC = 1/2.124; % Quere et al 2017
% convert C to CO2
C2CO2       = 44.01/12.011;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Load available real atmospheric CO2 data and plot it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% loads observed CO2 data, ADD REFERENCE, CO2a_obs in ppm CO2
load(strcat(path_data,'dataObservedCO2.mat'));

% remove unneccessary data
clear dpCO2a_obs dtdelpCO2a_obs

% save minimal year in the observation data
startYear_obs = floor(min(CO2a_obs(:,1)));


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Load past CO2 emissions for land use and fossil fuel and
%%%% process them to be input into Rafelski model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the emission data files to load and convert to ppm
FF = csvread(strcat(path_data,'dataFF_Boden_2016.csv'));   % in 10^12C /year (gtC/year) 
LU = csvread(strcat(path_data,'dataLU_Houghton_2016.csv'));% in 10^12C /year (gtC/year)

% Start emission data from observation data
FF = FF(FF(:,1)>=startYear_obs,:);

LU(1,1) = startYear_obs;

% convert to ppm CO2
FF(:,2) = FF(:,2)*gtonC_2_ppmC * C2CO2;
LU(:,2) = LU(:,2)*gtonC_2_ppmC * C2CO2;

% interpolate land use to yield values between startYear_obs and 1959
LU = interpolData( 1, LU);

% interpolate land use and ff to a monthly grid
FF =  interpolData( 12, FF, 'spline');
LU =  interpolData( 12, LU, 'spline');

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
  
xlim([1763 2017])
h = title('Past CO2 Emissions'); set(h, 'Interpreter', 'latex');
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = ylabel('CO2 [Gt CO2/year]'); set(h, 'Interpreter', 'latex');
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
PastTotalCemission(:,2) = PastTotalCO2emission(:,2) ./ C2CO2;

% start and end year for the period we want to optimize the LS fit for
opt_years = [1958 2005];

% define the loss function for optimization
minLoss = @(x) LSE_Params( x, PastTotalCemission, CO2a_obs, opt_years(1), opt_years(2) );

% value of minLoss for starting parameters
minLoss([278  0.85])

% optimize parameters
%[xopt, fval, exitflag] = fminsearch(minLoss, [278 0.85]);

% xopt  = [285.1693    0.8047];  % loss minimized 1958-2016
% xopt1 = [284.1945    0.7647];  % loss minimized 1765-2016

xopt  = [284.2729    0.7760];  % loss minimized 1958-2005
xopt1 = [283.9875    0.7356];  % loss minimized 1765-2005

% Loss after minimisation
minLoss(xopt)
minLoss(xopt1)

% Check that the optimal fit makes sense, up to 2004
[CO2a, ~, fas, ffer, Aoc, dtdelpCO2a] = JoosModelFix( PastTotalCemission, xopt );
% Check that the optimal fit makes sense, up to 2016
CO2a2 = JoosModelFix( PastTotalCemission, xopt1 );

% save the fitted past atmospheric CO2
save( strcat(path_data, 'Fit_RafelskiModelAtmosphericCO2', num2str(opt_years(1)),'_',...
      num2str(opt_years(2)),'.mat'), 'CO2a', 'xopt')

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