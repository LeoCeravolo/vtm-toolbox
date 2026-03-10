function participantConditionData = aggregateFlowAndEntropy(participantConditionData, data, run, ConditionName, combinedCondition)
% Append optical flow and entropy summary metrics from one trial.
trialData = data.(run).(ConditionName);

if isfield(trialData, 'ROIFlowMagnitude') && ~isempty(trialData.ROIFlowMagnitude)
    vals = trialData.ROIFlowMagnitude;
    vals = vals(isfinite(vals));
    if ~isempty(vals)
        participantConditionData.(combinedCondition).ROIFlowMagnitude(end+1) = mean(vals);
    end
end

if isfield(trialData, 'Entropy') && ~isempty(trialData.Entropy)
    vals = trialData.Entropy;
    vals = vals(isfinite(vals));
    if ~isempty(vals)
        participantConditionData.(combinedCondition).Entropy(end+1) = mean(vals);
    end
end
end
