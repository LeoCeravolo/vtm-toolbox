function createPatternAnalysisPanel(conditionData, participant)
    % Create pattern analysis and correlation panel
    
    % Panel 1: Pattern distribution
    nexttile;
    conditions = fieldnames(conditionData);
    patternSummary = struct();
    
    % Count patterns across all conditions
    allPatternTypes = {};
    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        if ~isempty(conditionData.(condName).patterns)
            for p = 1:length(conditionData.(condName).patterns)
                if isstruct(conditionData.(condName).patterns{p}) && ...
                   isfield(conditionData.(condName).patterns{p}, 'type')
                    pType = conditionData.(condName).patterns{p}.type;
                    if ~any(strcmp(allPatternTypes, pType))
                        allPatternTypes{end+1} = pType;
                    end
                end
            end
        end
    end
    
    if ~isempty(allPatternTypes)
        patternMatrix = zeros(length(conditions), length(allPatternTypes));
        
        for condIdx = 1:length(conditions)
            condName = conditions{condIdx};
            if ~isempty(conditionData.(condName).patterns)
                for p = 1:length(conditionData.(condName).patterns)
                    if isstruct(conditionData.(condName).patterns{p}) && ...
                       isfield(conditionData.(condName).patterns{p}, 'type')
                        pType = conditionData.(condName).patterns{p}.type;
                        pIdx = find(strcmp(allPatternTypes, pType));
                        if ~isempty(pIdx)
                            patternMatrix(condIdx, pIdx) = patternMatrix(condIdx, pIdx) + 1;
                        end
                    end
                end
            end
        end
        
        heatmap(allPatternTypes, conditions, patternMatrix, 'Colormap', parula, ...
            'Title', 'Pattern Distribution', 'XLabel', 'Pattern Type', 'YLabel', 'Condition');
    else
        text(0.5, 0.5, 'No Pattern Data Available', 'HorizontalAlignment', 'center');
        title('Pattern Distribution');
    end
    
    % Panel 2: CTAI vs Traditional Metrics
    nexttile;
    allCTAI = [];
    allTraditional = [];
    allCondLabels = {};
    
    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        if ~isempty(conditionData.(condName).durationMetrics)
            for m = 1:length(conditionData.(condName).durationMetrics)
                metrics = conditionData.(condName).durationMetrics(m);
                if ~isnan(metrics.CTAI)
                    allCTAI(end+1) = metrics.CTAI;
                    % Use MPI as traditional comparison (you could also use mean displacement)
                    allTraditional(end+1) = metrics.MPI;
                    allCondLabels{end+1} = condName;
                end
            end
        end
    end
    
    if length(allCTAI) > 2
        colors = [0.7 0.7 0.7; 0.2 0.8 0.2; 1 0.6 0; 0.8 0.2 0.2];
        colorMap = containers.Map({'neutral', 'pleasure', 'happiness', 'anger'}, ...
                                  {colors(1,:), colors(2,:), colors(3,:), colors(4,:)});
        
        for i = 1:length(allCTAI)
            if isKey(colorMap, allCondLabels{i})
                scatter(allTraditional(i), allCTAI(i), 50, colorMap(allCondLabels{i}), 'filled');
                hold on;
            end
        end
        
        xlabel('Movement Persistence Index (MPI)');
        ylabel('Comprehensive Temporal-Amplitude Index (CTAI)');
        title('CTAI vs Traditional Metric', 'Interpreter', 'none');
        grid on;
        
        % Add trend line
        if length(allCTAI) > 3
            p = polyfit(allTraditional, allCTAI, 1);
            xFit = linspace(min(allTraditional), max(allTraditional), 100);
            yFit = polyval(p, xFit);
            plot(xFit, yFit, 'k--', 'LineWidth', 1);
        end
    else
        text(0.5, 0.5, 'Insufficient Data for Correlation', 'HorizontalAlignment', 'center');
        title('CTAI vs Traditional Metric');
    end
    
    % Panel 3: Metric summary statistics
    nexttile;
    if ~isempty(allCTAI)
        metricStats = [mean(allCTAI), std(allCTAI), min(allCTAI), max(allCTAI)];
        bar(metricStats, 'FaceColor', [0.3 0.6 0.8], 'FaceAlpha', 0.7);
        set(gca, 'XTickLabel', {'Mean', 'Std', 'Min', 'Max'});
        ylabel('CTAI Value');
        title('CTAI Summary Statistics', 'Interpreter', 'none');
        grid on;
    else
        text(0.5, 0.5, 'No CTAI Data', 'HorizontalAlignment', 'center');
        title('CTAI Summary Statistics');
    end
end
