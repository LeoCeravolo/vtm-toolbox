function velocityMetrics = calculateEnhancedVelocityMetrics(displacements, frameRate)
% Enhanced velocity calculation with multiple metrics
velocityMetrics = struct();

if isempty(displacements) || length(displacements) < 2
    % Return empty metrics if insufficient data
    velocityMetrics.meanVelocity = NaN;
    velocityMetrics.maxVelocity = NaN;
    velocityMetrics.peakVelocity = NaN;
    velocityMetrics.velocityVariance = NaN;
    velocityMetrics.accelerations = [];
    velocityMetrics.maxAcceleration = NaN;
    velocityMetrics.velocityProfile = [];
    return;
end

% Convert displacements to velocities (pixels/second)
velocities = displacements * frameRate;

% Basic velocity metrics
velocityMetrics.meanVelocity = mean(velocities);
velocityMetrics.maxVelocity = max(velocities);
velocityMetrics.velocityVariance = var(velocities);
velocityMetrics.velocityProfile = velocities;

% Enhanced peak velocity detection using smoothing
if length(velocities) >= 5
    % Smooth velocities to reduce noise
    smoothedVelocities = smoothdata(velocities, 'gaussian', 3);

    % Find peaks in smoothed velocity profile
    [peakValues, peakLocs] = findpeaks(smoothedVelocities, 'MinPeakHeight', mean(smoothedVelocities) + std(smoothedVelocities));

    if ~isempty(peakValues)
        velocityMetrics.peakVelocity = max(peakValues);
        velocityMetrics.peakVelocityFrame = peakLocs(peakValues == max(peakValues));
        velocityMetrics.numPeaks = length(peakValues);
    else
        velocityMetrics.peakVelocity = max(smoothedVelocities);
        velocityMetrics.peakVelocityFrame = find(smoothedVelocities == max(smoothedVelocities), 1);
        velocityMetrics.numPeaks = 0;
    end
else
    velocityMetrics.peakVelocity = max(velocities);
    velocityMetrics.peakVelocityFrame = find(velocities == max(velocities), 1);
    velocityMetrics.numPeaks = 0;
end

% Calculate accelerations (change in velocity)
if length(velocities) >= 3
    accelerations = diff(velocities) * frameRate; % pixels/second²
    velocityMetrics.accelerations = accelerations;
    velocityMetrics.maxAcceleration = max(abs(accelerations));
    velocityMetrics.meanAcceleration = mean(abs(accelerations));
else
    velocityMetrics.accelerations = [];
    velocityMetrics.maxAcceleration = NaN;
    velocityMetrics.meanAcceleration = NaN;
end
end
