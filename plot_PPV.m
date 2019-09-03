function [] = plot_PPV(PPV, q, prior_p, yearStart, dyear, outputname)
BrightCol  = [[68 119 170];...    % blue
              [102 204 238];...   % cyan
              [34 136 51];...     % green
              [204 187 68];...    % yellow
              [238 102 119];...   % red
              [170 51 119];...    % purple
              [187 187 187]]/255; % grey
years = yearStart + (1:size(PPV,1))-1;

figure(1), clf, hold on,
% Define size and location of the figure [xPos yPos WidthFig HeightFig]
WidthFig  = 600;
HeightFig = 400;
set(gcf, 'Position', [ 300 300 WidthFig HeightFig]);
set(gcf,'PaperPosition', [ 300 300 WidthFig HeightFig])
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

for i = 1:length(prior_p)
    line(years, PPV(:,i), 'LineWidth', 2, 'Color', BrightCol(i,:))
end
grid

plot([years(1)-1, years(end)+1], [q, q], 'k--')
plot([years(1)-1, years(end)+1], [1-q, 1-q], 'k--')
plot([years(dyear), years(dyear)], [-0.95, 2.95], 'k--')

h = xlabel("years");  set(h, 'Interpreter', 'latex');
h = ylabel("positive predictive value");  set(h, 'Interpreter', 'latex');
h = legend(num2str(prior_p'),'location','east');
set(h, 'Interpreter', 'latex');

xlim([years(1), years(end)])
ylim([0, 1])
set(gca, 'fontsize', 14);

set(gcf,'papersize',[8 6])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(outputname, '-dpng')
hold off
