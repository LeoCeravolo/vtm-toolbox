%% 11. PLEASURE MIMICRY SCORE
function pleasureScore = calculatePleasureMimicryScore(conditionData, avgCoherence)
    % Calculate pleasure-specific mimicry score
    % Pleasure mimicry: sustained, rhythmic, coherent movements
    
    pleasureScore = 0;
    
    % Component 1: Temporal coherence (rhythmic patterns)
    if ~isnan(avgCoherence)
        pleasureScore = pleasureScore + avgCoherence * 0.4;
    end
    
    % Component 2: Movement sustainability (longer sustained movements)
    if ~isempty(conditionData.StableMeanDisplacement)
        % Count consecutive non-zero movements
        nonZeroMovements = conditionData.StableMeanDisplacement > 0;
        if any(nonZeroMovements)
            sustainedMovement = max(findConsecutiveOnes(nonZeroMovements)) / length(nonZeroMovements);
            pleasureScore = pleasureScore + sustainedMovement * 0.3;
        end
    end
    
    % Component 3: Spectral characteristics (speech-like frequencies)
    if isfield(conditionData, 'SpectralMimicryIndex') && ~isempty(conditionData.SpectralMimicryIndex)
        spectralScore = mean(conditionData.SpectralMimicryIndex);
        pleasureScore = pleasureScore + spectralScore * 0.3;
    end
    
    pleasureScore = min(1, max(0, pleasureScore)); % Bound between 0 and 1
end
