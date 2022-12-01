%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%	This script produces a .mat containing the paths for local use
%%%%
%%%%    Output: paths.mat
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear workspace
clear all
close all

server = 0;
% set correct working directory
if ~server
    path_PEDAC = '~/Seafile/Code/PEDAC';
else
    path_PEDAC = '~/projects/PEDAC';
end

path_pics  = strcat(path_PEDAC, '/pics/');
path_data  = strcat(path_PEDAC, '/data/');
path_work  = strcat(path_PEDAC, '/workspaces/');

save( strcat( path_PEDAC, '/scripts/paths.mat' ), 'path_PEDAC', 'path_pics', ...
                                        'path_data', 'path_work' )