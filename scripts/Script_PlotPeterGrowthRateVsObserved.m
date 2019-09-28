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
gtonC_2_ppmC = 1/2.124; % Quere et al 2017
% convert C to CO2
C2CO2       = 44.01/12.011;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Data loading and description of data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data from Peter's paper as extracted by Armin. According to the
% article the units are GtCO2/year
T = readtable(strcat(path_data,'Peters2017_Fig2_past.txt'));
PetersPast = T.Variables;

% load data from https://www.esrl.noaa.gov/gmd/ccgg/trends/gl_gr.html,
% giving the Annual Mean Global Carbon Dioxide Growth Rates in ppm per year
T     = readtable(strcat(path_data,'Global_2018_grCo2.txt'));
NOAA  = T.Variables;
% convert NOAA data into GtCO2/year
NOAA(:,2:3) = NOAA(:,2:3) / gtonC_2_ppmC;

% Peter's data in Figure 1 seems to be already incompatible with NOAA,
% compare https://www.esrl.noaa.gov/gmd/ccgg/trends/gl_gr.html

% Load my current best model fit of atmospheric CO2 using the Rafelski
% model. It is fitted against the data given in CO2 ppm, i.e. roughly 400
% today
year_s = 1958; % start year used in optimization
year_e = 2005; % end year used in optimization

load(strcat(path_data, 'Fit_RafelskiModelAtmosphericCO2', num2str(year_s),'_',...
      num2str(year_e),'.mat'))

%%%% Get annual growth rate from the model fit
% get annual values by choosing january measurement. The data is anyhow an
% interpolation so it does not matter
CO2a = CO2a(1:12:end,:);
% compute atmospheric CO2 as difference between consecutive years
grCO2a      = CO2a(1:end-1,:);
grCO2a(:,2) = diff(CO2a(:,2));
% convert ppm CO2 to GtCO2
grCO2a(:,2) = grCO2a(:,2) / gtonC_2_ppmC;

load( strcat(path_data, 'Emissions_PastMontly.mat') )
PastTotalCO2emission = PastTotalCO2emission(3013-59*12:12:end,:);

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
plot( PetersPast(:,1), PetersPast(:,3), 'LineWidth', 1.5, 'Color', BrightCol(1,:) )
plot( NOAA(:,1),NOAA(:,2), 'LineWidth', 1.5, 'Color', BrightCol(4,:) );
plot( grCO2a(:,1), grCO2a(:,2), 'LineWidth', 1.5, 'Color', BrightCol(5,:) );
plot( PastTotalCO2emission(:,1), PastTotalCO2emission(:,2), 'LineWidth', 1.5, 'Color', BrightCol(3,:) );
  
xlim([PetersPast(1,1) PetersPast(end,1)])

h = title('Comparison of Atmospheric Growth Rates');  set(h, 'Interpreter', 'latex');
h = xlabel('years');  set(h, 'Interpreter', 'latex');
h = ylabel('growth rate [GtCO2/year]');  set(h, 'Interpreter', 'latex');
h = legend('Peters et al observation','Peters et al reconstruction',...
           'NOAA observations', 'reconstruction from Rafelski model',...
           'past total emissions (Boden+Houghton)',...
           'location','northwest');  set(h, 'Interpreter', 'latex');
grid
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'AtmosphericGrowthRate_Comp_Peters.png'), '-dpng')
hold off

clear h fig fig_pos

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Can the difference in growth rate be a factor?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2), clf, hold on
set(gcf, 'Position', [ 300 300 550 450]);
set(gcf,'PaperPosition', [ 300 300 550 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% plot the quotient
plot(PetersPast(:,1), PetersPast(:,2)./ NOAA(1:end-1,2))
  
xlim([PetersPast(1,1) PetersPast(end,1)])
h = title('Quotient of Peters and NOAA atmospheric growth data');  set(h, 'Interpreter', 'latex');
h = xlabel('years');  set(h, 'Interpreter', 'latex');
h = ylabel('quotient factor');  set(h, 'Interpreter', 'latex');

grid
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'AtmosphericGrowthRate_Quotient_PetersNOAA.png'), '-dpng')
hold off

clear h fig fig_pos

% maybe there is roughly a factor of 3.7 between the two data sets? But
% shouldn't it match perfectly? From my feeling it cannot be a factor

