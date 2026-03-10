function reversedName = convertTrialNameFormat(trialName)
    % Convert anger_42 → 42_anger
    parts = split(trialName, '_');
    if length(parts) == 2
        reversedName = [parts{2}, '_', parts{1}];
    else
        reversedName = trialName;
    end
end