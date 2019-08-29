% getSourceData.m
%
% Author: Fabian Telschow based on Julia Dohner
% April 17, 2018
%
% Provides record of fossil fuel emissions and land use emissions for the 
% time frame 1765 to present.
% data needs to have in the first column years as an entry 

function [DATAmo] = getSourceData_fabian( ts, DATA, method )
if nargin < 3
    method = 'pchip';
end
% construct the monthly time vector
times = [];
for i = 1:(length(DATA(:,1))-1)
    gap = (DATA(i+1,1)-DATA(i,1));
    times = [times, double(DATA(i,1)) + double(0:1/ts:((1-1/ts)))];
    for j = 1:gap-1
        times = [times, double(DATA(i,1))+j + double(0:1/ts:((1-1/ts)))];
    end
end
times = [times, DATA(end,1)];

% allocate the monthly output
DATAmo = zeros([length(times)' 2]);

% interpolate to monthly
DATAmo(:,1) = times';
DATAmo(:,2) = interp1(DATA(:,1), DATA(:,2), DATAmo(:,1), method);


