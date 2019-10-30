function [] = plot_Emissions( data, cutyear, PastTotalCO2emission, method,...
                              ylims, titlestring, output, subset )         
                          
if nargin==8
	data    = data(:,logical([1 subset]));
    cutyear = cutyear(subset);
end

if nargin==7
    subset = NaN;
end

BrightCol  = [[68 119 170];...    % blue
              [102 204 238];...   % cyan
              [34 136 51];...     % green
              [204 187 68];...    % yellow
              [238 102 119];...   % red
              [170 51 119];...    % purple
              [187 187 187]]/255; % grey

figure, clf, hold on
    set(gcf, 'Position', [ 300 300 550 450]);
    set(gcf,'PaperPosition', [ 300 300 550 450])
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    for scn = 1:(size(data,2)-1)
        if ~strcmp(method, "interpolation")
            cyear = cutyear(scn);
            if cutyear(scn)==2005
                colo  = BrightCol(7,:);
            elseif cutyear(scn)==2000
                colo  = BrightCol(1,:);
            else
                colo  = BrightCol(2,:);                
            end
        else
            if cutyear(scn)~=2010
                cyear = [cutyear(scn)-5 cutyear(scn)];
                if cutyear(scn)==2005
                    colo  = BrightCol(7,:);
                else
                    colo  = BrightCol(1,:);
                end
            else
                cyear = [2009 2010];
                colo  = BrightCol(2,:);
            end
        end
        
        data_tmp = concatinateTimeseries( PastTotalCO2emission,...
                                          data(:, [1, scn+1]),...
                                          cyear,...
                                          method);
        plot(data_tmp(:,1), data_tmp(:,2), 'color', colo, 'LineWidth', 1.5)    
    end
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2), 'color',...
          BrightCol(4,:), 'LineWidth', 2)

    xlim( [ 1958 2102 ] )
    ylim( ylims )
    h = title(titlestring); set(h, 'Interpreter', 'latex');
    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('ppm'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);
    hold off

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(output, '-dpng')