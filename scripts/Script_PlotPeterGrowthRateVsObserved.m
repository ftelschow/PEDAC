%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%    Plotting the growth rate from Peters et al and comparing it to our
%%%%    observations
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% clear workspace and figures
clear all
close all

%%%% standard color scheme for color blind and grey scale figures, cf.
%%%% 'https://personal.sron.nl/~pault/'
BrightCol  = [[68 119 170];...    % blue
              [102 204 238];...   % cyan
              [34 136 51];...     % green
              [204 187 68];...    % yellow
              [238 102 119];...   % red
              [170 51 119];...    % purple
              [187 187 187]]/255; % grey

%%%% data path and figure path
% Change to the folder you want to use or if data is in the same directory
% simply make it ''
path_data = '/home/drtea/Research/Projects/CO2policy/PEDAC/data/';
path_pics = '/home/drtea/Research/Projects/CO2policy/pics/';

%%%% Constants
% convert constant from gton to ppm
gtonC_2_ppm = 1/2.124; % Quere et al 2017
% convert C to CO2
C2CO2       = 3.664; %44.01/12.011;

%%%% CAT data gtCO2/year
%%%%(https://climateactiontracker.org/global/cat-emissions-gaps/)
CAT = [1990:2015;[35.99 36.35 35.53 35.74 35.86 36.67 37.32 37.69 38.04...
       38.29 39.43 39.92 40.57 41.94 43.39 44.59 45.74 46.98 47.39 ...
       46.87 48.70 50.00 50.00 51.00 51.00 51.00]]';


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Data loading and description of data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load global carbonproject data, data in GtC/year
GCP = readtable(strcat(path_data,'GCP_2018.txt'));
GCP = GCP.Variables;
% transform into GtCO2/year
GCP(:,2:end) = GCP(:,2:end) * C2CO2;

% load data from Peter's paper as extracted by Armin. According to the
% article the units are GtCO2/year
T = readtable(strcat(path_data,'Peters2017_Fig2_past.txt'));
PetersPast = T.Variables;

% load data from https://www.esrl.noaa.gov/gmd/ccgg/trends/gl_gr.html,
% giving the Annual Mean Global Carbon Dioxide Growth Rates in ppm per year
T     = readtable(strcat(path_data,'Global_2018_grCo2.txt'));
NOAA  = T.Variables;
% convert NOAA data into GtCO2/year
NOAA(:,2:3) = NOAA(:,2:3) / gtonC_2_ppm*C2CO2;

% Peter's data in Figure 1 seems to be already incompatible with NOAA,
% compare https://www.esrl.noaa.gov/gmd/ccgg/trends/gl_gr.html

% Load my current best model fit of atmospheric CO2 using the Rafelski
% model. It is fitted against the data given in CO2 ppm, i.e. roughly 400
% today
year_s = 1958; % start year used in optimization
year_e = 2005; % end year used in optimization

load(strcat(path_data, 'Fit_RafelskiModelAtmosphericCO2', num2str(year_s),'_',...
      num2str(year_e),'.mat'))
  
% data given by Julia Pongratz for land net flux
LUPongratz = readtable(strcat(path_data,'Pongratz_GCP2019.txt'));
LUPongratz = LUPongratz(:,[1 6]).Variables;
LUPongratz(:,2) = LUPongratz(:,2)*gtonC_2_ppm* C2CO2;


GCP_historical = readtable(strcat(path_data,'GCP_historical.csv'));
GCP_historical = GCP_historical(:,1:end-1).Variables;
GCP_historical(:,2:end) = GCP_historical(:,2:end)* C2CO2;

%%%% Get annual growth rate from the model fit
% get annual values by choosing january measurement. The data is anyhow an
% interpolation so it does not matter
CO2a = CO2a(1:12:end,:);
% compute atmospheric CO2 as difference between consecutive years
grCO2a      = CO2a(1:end-1,:);
grCO2a(:,2) = diff(CO2a(:,2));
% convert ppm CO2 to GtCO2
grCO2a(:,2) = grCO2a(:,2) / gtonC_2_ppm*C2CO2;

load( strcat(path_data, 'Emissions_PastMontly.mat') )
PastTotal = PastTotalCO2emission(3013-56*12:12:end,:);
grPastTotal(:,1) = PastTotal(2:end,1);
grPastTotal(:,2) = diff(PastTotal(:,2));

dtdelpCO2a = dtdelpCO2a(3013-57*12:12:end,:);

clear T year_s year_e

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plot the different growth rate data sets in the same unit and compare
%%%% to computed growth rate from our model fit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1), clf, hold on
set(gcf, 'Position', [ 300 300 550 450]);
set(gcf,'PaperPosition', [ 300 300 550 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% Plot the different data sets
plot( PetersPast(:,1), PetersPast(:,2), 'LineWidth', 1.5, 'Color', BrightCol(2,:) )
plot( PetersPast(:,1), PetersPast(:,3), 'LineWidth', 1.5, 'Color', BrightCol(4,:) )
plot( GCP(:,1), GCP(:,4), 'LineWidth', 1.5, 'Color', BrightCol(1,:) );
plot( GCP(:,1), (GCP(:,2) + GCP(:,3) - GCP(:,5) - GCP(:,6)),...
      'LineWidth', 1.5, 'Color', BrightCol(5,:) )
plot( dtdelpCO2a(:,1), dtdelpCO2a(:,2) / gtonC_2_ppm*C2CO2,...
      'LineWidth', 2.5, 'Color', BrightCol(6,:), 'LineStyle', '--' )
plot( GCP_historical(:,1), (GCP_historical(:,2) + GCP_historical(:,3) - GCP_historical(:,5) - GCP_historical(:,6)),...
      'LineWidth', 1.5, 'Color', BrightCol(7,:) )

xlim([PetersPast(1,1) PetersPast(end,1)])

h = title('Comparison of Atmospheric Growth Rates');  set(h, 'Interpreter', 'latex');
h = xlabel('years');  set(h, 'Interpreter', 'latex');
h = ylabel('growth rate [GtCO2/year]');  set(h, 'Interpreter', 'latex');
h = legend( 'Peters et al observation','Peters et al reconstruction',...
            'GCP observations', 'GCP reconstruction',...
            'Rafelski Reconstruction',...
            'location','northwest');  set(h, 'Interpreter', 'latex');
grid
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'AtmosphericGrowthRate_Comp_PetersGCP.png'), '-dpng')
hold off

clear h fig fig_pos

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plot comparison of imblance processes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2), clf, hold on
set(gcf, 'Position', [ 300 300 550 450]);
set(gcf,'PaperPosition', [ 300 300 550 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% Plot the different data sets
plot( PetersPast(:,1), PetersPast(:,2)-PetersPast(:,3), 'LineWidth', 1.5, 'Color', BrightCol(2,:) )
plot( GCP(:,1), GCP(:,4) - (GCP(:,2) + GCP(:,3) - GCP(:,5) - GCP(:,6)), 'LineWidth', 1.5, 'Color', BrightCol(5,:) );
plot( dtdelpCO2a(:,1), GCP(1:end-1,4) - dtdelpCO2a(:,2) / gtonC_2_ppm*C2CO2,...
      'LineWidth', 1.5, 'Color', BrightCol(4,:) )

xlim([PetersPast(1,1) PetersPast(end,1)])

h = title('Comparison of Atmospheric Growth Rates');  set(h, 'Interpreter', 'latex');
h = xlabel('years');  set(h, 'Interpreter', 'latex');
h = ylabel('growth rate [GtCO2/year]');  set(h, 'Interpreter', 'latex');
h = legend( 'Peters et al',...
            'GCP',...
            'Rafelski',...
            'location','northwest');  set(h, 'Interpreter', 'latex');
grid
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'AtmosphericGrowthRate_Comp_Imbalances.png'), '-dpng')
hold off

clear h fig fig_pos

%%
close all
ImbalanceGCP = GCP(:,4) - (GCP(:,2) + GCP(:,3) - GCP(:,5) - GCP(:,6));
std(ImbalanceGCP)
ImbalancePeters = PetersPast(:,2)-PetersPast(:,3);
std(ImbalancePeters)
ImbalanceRafelski = GCP(1:end-1,4) - dtdelpCO2a(:,2) / gtonC_2_ppm*C2CO2;
std(ImbalanceRafelski)

figure
res = ImbalanceGCP;
autocorr(res,'NumLags',10,'NumSTD',2)
m  = ar(res,1)

figure
res = ImbalancePeters;
autocorr(res,'NumLags',10,'NumSTD',2)
m  = ar(res,1)

figure
res = ImbalanceRafelski;
autocorr(res,'NumLags',10,'NumSTD',2)
m  = ar(res,1)