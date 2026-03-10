function condition = extractConditionFromTrialName_Enhanced(trialName, runNumber)
    % Enhanced condition extraction for both natural and synthetic voices
    
    trialLower = lower(trialName);
    
    % Standard emotion detection patterns
    if contains(trialLower, 'anger')
        condition = 'anger';
    elseif contains(trialLower, 'neutral')
        condition = 'neutral';
    elseif contains(trialLower, 'happiness') || contains(trialLower, 'happy')
        condition = 'happiness';
    elseif contains(trialLower, 'pleasure')
        condition = 'pleasure';
    else
        % Fallback patterns for different naming schemes
        if runNumber <= 2
            % Natural voices - try original extraction method
            try
                condition = extractConditionFromTrialName(trialName);
            catch
                condition = 'unknown';
            end
        else
            % Synthetic voices - try alternative patterns
            if contains(trialLower, 'ang')
                condition = 'anger';
            elseif contains(trialLower, 'neu')
                condition = 'neutral';
            elseif contains(trialLower, 'hap')
                condition = 'happiness';
            elseif contains(trialLower, 'ple')
                condition = 'pleasure';
            else
                warning(['Could not determine condition for trial: ', trialName]);
                condition = 'unknown';
            end
        end
    end
end
