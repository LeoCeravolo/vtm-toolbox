function participantConditionData = enhancedConditionAggregation(participantConditionData, data, run, ConditionName, groupConditions)
% ENHANCED condition aggregation that preserves voice type information
% Creates separate conditions like: natural_anger, synthetic_noise_pleasure, etc.

try
    % === STEP 1: Determine emotion condition ===
    emotionCondition = determineConditionType(ConditionName);
    
    if isempty(emotionCondition)
        disp(['⚠ Could not determine emotion condition for: ', ConditionName]);
        return;
    end
    
    % === STEP 2: Determine voice type ===
    runNumber = str2double(regexp(run, '\d+', 'match', 'once'));
    if isempty(runNumber), runNumber = 1; end
    
    % Get trial data to check for VoiceType field
    trialData = data.(run).(ConditionName);
    voiceType = smartDetermineVoiceType(runNumber, ConditionName, trialData);
    
    % === STEP 3: Create combined condition ===
    combinedCondition = [voiceType, '_', emotionCondition];
    
    disp(['🎙️ Enhanced aggregation: ', ConditionName, ' → ', combinedCondition]);
    
    % === STEP 4: Initialize combined condition if needed ===
    if ~isfield(participantConditionData, combinedCondition)
        participantConditionData = initializeEnhancedConditionData(participantConditionData, combinedCondition);
    end
    
    % === STEP 5: Add trial to combined condition ===
    participantConditionData.(combinedCondition).trials{end+1} = ConditionName;
    
    % === STEP 6: Aggregate all metrics using your existing functions ===
    participantConditionData = aggregateDisplacementMetrics(participantConditionData, data, run, ConditionName, combinedCondition);
    participantConditionData = aggregateVelocityMetrics(participantConditionData, data, run, ConditionName, combinedCondition);
    participantConditionData = aggregateMimicryMetrics(participantConditionData, data, run, ConditionName, combinedCondition);
    participantConditionData = aggregateFlowAndEntropy(participantConditionData, data, run, ConditionName, combinedCondition);
    participantConditionData = aggregateAnatomicalMovement(participantConditionData, data, run, ConditionName, combinedCondition);
    
    % === STEP 7: Display progress ===
    numTrials = length(participantConditionData.(combinedCondition).trials);
    disp(['✓ Enhanced condition ', combinedCondition, ' now has ', num2str(numTrials), ' trials']);
    
catch ME
    disp(['❌ Enhanced condition aggregation error: ', ME.message]);
    disp(['  Trial: ', ConditionName]);
    disp(['  Error in: ', ME.stack(1).name, ' at line ', num2str(ME.stack(1).line)]);
end
end
