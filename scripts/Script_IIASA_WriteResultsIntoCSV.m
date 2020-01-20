%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%        Writing the results from Script_IIASA_Detection.m into
%%%%        a .csv table
%%%%
%%%%        Authors: Fabian Telschow
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear workspace
clear all
close all

% set correct working directory
path1     = strcat( '/home/drtea/Research/Projects/CO2policy/' );
path      = strcat( path1, 'PEDAC' );
path_pics = strcat( path1, 'pics/' );
path_data = strcat( path1, 'PEDAC/data/' );
cd( path )
clear path

method = "interpolation";
quants = [ 0.05, 0.5, 0.95 ];

%% %%% load namesCor
load( strcat( path_data, 'Emissions_IIASA_FutureMontly.mat' ) )


%% 
for base = [ "2000", "2005", "2010" ]
    % load the results of detection
    load( strcat( 'workspaces/Detection_aCO2_IISA_base', base, '_', method,...
                  '.mat' ) )
    % compute quantiles of detection year        
    quants_detect_year = get_Quants( detect_year, quants );

    % output file name
    outname = strcat( path_data, 'SI/Table_detectionResults_base',...
                      num2str( base ), '.csv' );

    % generate table with correct entries
    T = table( 'Size', [ size(namesAlt,2) 8],...
               'VariableTypes', { 'string', 'string', 'string',...
                                  'string', 'double', 'double', 'double', ...
                                  'double' }, ...
               'VariableNames', { 'model', 'scenario', 'category',...
                                  'baseline', 'quantile5',...
                                  'quantile50', 'quantile95', 'threshold' } );
    for scn = 1:size(namesAlt,2)
        
            alt = strsplit( namesAlt{ scn }, ': ' );
            bau = strsplit( namesBAU{ corBAU( scn ) }, ': ' );
            
            T( scn, 1 ) = { alt( 1 ) };
            T( scn, 2 ) = { alt( 2 ) };
            T( scn, 3 ) = { bau( 2 ) } ;
            T( scn, 4 ) = { category( scn ) };
    end
    T( :, 5:7 ) = array2table( quants_detect_year' );
    T( :, 8 ) = array2table( round( thresholds_year' / C2CO2 *...
                                    gtonC_2_ppm, 2 ) );
    
    % sort alphabetically
    T = sortrows( T );
    % write T into a .csv file
    writetable( T, outname )

end


