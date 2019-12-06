function [] = plot_Detection_drifts( drift_base, drift_alter, yearStart, quant, q, outputname )

Categories  = [ [ 102 204 238 ];...    % cyan
                [ 0 119 187 ];...      % blue
                [ 34 34 85 ];...       % darkblue
                [ 238 119 51 ];...     % orange
                [ 204 51 17 ];...      % red
                [ 136 34 85 ];...      % purple
                [ 187 187 187 ] ] / 255;  % grey


years = yearStart + ( 1 : size( probs, 1 ) ) - 1
            
        figure( 2 ), clf, hold on
        WidthFig  = 500 * 1.1;
        HeightFig = 400 * 1.1;
        set( gcf, 'Position', [ 300 300 WidthFig HeightFig ] );
        set( gcf, 'PaperPosition', [ 300 300 WidthFig HeightFig ] )
        set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
        set( groot, 'defaultLegendInterpreter', 'latex' );
                plot( years, drift_base, 'LineWidth', 1.5, 'Color',...
                      ColScheme( 1, : ) )
                plot( years, drift_alter, 'LineWidth', 1.5, 'Color',...
                      ColScheme( 3, : ) )
                plot( [ years( dyear ) years( dyear ) ], [ -2000, 2000 ],...
                      'k--' )
                title( 'atmospheric CO2' )
        h = xlabel( 'years' );  set( h, 'Interpreter', 'latex' );
        h = ylabel( 'atmospheric CO2 [ppm/year]' );
        set( h, 'Interpreter', 'latex' );
        ylim( [ 350 550 ] )
        xlim( [ 2005 2050 ] )
        h = legend( namesBAU{ corBAU( scn ) },...
                    namesAlt{ scn },...
                    'location', 'northwest' );
        set( h, 'Interpreter', 'latex' );
        grid
        set( gca, 'fontsize', 14 );

        set( gcf, 'papersize', [ 12 12 ] )
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [ fig_pos( 3 ) fig_pos( 4 ) ];
        print( strcat( path_pics, 'detect_', method, '/Sc_', num2str( scn ),...
               'DetectionTimes_aCO2_IISA_base2010_', method, '.png' ),...
               '-dpng' )
        hold off
