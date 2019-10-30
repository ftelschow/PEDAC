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

%%%% set correct working directory
path      = '/home/drtea/Research/Projects/CO2policy/PEDAC';
path_pics = '/home/drtea/Research/Projects/CO2policy/pics/';
path_data = '/home/drtea/Research/Projects/CO2policy/PEDAC/data/';
cd(path)
clear path

%%%% load color data base for plots
load(strcat(path_data,'colors.mat'))
% choose main color scheme for this script 
ColScheme  = Categories;
clear Vibrant colMat Categories

%%%% Constants
% convert constant from gton to ppm
gtonC_2_ppmC = 1/2.124; % Quere et al 2017
% convert C to CO2
C2CO2       = 44.01/12.011;

%%%% set methods for concatenation of scenarios
methodVec = ["direct" "interpolation"];

%%%% load total past emission data as produced in 'Script_FitRafelskiModel.m'
% values are in ppm
load(strcat(path_data, 'Emissions_PastMontly.mat'))


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Get baseline correspondence and categories for the scenarios
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load names of baseline model/scenario
T = readtable( strcat( path_data,'IIASA_BAU.csv' ) );
namesBAU = T( :, 1 : 2 );
namesBAU = namesBAU.Variables;

% number of BAU sceanrios
Nbau = size( namesBAU, 1 );

% concatenate model and scenario name for legend entries
namesBase = cell( [ 1 Nbau ] );
for k = 1 : Nbau
    namesBase{ k } = strcat( namesBAU{ k, 1 }, ": ", namesBAU{ k, 2 } );
end

% load names of 1°C model/scenario
T = readtable( strcat( path_data,'IIASA_1PS.csv' ) );
names1PS = T( :, 1 : 2 );
names1PS = names1PS.Variables;
% number of 1.5°C scenarios
N1deg = size( names1PS, 1 );

% concatenate model and scenario name for legend entries
names1deg = cell( [ 1 N1deg ] );
for k = 1 : N1deg
    names1deg{ k } = strcat( names1PS{ k, 1 }, ": ", names1PS{ k, 2 } );
end

% load names of 2°C model/scenario
T = readtable( strcat( path_data, 'IIASA_2PS.csv' ) );
names2PS = T( :, 1 : 2 );
names2PS = names2PS.Variables;
% number of 2°C scenarios
N2deg = size( names2PS, 1 );

% concatenate model and scenario name for legend entries
names2deg = cell( [ 1 N2deg ] );
for k = 1 : N2deg
    names2deg{ k } = strcat( names2PS{ k, 1 }, ": ", names2PS{ k, 2 } );
end

% load names of meta data on baseline and scenario correspondence 
T = readtable( strcat( path_data, 'IIASA_BAU_vs_ALT.csv' ) );
namesCor = T( :, [ 1 : 2, [ 4 7 ] ] );
namesCor = namesCor.Variables;
namesCor2 = T( :, [ 1 : 2, [ 5 7 ] ] );
namesCor2 = namesCor2.Variables;
clear T

% construct correspondence matrix for 1.5°
corBAU_1P5         = NaN * zeros( [ 2, N1deg ] );
corBAU_1P5( 1, : ) = 1 : N1deg;
category_1P5       = NaN * zeros( [ 1, N1deg ] );

for k = 1 : N1deg
    [ val, type ] = findBase( names1PS( k, : ), namesCor, namesBAU );
    corBAU_1P5( 2, k ) = 1 + val;
    if strcmp( type, "Below 1.5C" )
        category_1P5( k ) = 1;
    elseif strcmp( type, "1.5C low overshoot" )
        category_1P5( k ) = 2;
    elseif strcmp( type, "1.5C high overshoot" )
        category_1P5( k ) = 3;
    elseif strcmp(type, "Lower 2C" )
        category_1P5( k ) = 4;
    elseif strcmp( type, "Higher 2C" )
        category_1P5( k ) = 5;
    elseif strcmp( type, "Above 2C" )
        category_1P5( k ) = 6;
    else
        category_1P5( k ) = NaN;
    end
end

% construct correspondence matrix for 2°
corBAU_2 = NaN * zeros( [ 2, N2deg ] );
corBAU_2( 1, : ) = 1 : N2deg;
category_2 = NaN * zeros( [ 1, N2deg ] );

for k = 1 : N2deg
    [ val, type ] = findBase( names2PS( k, : ), namesCor, namesBAU );
    corBAU_2( 2, k ) = 1 + val;
    if strcmp( type, "Below 1.5C" )
        category_2( k ) = 1;
    elseif strcmp( type, "1.5C low overshoot" )
        category_2( k ) = 2;
    elseif strcmp( type, "1.5C high overshoot" )
        category_2( k ) = 3;
    elseif strcmp( type, "Lower 2C" )
        category_2( k ) = 4;
    elseif strcmp( type, "Higher 2C" )
        category_2( k ) = 5;
    elseif strcmp( type, "Above 2C" )
        category_2( k ) = 6;
    else
        category_2( k ) = NaN;
    end
end

%%%% Get sub categories
sub_category_1P5 = NaN * zeros( [ 1, N1deg ] );
for k = 1 : N1deg
    [ ~, type ] = findBase( names1PS( k, : ), namesCor2, namesBAU );
    if strcmp( type, "Below 1.5C (I)" )
        sub_category_1P5( k ) = 1;
    elseif strcmp( type, "Below 1.5C (II)" )
        sub_category_1P5( k ) = 2;
    elseif strcmp( type, "Lower 1.5C low overshoot" )
        sub_category_1P5( k ) = 3;
    elseif strcmp(type, "Higher 1.5C low overshoot" )
        sub_category_1P5( k ) = 4;
    elseif strcmp( type, "Lower 1.5C high overshoot" )
        sub_category_1P5( k ) = 5;
    elseif strcmp( type, "Higher 1.5C high overshoot" )
        sub_category_1P5( k ) = 6;
    elseif strcmp( type, "Lower 2C" )
        sub_category_1P5( k ) = 7;
    elseif strcmp( type, "Higher 2C" )
        sub_category_1P5( k ) = 8;
    elseif strcmp( type, "Above 2C" )
        sub_category_1P5( k ) = 9;
    else
        sub_category_1P5( k ) = NaN;
    end
end

sub_category_2 = NaN * zeros( [ 1, N2deg ] );
for k = 1 : N2deg
    [ ~, type ] = findBase( names2PS( k, : ), namesCor2, namesBAU );
    if strcmp( type, "Below 1.5C (I)" )
        sub_category_2( k ) = 1;
    elseif strcmp( type, "Below 1.5C (II)" )
        sub_category_2( k ) = 2;
    elseif strcmp( type, "Lower 1.5C low overshoot" )
        sub_category_2( k ) = 3;
    elseif strcmp(type, "Higher 1.5C low overshoot" )
        sub_category_2( k ) = 4;
    elseif strcmp( type, "Lower 1.5C high overshoot" )
        sub_category_2( k ) = 5;
    elseif strcmp( type, "Higher 1.5C high overshoot" )
        sub_category_2( k ) = 6;
    elseif strcmp( type, "Lower 2C" )
        sub_category_2( k ) = 7;
    elseif strcmp( type, "Higher 2C" )
        sub_category_2( k ) = 8;
    elseif strcmp( type, "Above 2C" )
        sub_category_2( k ) = 9;
    else
        sub_category_2( k ) = NaN;
    end
end


clear namesCor namesBAU names2PS names1PS k val type

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Read the IISA data and interplote it to monthly values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Interpolation of 2° scenarios
% IISA 2deg world scenarios for emissions in Mt CO2/year
IISA2deg_data = csvread( strcat( path_data, 'IIASA_2PS.csv' ), 0, 5 );
% amount of different scenarios
N2deg =  size( IISA2deg_data, 1 );
% convert to ppm in C
IISA2deg_data = IISA2deg_data / 10^3 * gtonC_2_ppmC / C2CO2;
    
% data is given in 5 year intervals starting 2005 and ending 2100, put this
% as the first entry in the AR52deg_data matrix. Note that some scenarios
% are starting at 2010
IISA2deg_data = [ 2000 : 1 : 2100; IISA2deg_data ]';

% define container for AR52deg_data on a monthly scale
times              = 2000 : 1/12 : 2100;
data_IISA2deg      = NaN*zeros( [ length( times ) size( IISA2deg_data, 2 ) ] );
data_IISA2deg( : , 1 ) = times;

% define container for the actual cut year of 2deg scenarios
cut_year2deg = zeros( [ 1 N2deg ] );

clear times

% Interpolate the data to feed into the Joos Model
for scn = 1:N2deg
    % find the missing data
    Index_NoNmissing = IISA2deg_data(:,scn+1)~=0;
    
    data_tmp         = [ IISA2deg_data(Index_NoNmissing,1) ...
                         IISA2deg_data(Index_NoNmissing, scn+1) ];

    % determine the cut_year for the scenario
    cut_year2deg(scn) = min(data_tmp(:,1));
    
    % interpolate the data to monthly using linear interpolation
    data_tmp = interpolData( 12, data_tmp, 'linear');
    Ia = find(data_IISA2deg(:,1)==data_tmp(1,1));
    Ie = find(data_IISA2deg(:,1)==data_tmp(end,1));
    
    data_IISA2deg(Ia:Ie,scn+1) = data_tmp(:,2);    
end

figure(1), clf, hold on
set(gcf, 'Position', [ 300 300 1050 450]);
set(gcf,'PaperPosition', [ 300 300 1050 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

subplot( 1, 3, 1 ), hold on
    for scn = 1 : N2deg
        if cut_year2deg( scn ) == 2000 && ~isnan( category_2( scn ) )
           plot( data_IISA2deg( :, 1 ), data_IISA2deg( :, scn + 1 ),...
                 'color', ColScheme( category_2( scn ), : ) )
        end
    end
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(4,:), 'LineWidth', 2)
    grid
    xlim([1990, 2100])
    ylim([-5 10])
    h = title('IISA 2$^\circ$: 2000'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

subplot(1,3,2), hold on
    for scn = 1 : N2deg
        if cut_year2deg( scn ) == 2005 && ~isnan( category_2( scn ) )
           plot( data_IISA2deg( :, 1 ), data_IISA2deg( :, scn + 1 ),...
                 'color', ColScheme( category_2( scn ), : ) )
        end
    end
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(4,:), 'LineWidth', 2)
    grid
    xlim([1990, 2100])
    ylim([-5 10])
    h = title('IISA 2$^\circ$: 2005'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

subplot(1,3,3), hold on
    for scn = 1 : N2deg
        if cut_year2deg( scn ) == 2010 && ~isnan( category_2( scn ) )
           plot( data_IISA2deg( :, 1 ), data_IISA2deg( :, scn + 1 ),...
                 'color', ColScheme( category_2( scn ), : ) )
        end
    end
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(4,:), 'LineWidth', 2)
    grid
    xlim([1990, 2100])
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
for scn = 1:N1deg
    % find the missing data
    Index_NoNmissing = IISA1deg_data(:,scn+1)~=0;
    data_tmp         = [ IISA1deg_data(Index_NoNmissing,1) ...
                         IISA1deg_data(Index_NoNmissing, scn+1) ];

    % determine the cut_year for the scenario
    cut_year1deg(scn) = min(data_tmp(:,1));
    
    % interpolate the data to monthly using linear interpolation
    data_tmp = interpolData( 12, data_tmp, 'linear');
    Ia = find(data_IISA1deg(:,1)==data_tmp(1,1));
    Ie = find(data_IISA1deg(:,1)==data_tmp(end,1));
    
    data_IISA1deg(Ia:Ie,scn+1) = data_tmp(:,2);    
end

figure(2), clf, hold on
set(gcf, 'Position', [ 300 300 1050 450]);
set(gcf,'PaperPosition', [ 300 300 1050 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
subplot(1,2,1), hold on
    for scn = 1 : N1deg
        if cut_year1deg( scn ) == 2000 && ~isnan( category_1P5( scn ) )
           plot( data_IISA1deg( :, 1 ), data_IISA1deg( :, scn + 1 ),...
                 'color', ColScheme( category_1P5( scn ), : ) )
        end
    end
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(4,:), 'LineWidth', 2)
    grid
    xlim([1990, 2100])
    ylim([-5 10])
    h = title('IISA 1.5$^\circ$: 2000'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

subplot(1,2,2), hold on
    for scn = 1 : N1deg
        if cut_year1deg( scn ) == 2005 && ~isnan( category_1P5( scn ) )
           plot( data_IISA1deg( :, 1 ), data_IISA1deg( :, scn + 1 ),...
                 'color', ColScheme( category_1P5( scn ), : ) )
        end
    end
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(4,:), 'LineWidth', 2)
    grid
    xlim([1990, 2100])
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
for scn = 1:Nbau
    % find the missing data
    Index_NoNmissing = IISAbau_data(:,scn+1)~=0;
    data_tmp         = [ IISAbau_data(Index_NoNmissing,1) ...
                         IISAbau_data(Index_NoNmissing, scn+1) ];

    % determine the cut_year for the scenario
    cut_yearbau(scn) = min(data_tmp(:,1));
    
    % interpolate the data to monthly using linear interpolation
    data_tmp = interpolData( 12, data_tmp, 'linear');
    Ia = find(data_IISAbau(:,1)==data_tmp(1,1));
    Ie = find(data_IISAbau(:,1)==data_tmp(end,1));
    
    data_IISAbau(Ia:Ie,scn+1) = data_tmp(:,2);    
end


figure(3), clf, hold on
set(gcf, 'Position', [ 300 300 1050 450]);
set(gcf,'PaperPosition', [ 300 300 1050 450])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
subplot(1,3,1), hold on
    plot(data_IISAbau(:,1), data_IISAbau(:,[false cut_yearbau==2000]), 'color',...
          BrightCol(7,:))
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(4,:), 'LineWidth', 2)
    grid
    xlim([1990, 2100])
    ylim([0 20])
    h = title('IISA BAU: 2000'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

subplot(1,3,2), hold on
    plot(data_IISAbau(:,1), data_IISAbau(:,[false cut_yearbau==2005]), 'color',...
          BrightCol(7,:))
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(4,:), 'LineWidth', 2)
    grid
    xlim([1990, 2100])
    ylim([0 20])
    h = title('IISA BAU: 2005'); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);

subplot(1,3,3), hold on
    plot(data_IISAbau(:,1), data_IISAbau(:,[false cut_yearbau==2010]), 'color',...
          BrightCol(7,:))
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
      BrightCol(4,:), 'LineWidth', 2)
    grid
    xlim([1990, 2100])
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
clear Ia Ie data_tmp Index_NoNmissing ...
      scn h fig fig_pos

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Detection start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    
detectStart1 = zeros([1 size(IISA1deg_data,2)-1]);
vale1 = zeros([1 size(IISA1deg_data,2)-1]);
detectStart2 = zeros([1 size(IISA2deg_data,2)-1]);
vale2 = zeros([1 size(IISA2deg_data,2)-1]);

for k= 2:size(IISA1deg_data,2)
    if ~isnan(corBAU_1P5(2,k-1))
        tmp = find(IISA1deg_data(:,k) - IISAbau_data(:,corBAU_1P5(2,k-1))~=0);
        tmp2 = IISA1deg_data(:,k) - IISAbau_data(:,corBAU_1P5(2,k-1));

        detectStart1(k-1) = IISA1deg_data(tmp(1),1);

        vale1(k-1) = tmp2(tmp(1));
    else
        detectStart1(k-1) = NaN;
        vale1(k-1) = NaN;
    end
end

close all
figure(1)
plot(detectStart1)
figure(2)
plot(vale1)

% manual calibration
detectStart1(16) = 2005;
detectStart1(17:18) = 2020;
detectStart1(19:23) = 2015;
detectStart1(24:26) = 2020;
detectStart1(29:30) = detectStart1(29:30)+5;
detectStart1(40) = 2010;
detectStart1(41) = 2010;
detectStart1(42) = 2020;
detectStart1(43:47) = 2010;
detectStart1(48) = 2010;
detectStart1(49) = 2010;
detectStart1(50:52) = 2010;
detectStart1(53:55) = 2015;
detectStart1(59) = 2020;
detectStart1(64:66) = 2015;
detectStart1(67:69) = 2010;
detectStart1(70) = 2015;
detectStart1(76:80) = 2015;
detectStart1(81:84) = 2010;


for k= 2:size(IISA2deg_data,2)
    if ~isnan(corBAU_2(2,k-1))
        tmp = find(IISA2deg_data(:,k) - IISAbau_data(:,corBAU_2(2,k-1))~=0);
        tmp2 = IISA2deg_data(:,k) - IISAbau_data(:,corBAU_2(2,k-1));

        detectStart2(k-1) = IISA2deg_data(tmp(1),1);

        vale2(k-1) = tmp2(tmp(1));
    else
        detectStart2(k-1) = NaN;
        vale2(k-1) = NaN;
    end
end
% manual calibration
detectStart2(21:22) = 2020;
detectStart2(25:26) = 2005;
detectStart2(34:35) = 2020;
detectStart2(36:37) = 2010;
detectStart2(39)    = 2010;
detectStart2(44:49) = 2010;
detectStart2(55:58) = 2010;
detectStart2(64)    = 2010;
detectStart2(69)    = 2010;
detectStart2(70)    = 2020;
detectStart2(71:90) = 2010;
detectStart2(92:93) = 2010;
detectStart2(94:97) = 2015;
detectStart2(101)    = 2020;
detectStart2(124:126) = 2015;
detectStart2(127:128) = 2010;
detectStart2(129:130) = 2020;
detectStart2(131:132) = 2010;
detectStart2(133:146) = 2015;
detectStart2(146:159) = 2015;
detectStart2(160:171) = 2010;


close all
figure(1)
plot(detectStart2)
figure(2)
plot(vale2)

%%%% produce output .mat
save( strcat(path_data, 'Emissions_IIASA_FutureMontly.mat'),...
                        'data_IISA2deg', 'data_IISAbau', 'data_IISA1deg',...
                        'N1deg', 'N2deg', 'Nbau', 'category_1P5', 'category_2',...
                        'sub_category_1P5', 'sub_category_2',...
                        'cut_yearbau', 'cut_year1deg', 'cut_year2deg',...
                        'corBAU_1P5', 'corBAU_2', 'detectStart1', 'detectStart2',...
                        'namesBase', 'names1deg', 'names2deg')
                   

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
              'LineWidth', 1.5, 'Color', BrightCol(5,:))
        plot( times, data_IISA1deg(:,scn+1),...
              'LineWidth', 1.5, 'Color', BrightCol(3,:), 'LineStyle', '--')
        plot( [detectStart1(scn) detectStart1(scn)], [-10 20], 'k--')
        h = legend( namesBase{corBAU_1P5(2,scn)-1},...
                    names1deg{scn},...
                    'location','southwest');
        set(h, 'Interpreter', 'latex');
        h = xlabel('years');  set(h, 'Interpreter', 'latex');
        h = ylabel('CO2 emissions [ppm/year]');
        set(h, 'Interpreter', 'latex');
        ylim([-5 15])
        xlim([2000 2100])
        grid
        set(gca, 'fontsize', 14);

        set(gcf,'papersize',[12 12])
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(strcat(path_pics,'emissionsPairs/IISASc_',num2str(scn),'_emissions_1deg.png'), '-dpng')
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
              'LineWidth', 1.5, 'Color', BrightCol(5,:))
        plot( times, data_IISA2deg(:,scn+1),...
              'LineWidth', 1.5, 'Color', BrightCol(3,:), 'LineStyle', '--')
        plot( [detectStart2(scn) detectStart2(scn)], [-10 20], 'k--')

        h = xlabel('years');  set(h, 'Interpreter', 'latex');
        h = ylabel('CO2 emissions [ppm/year]');
        set(h, 'Interpreter', 'latex');
        ylim([-5 15])
        xlim([2000 2100])
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
        print(strcat(path_pics,'emissionsPairs/IISASc_',...
            num2str(scn),'_emissions_2deg.png'), '-dpng')
        hold off
    end
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot the IIASA data emission trajectories and compare to reported
%%%%    historical emission trajectories 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plot BAU emission scenario trajectories
for method = methodVec
    plot_Emissions( data_IISAbau, cut_yearbau, PastTotalCO2emission, method,...
                    [ 0, 20 ], 'IISA BAU: CO2 emissions',...
                    strcat(path_pics,strcat('emissions/Emissions_IISAbau_',...
                    method,'.png')))
end
close all

%%%% Plot 2deg emission scenario trajectories
for method = methodVec
    plot_Emissions( data_IISA2deg, cut_year2deg, PastTotalCO2emission, method,...
                    [ -5, 10 ], 'IISA 2$^\circ$: CO2 emissions',...
                    strcat(path_pics,strcat('emissions/Emissions_IISA2deg_',...
                    method,'.png')))
end
close all
%%%% Plot 1deg emission scenario trajectories
for method = methodVec
    plot_Emissions( data_IISA1deg, cut_year1deg, PastTotalCO2emission, method,...
                    [ -5, 10 ], 'IISA 1$^\circ$: CO2 emissions',...
                    strcat( path_pics, strcat( 'emissions/Emissions_IISA1deg_',...
                    method, '.png' ) ) )
end
close all
clear h fig fig_pos