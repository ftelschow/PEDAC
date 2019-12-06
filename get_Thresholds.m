function thresholds = get_Thresholds( process, q, method )
switch nargin
    case 1
        q = 0.05;
        method = 'minimum';
    case 2
        method = 'minimum';
end

N = size( process, 2 );

% allocate the threshold vector
T = size( process, 1 );
thresholds = ones( [ 1 T ] ) * NaN;

if strcmp( method, 'minimum' )
  % Get cummulative probability of detecting an exeedance for all
  % thresholds
  for t = 1:T
    if t == 1
        mProc = process( 1, : );
    else
        mProc = min( process( 1:t, : ) );
    end
    thresholds( t )  = quantile( mProc, q );
  end
else
  % Get cummulative probability of detecting an exeedance for all
  % thresholds
  for t = 1:T
    if t == 1
        mProc = process( 1, : );
    else
        v         = ones( [ t N ] ) * NaN;
        v( 1, : ) = process( 1, : );
        for tt = 2:t
            v( tt, : ) = mean( process( 1:tt, : ) );
        end
        mProc = min( v );
    end
    thresholds( t ) = quantile( mProc, q );
  end   
end