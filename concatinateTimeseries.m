function catData = concatinateTimeseries(DATA1, DATA2, cut_time, method)
% This functions concatinates two time series at a specific time either
% continuously by shifting the second time series vertically or through
% glueing
%
%   Input:
%       DATA1 (N x 2 matrix): first column time points, second column data
%                             values
%       DATA2 (N x 2 matrix): first column time points, second column data
%                             values
%       cut_time (numeric):   time at which the time series needs to be
%                             concatinated. cut_time needs to be included
%                             in both DATA1(:,1) and DATA2(:,1)
%       method (string): 'continuous' for continuous glueing at cutting (default)
%                        'direct' for direct concatination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default method
if nargin < 4
    method = 'continuous';
end

if ~strcmp(method, "interpolation")
    % check that cut_year is contained in both time series
    if ~any(cut_time == DATA1(:,1)) && ~any(cut_time == DATA2(:,1))
        error('The cut_year variable must be contained in both DATA1(:,1) and DATA2(:,1)');
    end
end

switch method
    case "direct"
        % cut data1
        I1 = find(cut_time == DATA1(:,1))-1;
        I2 = find(cut_time == DATA2(:,1));
        catData = [DATA1(1:I1,:); DATA2(I2:end,:)];
    case "continuous"
        % cut data1
        I1 = find(cut_time == DATA1(:,1))-1;
        I2 = find(cut_time == DATA2(:,1));
        DATA2(:,2) = DATA2(:,2) + DATA1(I1,2) - DATA2(I2,2);
        catData = [DATA1(1:I1,:); DATA2(I2:end,:)];
    case "interpolation"
        I1 =  find(DATA1(:,1) == cut_time(1));
        I2 =  find(DATA2(:,1) == cut_time(2));
        catData = interpolData( 12, [DATA1(1:I1,:); DATA2(I2:end,:)], "linear" );
end




