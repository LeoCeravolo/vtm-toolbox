function trialNumber = extractTrialNumber(trialName)
    % Extract trial number from trial name
    try
        % Look for numbers in trial name
        numbers = regexp(trialName, '\d+', 'match');
        if ~isempty(numbers)
            trialNumber = str2double(numbers{end}); % Use last number found
        else
            trialNumber = 1; % Default
        end
    catch
        trialNumber = 1;
    end
end