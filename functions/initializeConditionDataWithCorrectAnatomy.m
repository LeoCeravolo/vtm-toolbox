function participantConditionData = initializeConditionDataWithCorrectAnatomy(conditions)
    participantConditionData = struct();
    
    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        participantConditionData.(condName) = struct();
        participantConditionData.(condName).trials = {};
        participantConditionData.(condName).StableMeanDisplacement = [];
        participantConditionData.(condName).StableMaxDisplacement = [];
        participantConditionData.(condName).StablePointCount = [];
        participantConditionData.(condName).PointCount = [];
        participantConditionData.(condName).ROIFlowMagnitude = [];
        participantConditionData.(condName).Entropy = [];
        participantConditionData.(condName).FlowSummary = struct();
        
        % === CORRECTED: Only include visible anatomical regions ===
        participantConditionData.(condName).AnatomicalMovement = struct();
        visibleRegions = {'pharynx', 'larynx', 'epiglottis', 'vocal_folds'};
        for regionIdx = 1:length(visibleRegions)
            regionName = visibleRegions{regionIdx};
            participantConditionData.(condName).AnatomicalMovement.(regionName) = [];
        end
        
        % Mimicry and velocity metrics
        participantConditionData.(condName).MimicryResponse = [];
        participantConditionData.(condName).MimicryLatency = [];
        participantConditionData.(condName).VelocityMetrics = {};
        participantConditionData.(condName).PeakVelocities = [];
        participantConditionData.(condName).MeanVelocities = [];
    end
end
