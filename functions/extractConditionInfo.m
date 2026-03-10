function [conditionName, conditionNumber] = extractConditionInfo(trialName)
    % Extract condition from trial name (adapt to your naming convention)
    if contains(trialName, 'neutral')
        conditionName = 'neutral';
        conditionNumber = 1;
    elseif contains(trialName, 'pleasure')
        conditionName = 'pleasure';
        conditionNumber = 2;
    elseif contains(trialName, 'happiness')
        conditionName = 'happiness';
        conditionNumber = 3;
    elseif contains(trialName, 'anger')
        conditionName = 'anger';
        conditionNumber = 4;
    else
        conditionName = 'unknown';
        conditionNumber = 0;
    end
end
