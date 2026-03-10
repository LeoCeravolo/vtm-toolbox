function generateTrackingStabilityHeatmap(data, run, conditionName, roiRect, outputDir, runDisplay)
    if nargin < 6
        runDisplay = '';
    end
    
    figure('Visible', 'off', 'Position', [100, 100, 1400, 1000]);
    
    % Panel 1: Point Count Over Time
    subplot(2,3,1);
    if isfield(data.(run).(conditionName), 'PointCount')
        pointCounts = data.(run).(conditionName).PointCount;
        pointCounts(pointCounts == 0) = NaN;
        plot(1:length(pointCounts), pointCounts, 'b-', 'LineWidth', 2);
        if ~isempty(runDisplay)
            title(['Points Tracked - ', runDisplay]);
        else
            title('Points Tracked Over Time');
        end
        xlabel('Frame'); ylabel('Number of Points');
        grid on;
        ylim([0, max(pointCounts)*1.1]);
    else
        text(0.5, 0.5, 'No Point Count Data', 'HorizontalAlignment', 'center');
    end
    
    % Panel 2: Point Count Distribution
    subplot(2,3,2);
    if isfield(data.(run).(conditionName), 'PointCount')
        pointCounts = data.(run).(conditionName).PointCount;
        pointCounts(pointCounts == 0 | isnan(pointCounts)) = [];
        if ~isempty(pointCounts)
            histogram(pointCounts, 20, 'FaceColor', 'green', 'EdgeColor', 'black', 'FaceAlpha', 0.7);
            title('Point Count Distribution');
            xlabel('Number of Points'); ylabel('Frequency');
            grid on;
        else
            text(0.5, 0.5, 'No Valid Point Count Data', 'HorizontalAlignment', 'center');
        end
    else
        text(0.5, 0.5, 'No Point Count Data', 'HorizontalAlignment', 'center');
    end
    
    % Panel 3: Stable Mean Displacement Over Time
    subplot(2,3,3);
    if isfield(data.(run).(conditionName), 'StableMeanDisplacement')
        meanDisp = data.(run).(conditionName).StableMeanDisplacement;
        validDisp = meanDisp(~isnan(meanDisp) & meanDisp > 0);
        validFrames = find(~isnan(meanDisp) & meanDisp > 0);
        if ~isempty(validDisp)
            plot(validFrames, validDisp, 'r-', 'LineWidth', 2);
            if ~isempty(runDisplay)
                title(['Stable Mean Displacement - ', runDisplay]);
            else
                title('Stable Mean Displacement Over Time');
            end
            xlabel('Frame'); ylabel('Displacement (pixels)');
            grid on;
            ylim([0, max(validDisp)*1.1]);
        else
            text(0.5, 0.5, 'No Valid Displacement Data', 'HorizontalAlignment', 'center');
        end
    else
        text(0.5, 0.5, 'No Stable Displacement Data', 'HorizontalAlignment', 'center');
    end
    
    % Continue with remaining panels (4-6) following the same pattern...
    % Panel 4: Stable Max Displacement Over Time
    subplot(2,3,4);
    if isfield(data.(run).(conditionName), 'StableMaxDisplacement')
        maxDisp = data.(run).(conditionName).StableMaxDisplacement;
        validDisp = maxDisp(~isnan(maxDisp) & maxDisp > 0);
        validFrames = find(~isnan(maxDisp) & maxDisp > 0);
        if ~isempty(validDisp)
            plot(validFrames, validDisp, 'm-', 'LineWidth', 2);
            title('Stable Max Displacement');
            xlabel('Frame'); ylabel('Displacement (pixels)');
            grid on;
            ylim([0, max(validDisp)*1.1]);
        else
            text(0.5, 0.5, 'No Valid Max Displacement Data', 'HorizontalAlignment', 'center');
        end
    else
        text(0.5, 0.5, 'No Stable Max Displacement Data', 'HorizontalAlignment', 'center');
    end
    
    % Panel 5: Stable Point Count Over Time
    subplot(2,3,5);
    if isfield(data.(run).(conditionName), 'StablePointCount')
        stableCount = data.(run).(conditionName).StablePointCount;
        validCount = stableCount(stableCount > 0);
        validFrames = find(stableCount > 0);
        if ~isempty(validCount)
            plot(validFrames, validCount, 'g-', 'LineWidth', 2);
            title('Stable Tracked Points');
            xlabel('Frame'); ylabel('Number of Stable Points');
            grid on;
            ylim([0, max(validCount)*1.1]);
        else
            text(0.5, 0.5, 'No Stable Point Count Data', 'HorizontalAlignment', 'center');
        end
    else
        text(0.5, 0.5, 'No Stable Point Count Data', 'HorizontalAlignment', 'center');
    end
    
    % Panel 6: Displacement Distribution
    subplot(2,3,6);
    if isfield(data.(run).(conditionName), 'StableMeanDisplacement')
        meanDisp = data.(run).(conditionName).StableMeanDisplacement;
        validDisp = meanDisp(~isnan(meanDisp) & meanDisp > 0);
        if ~isempty(validDisp)
            histogram(validDisp, 20, 'FaceColor', 'cyan', 'EdgeColor', 'black', 'FaceAlpha', 0.7);
            title('Stable Displacement Distribution');
            xlabel('Mean Displacement (pixels)'); ylabel('Frequency');
            grid on;
        else
            text(0.5, 0.5, 'No Valid Displacement Data', 'HorizontalAlignment', 'center');
        end
    else
        text(0.5, 0.5, 'No Stable Displacement Data', 'HorizontalAlignment', 'center');
    end
    
    if ~isempty(runDisplay)
        sgtitle(['Enhanced Tracking Stability - ', strrep(conditionName, '_', ' '), ' (', runDisplay, ')'], 'FontSize', 16);
        saveName = fullfile(outputDir, ['Enhanced_Tracking_Stability_', conditionName, '_', runDisplay, '.png']);
    else
        sgtitle(['Enhanced Tracking Stability - ', strrep(conditionName, '_', ' ')], 'FontSize', 16);
        saveName = fullfile(outputDir, ['Enhanced_Tracking_Stability_', conditionName, '.png']);
    end
    
    saveas(gcf, saveName, 'png');
    close(gcf);
end