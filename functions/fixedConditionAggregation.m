% %% ADD THIS FUNCTION TO YOUR MAIN SCRIPT (with the other helper functions at the end)
% function participantConditionData = aggregateMLMetrics(participantConditionData, data, run, ConditionName, conditionType)
% % Aggregate ML-specific metrics - CORRECTED FIELD NAMES
% 
% try
%     % ML filtered mean displacement
% %     end
% 
%     % ML filtered MAX DISPLACEMENT (not velocity!) - CORRECTED
% %     end
% 
%     % ML filtered POINT COUNT (not percentage!) - CORRECTED
% %     end
% 
%     % ML PROCESSING STATUS - NEW FIELD
% %         participantConditionData.(conditionType).MLProcessingStatus{end+1} = char(string(mlStatus));
%     end
% 
%     % OPTIONAL: Also try to extract ML accuracy metrics if they exist
% %             participantConditionData.(conditionType).MLAccuracyScores = ...
%                 [participantConditionData.(conditionType).MLAccuracyScores; mlAccuracy.overallAccuracy];
%         end
%     end
% 
%     disp(['✓ ML metrics aggregated for: ', ConditionName, ' → ', conditionType]);
% 
% catch ME
%     disp(['❌ ML metrics aggregation error: ', ME.message]);
%     disp(['  Trial: ', ConditionName]);
%     disp(['  Condition: ', conditionType]);
% end
% end
function participantConditionData = fixedConditionAggregation(participantConditionData, data, run, ConditionName, groupConditions)
% Fixed condition aggregation that properly handles all data types


try
    % Determine condition type from trial name
    conditionType = determineConditionType(ConditionName);

    if isempty(conditionType)
        disp(['⚠ Could not determine condition type for: ', ConditionName]);
        return;
    end

    % Initialize condition if it doesn't exist
    if ~isfield(participantConditionData, conditionType)
        participantConditionData = initializeConditionData(participantConditionData, conditionType);
    end

    % Add this trial to the condition
    participantConditionData.(conditionType).trials{end+1} = ConditionName;

    disp(['🔄 Aggregating ', ConditionName, ' into condition: ', conditionType]);

    % === DISPLACEMENT METRICS AGGREGATION ===
    participantConditionData = aggregateDisplacementMetrics(participantConditionData, data, run, ConditionName, conditionType);

    % === VELOCITY METRICS AGGREGATION ===
    participantConditionData = aggregateVelocityMetrics(participantConditionData, data, run, ConditionName, conditionType);

    % === MIMICRY METRICS AGGREGATION ===
    participantConditionData = aggregateMimicryMetrics(participantConditionData, data, run, ConditionName, conditionType);

    % === FLOW AND ENTROPY AGGREGATION ===
    participantConditionData = aggregateFlowAndEntropy(participantConditionData, data, run, ConditionName, conditionType);

    % === ANATOMICAL MOVEMENT AGGREGATION ===
    participantConditionData = aggregateAnatomicalMovement(participantConditionData, data, run, ConditionName, conditionType);

    % === ML METRICS AGGREGATION ===
    participantConditionData = aggregateMLMetrics(participantConditionData, data, run, ConditionName, conditionType);

    % Display aggregation summary
    numTrials = length(participantConditionData.(conditionType).trials);
    disp(['✓ Condition ', conditionType, ' now has ', num2str(numTrials), ' trials']);

catch ME
    disp(['Condition aggregation error: ', ME.message]);
    disp(['  Condition: ', ConditionName]);
    disp(['  Error in: ', ME.stack(1).name, ' at line ', num2str(ME.stack(1).line)]);
end
end

function participantConditionData = initializeConditionData(participantConditionData, conditionType)
% Initialize all fields for a new condition

participantConditionData.(conditionType) = struct();
participantConditionData.(conditionType).trials = {};

% Traditional metrics
participantConditionData.(conditionType).StableMeanDisplacement = [];
participantConditionData.(conditionType).StableMaxDisplacement = [];
participantConditionData.(conditionType).StablePointCount = [];
participantConditionData.(conditionType).PointCount = [];
participantConditionData.(conditionType).ROIFlowMagnitude = [];
participantConditionData.(conditionType).Entropy = [];
participantConditionData.(conditionType).FlowSummary = struct();

% Velocity metrics
participantConditionData.(conditionType).VelocityMetrics = {};
participantConditionData.(conditionType).PeakVelocities = [];
participantConditionData.(conditionType).MeanVelocities = [];
participantConditionData.(conditionType).VelocityVariances = [];
participantConditionData.(conditionType).MaxAccelerations = [];

% Mimicry metrics
participantConditionData.(conditionType).MimicryResponse = [];
participantConditionData.(conditionType).MimicryLatency = [];
participantConditionData.(conditionType).BaselineMovement = [];
participantConditionData.(conditionType).StimulusMovement = [];
participantConditionData.(conditionType).SpectralMimicryIndex = [];
participantConditionData.(conditionType).FrequencyProfile = [];
participantConditionData.(conditionType).EmotionMimicryIndex = [];
participantConditionData.(conditionType).TemporalCoherence = [];

% Anatomical movement
participantConditionData.(conditionType).AnatomicalMovement = struct();
anatomicalRegions = {'tongue', 'lip', 'pharynx', 'larynx'};
for regionIdx = 1:length(anatomicalRegions)
    regionName = anatomicalRegions{regionIdx};
    participantConditionData.(conditionType).AnatomicalMovement.(regionName) = [];
end

% ML metrics
end

function participantConditionData = aggregateDisplacementMetrics(participantConditionData, data, run, ConditionName, conditionType)
% Aggregate displacement-related metrics

try
    % Traditional displacement metrics
    if isfield(data.(run).(ConditionName), 'StableMeanDisplacement') && ~isempty(data.(run).(ConditionName).StableMeanDisplacement)
        meanDispData = data.(run).(ConditionName).StableMeanDisplacement;
        validDisp = meanDispData(isfinite(meanDispData) & meanDispData > 0);
        if ~isempty(validDisp)
            participantConditionData.(conditionType).StableMeanDisplacement = ...
                [participantConditionData.(conditionType).StableMeanDisplacement; mean(validDisp)];
        end
    end

    if isfield(data.(run).(ConditionName), 'StableMaxDisplacement') && ~isempty(data.(run).(ConditionName).StableMaxDisplacement)
        maxDispData = data.(run).(ConditionName).StableMaxDisplacement;
        validMaxDisp = maxDispData(isfinite(maxDispData) & maxDispData > 0);
        if ~isempty(validMaxDisp)
            participantConditionData.(conditionType).StableMaxDisplacement = ...
                [participantConditionData.(conditionType).StableMaxDisplacement; mean(validMaxDisp)];
        end
    end

catch ME
    disp(['Displacement aggregation error: ', ME.message]);
end
end

function participantConditionData = aggregateVelocityMetrics(participantConditionData, data, run, ConditionName, conditionType)
% Aggregate velocity-related metrics

try
    % Traditional velocity metrics
    if isfield(data.(run).(ConditionName), 'MaxVelocity') && ~isempty(data.(run).(ConditionName).MaxVelocity)
        maxVelData = data.(run).(ConditionName).MaxVelocity;
        validMaxVel = maxVelData(isfinite(maxVelData) & maxVelData > 0);
        if ~isempty(validMaxVel)
            participantConditionData.(conditionType).PeakVelocities = ...
                [participantConditionData.(conditionType).PeakVelocities; max(validMaxVel)];
        end
    end

    if isfield(data.(run).(ConditionName), 'MeanVelocity') && ~isempty(data.(run).(ConditionName).MeanVelocity)
        meanVelData = data.(run).(ConditionName).MeanVelocity;
        validMeanVel = meanVelData(isfinite(meanVelData) & meanVelData > 0);
        if ~isempty(validMeanVel)
            participantConditionData.(conditionType).MeanVelocities = ...
                [participantConditionData.(conditionType).MeanVelocities; mean(validMeanVel)];
        end
    end

    % Enhanced velocity metrics
    if isfield(data.(run).(ConditionName), 'EnhancedVelocityMetrics') && ~isempty(data.(run).(ConditionName).EnhancedVelocityMetrics)
        velocityMetrics = data.(run).(ConditionName).EnhancedVelocityMetrics;
        participantConditionData.(conditionType).VelocityMetrics{end+1} = velocityMetrics;

        if isfield(velocityMetrics, 'trialMaxVelocity') && isfinite(velocityMetrics.trialMaxVelocity)
            participantConditionData.(conditionType).PeakVelocities = ...
                [participantConditionData.(conditionType).PeakVelocities; velocityMetrics.trialMaxVelocity];
        end

        if isfield(velocityMetrics, 'trialMeanVelocity') && isfinite(velocityMetrics.trialMeanVelocity)
            participantConditionData.(conditionType).MeanVelocities = ...
                [participantConditionData.(conditionType).MeanVelocities; velocityMetrics.trialMeanVelocity];
        end
    end

    % Max accelerations
    if isfield(data.(run).(ConditionName), 'MaxAccelerations') && ~isempty(data.(run).(ConditionName).MaxAccelerations)
        maxAccelData = data.(run).(ConditionName).MaxAccelerations;
        validMaxAccel = maxAccelData(isfinite(maxAccelData) & maxAccelData > 0);
        if ~isempty(validMaxAccel)
            participantConditionData.(conditionType).MaxAccelerations = ...
                [participantConditionData.(conditionType).MaxAccelerations; max(validMaxAccel)];
        end
    end

    % Velocity variance calculation
    if isfield(data.(run).(ConditionName), 'AllVelocities') && ~isempty(data.(run).(ConditionName).AllVelocities)
        allVelocitiesInTrial = [];
        for frameIdx = 1:length(data.(run).(ConditionName).AllVelocities)
            if ~isempty(data.(run).(ConditionName).AllVelocities{frameIdx})
                frameVelocities = data.(run).(ConditionName).AllVelocities{frameIdx};
                validFrameVel = frameVelocities(isfinite(frameVelocities));
                allVelocitiesInTrial = [allVelocitiesInTrial; validFrameVel];
            end
        end

        if length(allVelocitiesInTrial) > 1
            velVariance = var(allVelocitiesInTrial);
            if isfinite(velVariance)
                participantConditionData.(conditionType).VelocityVariances = ...
                    [participantConditionData.(conditionType).VelocityVariances; velVariance];
            end
        end
    end

catch ME
    disp(['Velocity aggregation error: ', ME.message]);
end
end

function participantConditionData = aggregateMimicryMetrics(participantConditionData, data, run, ConditionName, conditionType)
% Aggregate mimicry-related metrics

try
    % Mimicry response
    if isfield(data.(run).(ConditionName), 'MimicryResponse') && ~isempty(data.(run).(ConditionName).MimicryResponse)
        mimicryResp = data.(run).(ConditionName).MimicryResponse;
        if isfinite(mimicryResp)
            participantConditionData.(conditionType).MimicryResponse = ...
                [participantConditionData.(conditionType).MimicryResponse; mimicryResp];
        end
    end

    % Mimicry latency
    if isfield(data.(run).(ConditionName), 'MimicryLatency') && ~isempty(data.(run).(ConditionName).MimicryLatency)
        mimicryLat = data.(run).(ConditionName).MimicryLatency;
        if isfinite(mimicryLat)
            participantConditionData.(conditionType).MimicryLatency = ...
                [participantConditionData.(conditionType).MimicryLatency; mimicryLat];
        end
    end

    % Spectral mimicry index
    if isfield(data.(run).(ConditionName), 'SpectralMimicryIndex') && ~isempty(data.(run).(ConditionName).SpectralMimicryIndex)
        spectralIdx = data.(run).(ConditionName).SpectralMimicryIndex;
        if isfinite(spectralIdx)
            participantConditionData.(conditionType).SpectralMimicryIndex = ...
                [participantConditionData.(conditionType).SpectralMimicryIndex; spectralIdx];
        end
    end

    % Temporal coherence
    if isfield(data.(run).(ConditionName), 'TemporalCoherence') && ~isempty(data.(run).(ConditionName).TemporalCoherence)
        tempCoh = data.(run).(ConditionName).TemporalCoherence;
        if isfinite(tempCoh)
            participantConditionData.(conditionType).TemporalCoherence = ...
                [participantConditionData.(conditionType).TemporalCoherence; tempCoh];
        end
    end

catch ME
    disp(['Mimicry aggregation error: ', ME.message]);
end
end

function participantConditionData = aggregateFlowAndEntropy(participantConditionData, data, run, ConditionName, conditionType)
% Aggregate flow and entropy metrics

try
    % Flow magnitude
    if isfield(data.(run).(ConditionName), 'ROIFlowMagnitude') && ~isempty(data.(run).(ConditionName).ROIFlowMagnitude)
        flowData = data.(run).(ConditionName).ROIFlowMagnitude;
        validFlow = flowData(isfinite(flowData) & flowData >= 0);
        if ~isempty(validFlow)
            participantConditionData.(conditionType).ROIFlowMagnitude = ...
                [participantConditionData.(conditionType).ROIFlowMagnitude; mean(validFlow)];
        end
    end

    % Entropy
    if isfield(data.(run).(ConditionName), 'Entropy') && ~isempty(data.(run).(ConditionName).Entropy)
        entropyData = data.(run).(ConditionName).Entropy;
        validEntropy = entropyData(isfinite(entropyData) & entropyData >= 0);
        if ~isempty(validEntropy)
            participantConditionData.(conditionType).Entropy = ...
                [participantConditionData.(conditionType).Entropy; mean(validEntropy)];
        end
    end

catch ME
    disp(['Flow/Entropy aggregation error: ', ME.message]);
end
end

function participantConditionData = aggregateAnatomicalMovement(participantConditionData, data, run, ConditionName, conditionType)
% Aggregate anatomical movement data

try
    if isfield(data.(run).(ConditionName), 'AnatomicalMovement') && ~isempty(data.(run).(ConditionName).AnatomicalMovement)
        anatMovement = data.(run).(ConditionName).AnatomicalMovement;
        anatFieldNames = fieldnames(anatMovement);

        for regionIdx = 1:length(anatFieldNames)
            regionName = anatFieldNames{regionIdx};
            if isfield(anatMovement, regionName) && ~isempty(anatMovement.(regionName))
                regionData = anatMovement.(regionName);
                validRegionData = regionData(isfinite(regionData) & regionData > 0);
                if ~isempty(validRegionData)
                    % Ensure anatomical movement structure exists
                    if ~isfield(participantConditionData.(conditionType), 'AnatomicalMovement')
                        participantConditionData.(conditionType).AnatomicalMovement = struct();
                    end
                    if ~isfield(participantConditionData.(conditionType).AnatomicalMovement, regionName)
                        participantConditionData.(conditionType).AnatomicalMovement.(regionName) = [];
                    end

                    participantConditionData.(conditionType).AnatomicalMovement.(regionName) = ...
                        [participantConditionData.(conditionType).AnatomicalMovement.(regionName); mean(validRegionData)];
                end
            end
        end
    end

catch ME
    disp(['Anatomical movement aggregation error: ', ME.message]);
end
end

function participantConditionData = aggregateMLMetrics(participantConditionData, data, run, ConditionName, conditionType)
% Aggregate ML-specific metrics

try
    % ML filtered displacement
    end

    % ML filtered velocity
    end

    % ML mimicry percentage
    end

    % ML mimicry frame count
    end

catch ME
    disp(['ML metrics aggregation error: ', ME.message]);
end
end