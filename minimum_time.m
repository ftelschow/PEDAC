function [ cut ] = minimum_time( data )
%UNTITLED SThis functions finds the minimal time point such that we have
% observations for all curves
%   Detailed explanation goes here
sD        = size(data);
Max_years = zeros([1 sD(2)]);
my        = sD(1);

for i = 2:size(data,2)
    tmp =  find(data(:,i)==0,1,'first');
    if isempty(tmp)
        Max_years(i) = my;
    else
        Max_years(i) =tmp-1;
    end
end
cut = min(Max_years(2:end));

end

