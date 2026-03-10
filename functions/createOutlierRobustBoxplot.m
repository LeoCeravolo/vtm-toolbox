function createOutlierRobustBoxplot(conditionData, conditionLabels, metricTitle, outlierInfo)
% Create boxplot with outlier information

try
    % Prepare data for boxplot
    allData = [];
    groupLabels = [];
    
    for i = 1:length(conditionData)
        data = conditionData{i};
        allData = [allData; data(:)];
        groupLabels = [groupLabels; repmat({conditionLabels{i}}, length(data), 1)];
    end
    
    if isempty(allData)
        text(0.5, 0.5, 'No valid data after outlier removal', 'HorizontalAlignment', 'center', 'Units', 'normalized');
        title([metricTitle, ' (No Data)']);
        return;
    end
    
    % Create boxplot
    h = boxplot(allData, groupLabels, 'Colors', 'kbrmg');
    title([metricTitle, ' (Outliers Removed)']);
    ylabel('Value');
    grid on;
    
    % Add scatter points with CORRECT alpha properties
    hold on;
    colors = [0.8, 0.2, 0.2; 0.2, 0.8, 0.2; 0.2, 0.2, 0.8; 0.8, 0.8, 0.2]; % Red, Green, Blue, Yellow
    
    uniqueLabels = unique(groupLabels, 'stable');
    for i = 1:length(uniqueLabels)
        labelData = allData(strcmp(groupLabels, uniqueLabels{i}));
        if ~isempty(labelData)
            % Add small random jitter for visibility
            xPos = i + 0.1 * (rand(length(labelData), 1) - 0.5);
            
            % Create scatter with CORRECT properties
            colorIdx = mod(i-1, size(colors, 1)) + 1;
            scatter(xPos, labelData, 30, colors(colorIdx, :), 'filled', ...
                   'MarkerFaceAlpha', 0.6, 'MarkerEdgeAlpha', 0.8);
        end
    end
    hold off;
    
    % Improve x-axis labels
    if length(uniqueLabels) <= 6
        set(gca, 'XTickLabel', uniqueLabels);
        xtickangle(45);
    end
    
    % Add outlier information as text
    if outlierInfo.totalOutliers > 0
        outlierText = sprintf('Outliers removed: %d (%.1f%%)', ...
                            outlierInfo.totalOutliers, ...
                            outlierInfo.totalOutliers/outlierInfo.totalOriginal*100);
        
        % Position text at top of plot
        ylims = ylim;
        text(0.02, 0.98, outlierText, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
             'FontSize', 8, 'BackgroundColor', 'white', 'EdgeColor', 'black');
    end
    
catch ME
    disp(['Outlier-robust boxplot creation error: ', ME.message]);
    % Fallback to simple bar plot
    try
        means = cellfun(@mean, conditionData);
        stds = cellfun(@std, conditionData);
        
        bar(means);
        hold on;
        errorbar(1:length(means), means, stds, 'k.', 'LineWidth', 1.5);
        hold off;
        
        set(gca, 'XTickLabel', conditionLabels);
        title([metricTitle, ' (Mean ± SD, Outliers Removed)']);
        ylabel('Value');
        grid on;
        xtickangle(45);
        
    catch ME2
        disp(['Fallback plot error: ', ME2.message]);
        text(0.5, 0.5, 'Plot creation failed', 'HorizontalAlignment', 'center', 'Units', 'normalized');
        title(metricTitle);
    end
end
end
