%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%	This script interpolates the IISA data of future CO2 emissions
%%%%    to monthly data and changes the units to ppm in C to be consistent
%%%%    with the input into the Rafelski model
%%%%
%%%%    Output: .mat file containing all interpolated BAU and alternative
%%%%            emission scenarios
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% clear workspace and figures
clear all
close all

%%%% load mat file containing the paths for output
load( 'paths.mat' )
cd(path)
clear path
%%%% load color data base for plots
load( strcat( path_work, 'colors.mat' ) )

%%%% Constants
% convert constant from gton to ppm
gtonC_2_ppm = 1/2.124; % Quere et al 2017
% convert C to CO2
C2CO2       = 3.664; %44.01/12.011;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Get baseline correspondence and categories for the scenarios
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Get names for BAU models and alternative scenarios
% load names of 1.5°C/2.0°C model/scenario
T = readtable( strcat( path_data, 'IAM/IIASA_all.csv' ) );
names1 = T( :, 1 : 2 );
names1 = names1.Variables;
% number of 1.5°C scenarios
Nalt = size( names1, 1 );

% concatenate model and scenario name for legend entries
namesAlt = cell( [ 1 Nalt ] );
for k = 1 : Nalt
    namesAlt{ k } = strcat( names1{ k, 1 }, ": ", names1{ k, 2 } );
end

% load names of baseline model/scenario
T = readtable( strcat( path_data, 'IAM/IIASA_BAU.csv' ) );
names2 = T( :, 1 : 2 );
names2 = names2.Variables;

% number of BAU sceanrios
Nbau = size( names2, 1 );

% concatenate model and scenario name for legend entries
namesBAU = cell( [ 1 Nbau ] );
for k = 1 : Nbau
    namesBAU{ k } = strcat( names2{ k, 1 }, ": ", names2{ k, 2 } );
end

%%%% Find corresponding BAU for each alternative scenario from meta data
%%%% information and save the category the model belongs to
% load names of meta data on baseline and scenario correspondence 
T = readtable( strcat( path_data, 'IAM/IIASA_BAU_vs_ALT.csv' ) );
namesCor = T( :, [ 1 : 2, [ 4 5 7 ] ] );
namesCor = namesCor.Variables;
clear T

% construct correspondence matrix for 1.5°
corBAU         = NaN * zeros( [ 1, Nalt ] );
category       = [ ];
sub_category   = [ ];

for k = 1 : Nalt
    val  = findBase( names1( k, : ), namesCor( :, 1 : 2 ) );
    val2 = findBase( namesCor( val, [1 5] ), names2( :, 1 : 2 ) );
    % save the index for the correspondence
    corBAU( k ) = val2;
    % find category and sub categories
    cat = namesCor( val, 3 );
    category = [ category, string( cat{ 1 } ) ];
    cat = namesCor( val, 4 );
    sub_category = [ sub_category, string( cat{ 1 } ) ];
end

names_category     = unique( category );
names_category     = names_category( [ 4 2 1 6 5 3 7 ] );
names_sub_category = unique( sub_category );
names_sub_category = names_sub_category( [ 2 7 4 6 3 8 5 1 9  ] );

% ahmed categories
category_a = [ repmat( 1, [ 1 85 ] ), repmat( 2, [ 1 173 ] ) ];

% remove data were no BAU is in the data set
I = ~isnan( corBAU );

category     = category( I );
sub_category = sub_category( I );
category_a   = category_a( I );
corBAU       = corBAU( I );
namesAlt     = namesAlt( I );
Nalt         = sum( I );

clear cat k names1 names2 namesCor val val2

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Read the IISA data and interplote it to monthly values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Interpolation of 2° scenarios
% IISA 2deg world scenarios for emissions in Mt CO2/year
alt_data = csvread( strcat( path_data, 'IAM/IIASA_all.csv' ), 0, 5 );
% convert to ppm in C
alt_data = alt_data / 10^3 * gtonC_2_ppm / C2CO2;
alt_data = alt_data( I, : );

% define container for AR52deg_data on a monthly scale
times             = 2000 : 1/12 : 2100;
data_alt          = NaN * zeros( [ length( times ) Nalt+1 ] );
data_alt( : , 1 ) = times;

% define container for the actual start year
start_year_alt = zeros( [ 1 Nalt ] );
times2 = 2000:1:2100;


% Interpolate the data to feed into the Joos Model
for scn = 1 : Nalt
    % find the missing data
    I = alt_data( scn, : ) ~= 0;
    
    data_tmp = [ times2( I ); alt_data( scn, I ) ]';

    % determine the cut_year for the scenario
    start_year_alt( scn ) = min( data_tmp( :, 1 ) );
    
    % interpolate the data to monthly using linear interpolation
    data_tmp = interpolData( 12, data_tmp, 'linear');
    Ia = find( data_alt( :, 1 ) == data_tmp( 1, 1 ) );
    Ie = find( data_alt( :, 1 ) == data_tmp( end, 1 ) );
    
    data_alt(Ia:Ie,scn+1) = data_tmp(:,2);    
end

%% %%%% Interpolation of BAU scenarios
% IISA BAU world scenarios for emissions in Mt CO2/yr
bau_data = csvread( strcat( path_data, 'IAM/IIASA_BAU.csv' ), 0, 5 );
Nbau =  size( bau_data, 1 );
% convert to ppm in C
bau_data = bau_data / 10^3 * gtonC_2_ppm / C2CO2;

% data is given in 5 year intervals starting 2005 and ending 2100, put this
% as the first entry in the IISAbau_data matrix. Note that some scenarios
% are starting at 2010
bau_data = [ 2000:1:2100; bau_data ]';

% define container for AR5base_data on a monthly scale
times         = 2000:1/12:2100;
data_bau      = NaN * zeros( [ length( times ) size( bau_data, 2 ) ] );
data_bau(:,1) = times;

% define container for the actual cut year of 2deg scenarios
start_year_bau       = zeros([1 Nbau]);

clear times times2

% Interpolate the data to feed into the Joos Model
for scn = 1:Nbau
    % find the missing data
    Index_NoNmissing = bau_data( :, scn + 1 )~=0;
    data_tmp         = [ bau_data( Index_NoNmissing, 1 ) ...
                         bau_data( Index_NoNmissing, scn + 1 ) ];

    % determine the cut_year for the scenario
    start_year_bau( scn ) = min( data_tmp( :, 1 ) );
    
    % interpolate the data to monthly using linear interpolation
    data_tmp = interpolData( 12, data_tmp, 'linear');
    Ia = find( data_bau( :, 1 ) == data_tmp( 1, 1 ) );
    Ie = find( data_bau( :, 1 ) == data_tmp( end, 1 ) );
    
    data_bau( Ia:Ie, scn + 1 ) = data_tmp( :, 2 );    
end

clear Ia Ie scn alt_data bau_data data_tmp Index_NoNmissing I

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Detection start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    
detectStart = NaN * zeros( [ 1 Nalt ] );

% 24, 26, 34, 62, 63, 91, 121, 190, 191, 194, 210, 211?
I2005 = [ 16 95:96 ];
I2010 = [ 1:15 17:18 27:31 33:42 57:61 65:69 71:90 93:94 97:105 106:120 ...
          122:139 141:159 160:162 188:189 192:193 208 212:224 ];
I2015 = [ 19:23 43:46 51:56 62:64 70 121 163:166 167:168 181:187 194:207 209:211 ...
          225:226 ];
I2020 = [ 24:26 32 47:50 91:92 140 ...
          169:180 190:191];
      
detectStart(I2005) = 2005;
detectStart(I2010) = 2010;
detectStart(I2015) = 2015;
detectStart(I2020) = 2020;

clear I2005 I2010 I2015 I2020


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Critical policy hit ( maximum of emission )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    
maxEmission = NaN * zeros( [ 2 Nalt ] );

for scn = 1 : Nalt
    [ val, I ] = max( data_alt( :, scn + 1 ) );
    maxEmission( :, scn ) = [ data_alt( I, 1 ) val];
end

clear scn
%%%% produce output .mat
save( strcat( path_data, 'Emissions_IIASA_FutureMontly.mat' ) )


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot emission curves versus each other
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WidthFig  = 550;
HeightFig = 450;
times = data_alt( :, 1 );

for scn = 1:Nalt
        figure(2), clf, hold on
        set( gcf, 'Position', [ 300 300 WidthFig HeightFig ] );
        set( gcf, 'PaperPosition', [ 300 300 WidthFig HeightFig ] )
        set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
        set( groot, 'defaultLegendInterpreter', 'latex' );

        plot( times, data_bau( :, corBAU( scn ) + 1 ),...
              'LineWidth', 1.5, 'Color', BrightCol( 5, : ) )
        plot( times, data_alt( :, scn + 1 ),...
              'LineWidth', 1.5, 'Color', BrightCol( 3, : ), 'LineStyle', '--')
        plot( [detectStart( scn ) detectStart( scn ) ], [ -10 20 ], 'k--')
        h = legend( namesBAU{ corBAU( scn ) },...
                    namesAlt{ scn },...
                    'location','southwest' );
        set( h, 'Interpreter', 'latex' );
        h = xlabel( 'years');  set( h, 'Interpreter', 'latex' );
        h = ylabel( 'CO2 emissions [ppm/year]' );
        set( h, 'Interpreter', 'latex' );
        ylim( [ -5 15 ] )
        xlim( [ 2000 2100 ] )
        grid
        set( gca, 'fontsize', 14 );

        set( gcf, 'papersize', [ 12 12 ] )
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
        print( strcat( path_pics, 'emissions/emissionsPairs/IISASc_' ,...
               num2str( scn ), '_emissionPairs.png' ), '-dpng')
        hold off
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Plot the IIASA data emission trajectories and compare to reported
%%%%    historical emission trajectories 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set methods for concatenation of scenarios
methodVec = [ "direct" "interpolation" ];
%%%% load total past emission data as produced in 'Script_FitRafelskiModel.m'
% values are in ppm
load( strcat( path_data, 'Emissions_PastMontly.mat' ) )
PastTotalCO2emission = PastTotalCO2emissionScripps;

%%%% Plot BAU emission scenario trajectories
for method = methodVec
    plot_Emissions( data_bau, start_year_bau, PastTotalCO2emission, method,...
                    [ 0, 40 ], 'IISA BAU: CO2 emissions',...
                    strcat( path_pics,strcat( 'emissions/Emissions_IISAbau_',...
                    method,'.png') ) )
end
close all

%%%% Plot 2deg emission scenario trajectories
for method = methodVec
    I = [true ( strcmp( category, names_category( 4 ) ) ...
                | strcmp( category, names_category( 5 ) ) ...
                | strcmp( category, names_category( 6 ) ) ) ];
    plot_Emissions( data_alt( :, I ), start_year_alt( I( 2:end ) ),...
                    PastTotalCO2emission, method,...
                    [ -5, 40 ], 'IISA 2$^\circ$: CO2 emissions',...
                    strcat( path_pics, strcat( 'emissions/Emissions_IISA2deg_',...
                    method,'.png' ) ) )
end
close all
%%%% Plot 1deg emission scenario trajectories
for method = methodVec
    I = [ true ( strcmp( category, names_category( 1 ) )...
               | strcmp( category, names_category( 2 ) )...
               | strcmp( category, names_category( 3 ) ) ) ];
    plot_Emissions( data_alt( :, I ), start_year_alt( I( 2:end ) ),...
                    PastTotalCO2emission, method,...
                    [ -5, 40 ], 'IISA 1.5$^\circ$: CO2 emissions',...
                    strcat( path_pics, strcat( 'emissions/Emissions_IISA1deg_',...
                    method, '.png' ) ) )
end
close all
clear h fig fig_pos