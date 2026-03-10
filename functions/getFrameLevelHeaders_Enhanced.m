function [headers, stringColumns] = getFrameLevelHeaders_Enhanced()
    % Column headers for the frame-level tab-delimited export file.
    % Each row in the output corresponds to one video frame from one trial.

    headers = {
        'Participant',           % 1
        'Gender',                % 2 - STRING
        'Age',                   % 3 - STRING
        'Run',                   % 4
        'Trial',                 % 5
        'VoiceType',             % 6 - STRING
        'Condition',             % 7 (numeric code: neutral=1, pleasure=2, happiness=3, anger=4)
        'Emotion',               % 8 - STRING
        'Frame',                 % 9
        'Time_Seconds',          % 10
        'Displacement',          % 11 - Mean displacement of fast-moving tracked points (pixels)
        'MaxDisplacement',       % 12 - Max displacement of tracked points (pixels)
        'PointCount',            % 13 - Number of fast-moving points retained
        'MeanVelocity',          % 14 - Mean velocity of fast-moving points (pixels/s)
        'MaxVelocity',           % 15 - Max velocity (pixels/s)
        'FlowMagnitude',         % 16 - Mean optical flow magnitude in ROI
        'FlowVx',                % 17 - Mean horizontal optical flow
        'FlowVy',                % 18 - Mean vertical optical flow
        'Entropy',               % 19 - Image entropy (frame complexity)
        'TotalPoints',           % 20 - Total tracked points in frame
        'TrackingQuality',       % 21 - Proportion of points successfully tracked
        'PointLossRate',         % 22 - Proportion of points lost
        'Epiglottis_Movement',   % 23 - Mean displacement in epiglottis ROI
        'Vocal_folds_Movement',  % 24 - Mean displacement in vocal folds ROI
        'Pharynx_Movement',      % 25 - Mean displacement in pharynx ROI
        'Larynx_Movement',       % 26 - Mean displacement in larynx ROI
        'MaxAcceleration',       % 27 - Max point acceleration (pixels/s^2)
        'FramesFromStimulus',       % 28 - Frame index relative to stimulus onset
        'SecondsFromStimulus',      % 29 - Time (s) relative to stimulus onset
        'LossTriggeredRefreshes',   % 30 - Trial-level count: refreshes triggered by point loss > threshold
        'TotalRefreshes'            % 31 - Trial-level count: all tracker refreshes (loss-triggered + periodic)
    };

    % Columns containing string data (for correct tab-delimited formatting)
    stringColumns = [2, 3, 6, 8]; % Gender, Age, VoiceType, Emotion
end
