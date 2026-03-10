
function addVoiceTypeLegend(conditionLabels)
% Add legend showing voice types
try
    % Extract unique voice types
    voiceTypes = {};
    for i = 1:length(conditionLabels)
        parts = split(conditionLabels{i}, '_');
        if length(parts) >= 2
            voiceType = parts{1};
            if length(parts) >= 3
                voiceType = [parts{1}, '_', parts{2}]; % For synthetic_noise, synthetic_spectrum
            end
            if ~ismember(voiceType, voiceTypes)
                voiceTypes{end+1} = voiceType;
            end
        end
    end
    
    if length(voiceTypes) > 1
        % Create invisible scatter points for legend
        colors = getVoiceTypeColors(voiceTypes);
        legendHandles = [];
        legendLabels = {};
        
        for i = 1:length(voiceTypes)
            h = scatter(NaN, NaN, 50, colors(i, :), 'filled');
            legendHandles(end+1) = h;
            
            % Clean up voice type label
            cleanLabel = strrep(voiceTypes{i}, '_', ' ');
            cleanLabel = strrep(cleanLabel, 'synthetic', 'Synthetic');
            cleanLabel = strrep(cleanLabel, 'natural', 'Natural');
            legendLabels{end+1} = cleanLabel;
        end
        
        legend(legendHandles, legendLabels, 'Location', 'best', 'FontSize', 8);
    end
    
catch ME
    % Continue if legend fails
end
end