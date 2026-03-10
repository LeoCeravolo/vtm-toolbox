function conditionStruct = initializeConditionDataStructure()
% Initialize condition structure with all metrics
conditionStruct = struct();

conditionStruct.trials = {};

% Traditional metrics (arrays from your data)
conditionStruct.StableMeanDisplacement = [];
conditionStruct.StableMaxDisplacement = [];
conditionStruct.ROIFlowMagnitude = [];
conditionStruct.Entropy = [];

% Velocity metrics
conditionStruct.PeakVelocities = [];
conditionStruct.MeanVelocities = [];
conditionStruct.VelocityVariances = [];
conditionStruct.MaxAccelerations = [];

% ML metrics (scalars from your data)
end
