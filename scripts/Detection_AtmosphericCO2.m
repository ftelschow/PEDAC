%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%        This file applies Armins procedure for detection
%%%%        times to ahmeds data
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

addpath '/home/drtea/Research/Projects/Hermite'
cd(path)
clear path
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load data from preprocessing
glue = 'cont';
%glue = 'direct';
load(strcat('workspaces/JoosModel_xopt_AR5_pchip_',glue,'.mat'))

load(strcat(path_data,'dataObservedCO2.mat'))
fig_counter = 1;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plot growth rate Peters versus the observed and reconstructed from
%%%% global carbon project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = readtable(strcat(path_data,'Peters2017_Fig2_past.txt'));
PetersPast = T.Variables;

tmp  = CO2a_obs(CO2a_obs(:,1)>=1958,:);
tmp2 = CO2a(CO2a(:,1)>=1958,:);

% Get the observed imbalance process from my reconstruction
IMBA_obs      = CO2a_obs;
IMBA_obs(:,2) = CO2a_obs(:,2) - CO2a(:,2);

%%%% Plot the atmospheric growth rate from Peters et al and from the data
%%%% used in this analysis
figure(fig_counter), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

plot( PetersPast(:,1), PetersPast(:,2), 'LineWidth', 1.5, 'Color', BrightCol(2,:) )
plot( PetersPast(:,1), PetersPast(:,3), 'LineWidth', 1.5, 'Color', BrightCol(1,:) )
plot( PetersPast(1:end-1,1),...
      diff(tmp(1:12:end,2))/gtonC_2_ppmC, 'LineWidth', 1.5, 'Color', BrightCol(4,:) );
plot( PetersPast(1:end-1,1),...
      diff(tmp2(1:12:end,2))/gtonC_2_ppmC, 'LineWidth', 1.5, 'Color', BrightCol(5,:) );
plot( dtdelpCO2a_obs(:,1),...
      dtdelpCO2a_obs(:,2)/gtonC_2_ppmC, 'LineWidth', 1.5, 'Color', BrightCol(3,:) );
  
xlim([PetersPast(1,1) PetersPast(end,1)])

h = title('Comparison of Atmospheric Growth Rate with Peters et al');  set(h, 'Interpreter', 'latex');
h = xlabel('years');  set(h, 'Interpreter', 'latex');
h = ylabel('growth rate [GtCO2/year]');  set(h, 'Interpreter', 'latex');
h = legend('Peters et al observation','Peters et al reconstruction',...
           'My observation', 'My Reconstruction','Global Carbon Project Observation', 'location','northwest');  set(h, 'Interpreter', 'latex');
grid
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'AtmosphericGrowthRate_Comp_Peters.png'), '-dpng')
hold off

clear tmp

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Close view plot of growth rates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(strcat(path_data,'dataObservedCO2.mat'))
% analyze the error process of the growth rate
size(CO2a_obs)
size(dtdelpCO2a_obs(dtdelpCO2a_obs(:,1)>=1765,:))

agr_obs  = dtdelpCO2a_obs(dtdelpCO2a_obs(:,1)>=1765,:);
tmp  = CO2a_obs(CO2a_obs(:,1)>=1958,:);
test_obs = CO2a_obs(1:end-1, :);
test_obs(:,2) = diff(CO2a_obs(:,2));
test_obs = test_obs(test_obs(:,1)>=1958,:);

test_obs_an = zeros([58, 2]);
test_obs_an(:,1) = 1958:2015;
for i = 0:57
    sum = 0;
    for k =1:12
        sum = sum + test_obs(i*12 + k,2);
    end
    test_obs_an(i+1,2) = sum;
end

CO2a_obs = CO2a_obs(CO2a_obs(:,1)<agr_obs(end,1),:);

figure(fig_counter), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

%plot( test_obs(:,1), test_obsn(:,2), 'LineWidth', 1.5, 'Color', BrightCol(4,:) )
plot( agr_obs(:,1), agr_obs(:,2), 'LineWidth', 1.5, 'Color', BrightCol(1,:) )
plot( PetersPast(1:end-1,1),...
      diff(tmp(1:12:end,2)), 'LineWidth', 1.5, 'Color', BrightCol(5,:) );
plot( tmp(1:end-1,1),...
      diff(tmp(1:end,2)), 'LineWidth', 1.5, 'Color', BrightCol(4,:) );
plot( PetersPast(1:end-1,1),...
      diff(tmp2(1:12:end,2)), 'LineWidth', 1.5, 'Color', BrightCol(3,:) );
  
xlim([PetersPast(1,1)-2 PetersPast(end,1)])

h = title('Comparison of Atmospheric Growth Rates - Real Observation Reconstruction');  set(h, 'Interpreter', 'latex');
h = xlabel('years');  set(h, 'Interpreter', 'latex');
h = ylabel('growth rate [ppm/year]');  set(h, 'Interpreter', 'latex');
h = legend('dtdelpCO2a\_obs', 'My observation','My observation (monthly)','My reconstruction',  'location','northwest');  set(h, 'Interpreter', 'latex');
grid
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'AtmosphericGrowthRate_Comp_AnnualObser.png'), '-dpng')
hold off


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Illustrate gain of power
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cut_year1 = 2006;
cut_year2 = 2050;
years     = (cut_year1-1):cut_year2;
Nscenario = size(data_AR52deg,2)-1;

%
scenario = 2;
times      = 1:size(COa_base,1);
index_cut1 = times(COa_base(:,1)==cut_year1);
index_cut2 = times(COa_base(:,1)==cut_year2);
drift_alter = [COa_2deg(index_cut1-12,scenario);...
                    COa_2deg(index_cut1:12:index_cut2,scenario)];

% Generate AR process for imbalance
Msim = 1e5;
T    = length(drift_alter);
rho  = 0.9;
sigma  = stdResa;

% Compute threshold
IMBALANCE = generate_AR(Msim, T, rho, sigma);
q = 0.05;
thresholdsF  = get_Thresholds(IMBALANCE, q);

% Simulate imbalance as error processes
IMBALANCE = generate_AR(Msim, T, rho, sigma);

scenario = 13
    % Find cutting point
    times      = 1:size(COa_base,1);
    index_cut1 = times(COa_base(:,1)==cut_year1);
    index_cut2 = times(COa_base(:,1)==cut_year2);

    % Define drifts for base and 2deg scenario
    drift_base  = [COa_base(index_cut1-12,deg_Base_correspondence(scenario-1)+1 );...
                        COa_base(index_cut1:12:index_cut2,deg_Base_correspondence(scenario-1)+1)];
    drift_alter = [COa_2deg(index_cut1-12,scenario);...
                        COa_2deg(index_cut1:12:index_cut2,scenario)];

    % Armins method
    thresholds = 1.5:0.05:3.5;
    [thresholdArmin0, dyearArmin0, probsArmin0] = get_Detection( IMBALANCE,...
                                               [drift_base, drift_alter]',...
                                               thresholds,q);
                    
    % new method
    [probs, dyear,~] = get_Detection2( IMBALANCE, [drift_base,drift_alter]',...
                                       thresholdsF, q);
    years = 2005 + (1:size(probs,1))-1;

    figure(1), clf, hold on,
    % Define size and location of the figure [xPos yPos WidthFig HeightFig]
    WidthFig  = 500*1.1;
    HeightFig = 400*1.1;
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');

    line(years, probs(:,1), 'Color', BrightCol(5,:), 'LineWidth', 2)
    line(years, probs(:,2), 'Color', BrightCol(1,:), 'LineWidth', 2)
    line(years, probsArmin0(:,1), 'Color', BrightCol(4,:), 'LineWidth', 2, 'LineStyle', '--')
    line(years, probsArmin0(:,2), 'Color', BrightCol(2,:), 'LineWidth', 2, 'LineStyle', '--')
    plot([years(1)-1, years(end)+1], [q, q], 'k--')
    plot([years(1)-1, years(end)+1], [1-q, 1-q], 'k--')
    plot([years(dyear), years(dyear)], [-0.95, 2.95], 'k--')
    grid

    h = xlabel("years");  set(h, 'Interpreter', 'latex');
    h = ylabel("Cummulated Probability of Detection");  set(h, 'Interpreter', 'latex');
    h = legend('False Detection New','True Detection New','False Detection Old','True Detection Old','location','east');
    set(h, 'Interpreter', 'latex');

    xlim([years(1), years(end)])
    ylim([0, 1])
    set(gca, 'fontsize', 14);

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,'/Sc_',num2str(scenario),'_PowerComparison.png'), '-dpng')
    hold off


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Apply detection method to the Models using atmospheric CO2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cut_year1 = 2006;
cut_year2 = 2050;
years     = (cut_year1-1):cut_year2;
Nscenario = size(data_AR52deg,2)-1;

%
scenario = 2;
times      = 1:size(COa_base,1);
index_cut1 = times(COa_base(:,1)==cut_year1);
index_cut2 = times(COa_base(:,1)==cut_year2);
drift_alter = [COa_2deg(index_cut1-12,scenario);...
                    COa_2deg(index_cut1:12:index_cut2,scenario)];

% Generate AR process for imbalance
Msim = 1e5;
T    = length(drift_alter);
rho  = 0.9;
sigma  = stdResa;

% Compute threshold
IMBALANCE = generate_AR(Msim, T, rho, sigma);
q = 0.05;
thresholdsF  = get_Thresholds(IMBALANCE, q);

% Simulate imbalance as error processes
IMBALANCE = generate_AR(Msim, T, rho, sigma);

% Save detection time
detect_year  = zeros([1 Nscenario]);
detect_year2 = zeros([1 Nscenario]);

for scenario = 2:Nscenario+1
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
    [probs, dyear,~] = get_Detection2( IMBALANCE, [drift_base,drift_alter]',...
                                       thresholdsF, q);
    plot_Detection( dyear, probs, 2005, q, strcat(path_pics,'detect_',...
                    glue,'/Sc_',num2str(scenario),'_detection_aCO2.png'));

    detect_year(scenario-1)  = dyear;
    
    figure(1), clf, hold on
    WidthFig  = 500*1.1;
    HeightFig = 400*1.1;
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
        plot(years, drift_base, 'LineWidth', 1.5, 'Color', BrightCol(1,:))
        plot(years, drift_alter, 'LineWidth', 1.5, 'Color', BrightCol(3,:))
        plot( years, drift_base  + thresholdsF(dyear), 'LineWidth', 1, 'Color', BrightCol(1,:), 'LineStyle', ':' )
        plot( years, drift_alter - thresholdsF(dyear), 'LineWidth', 1, 'Color', BrightCol(3,:), 'LineStyle', ':' )
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
    print(strcat(path_pics,'detect_',glue,'/Sc_',num2str(scenario),'_aCO2.png'), '-dpng')
    hold off
end

save(strcat('workspaces/Times_aCO2_AR5_pchip_',glue,'.mat'), 'detect_year')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(strcat('workspaces/Times_aCO2_AR5_pchip_',glue,'.mat'), 'detect_year')

m_detect   = mean(detect_year)
std_detect = std(detect_year)

m_detect   = mean(detect_year(cut_year_2deg==2005))
std_detect = std(detect_year(cut_year_2deg==2005))

quantile(detect_year, [0.05 0.25 0.5 0.75 0.95])

figure(1), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

histogram(detect_year)
title('Detection Times 2deg vs Baseline')
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
print(strcat(path_pics,'detect_',glue,'/Hist_Detect_aCO2.png'), '-dpng')
hold off

figure(2), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

histogram(detect_year(cut_year_2deg==2005))
title('Detection Times 2deg vs Baseline')
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
print(strcat(path_pics,'detect_',glue,'/Hist_Detect_aCO2_cut2005.png'), '-dpng')
hold off


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(strcat('workspaces/Times_aCO2_AR5_pchip_',glue,'.mat'), 'detect_year_mean')

m_detect   = mean(detect_year)
std_detect = std(detect_year)
quantile(detect_year, [0.05 0.25 0.5 0.75 0.95])
    figure(1), clf, hold on
    WidthFig  = 600;
    HeightFig = 400;
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');

    histogram(detect_year(detect_year~=0))
    title('Detection Times 2deg vs Baseline')
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
    print(strcat(path_pics,'detect_',glue,'/Hist_Detect_aCO2mean.png'), '-dpng')
    hold off
    
%% %%%%
% maxCOa_2deg = max(COa_2deg(:,2:end)');
% minCOa_base = min(COa_base(:,2:end)');
% 
% figure, hold on
% plot(COa_2deg(:,1), maxCOa_2deg)
% plot(COa_base(:,1),minCOa_base)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%% Apply detection method to the Models using atmospheric growth
cut_year1 = 2006;
cut_year2 = 2050;
years     = cut_year1:cut_year2;
Nscenario = size(data_AR52deg,2);

%
scenario = 2;
times      = 1:size(COa_base,1);
index_cut1 = times(COa_base(:,1)==cut_year1);
index_cut2 = times(COa_base(:,1)==cut_year2);
drift_alter = diff( [COa_2deg(index_cut1-12,scenario);...
                    COa_2deg(index_cut1:12:index_cut2,scenario)]);

% Generate AR process for imbalance
Msim = 1e5;
T    = length(drift_alter);
rho  = 0;
sigma  = stdRes;

% compute threshold
IMBALANCE = generate_AR(Msim, T, rho, sigma);
q = 0.05;
thresholdsF = get_Thresholds(IMBALANCE, q);

% simulate imbalance as error processes
IMBALANCE = generate_AR(Msim, T, rho, sigma);

% save detection time
detect_year = zeros([1 Nscenario]);

for scenario = 2:Nscenario
    % Find cutting point
    times      = 1:size( COa_base,1);
    index_cut1 =  times( COa_base(:,1)==cut_year1);
    index_cut2 =  times( COa_base(:,1)==cut_year2);

    % define drifts for base and 2deg scenario
    drift_base  = diff( [COa_base(index_cut1-12,deg_Base_correspondence(scenario-1)+1 );...
                         COa_base(index_cut1:12:index_cut2,deg_Base_correspondence(scenario-1)+1)]);
    drift_alter = diff( [COa_2deg(index_cut1-12,scenario);...
                         COa_2deg(index_cut1:12:index_cut2,scenario)]);

    figure(1), clf, hold on
    WidthFig  = 600;
    HeightFig = 400;
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
        plot( years, drift_base, 'LineWidth', 1.5, 'Color', BrightCol(1,:) )
        plot( years, drift_alter, 'LineWidth', 1.5, 'Color', BrightCol(3,:) )
        plot( years, drift_base  + thresholdsF', 'LineWidth', 1.5, 'Color', BrightCol(1,:), 'LineStyle', ':' )
        plot( years, drift_alter - thresholdsF', 'LineWidth', 1.5, 'Color', BrightCol(3,:), 'LineStyle', ':' )
        title('Growth Rates')
    h = xlabel('years');  set(h, 'Interpreter', 'latex');
    h = ylabel('growth rate [ppm/year]');  set(h, 'Interpreter', 'latex');
    h = legend( namesBase{deg_Base_correspondence(scenario-1)},...
                names2deg{scenario-1},...
                'location','northwest');  set(h, 'Interpreter', 'latex');    grid
    set(gca, 'fontsize', 14);

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,'detect_',glue,'/Sc_',num2str(scenario),'_Growth_rates.png'), '-dpng')
    hold off

    [probs, dyear,~] = get_Detection2( IMBALANCE, [drift_base,drift_alter]',...
                                       thresholdsF, q);
    plot_Detection( dyear, probs, 2005, q, strcat(path_pics,'detect_',glue,'/Sc_',num2str(scenario),'_detection_Growth_rates.png'));

    detect_year(scenario) = dyear;
end

save(strcat('workspaces/Times_graCO2_AR5_pchip_',glue,'.mat'), 'detect_year')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(strcat('workspaces/Times_graCO2_AR5_pchip_',glue,'.mat'), 'detect_year')

m_detect   = mean(detect_year)
std_detect = std(detect_year)
quantile(detect_year, [0.05 0.25 0.5 0.75 0.95])

figure(1), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

histogram(detect_year(detect_year~=0))
title('Detection Times 2deg vs Baseline')
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
print(strcat(path_pics,'detect_',glue,'/Hist_Detect_Growth_rates.png'), '-dpng')
hold off
