function summarizeVelocityMetrics(data, run, ConditionName)
    % Summarize frame-by-frame velocity metrics into trial-level summaries
    
    try
        % Extract frame-by-frame velocity data
        if isfield(data.(run).(ConditionName), 'PeakVelocityByFrame')
            peakVelData = data.(run).(ConditionName).PeakVelocityByFrame;
            validPeakVel = peakVelData(isfinite(peakVelData) & peakVelData > 0);
            
            if ~isempty(validPeakVel)
                data.(run).(ConditionName).TrialPeakVelocity = max(validPeakVel);
                data.(run).(ConditionName).TrialMeanPeakVelocity = mean(validPeakVel);
                data.(run).(ConditionName).TrialPeakVelocityStd = std(validPeakVel);
            else
                data.(run).(ConditionName).TrialPeakVelocity = NaN;
                data.(run).(ConditionName).TrialMeanPeakVelocity = NaN;
                data.(run).(ConditionName).TrialPeakVelocityStd = NaN;
            end
        end
        
        if isfield(data.(run).(ConditionName), 'VelocityVarianceByFrame')
            velVarData = data.(run).(ConditionName).VelocityVarianceByFrame;
            validVelVar = velVarData(isfinite(velVarData) & velVarData > 0);
            
            if ~isempty(validVelVar)
                data.(run).(ConditionName).TrialVelocityVariance = mean(validVelVar);
            else
                data.(run).(ConditionName).TrialVelocityVariance = NaN;
            end
        end
        
        if isfield(data.(run).(ConditionName), 'MaxAccelerationByFrame')
            accelData = data.(run).(ConditionName).MaxAccelerationByFrame;
            validAccel = accelData(isfinite(accelData) & accelData > 0);
            
            if ~isempty(validAccel)
                data.(run).(ConditionName).TrialMaxAcceleration = max(validAccel);
                data.(run).(ConditionName).TrialMeanAcceleration = mean(validAccel);
            else
                data.(run).(ConditionName).TrialMaxAcceleration = NaN;
                data.(run).(ConditionName).TrialMeanAcceleration = NaN;
            end
        end
        
        % Overall velocity metrics from MeanVelocity and MaxVelocity arrays
        if isfield(data.(run).(ConditionName), 'MeanVelocity')
            meanVelData = data.(run).(ConditionName).MeanVelocity;
            validMeanVel = meanVelData(isfinite(meanVelData) & meanVelData > 0);
            
            if ~isempty(validMeanVel)
                data.(run).(ConditionName).TrialOverallMeanVelocity = mean(validMeanVel);
            else
                data.(run).(ConditionName).TrialOverallMeanVelocity = NaN;
            end
        end
        
        if isfield(data.(run).(ConditionName), 'MaxVelocity')
            maxVelData = data.(run).(ConditionName).MaxVelocity;
            validMaxVel = maxVelData(isfinite(maxVelData) & maxVelData > 0);
            
            if ~isempty(validMaxVel)
                data.(run).(ConditionName).TrialOverallMaxVelocity = max(validMaxVel);
            else
                data.(run).(ConditionName).TrialOverallMaxVelocity = NaN;
            end
        end
        
        disp(['✓ Velocity metrics summarized for: ', ConditionName]);
        
    catch ME
        disp(['Velocity metrics summarization error for ', ConditionName, ': ', ME.message]);
    end
end
