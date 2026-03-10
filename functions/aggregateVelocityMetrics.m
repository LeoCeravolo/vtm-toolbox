function participantConditionData = aggregateVelocityMetrics(participantConditionData, data, run, ConditionName, combinedCondition)
% Append velocity and acceleration metrics from one trial into condition-level arrays.
trialData = data.(run).(ConditionName);

if isfield(trialData, 'MaxVelocity') && ~isempty(trialData.MaxVelocity)
    vals = trialData.MaxVelocity;
    vals = vals(isfinite(vals) & vals > 0);
    if ~isempty(vals)
        participantConditionData.(combinedCondition).PeakVelocities(end+1) = max(vals);
    end
end

if isfield(trialData, 'MeanVelocity') && ~isempty(trialData.MeanVelocity)
    vals = trialData.MeanVelocity;
    vals = vals(isfinite(vals) & vals > 0);
    if ~isempty(vals)
        participantConditionData.(combinedCondition).MeanVelocities(end+1)   = mean(vals);
        participantConditionData.(combinedCondition).VelocityVariances(end+1) = var(vals);
    end
end

if isfield(trialData, 'MaxAccelerations') && ~isempty(trialData.MaxAccelerations)
    vals = trialData.MaxAccelerations;
    vals = vals(isfinite(vals) & vals > 0);
    if ~isempty(vals)
        participantConditionData.(combinedCondition).MaxAccelerations(end+1) = max(vals);
    end
end
end
