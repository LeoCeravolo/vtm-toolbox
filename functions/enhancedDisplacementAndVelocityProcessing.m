function enhancedDisplacementAndVelocityProcessing(data, run, ConditionName, FrameCount, stableDisplacements, velocities, fastMovementIndices, frameRate)
    % Enhanced processing that properly calculates and stores velocity metrics
    
    if sum(fastMovementIndices) >= 5 % Increased threshold
        fastDisplacements = stableDisplacements(fastMovementIndices);
        fastVelocities = velocities(fastMovementIndices);

        % === TRADITIONAL DISPLACEMENT METRICS ===
        data.(run).(ConditionName).StableDisplacements{FrameCount} = fastDisplacements;
        data.(run).(ConditionName).StableMeanDisplacement(FrameCount) = mean(fastDisplacements);
        data.(run).(ConditionName).StableMaxDisplacement(FrameCount) = max(fastDisplacements);
        data.(run).(ConditionName).StablePointCount(FrameCount) = length(fastDisplacements);

        % === ENHANCED VELOCITY METRICS (FIXED) ===
        data.(run).(ConditionName).MeanVelocity(FrameCount) = mean(fastVelocities);
        data.(run).(ConditionName).MaxVelocity(FrameCount) = max(fastVelocities);
        
        % Calculate enhanced velocity metrics for this frame
        velocityMetrics = calculateEnhancedVelocityMetrics(fastDisplacements, frameRate);
        
        % Store frame-by-frame velocity metrics
        if ~isfield(data.(run).(ConditionName), 'FrameVelocityMetrics')
            data.(run).(ConditionName).FrameVelocityMetrics = {};
        end
        data.(run).(ConditionName).FrameVelocityMetrics{FrameCount} = velocityMetrics;
        
        % Store peak velocity for this frame
        if ~isfield(data.(run).(ConditionName), 'PeakVelocityByFrame')
            data.(run).(ConditionName).PeakVelocityByFrame = [];
        end
        if isfinite(velocityMetrics.peakVelocity)
            data.(run).(ConditionName).PeakVelocityByFrame(FrameCount) = velocityMetrics.peakVelocity;
        else
            data.(run).(ConditionName).PeakVelocityByFrame(FrameCount) = NaN;
        end
        
        % Store velocity variance for this frame
        if ~isfield(data.(run).(ConditionName), 'VelocityVarianceByFrame')
            data.(run).(ConditionName).VelocityVarianceByFrame = [];
        end
        if isfinite(velocityMetrics.velocityVariance)
            data.(run).(ConditionName).VelocityVarianceByFrame(FrameCount) = velocityMetrics.velocityVariance;
        else
            data.(run).(ConditionName).VelocityVarianceByFrame(FrameCount) = NaN;
        end
        
        % Store acceleration for this frame
        if ~isfield(data.(run).(ConditionName), 'MaxAccelerationByFrame')
            data.(run).(ConditionName).MaxAccelerationByFrame = [];
        end
        if isfinite(velocityMetrics.maxAcceleration)
            data.(run).(ConditionName).MaxAccelerationByFrame(FrameCount) = velocityMetrics.maxAcceleration;
        else
            data.(run).(ConditionName).MaxAccelerationByFrame(FrameCount) = NaN;
        end

        % Enhanced movement classification
        data.(run).(ConditionName).MovementClassification(FrameCount).TotalPoints = length(stableDisplacements);
        data.(run).(ConditionName).MovementClassification(FrameCount).FastMovements = sum(fastMovementIndices);
        data.(run).(ConditionName).MovementClassification(FrameCount).SlowMovements = length(stableDisplacements) - sum(fastMovementIndices);
        data.(run).(ConditionName).MovementClassification(FrameCount).NoMovement = 0;

    else
        % No fast movements - store NaN for consistency
        data.(run).(ConditionName).StableDisplacements{FrameCount} = stableDisplacements;
        data.(run).(ConditionName).StableMeanDisplacement(FrameCount) = NaN;
        data.(run).(ConditionName).StableMaxDisplacement(FrameCount) = NaN;
        data.(run).(ConditionName).StablePointCount(FrameCount) = 0;
        data.(run).(ConditionName).MeanVelocity(FrameCount) = mean(velocities);
        data.(run).(ConditionName).MaxVelocity(FrameCount) = max(velocities);
        
        % Store NaN for velocity metrics when no fast movements
        if ~isfield(data.(run).(ConditionName), 'PeakVelocityByFrame')
            data.(run).(ConditionName).PeakVelocityByFrame = [];
        end
        data.(run).(ConditionName).PeakVelocityByFrame(FrameCount) = NaN;
        
        if ~isfield(data.(run).(ConditionName), 'VelocityVarianceByFrame')
            data.(run).(ConditionName).VelocityVarianceByFrame = [];
        end
        data.(run).(ConditionName).VelocityVarianceByFrame(FrameCount) = NaN;
        
        if ~isfield(data.(run).(ConditionName), 'MaxAccelerationByFrame')
            data.(run).(ConditionName).MaxAccelerationByFrame = [];
        end
        data.(run).(ConditionName).MaxAccelerationByFrame(FrameCount) = NaN;
    end
end
