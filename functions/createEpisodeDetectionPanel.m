function createEpisodeDetectionPanel(conditionData, participant)
    % Create episode detection and pattern visualization
    
    conditions = fieldnames(conditionData);
    colors = [0.7 0.7 0.7; 0.2 0.8 0.2; 1 0.6 0; 0.8 0.2 0.2];
    
    for condIdx = 1:min(3, length(conditions))
        nexttile;
        condName = conditions{condIdx};
        
        if ~isempty(conditionData.(condName).patterns)
            % Analyze pattern types
            patternTypes = {};
            patternCounts = [];
            
            allPatterns = conditionData.(condName).patterns;
            uniqueTypes = {};
            
            for p = 1:length(allPatterns)
                if isstruct(allPatterns{p}) && isfield(allPatterns{p}, 'type')
                    pType = allPatterns{p}.type;
                    if ~any(strcmp(uniqueTypes, pType))
                        uniqueTypes{end+1} = pType;
                        patternCounts(end+1) = 1;
                    else
                        idx = find(strcmp(uniqueTypes, pType));
                        patternCounts(idx) = patternCounts(idx) + 1;
                    end
                end
            end
            
            if ~isempty(uniqueTypes)
                bar(patternCounts, 'FaceColor', colors(condIdx,:), 'FaceAlpha', 0.7);
                set(gca, 'XTickLabel', uniqueTypes, 'XTickLabelRotation', 45);
                title([condName, ' - Pattern Types'], 'Interpreter', 'none');
                ylabel('Trial Count');
            else
                text(0.5, 0.5, 'No Pattern Data', 'HorizontalAlignment', 'center');
            end
        else
            text(0.5, 0.5, 'No Pattern Data', 'HorizontalAlignment', 'center');
        end
    end
end
