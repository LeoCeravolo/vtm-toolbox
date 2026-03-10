function mimicryMetrics = enhancedVelocityBasedMimicryAnalysis(data, run, conditionName, mimicryConfig)
% Enhanced mimicry analysis focusing on velocity patterns
mimicryMetrics = struct();

try
    % Extract displacement data
    if isfield(data.(run).(conditionName), 'AllDisplacements') && ~isempty(data.(run).(conditionName).AllDisplacements)
        allDisplacements = data.(run).(conditionName).AllDisplacements;
    else
        mimicryMetrics.error = 'No displacement data available';
        return;
    end

    % Get stimulus timing
    stimulusOnset = 1; % Default to frame 1 if not specified
    if isfield(data.(run).(conditionName), 'StimulusOnsetFrame')
        stimulusOnset = data.(run).(conditionName).StimulusOnsetFrame;
    end

    frameRate = mimicryConfig.frameRate;

    % Calculate velocity profiles for each frame
    velocityProfiles = cell(size(allDisplacements));
    peakVelocities = [];
    meanVelocities = [];

    for frameIdx = 1:length(allDisplacements)
        if ~isempty(allDisplacements{frameIdx})
            velocityMetrics = calculateEnhancedVelocityMetrics(allDisplacements{frameIdx}, frameRate);
            velocityProfiles{frameIdx} = velocityMetrics;

            if isfinite(velocityMetrics.peakVelocity)
                peakVelocities(end+1) = velocityMetrics.peakVelocity;
            end
            if isfinite(velocityMetrics.meanVelocity)
                meanVelocities(end+1) = velocityMetrics.meanVelocity;
            end
        end
    end

    % Define analysis windows relative to stimulus onset
    baselineStart = max(1, stimulusOnset - round(0.2 * frameRate)); % 200ms before
    baselineEnd = stimulusOnset - 1;
    mimicryStart = stimulusOnset;
    mimicryEnd = min(length(allDisplacements), stimulusOnset + round(0.5 * frameRate)); % 500ms after

    % Extract baseline and mimicry window velocities
    baselineVelocities = [];
    mimicryVelocities = [];

    for frameIdx = baselineStart:baselineEnd
        if frameIdx <= length(velocityProfiles) && ~isempty(velocityProfiles{frameIdx})
            if isfinite(velocityProfiles{frameIdx}.peakVelocity)
                baselineVelocities(end+1) = velocityProfiles{frameIdx}.peakVelocity;
            end
        end
    end

    for frameIdx = mimicryStart:mimicryEnd
        if frameIdx <= length(velocityProfiles) && ~isempty(velocityProfiles{frameIdx})
            if isfinite(velocityProfiles{frameIdx}.peakVelocity)
                mimicryVelocities(end+1) = velocityProfiles{frameIdx}.peakVelocity;
            end
        end
    end

    % Calculate enhanced mimicry metrics
    if ~isempty(baselineVelocities) && ~isempty(mimicryVelocities)
        mimicryMetrics.baselineMeanVelocity = mean(baselineVelocities);
        mimicryMetrics.baselineMaxVelocity = max(baselineVelocities);
        mimicryMetrics.mimicryMeanVelocity = mean(mimicryVelocities);
        mimicryMetrics.mimicryMaxVelocity = max(mimicryVelocities);

        % Velocity-based mimicry response
        mimicryMetrics.velocityMimicryResponse = mimicryMetrics.mimicryMaxVelocity - mimicryMetrics.baselineMaxVelocity;
        mimicryMetrics.velocityMimicryRatio = mimicryMetrics.mimicryMaxVelocity / (mimicryMetrics.baselineMaxVelocity + eps);

        % Find latency to peak velocity
        [maxVel, maxIdx] = max(mimicryVelocities);
        mimicryMetrics.velocityMimicryLatency = (maxIdx - 1) / frameRate; % Convert to seconds

        % Statistical significance test
        if length(baselineVelocities) >= 3 && length(mimicryVelocities) >= 3
            [~, mimicryMetrics.velocitySignificance] = ttest2(baselineVelocities, mimicryVelocities);
        else
            mimicryMetrics.velocitySignificance = NaN;
        end
    else
        mimicryMetrics.baselineMeanVelocity = NaN;
        mimicryMetrics.mimicryMeanVelocity = NaN;
        mimicryMetrics.velocityMimicryResponse = NaN;
        mimicryMetrics.velocityMimicryLatency = NaN;
        mimicryMetrics.velocitySignificance = NaN;
    end

    % Store all velocity profiles for detailed analysis
    mimicryMetrics.velocityProfiles = velocityProfiles;
    mimicryMetrics.allPeakVelocities = peakVelocities;
    mimicryMetrics.allMeanVelocities = meanVelocities;

catch ME
    mimicryMetrics.error = ME.message;
    disp(['Enhanced velocity-based mimicry analysis error: ', ME.message]);
end
end
