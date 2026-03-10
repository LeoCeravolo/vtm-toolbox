function createEnhancedVoiceTypeBoxplot(conditionData, conditionLabels, metricTitle, outlierInfo)
% Create enhanced boxplot with voice type visual grouping

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
    
    % Create boxplot with enhanced styling
    h = boxplot(allData, groupLabels, 'Colors', getVoiceTypeColors(conditionLabels), 'Symbol', '');
    title([metricTitle, ' by Voice Type + Emotion']);
    ylabel('Value');
    grid on;
    
    % Enhance boxplot appearance
    enhanceBoxplotAppearance(h, conditionLabels);
    
    % Add scatter points with voice type colors
    hold on;
    addVoiceTypeScatterPoints(allData, groupLabels, conditionLabels);
    hold off;
    
    % Improve x-axis labels with voice type grouping
    enhanceXAxisLabels(conditionLabels);
    
    % Add outlier information
    if outlierInfo.totalOutliers > 0
        outlierText = sprintf('Outliers removed: %d (%.1f%%)', ...
                            outlierInfo.totalOutliers, ...
                            outlierInfo.totalOutliers/outlierInfo.totalOriginal*100);
        
        text(0.02, 0.98, outlierText, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
             'FontSize', 8, 'BackgroundColor', 'white', 'EdgeColor', 'black');
    end
    
    % Add voice type legend
    addVoiceTypeLegend(conditionLabels);
    
catch ME
    disp(['Enhanced voice type boxplot creation error: ', ME.message]);
    % Fallback to simple plot
    try
        means = cellfun(@mean, conditionData);
        stds = cellfun(@std, conditionData);
        
        bar(means);
        hold on;
        errorbar(1:length(means), means, stds, 'k.', 'LineWidth', 1.5);
        hold off;
        
        set(gca, 'XTickLabel', conditionLabels);
        title([metricTitle, ' (Mean ± SD)']);
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
