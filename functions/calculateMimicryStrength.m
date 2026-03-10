% Instead of: "mimicry_present" vs "no_mimicry"
% Use: mimicry_strength = (stimulus_response - baseline) / baseline

function mimicryStrength = calculateMimicryStrength(trialData)
    % Get baseline and stimulus periods
    baseline = mean(trialData.StableMeanDisplacement(1:25)); % First 1 second
    stimulus = mean(trialData.StableMeanDisplacement(26:75)); % Next 2 seconds
    
    % Calculate normalized change
    mimicryStrength = (stimulus - baseline) / (baseline + eps);
end