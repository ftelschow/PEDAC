function [] = plot_Detection( probs, yearStart, quant, q, outputname )

BrightCol  = [[68 119 170];...    % blue
              [102 204 238];...   % cyan
              [34 136 51];...     % green
              [204 187 68];...    % yellow
              [238 102 119];...   % red
              [170 51 119];...    % purple
              [187 187 187]] / 255; % grey

years = yearStart + ( 1 : size( probs, 1 ) ) - 1;

figure(1), clf, hold on,
% Define size and location of the figure [xPos yPos WidthFig HeightFig]
WidthFig  = 550;
HeightFig = 450;
set( gcf, 'Position', [ 300 300 WidthFig HeightFig ] );
set( gcf, 'PaperPosition', [ 300 300 WidthFig HeightFig ] )
set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
set( groot, 'defaultLegendInterpreter', 'latex' );

line( years, probs( :, 1 ), 'Color', BrightCol( 5, : ), 'LineWidth', 2 )
line( years, probs( :, 2 ), 'Color', BrightCol( 1, : ), 'LineWidth', 2 )
plot( [ years( 1 ) - 1, years( end ) + 1 ], [ q, q ], 'k--' )
plot( [ years( 1 ) - 1, years( end ) + 1 ], [ 1 - q, 1 - q ], 'k--' )

for l = 1 : length( quant )
    [ ~, qyear ] = min( abs(  probs( :, 2 ) - quant(l) ) );

    if l == 2
        plot( [ years( qyear ), years( qyear ) ], [ -0.95, 2.95 ], 'k-', 'LineWidth', 2 )
    else
        plot( [ years( qyear ), years( qyear ) ], [ -0.95, 2.95 ], 'k--' )
    end
end
grid

h = xlabel("years");  set(h, 'Interpreter', 'latex');
h = ylabel("cummulated probability of detection");  set(h, 'Interpreter', 'latex');
h = legend('False Detection','True Detection','location','east');
set(h, 'Interpreter', 'latex');

xlim([years(1), years(end)])
ylim([0, 1])
set(gca, 'fontsize', 14);

set(gcf,'papersize',[12 12])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(outputname, '-dpng')
hold off
