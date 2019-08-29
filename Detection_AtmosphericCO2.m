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
path      = '/home/drtea/Research/Projects/2018_CO2/joosModel';
path_pics = '/home/drtea/Research/Projects/2018_CO2/pics/';
path_data = '/home/drtea/Research/Projects/2018_CO2/joosModel/data/';
cd(path)
clear path

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%% Analyze data from Peters et al and Armin
T = readtable(strcat(path_data,'Peters2017_Fig2_past.txt'));
PetersPast = T.Variables;
T = readtable(strcat(path_data,'Peters2017_Fig2_future2050.txt'));
PetersFuture = T.Variables;

% Parameters for AR process
Msim  = 1e5;
T     = size(PetersFuture,1);
rho   = 0.48;
sigma = 3;

% Generate AR process for imbalance
IMBALANCE = generate_AR(Msim, T, rho, sigma);

%%%%%%%%% Try to reproduce Armins plot
% set detection level
q = 0.05;

% Peter et al threshold
thresholds = 2*sigma;
[thresholdPeter0, dyearPeter0, probsPeter0] = ...
            get_Detection( IMBALANCE, [PetersFuture(:,2),...
                                       PetersFuture(:,3)]', thresholds,q);
plot_Detection( dyearPeter0, probsPeter0, 2017, q, strcat(path_pics,'Reproduce_PeterR0_sd',num2str(sigma),'.png'));

[thresholdPeter1, dyearPeter1, probsPeter1] = ...
            get_Detection( IMBALANCE, [PetersFuture(:,2),...
                                       PetersFuture(:,4)]', thresholds,q);
plot_Detection( dyearPeter1, probsPeter1, 2017, q, strcat(path_pics,'Reproduce_PeterR1_sd',num2str(sigma),'.png'))

% Armin et al method
thresholds = ((1-0.5)*2*sigma):0.01:((1+0.5)*2*sigma);
[thresholdArmin0, dyearArmin0, probsArmin0] = get_Detection( IMBALANCE,...
                                           [PetersFuture(:,2),PetersFuture(:,3)]',...
                                           thresholds,q);
plot_Detection( dyearArmin0, probsArmin0, 2017, q, strcat(path_pics,'Reproduce_ArminR0_sd',num2str(sigma),'.png'));

thresholds = ((1-0.5)*2*sigma):0.01:((1+0.5)*2*sigma);
[thresholdArmin1, dyearArmin1, probsArmin1] = get_Detection( IMBALANCE,...
                                           [PetersFuture(:,2),PetersFuture(:,4)]',...
                                           thresholds,q);
plot_Detection( dyearArmin1, probsArmin1, 2017, q, strcat(path_pics,'Reproduce_ArminR1_sd',num2str(sigma),'.png'));

clear IMBALANCE

save(strcat('workspaces/ReproduceArminsResults_sd',num2str(sigma),'.mat'))

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyze Peter data with my technique
q = 0.05;
% Generate AR process for imbalance to compute the thresholds
IMBALANCE = generate_AR(Msim, T, rho, sigma);
thresholdsFabian = get_Thresholds(IMBALANCE, q);

% Generate AR process for imbalance for evaluation
IMBALANCE = generate_AR(Msim, T, rho, sigma);
[probs_myR0, dyear_myR0, probs_myArmR0] = get_Detection2( IMBALANCE,...
                                         [PetersFuture(:,2),PetersFuture(:,3)]',...
                                          thresholdsFabian, q);
plot_Detection( dyear_myR0, probs_myR0, 2017, q, ...
                strcat(path_pics,'MyMethod_R0_sd',num2str(sigma),'.png'));
plot_Detection( dyear_myR0, probs_myArmR0, 2017, q,...
                strcat(path_pics,'MyMethodArminsEval_R0_sd',num2str(sigma),'.png'));
            
[probs_myR1, dyear_myR1, probs_myArmR1] = get_Detection2( IMBALANCE,...
                                         [PetersFuture(:,2),PetersFuture(:,4)]',...
                                          thresholdsFabian, q);
plot_Detection( dyear_myR1, probs_myR1, 2017, q, ...
                strcat(path_pics,'MyMethod_R1_sd',num2str(sigma),'.png'));
plot_Detection( dyear_myR1, probs_myArmR1, 2017, q,...
                strcat(path_pics,'MyMethodArminsEval_R1_sd',num2str(sigma),'.png'));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load data from preprocessing
glue = 'cont';
load(strcat('workspaces/JoosModel_xopt_AR5_pchip_',glue,'.mat'))
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
figure(8), clf, hold on
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

plot( PetersPast(:,1), PetersPast(:,2), 'LineWidth', 1.5, 'Color', BrightCol(2,:) )
plot( PetersPast(:,1), PetersPast(:,3), 'LineWidth', 1.5, 'Color', BrightCol(1,:) )
plot( PetersPast(1:end-1,1),...
      diff(tmp(1:12:end,2))/gton2ppmCO2, 'LineWidth', 1.5, 'Color', BrightCol(4,:) );
plot( PetersPast(1:end-1,1),...
      diff(tmp2(1:12:end,2))/gton2ppmCO2, 'LineWidth', 1.5, 'Color', BrightCol(5,:) );
  
xlim([PetersPast(1,1) PetersPast(end,1)])

h = title('Comparison of Atmospheric Growth Rate with Peters et al');  set(h, 'Interpreter', 'latex');
h = xlabel('years');  set(h, 'Interpreter', 'latex');
h = ylabel('growth rate [GtCO2/year]');  set(h, 'Interpreter', 'latex');
h = legend('Peters et al obs','Peters et al rec', 'My obs', 'My Reconstruction','location','northwest');  set(h, 'Interpreter', 'latex');
grid
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'AtmosphericGrowthRate_Comp_Peters.png'), '-dpng')
hold off

clear tmp tmp2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%
gton2ppmCO2 = 1/2.31;
cut_year1 = 2005;
cut_year2 = 2050;
obs_year = 1958;
years    = cut_year:cut_year2;
scenario = 6;
sd       = 1;
% Find cutting point
times      = 1:size(COa_base,1);
index_cut1 = times(COa_base(:,1)==cut_year1);
index_cut2 = times(COa_base(:,1)==cut_year2);
index_obs  = times(COa_base(:,1)==obs_year);

% define drifts for base and 2deg scenario
drift_base  = diff( [COa_base(index_cut1-12,scenario);...
                    COa_base(index_cut1:12:index_cut2,scenario)])/gton2ppmCO2;
drift_alter = diff( [COa_2deg(index_cut1-12,scenario);...
                    COa_2deg(index_cut1:12:index_cut2,scenario)])/gton2ppmCO2;
                
figure(1)
plot(years, drift_base)
figure(2)
plot(years, drift_alter)

% Generate AR process for imbalance
Msim = 1e5;
T    = length(drift_alter);
IMBALANCE  = zeros([T,Msim]);
rho = 0.48;

for m = 1:Msim
   IMBALANCE(:,m) = sd*generate_AR(T, rho);
end
clear m

thresholds = 3:0.01:4.5;
q = 0.05;

[threshold, dyear, probs] = get_Detection(IMBALANCE, [drift_base,drift_alter]', thresholds);
plot_Detection( dyear, probs, 2005, q, strcat(path_pics,'ArminsMethod.png'));

thresholds = get_Thresholds(IMBALANCE, q);

IMBALANCE  = zeros([T,Msim]);
for m = 1:Msim
   IMBALANCE(:,m) = sd*generate_AR(T, rho);
end
clear m
[probs2, dyear,probs3] = get_Detection2(IMBALANCE, [drift_base,drift_alter]', thresholds, q);
plot_Detection( dyear, probs2, 2005, q, strcat(path_pics,'MyMethod.png'));
plot_Detection( dyear, probs3, 2005, q, strcat(path_pics,'MyMethodArminsEval.png'));
