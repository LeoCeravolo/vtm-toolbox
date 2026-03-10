function participantConditionData = aggregateDisplacementMetrics(participantConditionData, data, run, ConditionName, combinedCondition)
% Append displacement metrics from one trial into the condition-level arrays.
trialData = data.(run).(ConditionName);

if isfield(trialData, 'StableMeanDisplacement') && ~isempty(trialData.StableMeanDisplacement)
    vals = trialData.StableMeanDisplacement;
    vals = vals(isfinite(vals) & vals > 0);
    if ~isempty(vals)
        participantConditionData.(combinedCondition).StableMeanDisplacement(end+1) = mean(vals);
    end
end

if isfield(trialData, 'StableMaxDisplacement') && ~isempty(trialData.StableMaxDisplacement)
    vals = trialData.StableMaxDisplacement;
    vals = vals(isfinite(vals) & vals > 0);
    if ~isempty(vals)
        participantConditionData.(combinedCondition).StableMaxDisplacement(end+1) = max(vals);
    end
end

if isfield(trialData, 'StablePointCount') && ~isempty(trialData.StablePointCount)
    vals = trialData.StablePointCount;
    vals = vals(isfinite(vals));
    if ~isempty(vals)
        participantConditionData.(combinedCondition).StablePointCount(end+1) = mean(vals);
    end
end

if isfield(trialData, 'PointCount') && ~isempty(trialData.PointCount)
    vals = trialData.PointCount;
    vals = vals(isfinite(vals));
    if ~isempty(vals)
        participantConditionData.(combinedCondition).PointCount(end+1) = mean(vals);
    end
end
end
