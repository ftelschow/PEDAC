function [] = plot_Emissions( data, cutyear, PastTotalCO2emission, method,...
                              ylims, titlestring, output, subset )         
                          
if nargin==8
	data    = data(:,logical([1 subset]));
    cutyear = cutyear(subset);
end

if nargin==7
    subset = NaN;
end
scnVec = 1:(size(data,2)-1);
gtonC_2_ppm = 1 / 2.124;
BrightCol   = [ [ 68 119 170 ];...    % blue
                [ 102 204 238 ];...   % cyan
                [ 34 136 51 ];...     % green
                [ 204 187 68 ];...    % yellow
                [ 238 102 119 ];...   % red
                [ 170 51 119 ];...    % purple
                [ 187 187 187 ] ] / 255; % grey

xvec       = [ 1975, 2000, 2025, 2050, 2075, 2100 ];
xtickcell  = { '1975', '2000', '2025', '2050', '2075', '2100' };
          
          
figure, clf, hold on
    set( gcf, 'Position', [ 300 300 450 400] );
    set( gcf,'PaperPosition', [ 300 300 450 400] )
    % change background color
    set( groot, 'defaultAxesTickLabelInterpreter', 'latex' );
    set( groot, 'defaultLegendInterpreter', 'latex' );
    for scn = scnVec( cutyear==2005 )
        if ~strcmp(method, "interpolation")
            cyear = cutyear(scn);
        else
            if cutyear(scn)~=2010
                cyear = [cutyear(scn)-5 cutyear(scn)];
            else
                cyear = [2009 2010];
            end
        end
        
        data_tmp = concatinateTimeseries( PastTotalCO2emission,...
                                          data(:, [1, scn+1]),...
                                          cyear,...
                                          method);
        plot(data_tmp(:,1), data_tmp(:,2)/gtonC_2_ppm, 'color', BrightCol(1,:), 'LineWidth', 1.1)    
    end
    
    for scn = scnVec( cutyear==2000 )
        if ~strcmp(method, "interpolation")
            cyear = cutyear(scn);
        else
            if cutyear(scn)~=2010
                cyear = [cutyear(scn)-5 cutyear(scn)];
            else
                cyear = [2009 2010];
            end
        end
        
        data_tmp = concatinateTimeseries( PastTotalCO2emission,...
                                          data(:, [1, scn+1]),...
                                          cyear,...
                                          method);
        plot(data_tmp(:,1), data_tmp(:,2)/gtonC_2_ppm, 'color', BrightCol(3,:), 'LineWidth', 1.1)    
    end
    
    for scn = scnVec( cutyear==2010 )
        if ~strcmp(method, "interpolation")
            cyear = cutyear(scn);
        else
            if cutyear(scn)~=2010
                cyear = [cutyear(scn)-5 cutyear(scn)];
            else
                cyear = [2005 2010];
            end
        end
        
        data_tmp = concatinateTimeseries( PastTotalCO2emission,...
                                          data(:, [1, scn+1]),...
                                          cyear,...
                                          method);
        plot(data_tmp(:,1), data_tmp(:,2)/gtonC_2_ppm, 'color', BrightCol(5,:), 'LineWidth', 1.1)    
    end
    
    plot( PastTotalCO2emission(:, 1 ), PastTotalCO2emission(:,2)/gtonC_2_ppm, 'color',...
          [0 0 0], 'LineWidth', 2)

    % Change axis style
    xlim([xvec(1)-10 xvec(end)])
    xticks(xvec)
    xticklabels(xtickcell)
    
    ylim( ylims )
%    h = title(titlestring); set(h, 'Interpreter', 'latex');
%    h = xlabel('year'); set(h, 'Interpreter', 'latex');
    h = ylabel('$\rm{CO}_2$ emissions [GtC/year]'); set(h, 'Interpreter', 'latex');
    set(gca, 'fontsize', 14);
    set( gca, 'color', [220, 220, 220]/255 )

    hold off
    grid

    set(gcf,'papersize',[12 12])
    fig = gcf;
    fig.InvertHardcopy = 'off';
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(output, '-dpng')