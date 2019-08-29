function [times] = getMonthVectorFromYears(Ia, Ie)

% construct the monthly time vector
times = [];
for i = Ia:(Ie-1)
    times = [times, double(i) + double(0:1/12:(1-1/12))];
end
times = [times, Ie];