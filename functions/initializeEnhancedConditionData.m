function participantConditionData = initializeEnhancedConditionData(participantConditionData, combinedCondition)
% Initialize all fields for a new combined condition entry.

participantConditionData.(combinedCondition) = struct();
participantConditionData.(combinedCondition).trials = {};

% Displacement
participantConditionData.(combinedCondition).StableMeanDisplacement = [];
participantConditionData.(combinedCondition).StableMaxDisplacement   = [];
participantConditionData.(combinedCondition).StablePointCount        = [];
participantConditionData.(combinedCondition).PointCount              = [];

% Optical flow and entropy
participantConditionData.(combinedCondition).ROIFlowMagnitude = [];
participantConditionData.(combinedCondition).Entropy          = [];
participantConditionData.(combinedCondition).FlowSummary      = struct();

% Velocity
participantConditionData.(combinedCondition).VelocityMetrics    = {};
participantConditionData.(combinedCondition).PeakVelocities     = [];
participantConditionData.(combinedCondition).MeanVelocities     = [];
participantConditionData.(combinedCondition).VelocityVariances  = [];
participantConditionData.(combinedCondition).MaxAccelerations   = [];

% Mimicry
participantConditionData.(combinedCondition).MimicryResponse     = [];
participantConditionData.(combinedCondition).MimicryLatency      = [];
participantConditionData.(combinedCondition).BaselineMovement    = [];
participantConditionData.(combinedCondition).StimulusMovement    = [];
participantConditionData.(combinedCondition).SpectralMimicryIndex = [];
participantConditionData.(combinedCondition).FrequencyProfile    = [];
participantConditionData.(combinedCondition).EmotionMimicryIndex = [];
participantConditionData.(combinedCondition).TemporalCoherence   = [];

% Anatomical regions (must match defineAnatomicalROIs.m)
participantConditionData.(combinedCondition).AnatomicalMovement = struct();
for regionName = {'epiglottis', 'vocal_folds', 'pharynx', 'larynx'}
    participantConditionData.(combinedCondition).AnatomicalMovement.(regionName{1}) = [];
end
end
