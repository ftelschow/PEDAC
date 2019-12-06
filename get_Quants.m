function det_quants = get_Quants( detect_year, quants )
% this function computes the quantiles of a detection times

sDetect = size( detect_year );
N = size( detect_year, 2 );

if sDetect( 1 ) == 1
    det_quants = ones( [ length( quants ) 1 ] );
    for iq = 1 : length( quants )
        q = quants( iq );
        [ ~, qyear ] = min( abs( detect_year - q ) );
        det_quants( iq ) = qyear;
    end
else
    det_quants = ones( [ length( quants ) N ] );
    for scn = 1 : N
        for iq = 1 : length( quants )
            q = quants( iq );

            [ ~, qyear ] = min( abs( detect_year( :, scn ) - q ) );

            det_quants( iq, scn ) = qyear;
        end
    end
end

