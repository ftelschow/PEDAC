% getSourceData.m
%
% Author: Julia Dohner
% April 17, 2018
%
% Provides record of fossil fuel emissions and land use emissions for the 
% time frame 1765 to present.
 
function [ff,LU] = getSourceData(year,ts,FF_data,LU_data)
 
% interpolate to monthly
FFmo(:,1) = (year(1):(1/ts):FF_data(end,1))';
FFmo(:,2) = (interp1(FF_data(:,1),FF_data(:,2),FFmo(:,1)));
 
LUmo(:,1) = (year(1):(1/ts):LU_data(end,1))';
LUmo(:,2) = interp1(LU_data(:,1),LU_data(:,2),LUmo(:,1));
 
% shorten datasets to match time frame of year vector
FF_start = find(FFmo(:,1) == year(1));
FF_end = find(FFmo(:,1) == year(end));
ff = FFmo(FF_start:FF_end,:);
 
LU_start = find(LUmo(:,1) == year(1));
LU_end = find(LUmo(:,1) == year(end));
LU = LUmo(LU_start:LU_end,:);


