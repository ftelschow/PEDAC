%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%        This file processes the data by Ahmed of future CO2 emissions into
%%%%        atmospheric CO2  using historical emissions and the BERN model
%%%%        by Joos
%%%%
%%%%        It contains data cleaning, polynomial interpolation to monthly
%%%%        data, estimation of optimal parameters for BERN model and
%%%%        transformation of emissions into atmospheric CO2.
%%%%
%%%%        Authors: Fabian Telschow
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear workspace
clear all
close all

% set correct working directory
path      = '/home/drtea/Research/Projects/2018_CO2/PEDAC';
path_pics = '/home/drtea/Research/Projects/2018_CO2/pics/';
path_data = '/home/drtea/Research/Projects/2018_CO2/PEDAC/data/';
cd(path)
clear path

% glue option
%glue = 'cont';
glue = 'direct';

%%%% Constants
% convert constant from gton to ppm: 1 ppm CO2 = 2.31 gton CO2
gtonC_2_ppmC = 1/2.12; % Quere et al 2017
C2CO2       = 44.01/12.011;   % Is that correct?

%%%% Plot options
% figure counter
figure_counter = 1;

% standard color schemes 'https://personal.sron.nl/~pault/'
BrightCol  = [[68 119 170];...    % blue
              [102 204 238];...   % cyan
              [34 136 51];...     % green
              [204 187 68];...    % yellow
              [238 102 119];...   % red
              [170 51 119];...    % purple
              [187 187 187]]/255; % grey

HighContr  = [[221, 170,  51];...   % yellow
              [187,  85, 102];...   % red
              [  0,  68, 136]]/255; % blue
Vibrant    = [[0 119 187];... % blue
              [51 187 238];...% cyan
              [0 153 136];... % teal
              [238 119 51];...% orange
              [204 51 17];... % red
              [238 51 119];...% magenta
              [187 187 187]...% grey
              ]/255;

colMat = Vibrant([1 3 4 5],:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%% Load available real atmospheric CO2 data and plot it
% Load the real observed CO2 in the atmosphere
load(strcat(path_data,'dataObservedCO2.mat')); % loads in dtdelpCO2a_obs,
                                               % dpCO2a_obs, CO2a_obs in
                                               % ppm CO2
% save minimal year in the observation data
startYear_obs = floor(min(CO2a_obs(:,1)));

%%%% Plot the contained curves from this data repository
figure(1), clf, hold on,
% Define size and location of the figure [xPos yPos WidthFig HeightFig]
set(gcf, 'Position', [ 300 300 600 400]);
set(gcf,'PaperPosition', [ 300 300 600 400])
% set interpreter to latex
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

%plot the data
plot(dtdelpCO2a_obs(dtdelpCO2a_obs>=startYear_obs,1), dtdelpCO2a_obs(dtdelpCO2a_obs>=startYear_obs,2))
% configure axis and legend
xlim([min(dtdelpCO2a_obs(dtdelpCO2a_obs>=startYear_obs,1)), ...
    max(dtdelpCO2a_obs(dtdelpCO2a_obs>=startYear_obs,1))])
grid
h = xlabel("years");  set(h, 'Interpreter', 'latex');
h = ylabel("dtdelpCO2a_obs");  set(h, 'Interpreter', 'latex');
h = legend('dtdelpCO2a_obs','location','northwest');
set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);

% print figure
set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print('../pics/Observed_AtmosphericGrowth.png', '-dpng')
hold off

figure(2), clf, hold on,
% Define size and location of the figure [xPos yPos WidthFig HeightFig]
set(gcf, 'Position', [ 300 300 600 400]);
set(gcf,'PaperPosition', [ 300 300 600 400])
% set interpreter to latex
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% Plot the data
plot(dpCO2a_obs(:,1), dpCO2a_obs(:,2))
% configure axis and legend
xlim([min(dpCO2a_obs(:,1)), max(dpCO2a_obs(:,1))])
grid
h = xlabel("years");  set(h, 'Interpreter', 'latex');
h = ylabel("dpCO2a_obs");  set(h, 'Interpreter', 'latex');
h = legend('dpCO2a_obs','location','northwest');
set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);

% print figure
set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print('../pics/Observed_Unknown.png', '-dpng')
hold off

figure(3), clf, hold on,
% Define size and location of the figure [xPos yPos WidthFig HeightFig]
set(gcf, 'Position', [ 300 300 600 400]);
set(gcf,'PaperPosition', [ 300 300 600 400])
% set interpreter to latex
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% Plot the data
plot(CO2a_obs(:,1), CO2a_obs(:,2))
% configure axis and legend
xlim([min(CO2a_obs(:,1)), max(CO2a_obs(:,1))])
ylim([min(CO2a_obs(:,2))-1, max(CO2a_obs(:,2))]+1)
grid
h = xlabel("years");  set(h, 'Interpreter', 'latex');
h = ylabel("atmospheric CO2 [ppm]");  set(h, 'Interpreter', 'latex');
h = legend('atmospheric CO2','location','northwest');
set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);

% print figure
set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print('../pics/Observed_AtmosphericCO2.png', '-dpng')
hold off

clear dtdelpCO2a_obs dpCO2a_obs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%% Load past CO2 emissions for Land use and fossil fuel and interpolate+ add to yield total emissions
close all
Intpol_method = 'pchip'; %'linear'% 'linear' was chosen by Julia in her man-file for
                         % Joos model. Probably pchip is a better approach
                         % for early years

% Load the emission data files to load and convert to ppm
FF_data = csvread(strcat(path_data,'dataFF_Boden_2016.csv'));    % in 10^12C /year (gtC/year) 
LU_data = csvread(strcat(path_data,'dataLU_Houghton_2016.csv')); % in 10^12C /year (gtC/year)

% Start emission data from observation data
FF_data = FF_data(FF_data(:,1)>=startYear_obs,:);

LU_data(1,1) = startYear_obs;

% convert to ppm CO2
FF_data(:,2) = FF_data(:,2)*gtonC_2_ppmC * C2CO2;
LU_data(:,2) = LU_data(:,2)*gtonC_2_ppmC * C2CO2;

%%%% Compute total emissions interpolated until 2016
% Fosil fuel part of emissions annually
ff = getSourceData_fabian( 1, FF_data, Intpol_method);
LU = getSourceData_fabian( 1, LU_data, Intpol_method);

ff_int =  getSourceData_fabian( 12, ff, Intpol_method);
LU_int =  getSourceData_fabian( 12, LU, Intpol_method);

PastTotalCO2emission = LU;
PastTotalCO2emission(:,2) = LU(:,2) + ff(:,2);

PastTotalCO2emission_int = LU_int;
PastTotalCO2emission_int(:,2) = LU_int(:,2) + ff_int(:,2);
clear FF_data LU_data missing_years_LU;


figure(figure_counter), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

line( PastTotalCO2emission_int(:, 1 ), PastTotalCO2emission_int(:,2), 'color',...
      BrightCol(1,:), 'LineWidth', 1.5)
line( LU_int(:, 1 ), LU_int(:,2), 'color', BrightCol(3,:), 'LineWidth', 1.5)
line( ff_int(:, 1 ), ff_int(:,2), 'color', BrightCol(5,:), 'LineWidth', 1.5)
  
xlim([1763 2017])
h = title('Past CO2 emissions'); set(h, 'Interpreter', 'latex');
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = ylabel('CO2 [ppm/year]'); set(h, 'Interpreter', 'latex');
h = legend('Past total CO2',...
       'CO2 from land use',...
       'CO2 from fossil fuel','location','northwest'); set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('PastEmissionsPPM_',Intpol_method,'.png')), '-dpng')

figure_counter = figure_counter +1;
figure(figure_counter), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

line( PastTotalCO2emission_int(:, 1 ), PastTotalCO2emission_int(:,2)/gtonC_2_ppmC, 'color',...
      BrightCol(1,:), 'LineWidth', 1.5)
line( LU_int(:, 1 ), LU_int(:,2)/gtonC_2_ppmC, 'color', BrightCol(3,:), 'LineWidth', 1.5)
line( ff_int(:, 1 ), ff_int(:,2)/gtonC_2_ppmC, 'color', BrightCol(5,:), 'LineWidth', 1.5)
  
xlim([1763 2017])
h = title('Past CO2 emissions'); set(h, 'Interpreter', 'latex');
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = ylabel('CO2 [Gt CO2/year]'); set(h, 'Interpreter', 'latex');
h = legend('Past total CO2',...
       'CO2 from land use',...
       'CO2 from fossil fuel','location','northwest'); set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('PastEmissionsGtCO2_',Intpol_method,'.png')), '-dpng')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fit optimal parameters for Rafelski Model by least squares and plot results
% Define the loss function depending on the real observed atmospheric CO2
% find data until 2005
PastTotalCemission_int = PastTotalCO2emission_int;
PastTotalCemission_int(:,2) = PastTotalCO2emission_int(:,2) ./ C2CO2;

minLoss = @(x) LSE_Params( x, PastTotalCemission_int, CO2a_obs, 1958, 2016 );

% value of minLoss for starting parameters
minLoss([278  0.85])

% optimize parameter
%[xopt,fval, exitflag, output] = fminsearch(minLoss, [278 0.85]);

xopt1 = [284.1945    0.7647];  % loss minimized 1765-2016, min = 11.7401
xopt2 = [285.1693    0.8047];  % loss minimized 1958-2016, min = 0.7568

% Loss after minimisation
minLoss(xopt1)
minLoss(xopt2)
% Check that the optimal fit makes sense, up to 2004
[CO2a, ~, fas, ffer, Aoc, dtdelpCO2a] = JoosModelFix( PastTotalCemission_int, xopt1 );
% Check that the optimal fit makes sense, up to 2016
CO2a2 = JoosModelFix( PastTotalCemission_int, xopt2 );

clear minLoss

%%%% Plot fits with the two optimised parameters
figure_counter = figure_counter +1;
figure(figure_counter),clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% plot values
line(CO2a(:,1),CO2a(:,2), 'Color', colMat(4,:), 'LineWidth',2);
line(CO2a2(:,1),CO2a2(:,2), 'Color', BrightCol(4,:), 'LineWidth',2);
line(CO2a_obs(:,1),CO2a_obs(:,2), 'Color', colMat(1,:), 'LineWidth',2);

% define axis and labels
ylim([260 450])
h = legend('Calculated atmospheric CO2  optimised from 1765',...
       'Calculated atmospheric CO2 optimised from 1958',...
       'Observed atmospheric CO2','location','northwest'); set(h, 'Interpreter', 'latex');
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
print(strcat(path_pics,"AtmosphericCO2_fit_",Intpol_method,".png"), '-dpng')
hold off

%%%% Plot sinks and emissions
figure_counter = figure_counter +1;
figure(figure_counter), clf, hold on,
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

plot( ff(:,1),ff(:,2),...
      fas(:,1),Aoc*fas(:,2),...
      ffer(:,1),ffer(:,2),...
      LU(:,1),LU(:,2),...
      dtdelpCO2a(:,1),dtdelpCO2a(:,2), 'LineWidth', 2);
h = legend('Fossil fuel','Air-sea flux','Land sink','Land use','Change in atmospheric CO2','location','northwest');
set(h, 'Interpreter', 'latex');
h = ylabel('ppm/yr');  set(h, 'Interpreter', 'latex');
h = xlabel('year');  set(h, 'Interpreter', 'latex');
h = title('Sources and Sinks');  set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);

% print options
set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,"Emissions_AllSinks_",Intpol_method,".png"), '-dpng')
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%% Read the AR5 2 degree scenarios
AR52deg_data = csvread(strcat(path_data,'ar5_2deg_world_cO2_modFT.csv'),1,5); % in gigatons/year
% data is given in 5 year intervals starting 2005 and ending 2100, put this
% as the first entry in the AR52deg_data matrix
years = 2005:5:2100;
AR52deg_data = [ years; AR52deg_data(:,1:length(years)) ]';

% Define container for AR52deg_data on a monthly scale
monthTimes        = getMonthVectorFromYears(1765, 2100);
data_AR52deg      = zeros( [length(monthTimes) size(AR52deg_data,2)] );
data_AR52deg(:,1) = monthTimes;

clear years monthTimes

% Interpolate the data to feed into the Joos Model
for scenarioNum = 2:size(AR52deg_data,2)
    % Pick scenario and find the missing data
    Index_NoNmissing  = AR52deg_data(:,scenarioNum)~=0;
    data_AR5          = [ AR52deg_data(:,1) AR52deg_data(:, scenarioNum) ] ;
    data_AR5          = data_AR5(Index_NoNmissing, :);
    % convert to ppm in C
    data_AR5(:,2)     = data_AR5(:,2) / 10^3 * gtonC_2_ppmC;
    cut_year          = min(data_AR5(:,1));
    Ie                = find(PastTotalCO2emission_int(:,1)==cut_year);
    Ia                = find(PastTotalCO2emission_int(:,1)==1765);
    
    % linearly shift prediction to remove discontinuity
    if strcmp(glue,'cont')
        data_AR5(:,2) = data_AR5(:,2) + PastTotalCO2emission_int(Ie,2) - data_AR5(1,2);
    end
    
    % data for tuning the model
    data_obs = PastTotalCO2emission_int(Ia:(Ie-1),:);
    % interpolate the data
    data_int = getSourceData_fabian( 12, data_AR5, 'linear');    
    
    data_AR52deg( 1:(size(data_int,1)+size(data_obs,1)), scenarioNum ) = ...
                        [data_obs(:,2); data_int(:,2)];
end

% Clear workspace
clear Ia data_AR5 data_int data cut_year Index_NoNmissing AR52deg_data ...
      scenarioNum Index_NoNmissing Ie

figure_counter = figure_counter +1;
figure(figure_counter), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

for scenarioNum = 2:size(data_AR52deg,2)
    Index_NoNmissing     = find(data_AR52deg(:,scenarioNum)~=0);
    line(data_AR52deg( Index_NoNmissing, 1 ), data_AR52deg( Index_NoNmissing, scenarioNum ), 'color', BrightCol(7,:))    
end
line( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
  
% plot mean
%line(data_AR52deg(:, 1 ), mean(data_AR52deg(:,2:end), 2), 'color', BrightCol(5,:), 'LineWidth', 1.5)
xlim([1763 2102])
h = title('AR5 2°: CO2 emissions'); set(h, 'Interpreter', 'latex');
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = ylabel('CO2 [ppm]'); set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('Emissions_AR52deg_',glue,'.png')), '-dpng')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%% Read the AR5 baseline scenarios
AR5base_data = csvread(strcat(path_data,'ar5_baseline_world_cO2.csv'),1,5); % in gigatons/year

% data is given in 5 year intervals starting 2005 and ending 2100, put this
% as the first entry in the AR52deg_data matrix
years = 2005:5:2100;
AR5base_data = [ years; AR5base_data(:,1:length(years)) ]';

% Define container for AR52deg_data on a monthly scale
monthTimes        = getMonthVectorFromYears(1765, 2100);
data_AR5base      = zeros( [length(monthTimes) size(AR5base_data,2)] );
data_AR5base(:,1) = monthTimes;

clear years monthTimes

% Interpolate the data to feed into the Joos Model
for scenarioNum = 2:size(AR5base_data,2)
    % Pick scenario and find the missing data
    Index_NoNmissing  = find(AR5base_data(:,scenarioNum)~=0);
    data_AR5          = [ AR5base_data(:,1) AR5base_data(:, scenarioNum) ] ;
    data_AR5          = data_AR5(Index_NoNmissing, :);
    % convert to ppm in C
    data_AR5(:,2)     = data_AR5(:,2) / 10^3 * gtonC_2_ppmC;
    cut_year          = min(data_AR5(:,1));
    Ie                = find(PastTotalCO2emission_int(:,1)==cut_year);
    Ia                = find(PastTotalCO2emission_int(:,1)==1765);

    % linearly shift prediction to remove discontinuity
    if strcmp(glue,'cont')
        data_AR5(:,2) = data_AR5(:,2) + PastTotalCO2emission_int(Ie,2) - data_AR5(1,2);
    end
    
    % data for tuning the model
    data_obs = PastTotalCO2emission_int(Ia:(Ie-1),:);
    % interpolate the data
    data_int = getSourceData_fabian( 12, data_AR5, 'linear');    
    
    % glue together
    data_AR5base( 1:(size(data_int,1)+size(data_obs,1)), scenarioNum ) = ...
                        [data_obs(:,2); data_int(:,2)];
end

% Clear workspace
clear Ia data_AR5 data_int data cut_year Index_NoNmissing AR52deg_data ...
      scenarioNum Index_NoNmissing Ie

figure_counter = figure_counter +1;
figure(figure_counter), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

for scenarioNum = 2:size(data_AR5base,2)
    Index_NoNmissing     = find(data_AR5base(:,scenarioNum)~=0);
    line(data_AR5base( Index_NoNmissing, 1 ), ...
         data_AR5base( Index_NoNmissing, scenarioNum ), 'color', BrightCol(7,:))
end
line( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
% Plot mean
%line(data_AR5base(:, 1 ), mean(data_AR5base(:,2:end), 2), 'color', BrightCol(5,:), 'LineWidth', 1.5)

xlim([1763 2102])
h = title('AR5 BAU: CO2 emissions'); set(h, 'Interpreter', 'latex');
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = ylabel('CO2 [ppm]'); set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('Emissions_AR5base_',glue,'.png')), '-dpng')
hold off


figure_counter = figure_counter +1;
figure(figure_counter), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

outliers = [9 10 21 31 36 50 53 59 60 63 64];
for scenarioNum = 2:size(data_AR5base,2)
    Index_NoNmissing     = find(data_AR5base(:,scenarioNum)~=0);
    if any(scenarioNum == outliers)
        line(data_AR5base( Index_NoNmissing, 1 ), data_AR5base( ...
                           Index_NoNmissing, scenarioNum ), 'color', BrightCol(5,:), 'LineWidth', 2)
    else
        line(data_AR5base( Index_NoNmissing, 1 ), data_AR5base( ...
                           Index_NoNmissing, scenarioNum ), 'color', BrightCol(7,:))
    end
end
xlim([1763 2102])
h = xlabel('year'); set(h, 'Interpreter', 'latex');
h = ylabel('CO2 [ppm]'); set(h, 'Interpreter', 'latex');
h = title('AR5 BAU: unusal scenarios'); set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('Emissions_AR5baseUnusal_',glue,'.png')), '-dpng')
hold off
%%%% Get Baseline correspondence
deg_Base_correspondence = [1,2,5,8,9,10,11,1,2,3,5,6,7,8,9,10,11,12,... % AME Reference
                            repmat(13:21, [1 2]),... % AMPERE2-Base-FullTech-OPT
                            repmat(22:32, [1 4]),... % AMPERE3-Base
                            36,38, 35,36,38, repmat(33:39, [1 2]),... % EMF22 Reference
                            40,41,43,44,46,47,48,49,50,51,52,53,54,... % EMF27-Base-FullTech
                            40:54,... % EMF27-Base-FullTech
                            repmat(55:61, [1 2]),... % LIMITS-Base
                            repmat(62:64, [1 2])... % ROSE BAU DEF
                            ];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%% Get COa curves for baseline and 2 degr scenario
xopt = xopt2;
%%%% baseline
COa_base      = zeros(size(data_AR5base));
COa_base(:,1) = data_AR5base(:,1);
% Use Joos model to get the COa curves
for scenarioNum = 2:size(data_AR5base,2)
    Index_NoNmissing = data_AR5base(:,scenarioNum)~=0;
    tmp = data_AR5base(Index_NoNmissing,[1, scenarioNum]);
    tmp(:,2) = tmp(:,2)./ C2CO2;
    COa = JoosModelFix( tmp, xopt );
    COa_base(1:size(COa,1),scenarioNum) = COa(:,2);
    clear Ie;
end
% Clear workspace
clear Ia data_AR5 data_int data cut_year Index_NoNmissing AR5base_data

figure_counter = figure_counter +1;
figure(figure_counter), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

for scenarioNum = 2:size(COa_base,2)
    Index_NoNmissing = find(COa_base(:,scenarioNum)~=0);
    plot(COa_base( Index_NoNmissing, 1 ), COa_base( Index_NoNmissing, scenarioNum ))
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


%%%% 2 degree
COa_2deg      = zeros(size(data_AR52deg));
COa_2deg(:,1) = data_AR52deg(:,1);
% Use Joos model to get the COa curves
for scenarioNum = 2:size(data_AR52deg,2)
    Index_NoNmissing = data_AR52deg(:,scenarioNum)~=0;
    tmp = data_AR52deg(Index_NoNmissing,[1, scenarioNum]);
    tmp(:,2) = tmp(:,2)./ C2CO2;
    COa = JoosModelFix( tmp, xopt );
    COa_2deg(1:size(COa,1),scenarioNum) = COa(:,2);
    clear Ie;
end
% Clear workspace
clear Ia data_AR5 data_int data cut_year Index_NoNmissing AR5base_data

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot atmospheric CO2 and growth of AR models versus its baseline
%load(strcat('workspaces/JoosModel_xopt_AR5_pchip_',glue,'.mat'))

T = readtable(strcat(path_data,'ar5_baseline_world_cO2.csv'));
namesBase_t = T(2:end, 1:2);
namesBase   = cell([1 size(namesBase_t,1)]);

for k = 1:size(namesBase_t,1)
    namesBase{k} = [namesBase_t.Var1{k} ': ' namesBase_t.Var2{k}];
end

T = readtable(strcat(path_data,'ar5_2deg_world_cO2_modFT.csv'));
names2deg_t = T(2:end, 1:2);
names2deg   = cell([1 size(names2deg_t,1)]);

for k = 1:size(names2deg_t,1)
    names2deg{k} = [names2deg_t.Var1{k} ': ' names2deg_t.Var2{k}];
end

clear k names2deg_t namesBase_t

years = COa_2deg(:,1);

COa_2deg(COa_2deg==0) = NaN;
COa_base(COa_base==0) = NaN;

for scenario = 2:size(COa_2deg,2)

figure(1), clf, hold on
    WidthFig  = 600;
    HeightFig = 400;
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    
        plot(years, COa_base(:,deg_Base_correspondence(scenario-1)+1), 'LineWidth', 1.5, 'Color', BrightCol(5,:))
        plot(years, COa_2deg(:,scenario), 'LineWidth', 1.5, 'Color', BrightCol(1,:))
        title('Atmospheric CO2')
        xlim([1990 2060])
        h = xlabel('years');  set(h, 'Interpreter', 'latex');
        h = ylabel('atmospheric CO2 [ppm/year]');  set(h, 'Interpreter', 'latex');
        h = legend( namesBase{deg_Base_correspondence(scenario-1)},...
                    names2deg{scenario-1},...
                    'location','northwest');  set(h, 'Interpreter', 'latex');
        grid
        set(gca, 'fontsize', 14);
        hold off
        
    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,'ARmodels/',glue,'/Sc_',num2str(scenario),'_aCO2.png'), '-dpng')
hold off
end


for scenario = 2:size(COa_2deg,2)

figure(2), clf, hold on
    WidthFig  = 600;
    HeightFig = 400;
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    
        plot(years(1:end-1), diff(COa_base(:,deg_Base_correspondence(scenario-1)+1)), 'LineWidth', 1.5, 'Color', BrightCol(5,:))
        plot(years(1:end-1), diff(COa_2deg(:,scenario)), 'LineWidth', 1.5, 'Color', BrightCol(1,:))
        title('Atmospheric Growth Rate CO2')
        xlim([1990 2060])
        h = xlabel('years');  set(h, 'Interpreter', 'latex');
        h = ylabel('atmospheric growth rate CO2 [ppm]');  set(h, 'Interpreter', 'latex');
        h = legend( namesBase{deg_Base_correspondence(scenario-1)},...
                    names2deg{scenario-1},...
                    'location','northwest');  set(h, 'Interpreter', 'latex');
        grid
        set(gca, 'fontsize', 14);
        hold off
        
    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,'ARmodels/',glue,'/Sc_',num2str(scenario),'_graCO2.png'), '-dpng')
hold off
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot atmospheric CO2 and growth of AR models versus its baseline
%load(strcat('workspaces/JoosModel_xopt_AR5_pchip_',glue,'.mat'))

T = readtable(strcat(path_data,'ar5_baseline_world_cO2.csv'));
namesBase_t = T(2:end, 1:2);
namesBase   = cell([1 size(namesBase_t,1)]);

for k = 1:size(namesBase_t,1)
    namesBase{k} = [namesBase_t.Var1{k} ': ' namesBase_t.Var2{k}];
end

T = readtable(strcat(path_data,'ar5_2deg_world_cO2_modFT.csv'));
names2deg_t = T(2:end, 1:2);
names2deg   = cell([1 size(names2deg_t,1)]);

for k = 1:size(names2deg_t,1)
    names2deg{k} = [names2deg_t.Var1{k} ': ' names2deg_t.Var2{k}];
end

clear k names2deg_t namesBase_t

years = COa_2deg(:,1);

data_AR52deg(data_AR52deg==0) = NaN;
data_AR5base(data_AR5base==0) = NaN;

for scenario = 2:size(data_AR52deg,2)

figure(1), clf, hold on
    WidthFig  = 600;
    HeightFig = 400;
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    
        plot(years(1:end-1), diff(data_AR5base(:,deg_Base_correspondence(scenario-1)+1)), 'LineWidth', 1.5, 'Color', BrightCol(5,:))
        plot(years(1:end-1), diff(data_AR52deg(:,scenario)), 'LineWidth', 1.5, 'Color', BrightCol(1,:))
        title('Emissions CO2')
        xlim([1990 2060])
        h = xlabel('years');  set(h, 'Interpreter', 'latex');
        h = ylabel('emission CO2 [ppm C]');  set(h, 'Interpreter', 'latex');
        h = legend( namesBase{deg_Base_correspondence(scenario-1)},...
                    names2deg{scenario-1},...
                    'location','northwest');  set(h, 'Interpreter', 'latex');
        grid
        set(gca, 'fontsize', 14);
        hold off
        
    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,'ARmodels/',glue,'/Sc_',num2str(scenario),'_emissionCO2.png'), '-dpng')
hold off
end
%%
clear fig ans COa scale h fig gig_pos HeightFig WidthFig scale...
      fig_pos fval exitflag figure_counter Index_NoNmissing scenarioNum output tmp

%save(strcat('workspaces/JoosModel_xopt_AR5_pchip_',glue,'.mat'))