%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%	This script produces a color data base for color blind and grey
%%%%    scale compatible figures, which is used in the plots.
%%%%
%%%%    Output: colors.mat
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear workspace
clear all
close all

%%%% load mat file containing the paths for output
load( 'paths.mat' )
cd(path)
clear path

%%%% standard color scheme for color blind and grey scale figures, cf.
%%%% 'https://personal.sron.nl/~pault/'
BrightCol  = [ [ 68 119 170 ];...    % blue
               [ 102 204 238 ];...   % cyan
               [ 34 136 51 ];...     % green
               [ 204 187 68 ];...    % yellow
               [ 238 102 119 ];...   % red
               [ 170 51 119 ];...    % purple
               [ 187 187 187 ] ] / 255; % grey
          
Vibrant    = [ [ 0 119 187 ];... % blue
               [ 51 187 238 ];...% cyan
               [ 0 153 136 ];... % teal
               [ 238 119 51 ];...% orange
               [ 204 51 17 ];... % red
               [ 238 51 119 ];...% magenta
               [ 187 187 187 ]...% grey
               ] / 255;
          
Categories  = [ [ 102 204 238 ];...    % cyan
                [ 0 119 187 ];...      % blue
                [ 34 34 85 ];...       % darkblue
                [ 238 119 51 ];...     % orange
                [ 204 51 17 ];...      % red
                [ 136 34 85 ];...      % purple
                [ 187 187 187 ] ] / 255;  % grey

colMat = Vibrant( [ 1 3 4 5 ], : );

save( strcat( path_data, 'colors.mat' ), 'BrightCol', 'Vibrant', ...
                                     'colMat', 'Categories' )