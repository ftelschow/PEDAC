%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%	This script interpolates the IISA data of future CO2 emissions
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

methodVec = ["direct" "continuous" "Hist2000"];

% load total past emission data as produced in 'Script_FitRafelskiModel.m'
% values are in ppm
load(strcat(path_data, 'Emissions_PastMontly.mat'))

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Read the IISA data and interplote it to monthly values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Interpolation of 2° scenarios
% IISA 2deg world scenarios for emissions in Mt CO2/year
IISA2deg_data = csvread(strcat(path_data,'IIASA_2PS.csv'),0,5);
% amount of different scenarios
N2deg =  size(IISA2deg_data,1);
% convert to ppm in C
IISA2deg_data = IISA2deg_data / 10^3 * gtonC_2_ppmC / C2CO2;
    
% data is given in 5 year intervals starting 2005 and ending 2100, put this
% as the first entry in the AR52deg_data matrix. Note that some scenarios
% are starting at 2010
IISA2deg_data = [ 2000:1:2100; IISA2deg_data ]';

% define container for AR52deg_data on a monthly scale
times             = 2000:1/12:2100;
data_IISA2deg      = NaN*zeros( [length(times) size(IISA2deg_data,2)] );
data_IISA2deg(:,1) = times;

% define container for the actual cut year of 2deg scenarios
cut_year2deg          = zeros([1 N2deg]);

clear times

% Interpolate the data to feed into the Joos Model
for scenarioNum = 1:N2deg
    % find the missing data
    Index_NoNmissing = IISA2deg_data(:,scenarioNum+1)~=0;
    
    data_tmp         = [ IISA2deg_data(Index_NoNmissing,1) ...
                         IISA2deg_data(Index_NoNmissing, scenarioNum+1) ];

    % determine the cut_year for the scenario
    cut_year2deg(scenarioNum) = min(data_tmp(:,1));
    
    % interpolate the data to monthly using linear interpolation
    data_tmp = interpolData( 12, data_tmp, 'linear');
    Ia = find(data_IISA2deg(:,1)==data_tmp(1,1));
    Ie = find(data_IISA2deg(:,1)==data_tmp(end,1));
    
    data_IISA2deg(Ia:Ie,scenarioNum+1) = data_tmp(:,2);    
end

figure(1), clf, hold on
set(gcf, 'Position', [ 300 300 1050 450]);
set(gcf,'PaperPosition', [ 300 300 1050 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
subplot(1,3,1), hold on
    plot(data_IISA2deg(:,1), data_IISA2deg(:,[false cut_year2deg==2000]), 'color',...
          BrightCol(1,:))
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
    grid
    xlim([1950, 2100])
    ylim([-5 10])
    h = title('IISA 2$^\circ$: 2000'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

subplot(1,3,2), hold on
    plot(data_IISA2deg(:,1), data_IISA2deg(:,[false cut_year2deg==2005]), 'color',...
          BrightCol(7,:))
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
    grid
    xlim([1950, 2100])
    ylim([-5 10])
    h = title('IISA 2$^\circ$: 2005'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

subplot(1,3,3), hold on
    plot(data_IISA2deg(:,1), data_IISA2deg(:,[false cut_year2deg==2010]), 'color',...
          BrightCol(2,:))
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
    grid
    xlim([1950, 2100])
    ylim([-5 10])
    h = title('IISA 2$^\circ$: 2010'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);
    
set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'Emissions_IISA2deg.png'), '-dpng')

%% %%%% Interpolation of 1.5° scenarios
% IISA 1.5° world scenarios for emissions in Mt CO2/year
IISA1deg_data = csvread(strcat(path_data,'IIASA_1PS.csv'),0,5);
% amount of different scenarios
N1deg =  size(IISA1deg_data,1);
% convert to ppm in C
IISA1deg_data = IISA1deg_data / 10^3 * gtonC_2_ppmC / C2CO2;
    
% data is given in 5 year intervals starting 2005 and ending 2100, put this
% as the first entry in the AR52deg_data matrix. Note that some scenarios
% are starting at 2010
IISA1deg_data = [ 2000:1:2100; IISA1deg_data ]';

% define container for AR52deg_data on a monthly scale
times             = 2000:1/12:2100;
data_IISA1deg      = NaN*zeros( [length(times) size(IISA1deg_data,2)] );
data_IISA1deg(:,1) = times;

% define container for the actual cut year of 2deg scenarios
cut_year1deg          = zeros([1 N1deg]);

clear times

% Interpolate the data to feed into the Joos Model
for scenarioNum = 1:N1deg
    % find the missing data
    Index_NoNmissing = IISA1deg_data(:,scenarioNum+1)~=0;
    data_tmp         = [ IISA1deg_data(Index_NoNmissing,1) ...
                         IISA1deg_data(Index_NoNmissing, scenarioNum+1) ];

    % determine the cut_year for the scenario
    cut_year1deg(scenarioNum) = min(data_tmp(:,1));
    
    % interpolate the data to monthly using linear interpolation
    data_tmp = interpolData( 12, data_tmp, 'linear');
    Ia = find(data_IISA1deg(:,1)==data_tmp(1,1));
    Ie = find(data_IISA1deg(:,1)==data_tmp(end,1));
    
    data_IISA1deg(Ia:Ie,scenarioNum+1) = data_tmp(:,2);    
end

figure(2), clf, hold on
set(gcf, 'Position', [ 300 300 1050 450]);
set(gcf,'PaperPosition', [ 300 300 1050 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
subplot(1,2,1), hold on
    plot(data_IISA1deg(:,1), data_IISA1deg(:,[false cut_year1deg==2000]), 'color',...
          BrightCol(1,:))
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
    grid
    xlim([1950, 2100])
    ylim([-5 10])
    h = title('IISA 1.5$^\circ$: 2000'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

subplot(1,2,2), hold on
    plot(data_IISA1deg(:,1), data_IISA1deg(:,[false cut_year1deg==2005]), 'color',...
          BrightCol(7,:))
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
    grid
    xlim([1950, 2100])
    ylim([-5 10])
    h = title('IISA 1.5$^\circ$: 2005'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'Emissions_IISA1deg.png'), '-dpng')


%% %%%% Interpolation of BAU scenarios
% IISA BAU world scenarios for emissions in Mt CO2/yr
IISAbau_data = csvread(strcat(path_data,'IIASA_BAU.csv'),0,5);
Nbau =  size(IISAbau_data,1);
% convert to ppm in C
IISAbau_data = IISAbau_data / 10^3 * gtonC_2_ppmC / C2CO2;

% data is given in 5 year intervals starting 2005 and ending 2100, put this
% as the first entry in the IISAbau_data matrix. Note that some scenarios
% are starting at 2010
IISAbau_data = [ 2000:1:2100; IISAbau_data ]';

% define container for AR5base_data on a monthly scale
times             = 2000:1/12:2100;
data_IISAbau      = NaN*zeros( [length(times) size(IISAbau_data,2)] );
data_IISAbau(:,1) = times;

% define container for the actual cut year of 2deg scenarios
cut_yearbau       = zeros([1 Nbau]);

clear times

% Interpolate the data to feed into the Joos Model
for scenarioNum = 1:Nbau
    % find the missing data
    Index_NoNmissing = IISAbau_data(:,scenarioNum+1)~=0;
    data_tmp         = [ IISAbau_data(Index_NoNmissing,1) ...
                         IISAbau_data(Index_NoNmissing, scenarioNum+1) ];

    % determine the cut_year for the scenario
    cut_yearbau(scenarioNum) = min(data_tmp(:,1));
    
    % interpolate the data to monthly using linear interpolation
    data_tmp = interpolData( 12, data_tmp, 'linear');
    Ia = find(data_IISAbau(:,1)==data_tmp(1,1));
    Ie = find(data_IISAbau(:,1)==data_tmp(end,1));
    
    data_IISAbau(Ia:Ie,scenarioNum+1) = data_tmp(:,2);    
end


figure(3), clf, hold on
set(gcf, 'Position', [ 300 300 1050 450]);
set(gcf,'PaperPosition', [ 300 300 1050 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
subplot(1,3,1), hold on
    plot(data_IISAbau(:,1), data_IISAbau(:,[false cut_yearbau==2000]), 'color',...
          BrightCol(1,:))
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
    grid
    xlim([1950, 2100])
    ylim([0 20])
    h = title('IISA BAU: 2000'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

subplot(1,3,2), hold on
    plot(data_IISAbau(:,1), data_IISAbau(:,[false cut_yearbau==2005]), 'color',...
          BrightCol(7,:))
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
    grid
    xlim([1950, 2100])
    ylim([0 20])
    h = title('IISA BAU: 2005'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

subplot(1,3,3), hold on
    plot(data_IISAbau(:,1), data_IISAbau(:,[false cut_yearbau==2010]), 'color',...
          BrightCol(2,:))
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(5,:), 'LineWidth', 1.5)
    grid
    xlim([1950, 2100])
    ylim([0 20])
    h = title('IISA BAU: 2010'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);
    hold off
set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(strcat(path_pics,'Emissions_IISAbau.png'), '-dpng')


% Clear workspace
clear Ia Ie data_tmp Index_NoNmissing IISAbau_data IISAbau_data ...
      scenarioNum IISA2deg_data IISA1deg_data h fig fig_pos

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Get baseline correspondence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load names of baseline model/scenario
T = readtable(strcat(path_data,'IIASA_BAU.csv'));
namesBAU = T(:, 1:2);
namesBAU = namesBAU.Variables;
namesBase = cell([1 size(namesBAU,1)]);
for k = 1:size(namesBAU,1)
    namesBase{k} = [namesBAU{k,1} ': ' namesBAU{k,2}];
end

% load names of 1°C model/scenario
T = readtable(strcat(path_data,'IIASA_1PS.csv'));
names1PS = T(:, 1:2);
names1PS = names1PS.Variables;
names1deg = cell([1 size(names1PS,1)]);
for k = 1:size(names1PS,1)
    names1deg{k} = [names1PS{k,1} ': ' names1PS{k,2}];
end

% load names of 2°C model/scenario
T = readtable(strcat(path_data,'IIASA_2PS.csv'));
names2PS = T(:, 1:2);
names2PS = names2PS.Variables;
names2deg = cell([1 size(names2PS,1)]);
for k = 1:size(names2PS,1)
    names2deg{k} = [names2PS{k,1} ': ' names2PS{k,2}];
end

% load names of meta data on baseline and scenario correspondence 
T = readtable(strcat(path_data,'IIASA_BAU_vs_ALT.csv'));
namesCor = T(:, [1:2,7]);
namesCor = namesCor.Variables;
clear T


% construct correspondence matrix for 1.5°
corBAU_1P5 = NaN*zeros([2, N1deg]);
corBAU_1P5(1,:) = 1:N1deg;
for k = 1:N1deg
    corBAU_1P5(2,k) = 1+findBase(names1PS(k,:), namesCor, namesBAU);
end

% construct correspondence matrix for 2°
corBAU_2 = NaN*zeros([2, N2deg]);
corBAU_2(1,:) = 1:N2deg;
for k = 1:N2deg
    corBAU_2(2,k) = 1+findBase(names2PS(k,:), namesCor, namesBAU);
end

clear namesCor namesBAU names2PS names1PS

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot emission curves versus each other
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WidthFig  = 550;
HeightFig = 450;
times = data_IISAbau(:,1);

for scn = 1:N1deg
    if(~isnan(corBAU_1P5(2,scn)))
        figure(2), clf, hold on
        set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');

        plot( times, data_IISAbau(:,corBAU_1P5(2,scn)),...
              'LineWidth', 1.5, 'Color', BrightCol(1,:))
        plot( times, data_IISA1deg(:,scn+1),...
              'LineWidth', 1.5, 'Color', BrightCol(3,:))

        h = xlabel('years');  set(h, 'Interpreter', 'latex');
        h = ylabel('CO2 emissions [ppm/year]');
        set(h, 'Interpreter', 'latex');
        ylim([-5 15])
        xlim([2005 2100])
        h = legend( namesBase{corBAU_1P5(2,scn)-1},...
                    names1deg{scn},...
                    'location','southwest');
        set(h, 'Interpreter', 'latex');    grid
        set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'emissions/IISASc_',num2str(scn),'_emissions_1deg.png'), '-dpng')
        hold off
    end
end

for scn = 1:N2deg
    if(~isnan(corBAU_2(2,scn)))
        figure(2), clf, hold on
        set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
        set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
        set(groot, 'defaultAxesTickLabelInterpreter','latex');
        set(groot, 'defaultLegendInterpreter','latex');

        plot( times, data_IISAbau(:,corBAU_2(2,scn)),...
              'LineWidth', 1.5, 'Color', BrightCol(1,:))
        plot( times, data_IISA2deg(:,scn+1),...
              'LineWidth', 1.5, 'Color', BrightCol(3,:))

        h = xlabel('years');  set(h, 'Interpreter', 'latex');
        h = ylabel('CO2 emissions [ppm/year]');
        set(h, 'Interpreter', 'latex');
        ylim([-5 15])
        xlim([2005 2100])
        h = legend( namesBase{corBAU_2(2,scn)-1},...
                    names2deg{scn},...
                    'location','southwest');
        set(h, 'Interpreter', 'latex');    grid
        set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'emissions/IISASc_',...
            num2str(scn),'_emissions_2deg.png'), '-dpng')
        hold off
    end
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Get the first values of the different scenarios
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diff_Bau1deg = NaN*zeros([1 length(cut_year1deg)]);

for i =1:length(cut_year1deg)
    cor = corBAU_1P5(2,i);
    if(~isnan(cor))
        diff_Bau1deg(i) = data_IISA1deg(data_IISA1deg(:,1)==...
            cut_year1deg(i),i+1) - ...
        data_IISAbau(data_IISAbau(:,1)==cut_yearbau(cor-1),cor); 
    end
end

plot(diff_Bau1deg)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot the AR5 data emission trajectories and compare to reported
%%%%    historical emission trajectories 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plot BAU emission scenario trajectories
for method = methodVec
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
        plot(data_tmp(:,1), data_tmp(:,2)/gtonC_2_ppmC, 'color', BrightCol(7,:))    
    end
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2)/gtonC_2_ppmC, 'color',...
          BrightCol(5,:), 'LineWidth', 1.5)

    xlim([1958 2102])
    h = title('AR5 BAU: CO2 emissions'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
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
for method = methodVec
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
        plot(data_tmp(:,1), data_tmp(:,2)/gtonC_2_ppmC, 'color', BrightCol(7,:))    
    end
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2)/gtonC_2_ppmC, 'color',...
          BrightCol(5,:), 'LineWidth', 1.5)

    xlim([1958 2102])
    h = title('AR5 2$^\circ$: CO2 emissions'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
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



 