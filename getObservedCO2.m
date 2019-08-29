% getObservedCO2.m
%
% Author: Julia Dohner, adapted from Lauren Rafelski
% April 17, 2018
% 
% Outputs the observed annual increase in atmospheric CO2 (dtdelpCO2a_obs),
% the observed increase each year from the preindustrial CO2 value
% (dpCO2a_obs) and the observed CO2 record (CO2a_obs). The data is from a
% merged record of the Mauna Loa CO2 record, the South Pole observatory
% record, and ice core record from Law Dome. See README.txt for more
% detailed description.
        
function [dtdelpCO2a_obs,dpCO2a_obs,CO2a_obs] = getObservedCO2(ts,start_year,end_year)

load dataMlospo_meure2011.mat % loads mlospo_meure data vector

% processing data for CO2 up to 2011
% loads in mlospo_meure (4427x2), 1640-Feb 2010, monthly
meure_years = mlospo_meure(:,1);
mlostart = mlospo_meure(1,1);
mloend = mlospo_meure(end,1);
meure_CO2 = mlospo_meure(:,2);

% create new time array
meureInterp_years = mlostart:1/ts:mloend;

% spline interpolation
meureInterp_CO2 = interp1(meure_years,meure_CO2,meureInterp_years,'spline');

MLOSPOiceinterp(:,1) = meureInterp_years; % ends Feb 2010
MLOSPOiceinterp(:,2) = meureInterp_CO2;

%% everything past where co2_2011 ends

% starts at year 1, incremented by year
CO2_2016 = csvread('mergedCO2_2016.csv');
year_2016 = (CO2_2016(1,1):1/ts:CO2_2016(end,1))';
CO2_2016mo(:,1) = year_2016;
CO2_2016mo(:,2) = (interp1(CO2_2016(:,1),CO2_2016(:,2),year_2016)).';

% last point in MLOSPOiceinterp is 2010+(3/24) (i.e. Feb 2010)
% first point in CO2_2016mo is 2010 + 2/12 (i.e. March 2010)
% joinYear is 2010 + 2/12 (i.e. March 2010)
joinYear = MLOSPOiceinterp(end,1)+(1/24); 
i = find(CO2_2016mo(:,1) >= joinYear,1);
year_full(:,1) = [MLOSPOiceinterp(:,1) ; CO2_2016mo(i:end,1)];

% starts at beginning of MLOSPO, ends at end of 2016 record
co2_combine(:,1) = year_full; 
co2_combine(:,2) = [MLOSPOiceinterp(1:end,2); CO2_2016mo(i:end,2)];


%% Calculate CO2 increment with monthly resolution, in ppm/year

for n = ((ts/2)+1):(length(co2_combine)-(ts/2))
    dtdelpCO2a_obs(n,1) = co2_combine(n,1);
    dtdelpCO2a_obs(n,2) = co2_combine(n+(ts/2),2) - co2_combine(n-(ts/2),2);
end

i1 = find(co2_combine(:,1) >= start_year,1);
j1 = find(co2_combine(:,1) >= end_year);
co2_trunc = co2_combine(i1:j1,:);

%% Calculate change in atmospheric concentration
dpCO2a_obs(:,1) = co2_trunc(:,1); 
dpCO2a_obs(:,2) = co2_trunc(:,2)-co2_trunc(1,2);

n = find(co2_combine(:,1) >= end_year,1);
m = find(co2_combine(:,1) >= start_year,1);
CO2a_obs = co2_combine(m:n,:);