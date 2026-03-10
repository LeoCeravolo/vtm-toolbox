function createDetailedTimeSeriesFigure(conditionData, participant, outputDir)
    % Create detailed time series figure with all conditions
    
    fig = figure('Position', [200, 200, 1400, 800], 'Color', 'white');
    conditions = fieldnames(conditionData);
    colors = [0.7 0.7 0.7; 0.2 0.8 0.2; 1 0.6 0; 0.8 0.2 0.2];
    
    for condIdx = 1:length(conditions)
        subplot(2, 2, condIdx);
        condName = conditions{condIdx};
        
        if ~isempty(conditionData.(condName).timeSeriesData)
            for trialIdx = 1:length(conditionData.(condName).timeSeriesData)
                timeData = conditionData.(condName).timeSeriesData{trialIdx};
                if ~isempty(timeData) && ~isempty(timeData.displacements)
                    timeVector = (1:length(timeData.displacements)) / 25;
                    
                    plot(timeVector, timeData.displacements, 'Color', colors(condIdx,:), ...
                        'LineWidth', 1, 'Alpha', 0.6);
                    hold on;
                end
            end
            
            title([upper(condName(1)), condName(2:end), ' Condition (All Trials)'], ...
                'Interpreter', 'none');
            xlabel('Time (s)');
            ylabel('Movement Displacement (pixels)');
            grid on;
        end
    end
    
    sgtitle(['Detailed Time Series Analysis - Participant ', participant], ...
        'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');
    
    figFile = fullfile(outputDir, [participant, '_DetailedTimeSeries.png']);
    saveas(fig, figFile);
    close(fig);
end
