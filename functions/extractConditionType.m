function conditionType = extractConditionType(conditionName)
% Extract the base condition type from the condition name
% e.g., 'neutral_1' -> 'neutral', 'pleasure_10' -> 'pleasure'

try
    % Split by underscore and take the first part
    parts = split(conditionName, '_');
    if length(parts) >= 1
        conditionType = parts{1};
    else
        conditionType = conditionName;
    end
    
    % Handle specific cases from your code
    validConditions = {'neutral', 'pleasure', 'happiness', 'anger'};
    
    % Check if extracted type is valid
    if any(strcmp(conditionType, validConditions))
        % Valid condition type
    else
        % Try to find partial matches
        for i = 1:length(validConditions)
            if contains(lower(conditionName), validConditions{i})
                conditionType = validConditions{i};
                return;
            end
        end
        % If no match found, use 'unknown'
        conditionType = 'unknown';
    end
    
catch
    conditionType = 'unknown';
end
end
