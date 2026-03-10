%% 10. ANGER MIMICRY SCORE
function angerScore = calculateAngerMimicryScore(conditionData, avgLatency)
    % Calculate anger-specific mimicry score
    % Anger mimicry: fast, intense, brief responses
    
    angerScore = 0;
    
    % Component 1: Movement intensity (higher is more anger-like)
    if ~isempty(conditionData.StableMeanDisplacement)
        intensityScore = mean(conditionData.StableMeanDisplacement) / 10; % Normalize
        angerScore = angerScore + min(1, intensityScore) * 0.4;
    end
    
    % Component 2: Response speed (faster is more anger-like)
    if ~isnan(avgLatency) && avgLatency > 0
        speedScore = max(0, 1 - (avgLatency / 500)); % 500ms as reference
        angerScore = angerScore + speedScore * 0.3;
    end
    
    % Component 3: Movement variability (higher variability for anger)
    if ~isempty(conditionData.StableMeanDisplacement) && length(conditionData.StableMeanDisplacement) > 1
        variabilityScore = std(conditionData.StableMeanDisplacement) / mean(conditionData.StableMeanDisplacement);
        angerScore = angerScore + min(1, variabilityScore) * 0.3;
    end
    
    angerScore = min(1, max(0, angerScore)); % Bound between 0 and 1
end
