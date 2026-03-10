function enhancedVelocityAggregation(participantConditionData, conditionType, data, run, ConditionName)
    % Enhanced aggregation of velocity metrics for condition-level analysis
    
    try
        % Aggregate trial-level peak velocities
        if isfield(data.(run).(ConditionName), 'TrialPeakVelocity') && isfinite(data.(run).(ConditionName).TrialPeakVelocity)
            participantConditionData.(conditionType).PeakVelocities(end+1) = data.(run).(ConditionName).TrialPeakVelocity;
        elseif isfield(data.(run).(ConditionName), 'TrialOverallMaxVelocity') && isfinite(data.(run).(ConditionName).TrialOverallMaxVelocity)
            % Fallback to overall max velocity
            participantConditionData.(conditionType).PeakVelocities(end+1) = data.(run).(ConditionName).TrialOverallMaxVelocity;
        end
        
        % Aggregate trial-level mean velocities
        if isfield(data.(run).(ConditionName), 'TrialMeanPeakVelocity') && isfinite(data.(run).(ConditionName).TrialMeanPeakVelocity)
            participantConditionData.(conditionType).MeanVelocities(end+1) = data.(run).(ConditionName).TrialMeanPeakVelocity;
        elseif isfield(data.(run).(ConditionName), 'TrialOverallMeanVelocity') && isfinite(data.(run).(ConditionName).TrialOverallMeanVelocity)
            % Fallback to overall mean velocity
            participantConditionData.(conditionType).MeanVelocities(end+1) = data.(run).(ConditionName).TrialOverallMeanVelocity;
        end
        
        % Aggregate velocity variances
        if isfield(data.(run).(ConditionName), 'TrialVelocityVariance') && isfinite(data.(run).(ConditionName).TrialVelocityVariance)
            participantConditionData.(conditionType).VelocityVariances(end+1) = data.(run).(ConditionName).TrialVelocityVariance;
        end
        
        % Aggregate accelerations
        if isfield(data.(run).(ConditionName), 'TrialMaxAcceleration') && isfinite(data.(run).(ConditionName).TrialMaxAcceleration)
            participantConditionData.(conditionType).MaxAccelerations(end+1) = data.(run).(ConditionName).TrialMaxAcceleration;
        end
        
        % Create comprehensive velocity metrics structure for this trial
        velocityMetricStruct = struct();
        
        % Populate with trial-level summaries
        if isfield(data.(run).(ConditionName), 'TrialPeakVelocity')
            velocityMetricStruct.peakVelocity = data.(run).(ConditionName).TrialPeakVelocity;
        else
            velocityMetricStruct.peakVelocity = NaN;
        end
        
        if isfield(data.(run).(ConditionName), 'TrialMeanPeakVelocity')
            velocityMetricStruct.meanVelocity = data.(run).(ConditionName).TrialMeanPeakVelocity;
        else
            velocityMetricStruct.meanVelocity = NaN;
        end
        
        if isfield(data.(run).(ConditionName), 'TrialVelocityVariance')
            velocityMetricStruct.velocityVariance = data.(run).(ConditionName).TrialVelocityVariance;
        else
            velocityMetricStruct.velocityVariance = NaN;
        end
        
        if isfield(data.(run).(ConditionName), 'TrialMaxAcceleration')
            velocityMetricStruct.maxAcceleration = data.(run).(ConditionName).TrialMaxAcceleration;
        else
            velocityMetricStruct.maxAcceleration = NaN;
        end
        
        % Store in VelocityMetrics cell array
        participantConditionData.(conditionType).VelocityMetrics{end+1} = velocityMetricStruct;
        
        disp(['✓ Enhanced velocity aggregation completed for: ', conditionType, ' (', ConditionName, ')']);
        
    catch ME
        disp(['Enhanced velocity aggregation error: ', ME.message]);
    end
end
