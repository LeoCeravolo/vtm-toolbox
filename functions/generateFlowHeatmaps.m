function generateFlowHeatmaps(avgMagnitudeMap, avgVxMap, avgVyMap, outputDir, conditionName, runDisplay)
    if nargin < 6
        runDisplay = '';
    end
    
    % Magnitude heatmap
    figure('Visible', 'off', 'Position', [100, 100, 800, 600]);
    smoothedMagnitude = imgaussfilt(avgMagnitudeMap, 2);
    imagesc(smoothedMagnitude);
    colormap('hot'); colorbar;
    if ~isempty(runDisplay)
        title(['Optical Flow Magnitude - ', strrep(conditionName, '_', ' '), ' (', runDisplay, ')'], 'FontSize', 14);
    else
        title(['Optical Flow Magnitude - ', strrep(conditionName, '_', ' ')], 'FontSize', 14);
    end
    xlabel('Horizontal Position'); ylabel('Vertical Position');
    
    % Create filename with run info
    if ~isempty(runDisplay)
        saveName = fullfile(outputDir, ['Flow_Magnitude_', conditionName, '_', runDisplay, '.png']);
    else
        saveName = fullfile(outputDir, ['Flow_Magnitude_', conditionName, '.png']);
    end
    saveas(gcf, saveName, 'png');
    close(gcf);
    
    % Velocity components
    figure('Visible', 'off', 'Position', [100, 100, 1200, 400]);
    
    subplot(1,2,1);
    imagesc(imgaussfilt(avgVxMap, 1.5));
    colormap('jet'); colorbar;
    title('Horizontal Velocity (Vx)');
    
    subplot(1,2,2);
    imagesc(imgaussfilt(avgVyMap, 1.5));
    colormap('jet'); colorbar;
    title('Vertical Velocity (Vy)');
    
    if ~isempty(runDisplay)
        sgtitle(['Flow Components - ', strrep(conditionName, '_', ' '), ' (', runDisplay, ')'], 'FontSize', 16);
        saveName = fullfile(outputDir, ['Flow_Components_', conditionName, '_', runDisplay, '.png']);
    else
        sgtitle(['Flow Components - ', strrep(conditionName, '_', ' ')], 'FontSize', 16);
        saveName = fullfile(outputDir, ['Flow_Components_', conditionName, '.png']);
    end
    saveas(gcf, saveName, 'png');
    close(gcf);
end