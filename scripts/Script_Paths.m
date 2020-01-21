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
    path      = '/home/drtea/Research/Projects/CO2policy/PEDAC';
    path_pics = '/home/drtea/Research/Projects/CO2policy/pics/';
    path_data = '/home/drtea/Research/Projects/CO2policy/PEDAC/data/';
    path_work = '/home/drtea/Research/Projects/CO2policy/PEDAC/workspaces/';
else
    path      = '~/projects/PEDAC';
    path_pics = '~/projects/PEDAC/pics/';
    path_data = '~/projects/PEDAC/data/';
    path_work = '~/projects/PEDAC/workspaces/';
end

save( strcat( path, '/scripts/paths.mat' ), 'path', 'path_pics', ...
                                        'path_data', 'path_work' )