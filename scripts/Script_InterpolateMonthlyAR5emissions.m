%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%	This script interpolates the data by Ahmed of future CO2 emissions
%%%%    to monthly data and changes the units to ppm in C to be consistent
%%%%    with the input into the Rafelski model
%%%%
%%%%    Output: .mat file containing all interpolated BAU and 2deg
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

% load color data base for plots
load(strcat(path_data,'colors.mat'))

%%%% Constants
% convert constant from gton to ppm
gtonC_2_ppmC = 1/2.124; % Quere et al 2017
% convert C to CO2
C2CO2       = 44.01/12.011;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Read the AR5 data and interplote it to monthly values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AR5 2deg world scenarios for emissions in Mt CO2/year
AR52deg_data = csvread(strcat(path_data,'ar5_2deg_world_cO2_modFT.csv'),1,5);
% amount of different scenarios
N2deg =  size(AR52deg_data,1);
% convert to ppm in C
AR52deg_data = AR52deg_data / 10^3 * gtonC_2_ppmC;
    
% data is given in 5 year intervals starting 2005 and ending 2100, put this
% as the first entry in the AR52deg_data matrix. Note that some scenarios
% are starting at 2010
AR52deg_data = [ 2005:5:2100; AR52deg_data ]';

% define container for AR52deg_data on a monthly scale
times             = 2005:1/12:2100;
data_AR52deg      = NaN*zeros( [length(times) size(AR52deg_data,2)] );
data_AR52deg(:,1) = times;

% define container for the actual cut year of 2deg scenarios
cut_year2deg          = zeros([1 N2deg]);

clear times

% Interpolate the data to feed into the Joos Model
for scenarioNum = 1:N2deg
    % find the missing data
    Index_NoNmissing = AR52deg_data(:,scenarioNum+1)~=0;
    data_tmp         = [ AR52deg_data(Index_NoNmissing,1) ...
                         AR52deg_data(Index_NoNmissing, scenarioNum+1) ];

    % determine the cut_year for the scenario
    cut_year2deg(scenarioNum) = min(data_tmp(:,1));
    
    % interpolate the data to monthly using linear interpolation
    data_tmp = interpolData( 12, data_tmp, 'linear');
    Ia = find(data_AR52deg(:,1)==data_tmp(1,1));
    Ie = find(data_AR52deg(:,1)==data_tmp(end,1));
    
    data_AR52deg(Ia:Ie,scenarioNum+1) = data_tmp(:,2);    
end

%%%% Interpolation of BAU scenarios
% AR5 BAU world scenarios for emissions in Mt CO2/yr
AR5base_data = csvread(strcat(path_data,'ar5_baseline_world_cO2.csv'),1,5);
Nbase =  size(AR5base_data,1);
% convert to ppm in C
AR5base_data = AR5base_data / 10^3 * gtonC_2_ppmC;

% data is given in 5 year intervals starting 2005 and ending 2100, put this
% as the first entry in the AR52deg_data matrix. Note that some scenarios
% are starting at 2010
AR5base_data = [ 2005:5:2100; AR5base_data ]';

% define container for AR5base_data on a monthly scale
times             = 2005:1/12:2100;
data_AR5base      = NaN*zeros( [length(times) size(AR5base_data,2)] );
data_AR5base(:,1) = times;

% define container for the actual cut year of 2deg scenarios
cut_yearbase          = zeros([1 Nbase]);

clear times

% Interpolate the data to feed into the Joos Model
for scenarioNum = 1:Nbase
    % find the missing data
    Index_NoNmissing = AR5base_data(:,scenarioNum+1)~=0;
    data_tmp         = [ AR5base_data(Index_NoNmissing,1) ...
                         AR5base_data(Index_NoNmissing, scenarioNum+1) ];

    % determine the cut_year for the scenario
    cut_yearbase(scenarioNum) = min(data_tmp(:,1));
    
    % interpolate the data to monthly using linear interpolation
    data_tmp = interpolData( 12, data_tmp, 'linear');
    Ia = find(data_AR5base(:,1)==data_tmp(1,1));
    Ie = find(data_AR5base(:,1)==data_tmp(end,1));
    
    data_AR5base(Ia:Ie,scenarioNum+1) = data_tmp(:,2);    
end

% I2005 = find(cut_yearbase==2005)+1;
% I2010 = find(cut_yearbase==2010)+1;
% Stats_AR5base = [ [mean(AR5base_data(1,I2005)),...
%                    sqrt(var(AR5base_data(1,I2005)))];...
%                   [mean(AR5base_data(2,I2010)),...
%                    sqrt(var(AR5base_data(2,I2010)))] ]*10^3 * gtonC_2_ppmC

% Clear workspace
clear Ia Ie data_tmp Index_NoNmissing AR5base_data AR52deg_data ...
      scenarioNum

  
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Get vector of names of the models and BAU - 2deg correspondence
%%%%    and save everything as output mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Get names of the BAU / reference scenarios
T = readtable(strcat(path_data,'ar5_baseline_world_cO2.csv'));
namesBase_t = T(2:end, 1:2);
namesBase   = cell([1 size(namesBase_t,1)]);

for k = 1:size(namesBase_t,1)
    namesBase{k} = [namesBase_t.Var1{k} ': ' namesBase_t.Var2{k}];
end

%%%% Get names of the 2deg scenarios
T = readtable(strcat(path_data,'ar5_2deg_world_cO2_modFT.csv'));
names2deg_t = T(2:end, 1:2);
names2deg   = cell([1 size(names2deg_t,1)]);

for k = 1:size(names2deg_t,1)
    names2deg{k} = [names2deg_t.Var1{k} ': ' names2deg_t.Var2{k}];
end

clear k names2deg_t namesBase_t

deg_Base_correspondence = [ 1,2,5,8,9,10,11,1,2,3,5,6,7,8,9,10,11,12,... % AME Reference
                            repmat(13:21, [1 2]),... % AMPERE2-Base-FullTech-OPT
                            repmat(22:32, [1 4]),... % AMPERE3-Base
                            36,38, 35,36,38, repmat(33:39, [1 2]),... % EMF22 Reference
                            40,41,43,44,46,47,48,49,50,51,52,53,54,... % EMF27-Base-FullTech
                            40:54,... % EMF27-Base-FullTech
                            repmat(55:61, [1 2]),... % LIMITS-Base
                            repmat(62:64, [1 2])... % ROSE BAU DEF
                           ];

%%%% produce output .mat
save( strcat(path_data, 'Emissions_FutureAR5Montly.mat'),...
                                    'data_AR52deg', 'data_AR5base',...
                                    'names2deg', 'namesBase',...
                                    'cut_yearbase', 'cut_year2deg',...
                                    'deg_Base_correspondence')


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot the AR5 data emission trajectories and compare to reported
%%%%    historical emission trajectories 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load total past emission data as produced in 'Script_FitRafelskiModel.m'
load(strcat(path_data, 'Emissions_PastMontly.mat'))

%%%% Plot BAU emission scenario trajectories
for method = ["direct" "continuous"]
    figure, clf, hold on
    set(gcf, 'Position', [ 300 300 550 450]);
    set(gcf,'PaperPosition', [ 300 300 550 450])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');


    for scenarioNum = 1:Nbase
        data_tmp = concatinateTimeseries( PastTotalCO2emission,...
                                          data_AR5base(:, [1, scenarioNum+1]),...
                                          cut_yearbase(scenarioNum),...
                                          method);
        plot(data_tmp(:,1), data_tmp(:,2), 'color', BrightCol(7,:))    
    end
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
          BrightCol(5,:), 'LineWidth', 1.5)

    xlim([1763 2102])
    h = title('AR5 BAU: CO2 emissions'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('CO2 [ppm]'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);
    hold off

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('Emissions_AR5base_', method,'.png')), '-dpng')
end

%%%% Plot 2deg emission scenario trajectories
for method = ["direct" "continuous"]
    figure, clf, hold on
    set(gcf, 'Position', [ 300 300 550 450]);
    set(gcf,'PaperPosition', [ 300 300 550 450])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');


    for scenarioNum = 1:N2deg
        data_tmp = concatinateTimeseries( PastTotalCO2emission,...
                                          data_AR52deg(:, [1, scenarioNum+1]),...
                                          cut_year2deg(scenarioNum),...
                                          method);
        plot(data_tmp(:,1), data_tmp(:,2), 'color', BrightCol(7,:))    
    end
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
          BrightCol(5,:), 'LineWidth', 1.5)

    xlim([1763 2102])
    h = title('AR5 2$^\circ$: CO2 emissions'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('CO2 [ppm]'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);
    hold off

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,strcat('Emissions_AR52deg_', method,'.png')), '-dpng')
end

clear h fig fig_pos