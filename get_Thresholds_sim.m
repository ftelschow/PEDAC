function thresholds = get_Thresholds_sim( process, q )
% gets a threshold for a process, by specifying how large the rejection
% error should be until each time point.

% allocate the threshold vector
T = size( process, 1 );
thresholds = ones( [ 1 T ] ) * NaN;

% define false rejection
switch nargin
    case 1
        q = ( 0 : 1/T : 1 ) * 0.05;
        q = q( 2 : end );
end

q = [0, q];

N = size( process, 2 );

% save already detected processes
detected_past = false( [ 1 N ] );

  % Get cummulative probability of detecting an exeedance for all
  % thresholds
  for t = 1 : T
    if t == 1
        mProc = process( 1, : );
        thresholds( t ) = quantile( mProc, q( t ) );
        % save the rejected curves at this time
        tmp_detect = ( mProc <= thresholds( t ) );
    else
        mProc = min( process( 1:t, : ) );
        thresholds( t ) = quantile( mProc( :, ~detected_past ),...
                                    q( t ) - q( t - 1 ) );        
        
        tmp_detect = ( mProc <= thresholds( t ) ) | detected_past;
    end

%         mProc = mean( process( t, : ), 1 );
%         thresholds( t ) = quantile( mProc( ~detected_past ),...
%                                 q( t + 1 ) - q( t ) );        
%         % save the rejected curves at this time
%         tmp_detect = ( mProc <= thresholds( t ) ) | detected_past;

    % save the already rejected curves
    detected_past = detected_past | tmp_detect;
  end