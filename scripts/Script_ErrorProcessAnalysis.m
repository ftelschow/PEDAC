%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%	This script analyses the error process for model fits
%%%%    Note that this part will be moved to R, since the analysis tools
%%%%    are stronger.
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

%%%% Constants for figures
% load color data base for plots
load(strcat(path_data,'colors.mat'))

WidthFig  = 550;
HeightFig = 450;

% load the observed CO2 in the atmosphere
load(strcat(path_data,"dataObservedCO2.mat"))
clear dpCO2a_obs dtdelpCO2a_obs




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Analysis of residuals from Rafelski model fit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% load the Rafelski-model
load(strcat(path_data,"Fit_RafelskiModelAtmosphericCO21958_2005.mat"))
I = find(CO2a(:,1)==1958);
% monthly imbalance process
IMBALANCE = CO2a(I:12:end,2) - CO2a_obs(I:12:end,2);
IMBALANCE = IMBALANCE(1:end-5);
times     = CO2a(I:12:end-5*12,1);

%%%%%%%%%%%% analyse atmospheric growth rate error process
% define imbalance process
res = diff(IMBALANCE);
% estimate standard deviation
mRes   = mean(res);
stdRes = std(res);

figure(1), clf
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

subplot(2,2,1), hold on
plot(times(1:end-1),res)
plot([times(1) times(end)], [0 0])
h = title('Imbalance Process');  set(h, 'Interpreter', 'latex');
h = xlabel("year");  set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
h = legend( strcat("std dev: ", num2str(round(std(res),2))),...
            'location','northwest');  set(h, 'Interpreter', 'latex', 'FontSize', 10);
ylim([-2.1 2.1])
hold off

subplot(2,2,2), hold on
autocorr(res,'NumLags',10,'NumSTD',2);
h = title('Autocorrelation');  set(h, 'Interpreter', 'latex');
h = xlabel("lag");  set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

subplot(2,2,3), hold on
parcorr(res);
h = title('Partial Autocorrelation');  set(h, 'Interpreter', 'latex');
h = xlabel("lag");  set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

subplot(2,2,4), hold on
qqplot(res)
h = title('QQ-Plot');  set(h, 'Interpreter', 'latex');
h = xlabel("std normal");  set(h, 'Interpreter', 'latex');
h = ylabel("input sample");  set(h, 'Interpreter', 'latex');
% kolmogorov smirnow
[~,p] = kstest(res/stdRes);
set(gca, 'fontsize', 14);
h = legend( strcat("K-S test: ", num2str(round(p,2))),...
            'location','northwest');  set(h, 'Interpreter', 'latex', 'FontSize', 10);
hold off

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'ErrorProcess_agrCO2_Rafelski.png'), '-dpng')
hold off

% error process model parameters
rho = 0; % white noise seems to be a good model
save(strcat(path_data, 'ErrorProcess_Rafelski_agrCO2.mat'), 'stdRes', 'rho' )


%%%%%%%%%%%% analyse atmospheric CO2 concentration error process
%%%% oiginal error process
% get imbalance process
res = IMBALANCE;
% estimate standard deviation
stdRes = std(res);

% plot analysis tools of process
figure(2), clf
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

subplot(2,2,1), hold on
plot(times,res)
plot([times(1) times(end)], [0 0])
h = title('Imbalance Process');  set(h, 'Interpreter', 'latex');
h = xlabel("year");  set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
h = legend( strcat("std dev: ", num2str(round(std(res),2))),...
            'location','northwest');  set(h, 'Interpreter', 'latex', 'FontSize', 10);
ylim([-2.1 2.1])
hold off

subplot(2,2,2), hold on
autocorr(res,'NumLags',10,'NumSTD',2);
h = title('Autocorrelation');  set(h, 'Interpreter', 'latex');
h = xlabel("lag");  set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

subplot(2,2,3), hold on
parcorr(res);
h = title('Partial Autocorrelation');  set(h, 'Interpreter', 'latex');
h = xlabel("lag");  set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

subplot(2,2,4), hold on
qqplot(res)
h = title('QQ-Plot');  set(h, 'Interpreter', 'latex');
h = xlabel("std normal");  set(h, 'Interpreter', 'latex');
h = ylabel("input sample");  set(h, 'Interpreter', 'latex');
% kolmogorov smirnow
[~,p] = kstest(res/stdRes);
set(gca, 'fontsize', 14);
h = legend( strcat("K-S test: ", num2str(round(p,2))),...
            'location','northwest');  set(h, 'Interpreter', 'latex', 'FontSize', 10);
hold off

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'ErrorProcess_aCO2_Rafelski_original.png'), '-dpng')
hold off

%%%% fit AR1 model to error process
m  = ar(res,1);
m2 = ar(res,2);
rho = 0.8256;

res = res(2:end)- rho*res(1:end-1);

% plot analysis tools of process
figure(3), clf
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

subplot(2,2,1), hold on
plot(times(1:end-1),res)
plot([times(1) times(end)], [0 0])
h = title('Imbalance Process');  set(h, 'Interpreter', 'latex');
h = xlabel("year");  set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
h = legend( strcat("std dev: ", num2str(round(std(res),2))),...
            'location','northwest');  set(h, 'Interpreter', 'latex', 'FontSize', 10);
ylim([-2.1 2.1])
hold off

subplot(2,2,2), hold on
autocorr(res,'NumLags',10,'NumSTD',2);
h = title('Autocorrelation');  set(h, 'Interpreter', 'latex');
h = xlabel("lag");  set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

subplot(2,2,3), hold on
parcorr(res);
h = title('Partial Autocorrelation');  set(h, 'Interpreter', 'latex');
h = xlabel("lag");  set(h, 'Interpreter', 'latex');
set(gca, 'fontsize', 14);
hold off

subplot(2,2,4), hold on
qqplot(res)
h = title('QQ-Plot');  set(h, 'Interpreter', 'latex');
h = xlabel("std normal");  set(h, 'Interpreter', 'latex');
h = ylabel("input sample");  set(h, 'Interpreter', 'latex');
% kolmogorov smirnow
[~,p] = kstest(res/stdRes);
set(gca, 'fontsize', 14);
h = legend( strcat("K-S test: ", num2str(round(p,2))),...
            'location','northwest');  set(h, 'Interpreter', 'latex', 'FontSize', 10);
hold off

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'ErrorProcess_aCO2_Rafelski_AR1.png'), '-dpng')
hold off

% error process model parameters
save(strcat(path_data, 'ErrorProcess_Rafelski_aCO2.mat'), 'stdRes', 'rho' )

clear fig fig_pos h I m m2 p