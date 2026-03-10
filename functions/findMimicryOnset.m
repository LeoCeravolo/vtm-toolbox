%% 4. FIND MIMICRY ONSET LATENCY
function latencyMs = findMimicryOnset(displacement, baselineLevel, mimicryWindow, config)
    % Find the latency of mimicry onset in milliseconds
    
    if length(displacement) < 10 || length(mimicryWindow) < 2
        latencyMs = NaN;
        return;
    end
    
    % Define threshold as baseline + 2 standard deviations
    threshold = baselineLevel + 2 * std(displacement);
    
    % Look for first sustained increase above threshold
    searchWindow = mimicryWindow(1):min(mimicryWindow(2), length(displacement));
    
    for i = 1:(length(searchWindow)-2)
        frameIdx = searchWindow(i);
        if frameIdx <= length(displacement) && frameIdx+2 <= length(displacement)
            % Check for sustained increase (3 consecutive frames above threshold)
            if all(displacement(frameIdx:frameIdx+2) > threshold)
                latencyFrames = i - 1; % Relative to start of search window
                latencyMs = latencyFrames * 1000 / config.frameRate;
                return;
            end
        end
    end
    
    % If no clear onset found, return NaN
    latencyMs = NaN;
end
