%% Vocal Tract Mimicry (VTM) Toolbox — Main Analysis Script
% =========================================================================
% Analyses endoscopic video recordings of the vocal tract to quantify
% movement kinematics during auditory emotion perception tasks.
%
% PIPELINE:
%   For each pre-cut trial video clip, tracks a dense grid of points
%   (Lucas-Kanade), computes optical flow, and extracts frame-level
%   displacement, velocity, and anatomical region metrics. Results are
%   exported as a tab-delimited .txt file for downstream statistical
%   analysis (e.g. in R).
%
% INPUT:
%   Pre-cut per-trial video clips (.mp4), organised as:
%     <rootFolder>/
%       <participantID>/
%         Run1/   emotion_trialnumber.mp4  (one file per trial)
%         Run2/
%         Run3/
%   Video segmentation (splitting continuous recordings into per-trial
%   clips) should be done beforehand using your own logfile/timing scripts.
%
% OUTPUT:
%   <participant>_FrameLevel_Enhanced_<timestamp>.txt
%   One row per frame per trial. Columns: see getFrameLevelHeaders_Enhanced.m
%
% DEPENDENCIES:
%   MATLAB Image Processing Toolbox, Computer Vision Toolbox
%   All functions in the /functions subfolder must be on the MATLAB path.
%
% USAGE:
%   1. Set fixed parameters (frame rate, ROI, time windows) in the
%      USER CONFIGURATION section below.
%   2. Run the script — GUI dialogs will ask for:
%        - Root data folder
%        - Participant subfolders to process
%        - Runs (1 / 2 / 3) to process
%
% Author: Leonardo Ceravolo — initial version June 2025
% =========================================================================

tic;

%% =========================================================================
%  USER CONFIGURATION — fixed parameters (no paths needed here)
%  =========================================================================
cfg = struct();

% Acquisition frame rate (fps)
cfg.frameRate = 25;

% ROI rectangle [x, y, width, height] in pixels — adjust to your camera setup.
% This defines the region of the image used for all tracking and flow analysis.
% Tip: use imrect() on a sample frame to determine coordinates interactively.
cfg.roi = [226, 3, 1467, 1077];

% Mimicry analysis time windows (ms relative to stimulus onset)
cfg.mimicryWindowMs  = [50, 900];   % expected mimicry response window
cfg.baselineWindowMs = [-200, -50]; % pre-stimulus baseline

% Adaptive tracking: fraction of lost points that triggers grid refresh
cfg.adaptiveTrackingThreshold = 0.3;

% Frequency bands for spectral mimicry analysis [Hz]
cfg.frequencyBands = [0.5, 2; 2, 8; 8, 15]; % Low / Speech / High

% Save per-run .mat files (DataSummary_<participant>_Run<N>.mat in SummaryReports/).
% These preserve the full data struct for post-hoc inspection but can be large
% (100-500 MB per run). Set to false to skip and keep only the TXT export.
cfg.saveMatFiles = false;

% =========================================================================
%  END OF USER CONFIGURATION
%  =========================================================================

%% --- Select base directory ---
cfg.baseDir = uigetdir(pwd, 'Select the root data folder (containing participant subfolders)');
if cfg.baseDir == 0
    error('No folder selected. Aborting.');
end

cfg.functionsDir   = fullfile(cfg.baseDir, 'functions');
cfg.annotationFile = fullfile(cfg.baseDir, 'AnnotationTemplate.xlsx');

addpath(cfg.functionsDir);
cd(cfg.baseDir);

%% --- Discover and select participant folders ---
allFolders   = dir(cfg.baseDir);
allFolders   = allFolders([allFolders.isdir]);                     % keep directories only
allFolders   = allFolders(~ismember({allFolders.name}, {'.','..'})); % drop . and ..
folderNames  = {allFolders.name};

if isempty(folderNames)
    error('No subfolders found in: %s', cfg.baseDir);
end

[selectedIdx, ok] = listdlg( ...
    'ListString',     folderNames, ...
    'SelectionMode',  'multiple', ...
    'Name',           'Select participants', ...
    'PromptString',   'Select one or more participant folders:', ...
    'ListSize',       [300, 300]);

if ~ok || isempty(selectedIdx)
    error('No participants selected. Aborting.');
end

participants    = allFolders(selectedIdx);
iterParticipant = 1:length(participants); % index into selected list only

%% --- Select runs ---
[runIdx, ok] = listdlg( ...
    'ListString',    {'Run 1', 'Run 2', 'Run 3'}, ...
    'SelectionMode', 'multiple', ...
    'Name',          'Select runs', ...
    'PromptString',  'Select runs to process:', ...
    'ListSize',      [200, 120]);

if ~ok || isempty(runIdx)
    error('No runs selected. Aborting.');
end
iterRun = runIdx;

%% --- Assemble mimicryConfig ---
mimicryConfig = struct();
mimicryConfig.frameRate                  = cfg.frameRate;
mimicryConfig.mimicryWindowMs            = cfg.mimicryWindowMs;
mimicryConfig.baselineWindowMs           = cfg.baselineWindowMs;
mimicryConfig.adaptiveTrackingThreshold  = cfg.adaptiveTrackingThreshold;
mimicryConfig.frequencyBands             = cfg.frequencyBands;

%% =====================================================================
%  KINEMATIC ANALYSIS
%  =====================================================================
data = struct;
disp('=== Starting kinematic analysis ===');

groupData = struct();
groupData.participants = {};
groupData.conditions   = {'neutral', 'pleasure', 'happiness', 'anger'};
groupData.mimicryConfig = mimicryConfig;

for i = iterParticipant
    participant = participants(i).name;
    cd(cfg.baseDir);
    outputPaths = setupReorganizedOutputDirectories(participant);
    pDir = fullfile(cfg.baseDir, participant);

    cd(pDir);
    runs = dir('Run*');

    disp(['=== Processing participant: ', participant, ' ===']);

    % Initialise per-participant condition data structure
    participantConditionData = struct();
    for condIdx = 1:length(groupData.conditions)
        condName = groupData.conditions{condIdx};
        participantConditionData.(condName) = struct();
        participantConditionData.(condName).trials               = {};
        participantConditionData.(condName).StableMeanDisplacement = [];
        participantConditionData.(condName).StableMaxDisplacement  = [];
        participantConditionData.(condName).StablePointCount       = [];
        participantConditionData.(condName).PointCount             = [];
        participantConditionData.(condName).ROIFlowMagnitude       = [];
        participantConditionData.(condName).Entropy                = [];
        participantConditionData.(condName).FlowSummary            = struct();
        participantConditionData.(condName).AnatomicalMovement     = struct();
        anatomicalRegions = {'epiglottis', 'vocal_folds', 'pharynx', 'larynx'};
        for rIdx = 1:length(anatomicalRegions)
            participantConditionData.(condName).AnatomicalMovement.(anatomicalRegions{rIdx}) = [];
        end
        participantConditionData.(condName).MimicryResponse      = [];
        participantConditionData.(condName).MimicryLatency        = [];
        participantConditionData.(condName).BaselineMovement      = [];
        participantConditionData.(condName).StimulusMovement      = [];
        participantConditionData.(condName).SpectralMimicryIndex  = [];
        participantConditionData.(condName).FrequencyProfile      = [];
        participantConditionData.(condName).EmotionMimicryIndex   = [];
        participantConditionData.(condName).TemporalCoherence     = [];
        participantConditionData.(condName).VelocityMetrics       = {};
        participantConditionData.(condName).PeakVelocities        = [];
        participantConditionData.(condName).MeanVelocities        = [];
        participantConditionData.(condName).VelocityVariances     = [];
        participantConditionData.(condName).MaxAccelerations      = [];
    end

    for j = iterRun
        run    = runs(j).name;
        rundir = fullfile(pDir, run);
        cd(rundir);

        if j == 3
            TheNewFiles = [dir('*anger*.mp4'); dir('*neutral*.mp4'); ...
                dir('*happiness*.mp4'); dir('*pleasure*.mp4'); ...
                dir('*noize*.mp4');    dir('*shuffled*.mp4')];
        else
            TheNewFiles = [dir('*anger*.mp4'); dir('*neutral*.mp4'); ...
                dir('*happiness*.mp4'); dir('*pleasure*.mp4')];
        end

        data.(run) = [];

        disp(['--- Run: ', run, ' (', num2str(numel(TheNewFiles)), ' trials) ---']);

        for n = 1:numel(TheNewFiles)
            ConditionName = ['trial_', num2str(n)]; % fallback if error occurs before name is parsed
            try
                TheDetector     = vision.CascadeObjectDetector();
                TheNewvideoReader = VideoReader(TheNewFiles(n).name);

                if startsWith(TheNewFiles(n).name, '6_')
                    ConditionName = [TheNewvideoReader.name(3:end-4), '_', TheNewvideoReader.name(1)];
                else
                    ConditionName = [TheNewvideoReader.name(4:end-4), '_', TheNewvideoReader.name(1:2)];
                end

                voiceType = determineVoiceType(j, ConditionName);
                condition = extractConditionFromTrialName_Enhanced(ConditionName, j);

                disp(['  Trial ', num2str(n), ': ', ConditionName, ...
                    ' | voiceType=', voiceType, ' | condition=', condition]);

                % Store trial metadata
                data.(run).(ConditionName).VoiceType   = voiceType;
                data.(run).(ConditionName).RunNumber   = j;
                data.(run).(ConditionName).Condition   = condition;
                data.(run).(ConditionName).TrialNumber = n;

                % Read first frame and define ROI + anatomical sub-regions
                videoFrame   = readFrame(TheNewvideoReader);
                TheRectangleROI = cfg.roi;
                anatomicalROIs  = defineAnatomicalROIs(TheRectangleROI);

                % Initialise per-trial data fields
                data.(run).(ConditionName).AnatomicalMovement = struct();
                for regionName = fieldnames(anatomicalROIs)'
                    data.(run).(ConditionName).AnatomicalMovement.(regionName{1}) = [];
                end

                data.(run).(ConditionName).StableGridPoints   = {};
                data.(run).(ConditionName).StablePointIndices  = {};
                data.(run).(ConditionName).StableDisplacements = {};
                data.(run).(ConditionName).StableMeanDisplacement = [];
                data.(run).(ConditionName).StableMaxDisplacement  = [];
                data.(run).(ConditionName).StablePointCount       = [];
                data.(run).(ConditionName).PointCount             = [];
                data.(run).(ConditionName).Entropy                = [];
                data.(run).(ConditionName).AllDisplacements       = {};
                data.(run).(ConditionName).AllVelocities          = {};
                data.(run).(ConditionName).FastMovementIndices    = {};
                data.(run).(ConditionName).DisplacementThreshold  = [];
                data.(run).(ConditionName).VelocityThreshold      = [];
                data.(run).(ConditionName).MeanVelocity           = [];
                data.(run).(ConditionName).MaxVelocity            = [];
                data.(run).(ConditionName).MovementClassification = struct();
                data.(run).(ConditionName).PointLossRate          = [];
                data.(run).(ConditionName).TrackingQuality        = [];
                data.(run).(ConditionName).ROIFlowMagnitude       = [];
                data.(run).(ConditionName).ROIFlowDirection       = [];
                data.(run).(ConditionName).FlowVx                 = [];
                data.(run).(ConditionName).FlowVy                 = [];

                % Stimulus window setup
                stimulusOnsetFrame = 1;
                NFrAmEs = TheNewvideoReader.NumFrames;
                stimulusDurationFrames = min(NFrAmEs, round(2.5 * mimicryConfig.frameRate));
                baselineWindow = max(1, stimulusOnsetFrame + ...
                    round(mimicryConfig.baselineWindowMs * mimicryConfig.frameRate / 1000));
                mimicryWindow  = max(1, min( ...
                    stimulusOnsetFrame + round(mimicryConfig.mimicryWindowMs * mimicryConfig.frameRate / 1000), ...
                    NFrAmEs));

                data.(run).(ConditionName).StimulusOnsetFrame = stimulusOnsetFrame;
                data.(run).(ConditionName).BaselineWindow     = baselineWindow;
                data.(run).(ConditionName).MimicryWindow      = mimicryWindow;

                % Refresh counters (trial-level scalars, repeated in frame-level output)
                lossTriggeredRefreshCount = 0;
                totalRefreshCount         = 0;

                % Create dense tracking grid
                gridSpacing = 8;
                ThePoints   = createDenseGrid(TheRectangleROI, gridSpacing);

                % Initialise point tracker
                trackerAllPoints = vision.PointTracker( ...
                    'MaxBidirectionalError', 1.5, ...
                    'BlockSize',             [25 25], ...
                    'NumPyramidLevels',      3);
                initialize(trackerAllPoints, ThePoints, videoFrame);

                % Adaptive refresh state
                adaptiveRefreshInterval = 5;
                framesSinceRefresh      = 0;
                pointLossHistory        = [];

                % Optical flow accumulator
                testFrame = im2gray(videoFrame);
                roiTest   = imcrop(testFrame, TheRectangleROI);
                [roiHeight, roiWidth] = size(roiTest);
                magnitudeAccumulator = zeros(roiHeight, roiWidth, 'single');
                vxAccumulator        = zeros(roiHeight, roiWidth, 'single');
                vyAccumulator        = zeros(roiHeight, roiWidth, 'single');
                flowFrameCount       = 0;

                opticFlow    = opticalFlowLK('NoiseThreshold', 0.005);
                FrameCount   = 0;
                previousFrame = [];

                TheNewvideoReader.CurrentTime = 0;

                % === MAIN FRAME LOOP ===
                while hasFrame(TheNewvideoReader)
                    FrameCount         = FrameCount + 1;
                    framesSinceRefresh = framesSinceRefresh + 1;

                    videoFrame = readFrame(TheNewvideoReader);
                    grayFrame  = im2gray(videoFrame);

                    % Adaptive tracker refresh
                    shouldRefresh = false;
                    if FrameCount > 1
                        currentPointLoss = sum(~isFound) / length(isFound);
                        pointLossHistory(end+1) = currentPointLoss;
                        data.(run).(ConditionName).PointLossRate(FrameCount) = currentPointLoss;

                        if currentPointLoss > mimicryConfig.adaptiveTrackingThreshold
                            shouldRefresh = true;
                            lossTriggeredRefreshCount = lossTriggeredRefreshCount + 1;
                            adaptiveRefreshInterval = max(3, adaptiveRefreshInterval - 1);
                        elseif framesSinceRefresh >= adaptiveRefreshInterval
                            shouldRefresh = true;
                            adaptiveRefreshInterval = min(8, adaptiveRefreshInterval + 1);
                        end
                    end

                    if shouldRefresh
                        try
                            release(trackerAllPoints);
                            newGridPoints    = createDenseGrid(TheRectangleROI, gridSpacing);
                            trackerAllPoints = vision.PointTracker( ...
                                'MaxBidirectionalError', 1.5, ...
                                'BlockSize', [25 25], 'NumPyramidLevels', 3);
                            initialize(trackerAllPoints, newGridPoints, videoFrame);
                            ThePoints          = newGridPoints;
                            framesSinceRefresh = 0;
                            totalRefreshCount  = totalRefreshCount + 1;
                        catch ME
                            disp(['  Adaptive refresh failed at frame ', num2str(FrameCount), ': ', ME.message]);
                            continue;
                        end
                    end

                    % Track points
                    try
                        [ThePoints, isFound] = step(trackerAllPoints, videoFrame);
                    catch ME
                        try
                            release(trackerAllPoints);
                            newGridPoints    = createDenseGrid(TheRectangleROI, gridSpacing);
                            trackerAllPoints = vision.PointTracker( ...
                                'MaxBidirectionalError', 1.5, ...
                                'BlockSize', [25 25], 'NumPyramidLevels', 3);
                            initialize(trackerAllPoints, newGridPoints, videoFrame);
                            [ThePoints, isFound] = step(trackerAllPoints, videoFrame);
                            framesSinceRefresh = 0;
                        catch ME2
                            disp(['  Emergency tracker reinit failed: ', ME2.message]);
                            continue;
                        end
                    end

                    % Tracking quality
                    TheVisiblePoints = ThePoints(isFound, :);
                    data.(run).(ConditionName).PointCount(FrameCount) = size(TheVisiblePoints, 1);
                    if FrameCount > 1
                        data.(run).(ConditionName).TrackingQuality(FrameCount) = ...
                            size(TheVisiblePoints, 1) / size(ThePoints, 1);
                    end

                    % Displacement and velocity from stable common points
                    if size(TheVisiblePoints, 1) >= 15 && FrameCount > 1
                        data.(run).(ConditionName).StableGridPoints{FrameCount}   = TheVisiblePoints;
                        data.(run).(ConditionName).StablePointIndices{FrameCount} = find(isFound);

                        if ~isempty(data.(run).(ConditionName).StableGridPoints{FrameCount-1})
                            prevStablePoints = data.(run).(ConditionName).StableGridPoints{FrameCount-1};
                            currStablePoints = TheVisiblePoints;
                            prevIndices = data.(run).(ConditionName).StablePointIndices{FrameCount-1};
                            currIndices = data.(run).(ConditionName).StablePointIndices{FrameCount};

                            [~, prevIdx, currIdx] = intersect(prevIndices, currIndices);

                            if length(prevIdx) >= 15
                                commonPrevPoints  = prevStablePoints(prevIdx, :);
                                commonCurrPoints  = currStablePoints(currIdx, :);
                                stableDisplacements = sqrt(sum((commonCurrPoints - commonPrevPoints).^2, 2));

                                frameRate         = mimicryConfig.frameRate;
                                velocities        = stableDisplacements * frameRate;
                                displacementMean  = mean(stableDisplacements);
                                displacementStd   = std(stableDisplacements);
                                enhancedThreshold = displacementMean + 0.5 * displacementStd;

                                stimulusOnset   = 1;
                                timeFromStimulus = abs(FrameCount - stimulusOnset) / frameRate;
                                isNearStimulus  = timeFromStimulus < 1.0;

                                velocityThreshold = prctile(velocities, 70);
                                isHighVelocity    = velocities > velocityThreshold;

                                if isNearStimulus
                                    fastMovementIndices = (stableDisplacements > displacementMean) & isHighVelocity;
                                else
                                    fastMovementIndices = (stableDisplacements > enhancedThreshold) & isHighVelocity;
                                end

                                try
                                    enhancedDisplacementAndVelocityProcessing(data, run, ConditionName, ...
                                        FrameCount, stableDisplacements, velocities, fastMovementIndices, frameRate);
                                catch ME
                                    disp(['  enhancedDisplacementAndVelocityProcessing error: ', ME.message]);
                                end

                                data.(run).(ConditionName).AllDisplacements{FrameCount}    = stableDisplacements;
                                data.(run).(ConditionName).AllVelocities{FrameCount}       = velocities;
                                data.(run).(ConditionName).FastMovementIndices{FrameCount} = fastMovementIndices;
                                data.(run).(ConditionName).DisplacementThreshold(FrameCount) = displacementMean;
                                data.(run).(ConditionName).VelocityThreshold(FrameCount)     = velocityThreshold;

                                % Anatomical region displacements
                                regionNames = fieldnames(anatomicalROIs);
                                for regionIdx = 1:length(regionNames)
                                    regionName = regionNames{regionIdx};
                                    regionROI  = anatomicalROIs.(regionName);
                                    regionIdx2 = findPointsInROI(commonCurrPoints, regionROI);
                                    if ~isfield(data.(run).(ConditionName).AnatomicalMovement, regionName)
                                        data.(run).(ConditionName).AnatomicalMovement.(regionName) = [];
                                    end
                                    if ~isempty(regionIdx2)
                                        regionDisp = stableDisplacements(regionIdx2);
                                        data.(run).(ConditionName).AnatomicalMovement.(regionName)(FrameCount) = mean(regionDisp);
                                    else
                                        data.(run).(ConditionName).AnatomicalMovement.(regionName)(FrameCount) = NaN;
                                    end
                                end

                                % Store displacement / velocity summaries
                                if sum(fastMovementIndices) >= 5
                                    fastDisplacements = stableDisplacements(fastMovementIndices);
                                    fastVelocities    = velocities(fastMovementIndices);

                                    data.(run).(ConditionName).StableDisplacements{FrameCount}    = fastDisplacements;
                                    data.(run).(ConditionName).StableMeanDisplacement(FrameCount) = mean(fastDisplacements);
                                    data.(run).(ConditionName).StableMaxDisplacement(FrameCount)  = max(fastDisplacements);
                                    data.(run).(ConditionName).StablePointCount(FrameCount)       = length(fastDisplacements);
                                    data.(run).(ConditionName).MeanVelocity(FrameCount)           = mean(fastVelocities);
                                    data.(run).(ConditionName).MaxVelocity(FrameCount)            = max(fastVelocities);

                                    % Acceleration
                                    if FrameCount > 2 && ...
                                            length(data.(run).(ConditionName).AllVelocities) >= (FrameCount-1) && ...
                                            ~isempty(data.(run).(ConditionName).AllVelocities{FrameCount-1})
                                        prevVel  = data.(run).(ConditionName).AllVelocities{FrameCount-1};
                                        minLen   = min(length(velocities), length(prevVel));
                                        if minLen > 0
                                            accels = (velocities(1:minLen) - prevVel(1:minLen)) * frameRate;
                                            validA = accels(isfinite(accels));
                                            if ~isempty(validA)
                                                if ~isfield(data.(run).(ConditionName), 'MaxAccelerations')
                                                    data.(run).(ConditionName).MaxAccelerations = [];
                                                end
                                                data.(run).(ConditionName).MaxAccelerations(FrameCount) = max(abs(validA));
                                            end
                                        end
                                    end

                                    data.(run).(ConditionName).MovementClassification(FrameCount).TotalPoints   = length(prevIdx);
                                    data.(run).(ConditionName).MovementClassification(FrameCount).FastMovements = sum(fastMovementIndices);
                                    data.(run).(ConditionName).MovementClassification(FrameCount).SlowMovements = length(prevIdx) - sum(fastMovementIndices);
                                else
                                    data.(run).(ConditionName).StableDisplacements{FrameCount}    = stableDisplacements;
                                    data.(run).(ConditionName).StableMeanDisplacement(FrameCount) = NaN;
                                    data.(run).(ConditionName).StableMaxDisplacement(FrameCount)  = NaN;
                                    data.(run).(ConditionName).StablePointCount(FrameCount)       = 0;
                                    data.(run).(ConditionName).MeanVelocity(FrameCount)           = mean(velocities);
                                    data.(run).(ConditionName).MaxVelocity(FrameCount)            = max(velocities);
                                end
                            end
                        end
                    end

                    % Optical flow
                    if ~isempty(previousFrame)
                        try
                            flow      = estimateFlow(opticFlow, grayFrame);
                            magnitude = sqrt(flow.Vx.^2 + flow.Vy.^2);
                            direction = atan2(flow.Vy, flow.Vx);

                            roiMagnitude = imcrop(magnitude,  TheRectangleROI);
                            roiDirection = imcrop(direction,  TheRectangleROI);
                            roiVx        = imcrop(flow.Vx,    TheRectangleROI);
                            roiVy        = imcrop(flow.Vy,    TheRectangleROI);

                            magnitudeAccumulator = magnitudeAccumulator + single(roiMagnitude);
                            vxAccumulator        = vxAccumulator        + single(roiVx);
                            vyAccumulator        = vyAccumulator        + single(roiVy);
                            flowFrameCount       = flowFrameCount + 1;

                            data.(run).(ConditionName).ROIFlowMagnitude(end+1) = mean(roiMagnitude(:));
                            data.(run).(ConditionName).ROIFlowDirection(end+1) = mean(roiDirection(:));
                            data.(run).(ConditionName).FlowVx(end+1)           = mean(roiVx(:));
                            data.(run).(ConditionName).FlowVy(end+1)           = mean(roiVy(:));
                        catch ME
                            disp(['  Optical flow error: ', ME.message]);
                        end
                    end

                    % Entropy
                    try
                        data.(run).(ConditionName).Entropy(end+1) = entropy(videoFrame);
                    catch ME
                        disp(['  Entropy error: ', ME.message]);
                    end

                    previousFrame = grayFrame;
                end % end main frame loop

                % --- Post-processing for this trial ---
                try
                    % Velocity processing
                    improvedTrialLevelVelocityProcessing(data, run, ConditionName, mimicryConfig.frameRate);
                catch ME
                    disp(['  Velocity processing error: ', ME.message]);
                end

                % Flow summaries
                if ~isempty(data.(run).(ConditionName).ROIFlowMagnitude)
                    flowMag = data.(run).(ConditionName).ROIFlowMagnitude;
                    flowMag = flowMag(isfinite(flowMag));
                    if ~isempty(flowMag)
                        data.(run).(ConditionName).FlowSummary.meanMagnitude = mean(flowMag);
                        data.(run).(ConditionName).FlowSummary.maxMagnitude  = max(flowMag);
                        data.(run).(ConditionName).FlowSummary.stdMagnitude  = std(flowMag);
                        data.(run).(ConditionName).FlowSummary.totalMotion   = sum(flowMag);
                    end
                end

                % Entropy summaries
                if ~isempty(data.(run).(ConditionName).Entropy)
                    entropyData = data.(run).(ConditionName).Entropy;
                    entropyData = entropyData(isfinite(entropyData));
                    if ~isempty(entropyData)
                        data.(run).(ConditionName).EntropyAvg = mean(entropyData);
                        data.(run).(ConditionName).EntropyVar = var(entropyData);
                        data.(run).(ConditionName).EntropyMax = max(entropyData);
                    end
                end

                % Stimulus-aligned mimicry metrics
                try
                    mimicryMetrics = performStimulusAlignedAnalysis(data, run, ConditionName, mimicryConfig);
                    data.(run).(ConditionName).MimicryResponse   = mimicryMetrics.mimicryResponse;
                    data.(run).(ConditionName).MimicryLatency    = mimicryMetrics.mimicryLatency;
                    data.(run).(ConditionName).BaselineMovement  = mimicryMetrics.baselineMovement;
                    data.(run).(ConditionName).StimulusMovement  = mimicryMetrics.stimulusMovement;
                    data.(run).(ConditionName).MimicrySignificance = mimicryMetrics.significance;
                catch ME
                    disp(['  Stimulus-aligned analysis error: ', ME.message]);
                end

                % Frequency-domain mimicry metrics
                try
                    spectralMetrics = performFrequencyAnalysis(data, run, ConditionName, mimicryConfig);
                    data.(run).(ConditionName).SpectralMimicryIndex = spectralMetrics.spectralMimicryIndex;
                    data.(run).(ConditionName).FrequencyProfile     = spectralMetrics.frequencyProfile;
                    data.(run).(ConditionName).Frequencies          = spectralMetrics.frequencies;
                    data.(run).(ConditionName).SpeechBandPower      = spectralMetrics.speechBandPower;
                    data.(run).(ConditionName).TemporalCoherence    = spectralMetrics.temporalCoherence;
                catch ME
                    disp(['  Frequency analysis error: ', ME.message]);
                end

                % Trial-level analysis plots
                try
                    if isfield(data.(run).(ConditionName), 'StableMeanDisplacement') && ...
                            ~isempty(data.(run).(ConditionName).StableMeanDisplacement)
                        generateMimicryAnalysis(data, run, ConditionName, outputPaths.trialAnalysis, mimicryConfig);
                    end
                catch ME
                    disp(['  generateMimicryAnalysis error: ', ME.message]);
                end

                try
                    generateEnhancedMovingAverageAnalysis(data, run, ConditionName, outputPaths.trialAnalysis);
                catch ME
                    disp(['  Moving average analysis error: ', ME.message]);
                end

                if flowFrameCount > 0
                    avgMagnitudeMap = magnitudeAccumulator / flowFrameCount;
                    avgVxMap        = vxAccumulator        / flowFrameCount;
                    avgVyMap        = vyAccumulator        / flowFrameCount;
                    try
                        generateEnhancedGridHeatmaps(data, run, ConditionName, TheRectangleROI, ...
                            avgMagnitudeMap, avgVxMap, avgVyMap, outputPaths.trialAnalysis);
                    catch ME
                        disp(['  Heatmaps error: ', ME.message]);
                    end
                end

                % Condition aggregation
                try
                    participantConditionData = enhancedConditionAggregation( ...
                        participantConditionData, data, run, ConditionName, groupData.conditions);
                catch ME
                    disp(['  Condition aggregation error: ', ME.message]);
                end

                % Store trial-level refresh counts in data struct
                data.(run).(ConditionName).LossTriggeredRefreshes = lossTriggeredRefreshCount;
                data.(run).(ConditionName).TotalRefreshes         = totalRefreshCount;

            catch ME
                disp(['ERROR in trial ', num2str(n), ' (', ConditionName, '): ', ME.message]);
                continue;
            end

            % Release tracker
            try, release(trackerAllPoints); catch, end
            clear avgMagnitudeMap avgVxMap avgVyMap grayFrame videoFrame previousFrame;

            disp(['  Trial ', num2str(n), ' complete.']);
        end % end trial loop

        % Save run-level data
        if cfg.saveMatFiles
            try
                runDataFile = fullfile(outputPaths.summaryReports, ...
                    ['DataSummary_', participant, '_', run, '.mat']);
                runData = data.(run);
                save(runDataFile, 'runData');
                disp(['Run data saved: ', runDataFile]);
            catch ME
                disp(['Run data save error: ', ME.message]);
            end
        end

    end % end run loop

    % --- Export frame-level data ---
    try
        generateFrameLevelTXT_Auto_Enhanced(data, participant, outputPaths.dataExports);
        disp(['Frame-level TXT export complete: ', participant]);
    catch ME
        disp(['Frame-level export error: ', ME.message]);
    end

    % --- Emotion-specific mimicry metrics ---
    try
        participantConditionData = calculateEmotionSpecificMimicry( ...
            participantConditionData, groupData.conditions, mimicryConfig);
    catch ME
        disp(['Emotion-specific mimicry error: ', ME.message]);
    end

    % --- Participant-level condition analysis ---
    try
        validateConditionDataSimple(participantConditionData, participant, groupData.conditions);
    catch ME
        disp(['Condition validation error: ', ME.message]);
    end

    try
        updateConditionDataWithVelocityMetrics(participantConditionData, participant, groupData.conditions);
    catch ME
        disp(['Velocity metrics update error: ', ME.message]);
    end

    % --- Text reports (no MATLAB figures — use R for plotting) ---
    try
        analysisDir = fullfile(cfg.baseDir, participant, 'ConditionAnalysis');
        if ~exist(analysisDir, 'dir'), mkdir(analysisDir); end
        generateDataInventoryReport(data, participant, analysisDir);
    catch ME
        disp(['Report error: ', ME.message]);
    end

    try
        createParticipantSummaryReport(participant, outputPaths);
    catch ME
        disp(['Participant summary error: ', ME.message]);
    end

    % Store participant in group structure
    groupData.participants{end+1}              = participant;
    groupData.participantData.(participant)    = participantConditionData;

    disp(['=== Completed participant: ', participant, ' ===']);

end % end participant loop

disp('=== Analysis complete ===');
disp('Key output: *_FrameLevel_Enhanced_*.txt in each participant DataExports folder.');

%% Completion summary
elapsedTime = toc;
fprintf('\n=== VTM Toolbox run complete ===\n');
fprintf('Total time     : %.2f minutes\n', elapsedTime / 60);
fprintf('Participants   : %d\n', length(participants));
fprintf('Runs           : %d\n', length(iterRun));
