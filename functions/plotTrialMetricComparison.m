function plotTrialMetricComparison(mlSummary, metricName, metricLabel)
    % Helper function to plot trial metric comparison
    
    supValues = [];
    unsupValues = [];
    trialIndices = [];
    
    for i = 1:mlSummary.numTrials
        if i <= length(mlSummary.supervised) && i <= length(mlSummary.unsupervised)
            supVal = getField(mlSummary.supervised(i), metricName, NaN);
            unsupVal = getField(mlSummary.unsupervised(i), metricName, NaN);
            
            if isfinite(supVal) && isfinite(unsupVal)
                supValues(end+1) = supVal;
                unsupValues(end+1) = unsupVal;
                trialIndices(end+1) = i;
            end
        end
    end
    
    if ~isempty(supValues)
        x = 1:length(supValues);
        plot(x, supValues, 'o-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Supervised');
        hold on;
        plot(x, unsupValues, 's-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Unsupervised');
        
        xlabel('Trial Number');
        ylabel(metricLabel);
        title([metricLabel, ' Comparison']);
        legend;
        grid on;
        
        % Add correlation info
        if length(supValues) > 1
            corrVal = corr(supValues', unsupValues');
            text(0.05, 0.95, sprintf('r = %.3f', corrVal), 'Units', 'normalized', ...
                 'BackgroundColor', 'white', 'FontSize', 10);
        end
    else
        text(0.5, 0.5, 'No data available', 'HorizontalAlignment', 'center');
        title([metricLabel, ' - No Data']);
    end
end
