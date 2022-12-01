%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%    This script merges simulation results if
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

%%%% load mat file containing the paths for output
load( 'paths.mat' )
cd(path_PEDAC)

Npar = 15;


for identifier = ["Detection_aCO2_IISA_all_base2000_direct",...
                  "Detection_aCO2_IISA_all_base2000_interpolation",...
                  "Detection_aCO2_IISA_all_base2010_interpolation"]
detect_year_tmp = [];
thresholds_year_tmp = [];

for i = 1:Npar-1
    load( strcat( path_work, identifier,'_',...
          num2str(i), ".mat" ) );
    if i~=Npar
       detect_year_tmp = cat( 3, detect_year_tmp,...
                              detect_year(:,:,1:5));
    else
        detect_year_tmp = cat( 3, detect_year_tmp,...
                               detect_year(:,:,1:end));
    end
   thresholds_year_tmp = cat( 3, thresholds_year_tmp,...
                          thresholds_year );
end


detect_year =  detect_year_tmp;
thresholds_year = thresholds_year_tmp;

save( strcat(path_work, identifier),...
        'detect_year', 'detectStart', 'category', 'sub_category',...
        'namesAlt', 'namesBAU', 'start_year_alt', 'start_year_bau',...
        'Nbau', 'Nalt', 'names_category', 'names_sub_category',...
        'thresholds_year' )
end