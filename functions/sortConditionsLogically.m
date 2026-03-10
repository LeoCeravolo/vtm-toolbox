
function sortedConditions = sortConditionsLogically(conditions)
% Sort conditions to group by voice type, then by emotion
% Order: natural_anger, natural_happiness, natural_neutral, natural_pleasure,
%        synthetic_noise_anger, synthetic_noise_happiness, etc.

sortedConditions = {};

% Define desired order
voiceTypeOrder = {'natural', 'synthetic_noise', 'synthetic_spectrum', 'synthetic_unknown'};
emotionOrder = {'anger', 'happiness', 'neutral', 'pleasure'};

% Sort by voice type, then emotion
for vIdx = 1:length(voiceTypeOrder)
    voiceType = voiceTypeOrder{vIdx};
    for eIdx = 1:length(emotionOrder)
        emotion = emotionOrder{eIdx};
        targetCondition = [voiceType, '_', emotion];
        
        if ismember(targetCondition, conditions)
            sortedConditions{end+1} = targetCondition;
        end
    end
end

% Add any remaining conditions that didn't match the standard pattern
for i = 1:length(conditions)
    if ~ismember(conditions{i}, sortedConditions)
        sortedConditions{end+1} = conditions{i};
    end
end
end