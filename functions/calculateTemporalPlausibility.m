function [temporalMetrics] = calculateTemporalPlausibility(mlClassification, stimulusOnset, frameRate)
% Calculate how plausible the classifications are temporally

temporalMetrics = struct();

% Define expected mimicry window (0-1 second after stimulus)
expectedWindow = stimulusOnset + round([0, 1.0] * frameRate);
expectedWindow = max(1, min(expectedWindow, length(mlClassification)));

% Calculate metrics
mimicryFrames = find(mlClassification);

if ~isempty(mimicryFrames)
    % 1. Percentage of mimicry in expected window
    mimicryInWindow = sum(mimicryFrames >= expectedWindow(1) & mimicryFrames <= expectedWindow(2));
    temporalMetrics.mimicryInExpectedWindow = mimicryInWindow / length(mimicryFrames) * 100;
    
    % 2. Mean distance from stimulus onset
    distances = abs(mimicryFrames - stimulusOnset) / frameRate;
    temporalMetrics.meanDistanceFromStimulus = mean(distances);
    
    % 3. Temporal clustering (how clustered are mimicry detections)
    if length(mimicryFrames) > 1
        frameDiffs = diff(mimicryFrames);
        temporalMetrics.temporalClustering = std(frameDiffs) / mean(frameDiffs);
    else
        temporalMetrics.temporalClustering = 0;
    end
    
    % 4. Early vs late mimicry ratio
    earlyMimicry = sum(mimicryFrames < stimulusOnset + round(0.5 * frameRate));
    lateMimicry = sum(mimicryFrames >= stimulusOnset + round(0.5 * frameRate));
    temporalMetrics.earlyToLateRatio = earlyMimicry / (lateMimicry + 1);
    
else
    temporalMetrics.mimicryInExpectedWindow = 0;
    temporalMetrics.meanDistanceFromStimulus = Inf;
    temporalMetrics.temporalClustering = 0;
    temporalMetrics.earlyToLateRatio = 0;
end

% 5. Temporal plausibility score (0-100, higher = better)
plausibilityScore = 0;
if temporalMetrics.mimicryInExpectedWindow > 50
    plausibilityScore = plausibilityScore + 30;
end
if temporalMetrics.meanDistanceFromStimulus < 1.0
    plausibilityScore = plausibilityScore + 25;
end
if temporalMetrics.temporalClustering < 2.0
    plausibilityScore = plausibilityScore + 25;
end
if temporalMetrics.earlyToLateRatio > 0.3
    plausibilityScore = plausibilityScore + 20;
end

temporalMetrics.plausibilityScore = plausibilityScore;
end
