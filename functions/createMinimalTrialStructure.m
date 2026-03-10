function minimalStruct = createMinimalTrialStructure(trialName, runNumber)
% Create a minimal trial structure when processing fails.
% Uses [] (not NaN) for array fields so the export function skips this trial cleanly.
if nargin < 2, runNumber = 1; end

minimalStruct = struct();
minimalStruct.VoiceType   = determineVoiceType(runNumber, trialName);
minimalStruct.Condition   = extractConditionFromTrialName_Enhanced(trialName, runNumber);
minimalStruct.RunNumber   = runNumber;

% Use [] so extractFrameLevelData_Enhanced returns empty and skips the trial
minimalStruct.StableMeanDisplacement = [];
minimalStruct.StableMaxDisplacement  = [];
minimalStruct.StablePointCount       = [];
minimalStruct.PointCount             = [];
minimalStruct.MeanVelocity           = [];
minimalStruct.MaxVelocity            = [];
minimalStruct.ROIFlowMagnitude       = [];
minimalStruct.Entropy                = [];
minimalStruct.TrackingQuality        = [];
minimalStruct.PointLossRate          = [];
minimalStruct.AnatomicalMovement     = struct();
end
