function integrateEnhancedVelocityAnalysis(data, run, conditionName, mimicryConfig)
% Integration function to add enhanced velocity analysis to existing data

try
    % Calculate enhanced velocity metrics
    velocityMetrics = enhancedVelocityBasedMimicryAnalysis(data, run, conditionName, mimicryConfig);

    % Store in data structure
    data.(run).(conditionName).EnhancedVelocityMetrics = velocityMetrics;

    % Extract key metrics for easy access
    if isfield(velocityMetrics, 'allPeakVelocities') && ~isempty(velocityMetrics.allPeakVelocities)
        data.(run).(conditionName).PeakVelocityTimeSeries = velocityMetrics.allPeakVelocities;
    end

    if isfield(velocityMetrics, 'velocityMimicryResponse') && isfinite(velocityMetrics.velocityMimicryResponse)
        data.(run).(conditionName).VelocityMimicryResponse = velocityMetrics.velocityMimicryResponse;
    end

    if isfield(velocityMetrics, 'velocityMimicryLatency') && isfinite(velocityMetrics.velocityMimicryLatency)
        data.(run).(conditionName).VelocityMimicryLatency = velocityMetrics.velocityMimicryLatency;
    end

    disp(['✓ Enhanced velocity analysis completed for: ', conditionName]);

catch ME
    disp(['Enhanced velocity analysis integration error: ', ME.message]);
end
end
