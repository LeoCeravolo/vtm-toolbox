function voiceType = determineVoiceType(runNumber, trialName)
    % Determine voice type based on run number and trial name
    
    if runNumber <= 2
        voiceType = 'natural';
    elseif runNumber == 3
        % Determine synthetic type based on trial name patterns
        trialLower = lower(trialName);
        if contains(trialLower, 'noise') || contains(trialLower, 'pink')
            voiceType = 'synthetic_noise';
        elseif contains(trialLower, 'spectrum') || contains(trialLower, 'shift') || contains(trialLower, 'rand')
            voiceType = 'synthetic_spectrum';
        else
            % Default for Run 3 if pattern unclear
            voiceType = 'synthetic_unknown';
        end
    else
        voiceType = 'unknown';
    end
end
