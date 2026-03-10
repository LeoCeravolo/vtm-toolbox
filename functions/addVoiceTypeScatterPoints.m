function addVoiceTypeScatterPoints(allData, groupLabels, conditionLabels)
% Add scatter points with voice type specific colors
try
    colors = getVoiceTypeColors(conditionLabels);
    uniqueLabels = unique(groupLabels, 'stable');
    
    for i = 1:length(uniqueLabels)
        labelData = allData(strcmp(groupLabels, uniqueLabels{i}));
        if ~isempty(labelData)
            % Add small random jitter for visibility
            xPos = i + 0.1 * (rand(length(labelData), 1) - 0.5);
            
            % Find color for this condition
            colorIdx = find(strcmp(conditionLabels, uniqueLabels{i}));
            if ~isempty(colorIdx)
                scatter(xPos, labelData, 25, colors(colorIdx(1), :), 'filled', ...
                       'MarkerFaceAlpha', 0.6, 'MarkerEdgeAlpha', 0.8);
            end
        end
    end
catch ME
    % Continue if scatter addition fails
end
end
