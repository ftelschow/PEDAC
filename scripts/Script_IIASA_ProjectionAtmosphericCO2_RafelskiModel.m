%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%	This script predicts the future atmospheric CO2 from AR5 emission
%%%%    scenarios using the Rafelski model.
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

% convert C to CO2
C2CO2       = 44.01/12.011;

% load color data base for plots
load(strcat(path_data,'colors.mat'))

% methods to be used for emission concationation
methodVec = ["direct" "interpolation"];

% load the true past emission data. Note it must be in ppm C as input of
% Rafelski! 
load(strcat(path_data, 'Emissions_PastMontly.mat'))

% load the predicted future emission data . Note it must be in ppm C as input of
% Rafelski, but it is CO2 right now!  
load( strcat(path_data, 'Emissions_IIASA_FutureMontly.mat'))


%%%% Specify the optimisation periods of Rafelski model, which needs to be
%%%% loaded
% years used for LSE
opt_years = [1765 2016];

% load fit of Rafelski model from the historical record of atmospheric CO2
load(strcat(path_data, 'Fit_RafelskiModelAtmosphericCO2', num2str(opt_years(1)),'_',...
      num2str(opt_years(2)),'.mat'))
  
% output figure width and height
WidthFig  = 550;
HeightFig = 450;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot the IISA data emission trajectories and compare to reported
%%%%    historical emission trajectories 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop over different ways to glue past emissions with future emissions
for method = methodVec
    %%%% initialize containers for atmospheric CO2 predicted in the different
    % models
    times = PastTotalCO2emission(1,1):1/12:2100;
    Nt    = length(times);

    COa_base      = zeros([Nt size(data_IISAbau,2)])*NaN;
    COa_base(:,1) = times;

    COa_1deg      = zeros([Nt size(data_IISA1deg,2)])*NaN;
    COa_1deg(:,1) = times;    
    
    COa_2deg      = zeros([Nt size(data_IISA2deg,2)])*NaN;
    COa_2deg(:,1) = times;

    %%%% use Rafelski model to get the COa curves for BAU scenarios
    for scn = 2:size(data_IISAbau,2)
        if ~strcmp(method, "interpolation")
            cyear = cut_yearbau(scn-1);
        else
            if cut_yearbau(scn-1)~=2010
                cyear = [cut_yearbau(scn-1)-5 cut_yearbau(scn-1)];
            else
                cyear = [2009 2010];
            end
        end
        % concatenate past and future emissions to yield a full world
        % future history
        tmp = concatinateTimeseries( PastTotalCO2emission,...
                                     data_IISAbau(:,[1 scn]),...
                                     cyear,...
                                     method);
        % remove NaNs. This is neccessary since the Rafelski model somehow
        % predicts to far... (ask Ralph about it. Is it a bug?)
        tmp = tmp(~isnan(tmp(:,2)),:);
        % predict atmospheric CO2 using rafelski model
        tmp = JoosModelFix( tmp, xopt );
        COa_base(1:size(tmp,1),scn) = tmp(:,2);
    end
    
    %%%% use Rafelski model to get the COa curves for 2° scenarios
    for scn = 2:size(data_IISA1deg,2)
        if ~strcmp(method, "interpolation")
            cyear = cut_year1deg(scn-1);
        else
            if cut_year1deg(scn-1)~=2010
                cyear = [cut_year1deg(scn-1)-5 cut_year1deg(scn-1)];
            else
                cyear = [2009 2010];
            end
        end
        % concatenate past and future emissions to yield a full world
        % future history
        tmp = concatinateTimeseries( PastTotalCO2emission,...
                                     data_IISA1deg(:,[1 scn]),...
                                     cyear,...
                                     method);

        % predict atmospheric CO2 using rafelski model
        tmp = JoosModelFix( tmp, xopt );
        COa_1deg(1:size(tmp,1),scn) = tmp(:,2);
    end
    
    %%%% use Rafelski model to get the COa curves for 2° scenarios
    for scn = 2:size(data_IISA2deg,2)
        if ~strcmp(method, "interpolation")
            cyear = cut_year2deg(scn-1);
        else
            if cut_year2deg(scn-1)~=2010
                cyear = [cut_year2deg(scn-1)-5 cut_year2deg(scn-1)];
            else
                cyear = [2009 2010];
            end
        end
        % concatenate past and future emissions to yield a full world
        % future history
        tmp = concatinateTimeseries( PastTotalCO2emission,...
                                     data_IISA2deg(:,[1 scn]),...
                                     cyear,...
                                     method);

        % predict atmospheric CO2 using rafelski model
        tmp = JoosModelFix( tmp, xopt );
        COa_2deg(1:size(tmp,1),scn) = tmp(:,2);
    end
    %%%% produce output .mat
    save( strcat(path_data, 'AtmosphericCO2_IISAMontly_',method,'.mat'),...
                            'COa_base', 'COa_2deg', 'COa_1deg',...
                            'cut_yearbau', 'cut_year2deg', 'cut_year1deg',...
                            'corBAU_1P5', 'corBAU_2', 'category_1P5', 'category_2')
end

% Clear workspace
clear tmp Nt CO2a

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot the predicted atmospheric CO2 records 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
% loop over methods
for method = methodVec
    % load the correct atmospheric CO2 data
    load( strcat(path_data, 'AtmosphericCO2_IISAMontly_',method,'.mat'))
    
    % plot all the BAU scenarios
    figure(1), clf, hold on
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    % plot the actual curves
    for scn = 2:size(COa_base,2)
        plot(COa_base(:, 1 ), COa_base(:, scn ),...
                  'LineWidth', 1.5)
    end
    xlim([2000 2102])
    ylim([250 1150])
    h = xlabel('years');  set(h, 'Interpreter', 'latex');
    h = ylabel('C02 [ppm]');  set(h, 'Interpreter', 'latex');
    h = title('Predictions for atmospheric CO2 for BAU scenarios');  set(h, 'Interpreter', 'latex');
    line([2005 2005],[-10, 1e4],'Color','black','LineStyle','--')
    grid
    set(gca, 'fontsize', 14);

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,strcat('AtmosphericCO2_IISA_base_',method,'.png')), '-dpng')
    hold off

    sty = ["-.", "-.", "-", "--", "-", "--"];

    % plot all the 2° scenarios
    figure(2), clf, hold on
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');

    for scn = 2:size(COa_2deg,2)
        if ~isnan(category_2(scn-1))
            plot( COa_2deg( :, 1 ), COa_2deg( :, scn ),...
                  'Color',  BrightCol(category_2(scn-1),:),...
                  'LineStyle', "-",...
                  'LineWidth', 1.5)
        end
    end
    line([2005 2005],[-10, 1e4],'Color','black','LineStyle','--')
    xlim([2000 2102])
    ylim([250 550])
    h = title('Predictions for atmospheric CO2 for 2$^\circ$ scenarios');  set(h, 'Interpreter', 'latex');
    h = xlabel('years');  set(h, 'Interpreter', 'latex');
    h = ylabel('C02 [ppm]');  set(h, 'Interpreter', 'latex');
    grid
    set(gca, 'fontsize', 14);

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,strcat('AtmosphericCO2_IISA_2deg_',method,'.png')), '-dpng')
    hold off
    
    
    % plot all the 1.5° scenarios
    figure(3), clf, hold on
    set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
    set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');

    for scn = 2:size(COa_1deg,2)
        if ~isnan(category_1P5(scn-1))
            plot( COa_1deg( :, 1 ), COa_1deg( :, scn ),...
                  'Color',  BrightCol(category_1P5(scn-1),:),...
                  'LineStyle', "-",...
                  'LineWidth', 1.5)
        end
    end
    line([2005 2005],[-10, 1e4],'Color','black','LineStyle','--')
    xlim([2000 2102])
    ylim([250 550])
    h = title('Predictions for atmospheric CO2 for 1.5$^\circ$ scenarios');  set(h, 'Interpreter', 'latex');
    h = xlabel('years');  set(h, 'Interpreter', 'latex');
    h = ylabel('C02 [ppm]');  set(h, 'Interpreter', 'latex');
    grid
    set(gca, 'fontsize', 14);

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(strcat(path_pics,strcat('AtmosphericCO2_IISA_1deg_',method,'.png')), '-dpng')
    hold off
end

% %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%    Checking Ralph's claim of not being sensitive to parameters
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Specify the optimisation periods of Rafelski model, which needs to be
% %%%% loaded
% % years used for LSE
% opt_years = [1958 2005];
% 
% % load fit of Rafelski model from the historical record of atmospheric CO2
% load(strcat(path_data, 'Fit_RafelskiModelAtmosphericCO2', num2str(opt_years(1)),'_',...
%       num2str(opt_years(2)),'.mat'))
%   
%   