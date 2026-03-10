function enhanceXAxisLabels(conditionLabels)
% Enhance x-axis labels to show voice type grouping
try
    % Create readable labels (remove voice type prefix and capitalize)
    shortLabels = cell(size(conditionLabels));
    for i = 1:length(conditionLabels)
        parts = split(conditionLabels{i}, '_');
        if length(parts) >= 2
            emotion = parts{end};
            shortLabels{i} = [upper(emotion(1)), emotion(2:end)];
        else
            shortLabels{i} = conditionLabels{i};
        end
    end
    
    set(gca, 'XTickLabel', shortLabels);
    xtickangle(45);
    
catch ME
    % Fallback to original labels
    set(gca, 'XTickLabel', conditionLabels);
    xtickangle(45);
end
end
