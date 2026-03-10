function frameData = extractFrameLevelData_Enhanced(trialData, participant, runName, trialName, condition, gender, age, voiceType, runNumber)
    % Extract frame-level kinematic data from a single trial data structure.
    %
    % Inputs:
    %   trialData   - struct: data.(run).(ConditionName) for one trial
    %   participant - string: participant folder name (e.g. 'p01_26092024')
    %   runName     - string: run field name (e.g. 'Run1')
    %   trialName   - string: trial field name / condition label
    %   condition   - string: emotion label ('neutral','pleasure','happiness','anger')
    %   gender      - string: participant gender
    %   age         - numeric or string: participant age
    %   voiceType   - string: 'natural', 'synthetic', etc.
    %   runNumber   - numeric: run index (1, 2, or 3)
    %
    % Output:
    %   frameData   - cell array [nFrames x nCols] for appending to the group export

    frameData = [];

    if ~isfield(trialData, 'StableMeanDisplacement') || isempty(trialData.StableMeanDisplacement)
        return;
    end

    displacements = trialData.StableMeanDisplacement;
    numFrames = length(displacements);
    if numFrames == 0, return; end

    [headers, stringColumns] = getFrameLevelHeaders_Enhanced();
    numCols = length(headers);
    frameData = cell(numFrames, numCols);

    % Scalar identifiers
    participantNum = str2double(regexp(participant, '\d+', 'match', 'once'));
    if isempty(participantNum), participantNum = NaN; end

    runNum = str2double(regexp(runName, '\d+', 'match', 'once'));
    if isempty(runNum), runNum = NaN; end

    trialNumber = extractTrialNumber(trialName);

    conditionMap = containers.Map( ...
        {'neutral', 'pleasure', 'happiness', 'anger'}, {1, 2, 3, 4});
    if conditionMap.isKey(condition)
        conditionNum = conditionMap(condition);
    else
        conditionNum = NaN;
    end

    if isnumeric(age)
        ageStr = num2str(age);
    else
        ageStr = char(age);
    end

    stimulusOnset = safeGetFieldValue(trialData, 'StimulusOnsetFrame', 1);

    for frameIdx = 1:numFrames
        col = 1;

        frameData{frameIdx, col} = participantNum;  col = col + 1; % Participant
        frameData{frameIdx, col} = gender;           col = col + 1; % Gender
        frameData{frameIdx, col} = ageStr;           col = col + 1; % Age
        frameData{frameIdx, col} = runNum;           col = col + 1; % Run
        frameData{frameIdx, col} = trialNumber;      col = col + 1; % Trial
        frameData{frameIdx, col} = voiceType;        col = col + 1; % VoiceType
        frameData{frameIdx, col} = conditionNum;     col = col + 1; % Condition (numeric)
        frameData{frameIdx, col} = condition;        col = col + 1; % Emotion (string)
        frameData{frameIdx, col} = frameIdx;         col = col + 1; % Frame
        frameData{frameIdx, col} = frameIdx / 25;    col = col + 1; % Time_Seconds

        % Displacement and tracking
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'StableMeanDisplacement', frameIdx); col = col + 1;
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'StableMaxDisplacement',  frameIdx); col = col + 1;
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'StablePointCount',       frameIdx); col = col + 1;

        % Velocity
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'MeanVelocity', frameIdx); col = col + 1;
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'MaxVelocity',  frameIdx); col = col + 1;

        % Optical flow
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'ROIFlowMagnitude', frameIdx); col = col + 1;
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'FlowVx',           frameIdx); col = col + 1;
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'FlowVy',           frameIdx); col = col + 1;

        % Entropy and tracking quality
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'Entropy',          frameIdx); col = col + 1;
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'PointCount',        frameIdx); col = col + 1;
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'TrackingQuality',   frameIdx); col = col + 1;
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'PointLossRate',     frameIdx); col = col + 1;

        % Anatomical regions
        frameData{frameIdx, col} = safeGetAnatomicalValue(trialData, 'epiglottis',  frameIdx); col = col + 1;
        frameData{frameIdx, col} = safeGetAnatomicalValue(trialData, 'vocal_folds', frameIdx); col = col + 1;
        frameData{frameIdx, col} = safeGetAnatomicalValue(trialData, 'pharynx',     frameIdx); col = col + 1;
        frameData{frameIdx, col} = safeGetAnatomicalValue(trialData, 'larynx',      frameIdx); col = col + 1;

        % Acceleration
        frameData{frameIdx, col} = safeGetFieldValue(trialData, 'MaxAccelerations', frameIdx); col = col + 1;

        % Stimulus timing
        if ~isnan(stimulusOnset) && stimulusOnset > 0
            frameData{frameIdx, col} = frameIdx - stimulusOnset; col = col + 1;
            frameData{frameIdx, col} = (frameIdx - stimulusOnset) / 25; col = col + 1;
        else
            frameData{frameIdx, col} = NaN; col = col + 1;
            frameData{frameIdx, col} = NaN; col = col + 1;
        end

        % Trial-level refresh counts (scalar, repeated for every frame of this trial)
        if isfield(trialData, 'LossTriggeredRefreshes')
            frameData{frameIdx, col} = trialData.LossTriggeredRefreshes; col = col + 1;
        else
            frameData{frameIdx, col} = NaN; col = col + 1;
        end
        if isfield(trialData, 'TotalRefreshes')
            frameData{frameIdx, col} = trialData.TotalRefreshes;
        else
            frameData{frameIdx, col} = NaN;
        end
    end
end
