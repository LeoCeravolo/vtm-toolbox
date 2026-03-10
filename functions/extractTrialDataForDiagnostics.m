function [allTrialData, allTrialLabels, allTrialMetadata] = extractTrialDataForDiagnostics(data)
% Extract all trial data for comprehensive diagnostics

allTrialData = [];
allTrialLabels = {};
allTrialMetadata = struct();
trialCount = 0;

runs = fieldnames(data);
for runIdx = 1:length(runs)
    runName = runs{runIdx};
    if ~isstruct(data.(runName)), continue; end
    
    trials = fieldnames(data.(runName));
    for trialIdx = 1:length(trials)
        trialName = trials{trialIdx};
        trialData = data.(runName).(trialName);
        
        % Check if trial has sufficient data
        if isfield(trialData, 'StableMeanDisplacement') && ~isempty(trialData.StableMeanDisplacement)
            trialCount = trialCount + 1;
            
            % Store metadata
            allTrialMetadata(trialCount).trialName = trialName;
            allTrialMetadata(trialCount).runName = runName;
            
            if isfield(trialData, 'VoiceType')
                allTrialMetadata(trialCount).voiceType = trialData.VoiceType;
            else
                allTrialMetadata(trialCount).voiceType = 'unknown';
            end
            
            if isfield(trialData, 'Condition')
                allTrialMetadata(trialCount).condition = trialData.Condition;
            else
                allTrialMetadata(trialCount).condition = 'unknown';
            end
            
            % Determine label based on current logic
            if contains(trialName, 'neutral')
                allTrialLabels{trialCount} = 'no_mimicry';
            else
                allTrialLabels{trialCount} = 'mimicry_present';
            end
        end
    end
end

% For now, return empty features - will be filled by enhanced extraction
allTrialData = zeros(trialCount, 7); % Placeholder

end
