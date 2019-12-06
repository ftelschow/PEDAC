function detect = get_Detection( error_process, drift, thresholds,...
                                      ptwise )

if nargin < 4
    ptwise = 0;
end
                                  
N = size( error_process, 2 );
T = size( error_process, 1 );

if all( size( thresholds ) == [ 1 1 ] )
    thresholds = repmat( thresholds, [ 1 T ] );
elseif all( size( thresholds ) ~= [ 1 T ] )
    error( "thresholds need to be either a numeric of a vector of size [1 T]." )
end

detect  = NaN * zeros( [ 1 T ] );

process_shift = error_process + drift( :, 2 ) - drift( :, 1 );

% save already detected processes
detected_past = false( [ 1 N ] );

for t = 1:T
    if t == 1
        mProc = process_shift( 1, : );
    else
        mProc = min( process_shift( 1:t, : ) );
    end
    
    if ptwise
        tmp_detect = ( mProc < thresholds( t ) );
    else
        tmp_detect = ( mProc < thresholds( t ) ) | detected_past;
        % update already detected processes
        detected_past = detected_past | tmp_detect;
    end
    
    detect( t ) = sum( tmp_detect ) / N;
end