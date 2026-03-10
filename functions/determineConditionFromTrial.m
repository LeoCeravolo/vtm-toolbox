function condType = determineConditionFromTrial(trialName)
    if contains(trialName, 'neutral')
        condType = 'neutral';
    elseif contains(trialName, 'pleasure')
        condType = 'pleasure';
    elseif contains(trialName, 'happiness')
        condType = 'happiness';
    elseif contains(trialName, 'anger')
        condType = 'anger';
    else
        condType = '';
    end
end
