function [ detect, threshold ] = DetectionDelay_SK( error_process,...
                                                    drift,...
                                                    q )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%     Estimates detection times using detection protocol of
%%%     Schwartzman Keeling et al.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input: 
%  error_process ( array T x Msim ):
%       Msim observations of a residual field
%
%  drift ( array T x 2 ):
%       drifts first column baseline, second column alternative
%  q ( array 1 x 2 ):
%       first column false detection rate, second column required
%       power. Default: [ 0.05 0.95 ].
%
% Output:
%  detect ( array 1 x T )
%       cdf of detection times
%  threshold ( numeric )
%       threshold used in the test.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set values
if nargin < 3
    q = [0.05 0.95];
end

%%%% calibrate method
% get thresholds controlling the false detections of the error process
thresholds = get_Thresholds( error_process, q( 1 ) );
% find true detections of the minimum statistic
true_detect = get_Detection( error_process, drift, thresholds, 1 );
% find time point such that calibration holds true
[ ~, qyear ] = min( abs( true_detect - q( 2 ) ) );
% get calibrated threshold
threshold = thresholds( qyear );

%%%% find detection times
detect = get_Detection( error_process, drift, threshold );