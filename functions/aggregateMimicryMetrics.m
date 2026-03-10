function participantConditionData = aggregateMimicryMetrics(participantConditionData, data, run, ConditionName, combinedCondition)
% Append stimulus-aligned mimicry and spectral metrics from one trial.
trialData = data.(run).(ConditionName);

scalarFields = {'MimicryResponse', 'MimicryLatency', 'BaselineMovement', ...
                'StimulusMovement', 'SpectralMimicryIndex', 'TemporalCoherence'};

for k = 1:length(scalarFields)
    f = scalarFields{k};
    if isfield(trialData, f) && ~isempty(trialData.(f)) && isfinite(trialData.(f))
        participantConditionData.(combinedCondition).(f)(end+1) = trialData.(f);
    end
end
end
