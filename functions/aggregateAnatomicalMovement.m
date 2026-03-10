function participantConditionData = aggregateAnatomicalMovement(participantConditionData, data, run, ConditionName, combinedCondition)
% Append per-region mean displacement from one trial into condition-level arrays.
trialData = data.(run).(ConditionName);

if ~isfield(trialData, 'AnatomicalMovement'), return; end

regions = fieldnames(trialData.AnatomicalMovement);
for k = 1:length(regions)
    regionName = regions{k};
    vals = trialData.AnatomicalMovement.(regionName);
    vals = vals(isfinite(vals));
    if isempty(vals), continue; end

    if ~isfield(participantConditionData.(combinedCondition).AnatomicalMovement, regionName)
        participantConditionData.(combinedCondition).AnatomicalMovement.(regionName) = [];
    end
    participantConditionData.(combinedCondition).AnatomicalMovement.(regionName)(end+1) = mean(vals);
end
end
