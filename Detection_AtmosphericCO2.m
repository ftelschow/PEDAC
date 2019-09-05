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
path      = '/home/drtea/Research/Projects/2018_CO2/PEDAC';
path_pics = '/home/drtea/Research/Projects/2018_CO2/pics/';
path_data = '/home/drtea/Research/Projects/2018_CO2/PEDAC/data/';
cd(path)
clear path

fig_counter=1;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load data from preprocessing
glue = 'direct';
load(strcat('workspaces/JoosModel_xopt_AR5_pchip_',glue,'.mat'))
load(strcat(path_data,'dataObservedCO2.mat'))
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%% Analysis of residuals from fit
%%%% growth rate
grRate = diff(tmp(1:12:end,2));
grRate_model = diff(tmp2(1:12:end,2));

res = grRate - grRate_model;

res = res(1:end-5);
% estimate standard deviation
mRes   = mean(res)
stdRes = std(res)

figure(1), clf
subplot(2,2,1), hold on
plot(res)
plot([0 60], [0 0])
hold off
subplot(2,2,2)
autocorr(res,'NumLags',10,'NumSTD',2)
subplot(2,2,3)
parcorr(res)
subplot(2,2,4)
qqplot(res)

% kolmogorov smirnow
[h,p] = kstest(res/stdRes) % test does not reject!

%%%% atmospheric CO2
aRate = tmp(1:12:end,2);
aRate_model = tmp2(1:12:end,2);

resa = aRate - aRate_model;

resa = resa(1:end-5);
% estimate standard deviation
mResa   = mean(resa)
stdResa = std(resa)

figure(2), clf
subplot(2,2,1), hold on
plot(resa)
plot([0 60], [0 0])
hold off
subplot(2,2,2)
autocorr(resa,'NumLags',10,'NumSTD',2)
subplot(2,2,3)
parcorr(resa)
subplot(2,2,4)
qqplot(resa)

m  = ar(resa,1)
m2 = ar(resa,2)

% kolmogorov smirnow
[h,p] = kstest(resa/stdResa) % test does not reject!

resa2 = resa(2:end)- 0.9009*resa(1:end-1) 
figure(3), clf
subplot(2,2,1), hold on
plot(resa2)
plot([0 60], [0 0])
hold off
subplot(2,2,2)
autocorr(resa2,'NumLags',16,'NumSTD',2)
subplot(2,2,3)
parcorr(resa2)
subplot(2,2,4)
qqplot(resa2)

mResa2   = mean(resa2)
stdResa2 = std(resa2)

% kolmogorov smirnow
[h,p] = kstest(resa2/stdResa2) % test does not reject!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%% Apply detection method to the Models
cut_year1 = 2005-1;
cut_year2 = 2050-1;
years     = cut_year1:cut_year2;
Nscenario = size(data_AR52deg,2);

out = [41 44 52];

% Generate AR process for imbalance
Msim = 1e5;
T    = length(drift_alter);
rho = 0;
sigma  = 0.4647;

% compute threshold
IMBALANCE = generate_AR(Msim, T, rho, sigma);
q = 0.05;
thresholdsF = get_Thresholds(IMBALANCE, q);

% simulate imbalance as error processes
IMBALANCE = generate_AR(Msim, T, rho, sigma);

% save detection time
detect_year = zeros([1 Nscenario]);

for scenario = 2:Nscenario
    if ~any(out==deg_Base_correspondence(scenario-1)+1)
        % Find cutting point
        times      = 1:size(COa_base,1);
        index_cut1 = times(COa_base(:,1)==cut_year1);
        index_cut2 = times(COa_base(:,1)==cut_year2);

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
        plot(years, drift_base, 'LineWidth', 1.5, 'Color', BrightCol(1,:))
        plot(years, drift_alter, 'LineWidth', 1.5, 'Color', BrightCol(3,:))
        title('Growth Rates')
    h = xlabel('years');  set(h, 'Interpreter', 'latex');
    h = ylabel('growth rate [ppm/year]');  set(h, 'Interpreter', 'latex');
    h = legend('BAU','AR5',  'location','northwest');  set(h, 'Interpreter', 'latex');
    grid
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
        plot_Detection( dyear, probs, 2005, q, strcat(path_pics,'detect_',glue,'/Sc_',num2str(scenario),'_detection.png'));

        detect_year(scenario) = dyear;
    end
end

save(strcat('workspaces/Times_AR5_pchip_',glue,'.mat'), 'detect_year')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(strcat('workspaces/Times_AR5_pchip_',glue,'.mat'), 'detect_year')

m_detect   = mean(detect_year)
std_detect = std(detect_year)
quantile(detect_year, [0.05 0.25 0.5 0.75 0.95])

histogram(detect_year(detect_year~=0))
title('detection times AR5 vs Baseline')