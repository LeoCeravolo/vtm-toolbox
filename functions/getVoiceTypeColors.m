function colors = getVoiceTypeColors(conditionLabels)
% Define colors for different voice types
colors = [];

% Define color scheme
colorMap = containers.Map();
colorMap('natural') = [0.2, 0.4, 0.8];           % Blue for natural
colorMap('synthetic_noise') = [0.8, 0.2, 0.2];   % Red for synthetic noise
colorMap('synthetic_spectrum') = [0.2, 0.8, 0.2]; % Green for synthetic spectrum
colorMap('synthetic_unknown') = [0.8, 0.6, 0.2];  % Orange for unknown synthetic

for i = 1:length(conditionLabels)
    label = conditionLabels{i};
    
    % Extract voice type
    if startsWith(label, 'natural')
        colors = [colors; colorMap('natural')];
    elseif startsWith(label, 'synthetic_noise')
        colors = [colors; colorMap('synthetic_noise')];
    elseif startsWith(label, 'synthetic_spectrum')
        colors = [colors; colorMap('synthetic_spectrum')];
    elseif startsWith(label, 'synthetic')
        colors = [colors; colorMap('synthetic_unknown')];
    else
        colors = [colors; [0.5, 0.5, 0.5]]; % Gray for unknown
    end
end
end
