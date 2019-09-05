%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%        This file reproduces results from Armin and applies new
%%%%        ideas to Peters et al data.
%%%%
%%%%        Authors: Fabian Telschow
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

% set correct working directory
path      = '/home/drtea/Research/Projects/2018_CO2/PEDAC';
path_pics = '/home/drtea/Research/Projects/2018_CO2/pics/';
path_data = '/home/drtea/Research/Projects/2018_CO2/joosModel/data/';
cd(path)
clear path

%%%% Constants
% convert constant from gton to ppm: 1 ppm CO2 = 2.31 gton CO2
gtonC_2_ppmC = 1/2.12; % Quere et al 2017
gtonCO2_2_ppmCO2 = 1/2.31;
C2CO2       = 44.01/12.011;   % Is that correct?

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load data from preprocessing
glue = 'direct';
load(strcat('workspaces/JoosModel_xopt_AR5_pchip_',glue,'.mat'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = readtable(strcat(path_data,'Peters2017_Fig2_past.txt'));
PetersPast = T.Variables;

tmp  = CO2a_obs(CO2a_obs(:,1)>=1958,:)/gtonCO2_2_ppmCO2;
tmp2 = CO2a(CO2a(:,1)>=1958,:)/gtonCO2_2_ppmCO2;

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
      diff(tmp(1:12:end,2)), 'LineWidth', 1.5, 'Color', BrightCol(4,:) );
plot( PetersPast(1:end-1,1),...
      diff(tmp2(1:12:end,2)), 'LineWidth', 1.5, 'Color', BrightCol(5,:) );
plot( dtdelpCO2a(:,1),dtdelpCO2a(:,2)/gtonCO2_2_ppmCO2, 'LineWidth', 1.5, 'Color', BrightCol(3,:), 'LineStyle', '--' );
  
xlim([PetersPast(1,1) PetersPast(end,1)])
h = title('Comparison of Atmospheric Growth Rate with Peters et al');  set(h, 'Interpreter', 'latex');
h = xlabel('years');  set(h, 'Interpreter', 'latex');
h = ylabel('growth rate [GtCO2/year]');  set(h, 'Interpreter', 'latex');
h = legend('Peters et al observed','Peters et al reconstructed', 'My observation', 'My Reconstruction', 'Output from Joos Model','location','northwest');  set(h, 'Interpreter', 'latex');
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

q = 0.05;
prior_q = [0.5 0.3 0.1];
yearStart = 2017;

% Generate AR process for imbalance
IMBALANCE = generate_AR(Msim, T, rho, sigma);

%%%%%%%%% Try to reproduce Armins plot

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
PPV_Armin0 = PPV( probsArmin0, prior_q);

plot_PPV( PPV_Armin0, q, prior_q, yearStart, dyearArmin0, ...
          strcat(path_pics,'Reproduce_ArminR0_sd',num2str(sigma),'PPV.png'))
plot_Detection( dyearArmin0, probsArmin0, 2017, q, strcat(path_pics,'Reproduce_ArminR0_sd',num2str(sigma),'.png'));


thresholds = ((1-0.5)*2*sigma):0.01:((1+0.5)*2*sigma);
[thresholdArmin1, dyearArmin1, probsArmin1] = get_Detection( IMBALANCE,...
                                           [PetersFuture(:,2),PetersFuture(:,4)]',...
                                           thresholds,q);
PPV_Armin1 = PPV( probsArmin1, prior_q);

plot_PPV( PPV_Armin1, q, prior_q, yearStart, dyearArmin1, ...
          strcat(path_pics,'Reproduce_ArminR0_sd',num2str(sigma),'PPV.png'))
plot_Detection( dyearArmin1, probsArmin1, 2017, q, strcat(path_pics,'Reproduce_ArminR1_sd',num2str(sigma),'.png'));

clear IMBALANCE

%save(strcat('workspaces/ReproduceArminsResults_sd',num2str(sigma),'.mat'))

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyze Peter data with my technique
q = 0.05;
prior_q = [0.5 0.3 0.1];
yearStart = 2017;

% Generate AR process for imbalance to compute the thresholds
IMBALANCE = generate_AR(Msim, T, rho, sigma);
thresholdsFabian = get_Thresholds(IMBALANCE, q);

% Generate AR process for imbalance for evaluation
IMBALANCE = generate_AR(Msim, T, rho, sigma);
[probs_myR0, dyear_myR0, probs_myArmR0] = get_Detection2( IMBALANCE,...
                                         [PetersFuture(:,2),PetersFuture(:,3)]',...
                                          thresholdsFabian, q);
% giddens structuration theory   
detect_years = [1 5 10 dyear_myR0];                         
prior = 0.1;
PPVtraj01_myR0 = PPV_trajectories( probs_myR0, [prior, prior prior prior], detect_years);
plot_PPV( PPVtraj01_myR0, q, yearStart+detect_years, yearStart, dyear_myR0, ...
          strcat( path_pics,'MyMethod_R0_sd',num2str(sigma),'PPVBayesianPrior',...
                  num2str(100*prior),'.png'));

prior = 0.5;
PPVtraj01_myR0 = PPV_trajectories( probs_myR0, [prior, prior prior prior], detect_years);
plot_PPV( PPVtraj01_myR0, q, yearStart+detect_years, yearStart, dyear_myR0, ...
          strcat( path_pics,'MyMethod_R0_sd',num2str(sigma),'PPVBayesianPrior',...
                  num2str(100*prior),'.png'));


                                      
PPV_myR0 = PPV( probs_myR0, prior_q);

plot_PPV( PPV_myR0, q, prior_q, yearStart, dyear_myR0, ...
          strcat(path_pics,'MyMethod_R0_sd',num2str(sigma),'PPV.png'))
plot_Detection( dyear_myR0, probs_myR0, yearStart, q, ...
                strcat(path_pics,'MyMethod_R0_sd',num2str(sigma),'.png'));
plot_Detection( dyear_myR0, probs_myArmR0, yearStart, q,...
                strcat(path_pics,'MyMethodArminsEval_R0_sd',num2str(sigma),'.png'));
            
[probs_myR1, dyear_myR1, probs_myArmR1] = get_Detection2( IMBALANCE,...
                                         [PetersFuture(:,2),PetersFuture(:,4)]',...
                                          thresholdsFabian, q);
PPV_myR1 = PPV( probs_myR1, prior_q);

plot_PPV( PPV_myR1, q, prior_q, yearStart, dyear_myR1, ...
          strcat(path_pics,'MyMethod_R1_sd',num2str(sigma),'PPV.png'))
plot_Detection( dyear_myR1, probs_myR1, yearStart, q, ...
                strcat(path_pics,'MyMethod_R1_sd',num2str(sigma),'.png'));
plot_Detection( dyear_myR1, probs_myArmR1, yearStart, q,...
                strcat(path_pics,'MyMethodArminsEval_R1_sd',num2str(sigma),'.png'));
           
%% %%%% Armins Method with my counting of false positives
[probs_myArminR0, dyear_myArminR0, probs_myArminR02] = get_Detection2( IMBALANCE,...
                                         [PetersFuture(:,2),PetersFuture(:,3)]',...
                                          repmat(-thresholdArmin0, [1 T]), q);
PPV_myArminR0 = PPV( probs_myArminR0, prior_q);
PPV_myArminR02 = PPV( probs_myArminR02, prior_q);

plot_PPV( PPV_myArminR0, q, prior_q, yearStart, dyear_myArminR0, ...
          strcat(path_pics,'MyMethodArmin_R0_sd',num2str(sigma),'PPV.png'))
plot_PPV( PPV_myArminR02, q, prior_q, yearStart, dyear_myArminR0, ...
          strcat(path_pics,'MyMethodArminArmin_R0_sd',num2str(sigma),'PPV.png'))
plot_Detection( dyear_myArminR0, probs_myArminR0, yearStart, q, ...
                strcat(path_pics,'MyMethodArmin_R0_sd',num2str(sigma),'.png'));
plot_Detection( dyear_myArminR0, probs_myArminR02, yearStart, q,...
                strcat(path_pics,'MyMethodArminArminsEval_R0_sd',num2str(sigma),'.png'));
            
[probs_myR1, dyear_myR1, probs_myArmR1] = get_Detection2( IMBALANCE,...
                                         [PetersFuture(:,2),PetersFuture(:,4)]',...
                                          thresholdArmin1, q);
PPV_myR1 = PPV( probs_myR1, prior_q);

plot_PPV( PPV_myR1, q, prior_q, yearStart, dyear_myR1, ...
          strcat(path_pics,'MyMethod_R1_sd',num2str(sigma),'PPV.png'))
plot_Detection( dyear_myR1, probs_myR1, yearStart, q, ...
                strcat(path_pics,'MyMethod_R1_sd',num2str(sigma),'.png'));
plot_Detection( dyear_myR1, probs_myArmR1, yearStart, q,...
                strcat(path_pics,'MyMethodArminsEval_R1_sd',num2str(sigma),'.png'));
%% %%%% Prediction bands
% Analyze Peter data with my technique
q = 0.05;
prior_q = [0.5 0.3 0.1];
yearStart = 2017;

% Generate AR process for imbalance to compute the thresholds
IMBALANCE = generate_AR(Msim, T, rho, sigma);
thresholdsFabian = get_Thresholds(IMBALANCE, q);

