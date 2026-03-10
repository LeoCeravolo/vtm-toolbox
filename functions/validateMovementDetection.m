function validateMovementDetection(data, run, ConditionName)
% Validate the quality of movement detection

try
    % Extract detection data
    if ~isfield(data.(run).(ConditionName), 'TimeFromStimulus')
        disp('No detection data available for validation');
        return;
    end
    
    timeFromStimulus = data.(run).(ConditionName).TimeFromStimulus;
    detectionMethod = data.(run).(ConditionName).DetectionMethod;
    
    % Calculate validation metrics
    totalFrames = length(timeFromStimulus);
    nearStimulusFrames = sum(timeFromStimulus < 1.0);
    farStimulusFrames = totalFrames - nearStimulusFrames;
    
    disp(['=== MOVEMENT DETECTION VALIDATION: ', ConditionName, ' ===']);
    disp(['Total frames processed: ', num2str(totalFrames)]);
    disp(['Frames near stimulus (<1s): ', num2str(nearStimulusFrames), ' (', num2str(nearStimulusFrames/totalFrames*100, '%.1f'), '%)']);
    disp(['Frames far from stimulus: ', num2str(farStimulusFrames), ' (', num2str(farStimulusFrames/totalFrames*100, '%.1f'), '%)']);
    
    % Check if we have meaningful movement detection
    if isfield(data.(run).(ConditionName), 'StableMeanDisplacement')
        displacement = data.(run).(ConditionName).StableMeanDisplacement;
        validDisp = displacement(isfinite(displacement) & displacement > 0);
        
        if ~isempty(validDisp)
            disp(['Mean displacement detected: ', num2str(mean(validDisp), '%.3f'), ' pixels']);
            disp(['Max displacement detected: ', num2str(max(validDisp), '%.3f'), ' pixels']);
            disp(['Movement frames: ', num2str(length(validDisp)), ' out of ', num2str(totalFrames)]);
            
            % Check temporal distribution
            if length(validDisp) >= 5
                disp(['Movement detection appears successful ✓']);
            else
                disp(['⚠ Low movement detection - may need threshold adjustment']);
            end
        else
            disp(['✗ No valid movements detected - check thresholds']);
        end
    end
    
catch ME
    disp(['Validation error: ', ME.message]);
end
end