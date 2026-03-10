function generatePointDensityHeatmap(data, run, conditionName, roiRect, outputDir, runDisplay)
    if nargin < 6
        runDisplay = '';
    end
    
    if isfield(data.(run).(conditionName), 'StableGridPoints')
        gridData = data.(run).(conditionName).StableGridPoints;
        disp('Using STABLE grid points for density heatmap');
    else
        disp('No stable grid points found for density heatmap');
        return;
    end
    
    binSize = 25;
    xBins = roiRect(1):binSize:(roiRect(1) + roiRect(3));
    yBins = roiRect(2):binSize:(roiRect(2) + roiRect(4));
    
    densityGrid = zeros(length(yBins)-1, length(xBins)-1);
    
    for frameIdx = 1:length(gridData)
        if ~isempty(gridData{frameIdx})
            points = gridData{frameIdx};
            
            for ptIdx = 1:size(points, 1)
                x = points(ptIdx, 1);
                y = points(ptIdx, 2);
                
                xBin = find(x >= xBins(1:end-1) & x < xBins(2:end), 1);
                yBin = find(y >= yBins(1:end-1) & y < yBins(2:end), 1);
                
                if ~isempty(xBin) && ~isempty(yBin)
                    densityGrid(yBin, xBin) = densityGrid(yBin, xBin) + 1;
                end
            end
        end
    end
    
    densityGrid = imgaussfilt(densityGrid, 2);
    
    figure('Visible', 'off', 'Position', [100, 100, 800, 600]);
    imagesc(densityGrid);
    colormap('cool'); colorbar;
    
    if ~isempty(runDisplay)
        title(['Stable Point Density - ', strrep(conditionName, '_', ' '), ' (', runDisplay, ')'], 'FontSize', 14);
        saveName = fullfile(outputDir, ['Stable_Point_Density_', conditionName, '_', runDisplay, '.png']);
    else
        title(['Stable Point Density - ', strrep(conditionName, '_', ' ')'], 'FontSize', 14);
        saveName = fullfile(outputDir, ['Stable_Point_Density_', conditionName, '.png']);
    end
    xlabel('Spatial Bins'); ylabel('Spatial Bins');
    
    saveas(gcf, saveName, 'png');
    close(gcf);
end