function enhancedFastMovementDetection(data, run, ConditionName, FrameCount, stableDisplacements, velocities, frameRate, stimulusOnset)
% Enhanced version of the existing fast movement detection
% ADD THIS FUNCTION AND CALL IT INSTEAD OF THE SIMPLE fastMovementIndices

try
    if isempty(stableDisplacements) || length(stableDisplacements) < 3
        data.(run).(ConditionName).EnhancedFastIndices{FrameCount} = [];
        return;
    end
    
    % === IMPROVED THRESHOLDING ===
    % Use more sophisticated threshold instead of simple mean
    displacementMean = mean(stableDisplacements);
    displacementStd = std(stableDisplacements);
    
    % Dynamic threshold: mean + 1 standard deviation (more selective)
    dynamicThreshold = displacementMean + 0.5 * displacementStd;
    
    % === SPATIAL FILTERING ===
    % Prefer movements that are more concentrated (mimicry-like)
    if length(stableDisplacements) >= 5
        % Calculate movement concentration
        concentrationScore = calculateConcentrationScore(stableDisplacements);
        spatialWeight = concentrationScore > median(concentrationScore);
    else
        spatialWeight = true(size(stableDisplacements));
    end
    
    % === TEMPORAL FILTERING ===
    % Prefer movements close to stimulus onset
    timeFromStimulus = abs(FrameCount - stimulusOnset) / frameRate;
    temporalWeight = timeFromStimulus < 1.0; % Within 1 second of stimulus
    
    % === VELOCITY FILTERING ===
    % Prefer high-velocity movements (sudden, mimicry-like)
    velocityThreshold = prctile(velocities, 75); % Top 25% of velocities
    velocityWeight = velocities > velocityThreshold;
    
    % === COMBINE FILTERS ===
    % Original simple filter
    originalFastIndices = stableDisplacements > displacementMean;
    
    % Enhanced filter combining multiple criteria
    enhancedFastIndices = (stableDisplacements > dynamicThreshold) & ...
                         spatialWeight & ...
                         velocityWeight;
    
    % Apply temporal weighting if we're in a good time window
    if temporalWeight
        enhancedFastIndices = enhancedFastIndices | ...
                            (stableDisplacements > displacementMean & velocityWeight);
    end
    
    % Store both for comparison
    data.(run).(ConditionName).OriginalFastIndices{FrameCount} = originalFastIndices;
    data.(run).(ConditionName).EnhancedFastIndices{FrameCount} = enhancedFastIndices;
    data.(run).(ConditionName).SpatialWeight{FrameCount} = spatialWeight;
    data.(run).(ConditionName).TemporalWeight(FrameCount) = temporalWeight;
    data.(run).(ConditionName).VelocityWeight{FrameCount} = velocityWeight;
    
    % Debug output
    originalCount = sum(originalFastIndices);
    enhancedCount = sum(enhancedFastIndices);
    
    disp(['Frame ', num2str(FrameCount), ': Original fast=', num2str(originalCount), ...
          ', Enhanced fast=', num2str(enhancedCount), ', Time from stim=', num2str(timeFromStimulus, '%.2f'), 's']);
    
catch ME
    disp(['Enhanced fast movement detection error: ', ME.message]);
    data.(run).(ConditionName).EnhancedFastIndices{FrameCount} = [];
end
end