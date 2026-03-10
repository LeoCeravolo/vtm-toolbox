function condition = extractConditionFromTrialName(trialName)
    % Extract condition type from trial name
    
    conditionMap = containers.Map(...
        {'neutral', 'pleasure', 'happiness', 'anger'}, ...
        {'neutral', 'pleasure', 'happiness', 'anger'});
    
    trialLower = lower(trialName);
    
    conditions = keys(conditionMap);
    for i = 1:length(conditions)
        if contains(trialLower, conditions{i})
            condition = conditionMap(conditions{i});
            return;
        end
    end
    
    condition = 'unknown';
end
