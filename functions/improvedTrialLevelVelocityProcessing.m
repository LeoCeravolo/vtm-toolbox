%% ADD THIS FUNCTION TO YOUR MAIN SCRIPT (with the other helper functions at the end)

function improvedTrialLevelVelocityProcessing(data, run, ConditionName, frameRate)
% Improved trial-level velocity processing with enhanced metrics

try
    % Check if velocity data exists
    if ~isfield(data.(run).(ConditionName), 'AllVelocities') || isempty(data.(run).(ConditionName).AllVelocities)
        disp(['No velocity data for trial-level processing: ', ConditionName]);
        return;
    end
    
    allVelocities = data.(run).(ConditionName).AllVelocities;
    
    % Initialize enhanced velocity metrics
    allVelocityValues = [];
    frameVelocityMeans = [];
    frameVelocityPeaks = [];
    frameVelocityStds = [];
    
    % Process each frame's velocity data
    for frameIdx = 1:length(allVelocities)
        if ~isempty(allVelocities{frameIdx})
            frameVelocities = allVelocities{frameIdx};
            validVelocities = frameVelocities(isfinite(frameVelocities) & frameVelocities > 0);
            
            if ~isempty(validVelocities)
                % Collect all velocities for trial-level statistics
                allVelocityValues = [allVelocityValues; validVelocities];
                
                % Frame-level velocity metrics
                frameVelocityMeans(frameIdx) = mean(validVelocities);
                frameVelocityPeaks(frameIdx) = max(validVelocities);
                frameVelocityStds(frameIdx) = std(validVelocities);
            else
                frameVelocityMeans(frameIdx) = NaN;
                frameVelocityPeaks(frameIdx) = NaN;
                frameVelocityStds(frameIdx) = NaN;
            end
        else
            frameVelocityMeans(frameIdx) = NaN;
            frameVelocityPeaks(frameIdx) = NaN;
            frameVelocityStds(frameIdx) = NaN;
        end
    end
    
    % Calculate enhanced trial-level velocity metrics
    if ~isempty(allVelocityValues)
        data.(run).(ConditionName).EnhancedVelocityMetrics = struct();
        data.(run).(ConditionName).EnhancedVelocityMetrics.allVelocities = allVelocityValues;
        data.(run).(ConditionName).EnhancedVelocityMetrics.trialMeanVelocity = mean(allVelocityValues);
        data.(run).(ConditionName).EnhancedVelocityMetrics.trialMaxVelocity = max(allVelocityValues);
        data.(run).(ConditionName).EnhancedVelocityMetrics.trialStdVelocity = std(allVelocityValues);
        data.(run).(ConditionName).EnhancedVelocityMetrics.trialMedianVelocity = median(allVelocityValues);
        
        % Percentile-based metrics for robust statistics
        data.(run).(ConditionName).EnhancedVelocityMetrics.velocity75th = prctile(allVelocityValues, 75);
        data.(run).(ConditionName).EnhancedVelocityMetrics.velocity90th = prctile(allVelocityValues, 90);
        data.(run).(ConditionName).EnhancedVelocityMetrics.velocity95th = prctile(allVelocityValues, 95);
        
        % Frame-level velocity progression
        data.(run).(ConditionName).EnhancedVelocityMetrics.frameVelocityMeans = frameVelocityMeans;
        data.(run).(ConditionName).EnhancedVelocityMetrics.frameVelocityPeaks = frameVelocityPeaks;
        data.(run).(ConditionName).EnhancedVelocityMetrics.frameVelocityStds = frameVelocityStds;
        
        % Velocity consistency metrics
        validFrameMeans = frameVelocityMeans(~isnan(frameVelocityMeans));
        if length(validFrameMeans) > 1
            data.(run).(ConditionName).EnhancedVelocityMetrics.velocityConsistency = std(validFrameMeans) / mean(validFrameMeans);
        else
            data.(run).(ConditionName).EnhancedVelocityMetrics.velocityConsistency = NaN;
        end
        
        % Enhanced movement classification based on velocity
        highVelocityThreshold = prctile(allVelocityValues, 80);
        moderateVelocityThreshold = prctile(allVelocityValues, 50);
        
        data.(run).(ConditionName).EnhancedVelocityMetrics.highVelocityFrames = sum(frameVelocityPeaks > highVelocityThreshold, 'omitnan');
        data.(run).(ConditionName).EnhancedVelocityMetrics.moderateVelocityFrames = sum(frameVelocityPeaks > moderateVelocityThreshold & frameVelocityPeaks <= highVelocityThreshold, 'omitnan');
        data.(run).(ConditionName).EnhancedVelocityMetrics.lowVelocityFrames = sum(frameVelocityPeaks <= moderateVelocityThreshold, 'omitnan');
        
        % Velocity-based movement detection
        data.(run).(ConditionName).EnhancedVelocityMetrics.significantMovementFrames = sum(frameVelocityPeaks > data.(run).(ConditionName).EnhancedVelocityMetrics.trialMeanVelocity + data.(run).(ConditionName).EnhancedVelocityMetrics.trialStdVelocity, 'omitnan');
        
        disp(['✓ Enhanced velocity processing completed for: ', ConditionName]);
        disp(['  - Total velocity values: ', num2str(length(allVelocityValues))]);
        disp(['  - Mean velocity: ', num2str(data.(run).(ConditionName).EnhancedVelocityMetrics.trialMeanVelocity, '%.2f')]);
        disp(['  - Peak velocity: ', num2str(data.(run).(ConditionName).EnhancedVelocityMetrics.trialMaxVelocity, '%.2f')]);
        disp(['  - High velocity frames: ', num2str(data.(run).(ConditionName).EnhancedVelocityMetrics.highVelocityFrames)]);
    else
        disp(['⚠ No valid velocity values found for: ', ConditionName]);
    end
    
catch ME
    disp(['Enhanced velocity processing error: ', ME.message]);
end
end