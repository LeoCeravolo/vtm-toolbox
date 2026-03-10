function createTimeSeriesPanel(conditionData, participant)
    % Create time series visualization panels
    
    conditions = fieldnames(conditionData);
    colors = [0.7 0.7 0.7; 0.2 0.8 0.2; 1 0.6 0; 0.8 0.2 0.2]; % neutral, pleasure, happiness, anger
    
    for condIdx = 1:min(3, length(conditions)) % Show first 3 conditions
        nexttile;
        condName = conditions{condIdx};
        
        if ~isempty(conditionData.(condName).timeSeriesData)
            % Plot first few trials as examples
            maxTrials = min(3, length(conditionData.(condName).timeSeriesData));
            
            for trialIdx = 1:maxTrials
                timeData = conditionData.(condName).timeSeriesData{trialIdx};
                if ~isempty(timeData)
                    timeVector = (1:length(timeData.displacements)) / 25; % Convert to seconds
                    
                    plot(timeVector, timeData.displacements, 'Color', colors(condIdx,:), ...
                        'LineWidth', 1.5, 'DisplayName', ['Trial ', num2str(trialIdx)]);
                    hold on;
                    
                    % Mark movement episodes
                    if isfield(timeData, 'episodes') && ~isempty(timeData.episodes)
                        for ep = 1:length(timeData.episodes)
                            epStart = timeData.episodes(ep).start / 25;
                            epEnd = timeData.episodes(ep).end / 25;
                            patch([epStart epEnd epEnd epStart], ...
                                  [min(timeData.displacements) min(timeData.displacements) ...
                                   max(timeData.displacements) max(timeData.displacements)], ...
                                  colors(condIdx,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                        end
                    end
                end
            end
            
            title([upper(condName(1)), condName(2:end), ' Condition'], 'Interpreter', 'none');
            xlabel('Time (s)');
            ylabel('Displacement (pixels)');
            grid on;
            
        else
            text(0.5, 0.5, 'No Data', 'HorizontalAlignment', 'center', ...
                'FontSize', 12, 'Color', [0.5 0.5 0.5]);
            title([upper(condName(1)), condName(2:end), ' - No Data'], 'Interpreter', 'none');
        end
    end
end
