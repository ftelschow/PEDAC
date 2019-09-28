

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Plot atmospheric CO2 and growth of AR models versus its baseline
load(strcat('workspaces/JoosModel_xopt_AR5_pchip_',glue,'.mat'))

T = readtable(strcat(path_data,'ar5_baseline_world_cO2.csv'));
namesBase_t = T(2:end, 1:2);
namesBase   = cell([1 size(namesBase_t,1)]);

for k = 1:size(namesBase_t,1)
    namesBase{k} = [namesBase_t.Var1{k} ': ' namesBase_t.Var2{k}];
end

T = readtable(strcat(path_data,'ar5_2deg_world_cO2_modFT.csv'));
names2deg_t = T(2:end, 1:2);
names2deg   = cell([1 size(names2deg_t,1)]);

for k = 1:size(names2deg_t,1)
    names2deg{k} = [names2deg_t.Var1{k} ': ' names2deg_t.Var2{k}];
end

clear k names2deg_t namesBase_t
%%
clear fig ans COa scale h fig gig_pos HeightFig WidthFig scale...
      fig_pos fval exitflag figure_counter Index_NoNmissing scenarioNum...
      output tmp fval path_data path_pics exitflag

save( )