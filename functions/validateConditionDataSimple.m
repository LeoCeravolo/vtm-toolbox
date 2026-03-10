function validateConditionDataSimple(participantConditionData, participant, conditions)
% Simplified validation with minimal output

try
    validConditions = 0;
    
    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        if isfield(participantConditionData, condName) && ...
           isfield(participantConditionData.(condName), 'trials') && ...
           ~isempty(participantConditionData.(condName).trials)
            validConditions = validConditions + 1;
        end
    end
    
    disp(['✓ Condition validation for ', participant, ': ', num2str(validConditions), '/', num2str(length(conditions)), ' conditions have data']);
    
catch ME
    disp(['Validation error for ', participant, ': ', ME.message]);
end
end