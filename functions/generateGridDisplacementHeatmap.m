function generateGridDisplacementHeatmap(data, run, conditionName, roiRect, outputDir, runDisplay)
    if nargin < 6
        runDisplay = '';
    end
    
    % Try stable displacement data first
    if isfield(data.(run).(conditionName), 'StableDisplacements')
        gridData = data.(run).(conditionName).StableGridPoints;
        dispData = data.(run).(conditionName).StableDisplacements;
        disp('Using STABLE displacement data for heatmap');
    elseif isfield(data.(run).(conditionName), 'GridDisplacements')
        gridData = data.(run).(conditionName).GridPoints;
        dispData = data.(run).(conditionName).GridDisplacements;
        disp('Using regular displacement data for heatmap');
    else
        disp('No displacement data found!');
        return;
    end
    
    % Debug: Check displacement data
    totalDisplacements = 0;
    maxFoundDisp = 0;
    validFrames = 0;
    
    for frameIdx = 2:length(gridData)
        if frameIdx <= length(dispData) && ~isempty(dispData{frameIdx})
            totalDisplacements = totalDisplacements + length(dispData{frameIdx});
            maxFoundDisp = max(maxFoundDisp, max(dispData{frameIdx}));
            validFrames = validFrames + 1;
        end
    end
    
    disp(['DEBUG - Total displacements found: ', num2str(totalDisplacements)]);
    disp(['DEBUG - Max displacement found: ', num2str(maxFoundDisp)]);
    disp(['DEBUG - Valid frames: ', num2str(validFrames)]);
    
    if totalDisplacements == 0
        disp('WARNING: No displacement data found for heatmap generation!');
        return;
    end
    
    % Create spatial bins
    binSize = 20;
    xBins = roiRect(1):binSize:(roiRect(1) + roiRect(3));
    yBins = roiRect(2):binSize:(roiRect(2) + roiRect(4));
    
    heatmapGrid = zeros(length(yBins)-1, length(xBins)-1);
    countGrid = zeros(length(yBins)-1, length(xBins)-1);
    
    % Accumulate displacement data
    for frameIdx = 2:length(gridData)
        if ~isempty(gridData{frameIdx}) && frameIdx <= length(dispData) && ~isempty(dispData{frameIdx})
            points = gridData{frameIdx};
            displacements = dispData{frameIdx};
            
            for ptIdx = 1:min(size(points, 1), length(displacements))
                x = points(ptIdx, 1);
                y = points(ptIdx, 2);
                
                xBin = find(x >= xBins(1:end-1) & x < xBins(2:end), 1);
                yBin = find(y >= yBins(1:end-1) & y < yBins(2:end), 1);
                
                if ~isempty(xBin) && ~isempty(yBin) && xBin <= size(heatmapGrid, 2) && yBin <= size(heatmapGrid, 1)
                    heatmapGrid(yBin, xBin) = heatmapGrid(yBin, xBin) + displacements(ptIdx);
                    countGrid(yBin, xBin) = countGrid(yBin, xBin) + 1;
                end
            end
        end
    end
    
    % Average and smooth
    avgDisplacementMap = heatmapGrid ./ max(countGrid, 1);
    avgDisplacementMap(countGrid == 0) = NaN;
    avgDisplacementMap = imgaussfilt(avgDisplacementMap, 1.5, 'FilterSize', 5);
    
    % Plot
    figure('Visible', 'off', 'Position', [100, 100, 800, 600]);
    imagesc(avgDisplacementMap);
    colormap('jet'); colorbar;
    
    if ~isempty(runDisplay)
        title(['Grid Point Displacement - ', strrep(conditionName, '_', ' '), ' (', runDisplay, ')'], 'FontSize', 14);
        saveName = fullfile(outputDir, ['GridPoint_Displacement_', conditionName, '_', runDisplay, '.png']);
    else
        title(['Grid Point Displacement - ', strrep(conditionName, '_', ' ')], 'FontSize', 14);
        saveName = fullfile(outputDir, ['GridPoint_Displacement_', conditionName, '.png']);
    end
    xlabel('Spatial Bins (Horizontal)'); ylabel('Spatial Bins (Vertical)');
    
    saveas(gcf, saveName, 'png');
    close(gcf);
    
    disp(['Grid displacement heatmap saved - Max displacement: ', num2str(nanmax(avgDisplacementMap(:)), '%.2f')]);
end