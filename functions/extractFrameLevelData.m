function frameData = extractFrameLevelData(trialData, participant, runName, trialName, condition, gender, age, trialNum)
    % Extract frame-by-frame data from trial structure
    
    frameData = [];
    
    % Check if we have frame-level displacement data
    if ~isfield(trialData, 'StableMeanDisplacement') || isempty(trialData.StableMeanDisplacement)
        return;
    end
    
    displacements = trialData.StableMeanDisplacement;
    numFrames = length(displacements);
    
    if numFrames == 0
        return;
    end
    
    % Initialize frame data as cell array to handle mixed data types
    [headers, stringColumns] = getFrameLevelHeaders();
    numCols = length(headers);
    frameData = cell(numFrames, numCols);
    
    % Basic information (same for all frames)
    participantNum = str2double(regexp(participant, '\d+', 'match', 'once'));
    if isempty(participantNum), participantNum = NaN; end
    
    runNum = str2double(regexp(runName, '\d+', 'match', 'once'));
    if isempty(runNum), runNum = NaN; end
    
    % Map condition to number
    conditionMap = containers.Map(...
        {'neutral', 'pleasure', 'happiness', 'anger'}, ...
        {1, 2, 3, 4});
    conditionNum = conditionMap.isKey(condition) * conditionMap(condition);
    
    % Convert age to string for consistency
    if isnumeric(age)
        ageStr = num2str(age);
    else
        ageStr = char(age);
    end
    
    % Fill frame-by-frame data
    for frameIdx = 1:numFrames
        row = frameIdx;
        col = 1;
        
        % Basic identifiers - ALL using curly braces for cell array
        frameData{row, col} = participantNum; col = col + 1;  % Participant
        frameData{row, col} = gender; col = col + 1;          % Gender
        frameData{row, col} = ageStr; col = col + 1;          % Age (as string)
        frameData{row, col} = runNum; col = col + 1;          % Run
        frameData{row, col} = trialNum; col = col + 1;        % Trial
        frameData{row, col} = conditionNum; col = col + 1;    % Condition (number)
        frameData{row, col} = condition; col = col + 1;       % Emotion (text)
        frameData{row, col} = frameIdx; col = col + 1;        % Frame
        frameData{row, col} = frameIdx / 25; col = col + 1;   % Time_Seconds
        
        % Movement metrics - ALL using curly braces
        frameData{row, col} = getFieldValue(trialData, 'StableMeanDisplacement', frameIdx); col = col + 1; % Displacement
        frameData{row, col} = getFieldValue(trialData, 'StableMaxDisplacement', frameIdx); col = col + 1;
        frameData{row, col} = getFieldValue(trialData, 'StablePointCount', frameIdx); col = col + 1;
        
        % Velocity metrics
        frameData{row, col} = getFieldValue(trialData, 'MeanVelocity', frameIdx); col = col + 1;
        frameData{row, col} = getFieldValue(trialData, 'MaxVelocity', frameIdx); col = col + 1;
        
        % Optical flow
        frameData{row, col} = getFieldValue(trialData, 'ROIFlowMagnitude', frameIdx); col = col + 1;
        frameData{row, col} = getFieldValue(trialData, 'FlowVx', frameIdx); col = col + 1;
        frameData{row, col} = getFieldValue(trialData, 'FlowVy', frameIdx); col = col + 1;
        
        % Entropy
        frameData{row, col} = getFieldValue(trialData, 'Entropy', frameIdx); col = col + 1;
        
        % Tracking quality
        frameData{row, col} = getFieldValue(trialData, 'PointCount', frameIdx); col = col + 1;
        frameData{row, col} = getFieldValue(trialData, 'TrackingQuality', frameIdx); col = col + 1;
        frameData{row, col} = getFieldValue(trialData, 'PointLossRate', frameIdx); col = col + 1;
        
        % ML Classification (if available)
        
        % Anatomical regions (if available)
        frameData{row, col} = getAnatomicalValue(trialData, 'tongue', frameIdx); col = col + 1;
        frameData{row, col} = getAnatomicalValue(trialData, 'lip', frameIdx); col = col + 1;
        frameData{row, col} = getAnatomicalValue(trialData, 'pharynx', frameIdx); col = col + 1;
        frameData{row, col} = getAnatomicalValue(trialData, 'larynx', frameIdx); col = col + 1;
        
        % Acceleration (if available)
        frameData{row, col} = getFieldValue(trialData, 'MaxAccelerations', frameIdx); col = col + 1;
        
        % Stimulus timing indicators
        stimulusOnset = getFieldValue(trialData, 'StimulusOnsetFrame', 1);
        if ~isnan(stimulusOnset)
            frameData{row, col} = frameIdx - stimulusOnset; % Frames from stimulus
        else
            frameData{row, col} = NaN;
        end
        col = col + 1;
        
        frameData{row, col} = (frameIdx - stimulusOnset) / 25; % Seconds from stimulus
    end
end