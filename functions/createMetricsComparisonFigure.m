
function createMetricsComparisonFigure(conditionData, participant, outputDir)
    % Create comprehensive metrics comparison figure
    
    fig = figure('Position', [300, 300, 1200, 900], 'Color', 'white');
    conditions = fieldnames(conditionData);
    colors = [0.7 0.7 0.7; 0.2 0.8 0.2; 1 0.6 0; 0.8 0.2 0.2];
    
    % Collect all metrics
    allData = struct();
    metrics = {'CTAI', 'MPI', 'TDI', 'OSI'};
    
    for metIdx = 1:length(metrics)
        allData.(metrics{metIdx}) = [];
        allData.([metrics{metIdx}, '_cond']) = {};
    end
    
    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        if ~isempty(conditionData.(condName).durationMetrics)
            for m = 1:length(conditionData.(condName).durationMetrics)
                metricStruct = conditionData.(condName).durationMetrics(m);
                for metIdx = 1:length(metrics)
                    metName = metrics{metIdx};
                    if isfield(metricStruct, metName) && ~isnan(metricStruct.(metName))
                        allData.(metName)(end+1) = metricStruct.(metName);
                        allData.([metName, '_cond']){end+1} = condName;
                    end
                end
            end
        end
    end
    
    % Create subplots for each metric
    for metIdx = 1:length(metrics)
        subplot(2, 2, metIdx);
        metName = metrics{metIdx};
        
        if ~isempty(allData.(metName))
            % Box plot by condition
            conditionLabels = allData.([metName, '_cond']);
            values = allData.(metName);
            
            uniqueConds = unique(conditionLabels);
            groupedData = cell(1, length(uniqueConds));
            
            for ucIdx = 1:length(uniqueConds)
                condName = uniqueConds{ucIdx};
                condIndices = strcmp(conditionLabels, condName);
                groupedData{ucIdx} = values(condIndices);
            end
            
            boxplot([groupedData{:}], 'Labels', uniqueConds, 'Colors', colors(1:length(uniqueConds),:));
            title(metName, 'Interpreter', 'none');
            ylabel('Metric Value');
            grid on;
        end
    end
    
    sgtitle(['Duration-Enhanced Metrics Comparison - Participant ', participant], ...
        'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');
    
    figFile = fullfile(outputDir, [participant, '_MetricsComparison.png']);
    saveas(fig, figFile);
    close(fig);
end
