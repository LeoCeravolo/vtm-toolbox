function [headers, stringColumns] = getFrameLevelHeaders()
    % Define column headers for frame-level data and identify string columns
    
    headers = {
        'Participant'
        'Gender'
        'Age'
        'Run'
        'Trial'
        'Condition'
        'Emotion'
        'Frame'
        'Time_Seconds'
        'Displacement'
        'MaxDisplacement'
        'PointCount'
        'MeanVelocity'
        'MaxVelocity'
        'FlowMagnitude'
        'FlowVx'
        'FlowVy'
        'Entropy'
        'TotalPoints'
        'TrackingQuality'
        'PointLossRate'
        'ML_Classification'
        'ML_Confidence'
        'Tongue_Movement'
        'Lip_Movement'
        'Pharynx_Movement'
        'Larynx_Movement'
        'MaxAcceleration'
        'Frames_From_Stimulus'
        'Seconds_From_Stimulus'
    };
    
    % Identify which columns contain strings (for proper formatting)
    stringColumns = [2, 7]; % Gender (col 2) and Emotion (col 6)
end
