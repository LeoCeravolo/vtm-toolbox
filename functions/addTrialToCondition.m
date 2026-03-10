function conditionStruct = addTrialToCondition(conditionStruct, trialData, ConditionName)
% Add trial data to condition structure - extracts values from your data format

% Add trial name
conditionStruct.trials{end+1} = ConditionName;

% === EXTRACT TRADITIONAL METRICS (ARRAYS) ===
% Your data has arrays like [0 0 0.5729 0.5554 ...] - extract mean/max
conditionStruct.StableMeanDisplacement(end+1) = extractArrayMetric(trialData, 'StableMeanDisplacement', @mean);
conditionStruct.StableMaxDisplacement(end+1) = extractArrayMetric(trialData, 'StableMaxDisplacement', @max);
conditionStruct.ROIFlowMagnitude(end+1) = extractArrayMetric(trialData, 'ROIFlowMagnitude', @mean);
conditionStruct.Entropy(end+1) = extractArrayMetric(trialData, 'Entropy', @mean);

% === EXTRACT VELOCITY METRICS (ARRAYS) ===
conditionStruct.PeakVelocities(end+1) = extractArrayMetric(trialData, 'MaxVelocity', @max);
conditionStruct.MeanVelocities(end+1) = extractArrayMetric(trialData, 'MeanVelocity', @mean);

% Velocity variance - calculate from MeanVelocity array
if isfield(trialData, 'MeanVelocity') && ~isempty(trialData.MeanVelocity)
    validVel = trialData.MeanVelocity(isfinite(trialData.MeanVelocity) & trialData.MeanVelocity > 0);
    if length(validVel) > 1
        conditionStruct.VelocityVariances(end+1) = var(validVel);
    else
        conditionStruct.VelocityVariances(end+1) = NaN;
    end
else
    conditionStruct.VelocityVariances(end+1) = NaN;
end

conditionStruct.MaxAccelerations(end+1) = extractArrayMetric(trialData, 'MaxAccelerations', @max);

% === EXTRACT ML METRICS (SCALARS) ===
end
