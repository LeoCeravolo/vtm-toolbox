%% 3. STIMULUS-ALIGNED TEMPORAL ANALYSIS
function mimicryMetrics = performStimulusAlignedAnalysis(data, run, conditionName, config)
    % Analyze movement patterns relative to stimulus onset
    
    mimicryMetrics = struct();
    
    % Get displacement data
    if isfield(data.(run).(conditionName), 'StableMeanDisplacement')
        displacement = data.(run).(conditionName).StableMeanDisplacement;
        displacement = displacement(~isnan(displacement));
    else
        mimicryMetrics.mimicryResponse = NaN;
        mimicryMetrics.mimicryLatency = NaN;
        mimicryMetrics.baselineMovement = NaN;
        mimicryMetrics.stimulusMovement = NaN;
        mimicryMetrics.significance = false;
        return;
    end
    
    if length(displacement) < 10
        mimicryMetrics.mimicryResponse = NaN;
        mimicryMetrics.mimicryLatency = NaN;
        mimicryMetrics.baselineMovement = NaN;
        mimicryMetrics.stimulusMovement = NaN;
        mimicryMetrics.significance = false;
        return;
    end
    
    % Get timing windows
    if isfield(data.(run).(conditionName), 'BaselineWindow') && isfield(data.(run).(conditionName), 'MimicryWindow')
        baselineWindow = data.(run).(conditionName).BaselineWindow;
        mimicryWindow = data.(run).(conditionName).MimicryWindow;
    else
        % Default windows if not set
        stimulusOnset = 1;
        baselineWindow = max(1, stimulusOnset + round(config.baselineWindowMs * config.frameRate / 1000));
        mimicryWindow = min(length(displacement), stimulusOnset + round(config.mimicryWindowMs * config.frameRate / 1000));
    end
    
    % Ensure windows are valid
    baselineWindow = max(1, min(baselineWindow, length(displacement)));
    mimicryWindow = max(1, min(mimicryWindow, length(displacement)));
    
    % Calculate baseline and stimulus-period movement
    if length(baselineWindow) >= 2 && baselineWindow(1) > 0 && baselineWindow(2) <= length(displacement)
        baselineMovement = mean(displacement(baselineWindow(1):baselineWindow(2)));
    else
        baselineMovement = mean(displacement(1:min(5, length(displacement))));
    end
    
    if length(mimicryWindow) >= 2 && mimicryWindow(1) > 0 && mimicryWindow(2) <= length(displacement)
        stimulusMovement = mean(displacement(mimicryWindow(1):mimicryWindow(2)));
    else
        stimulusMovement = mean(displacement(max(1, end-4):end));
    end
    
    % Calculate mimicry response (stimulus - baseline)
    mimicryResponse = stimulusMovement - baselineMovement;
    
    % Find mimicry onset latency (first significant increase above baseline)
    mimicryLatency = findMimicryOnset(displacement, baselineMovement, mimicryWindow, config);
    
    % Statistical significance test (simple t-test approach)
    if length(baselineWindow) >= 2 && length(mimicryWindow) >= 2
        try
            baselineData = displacement(baselineWindow(1):baselineWindow(2));
            stimulusData = displacement(mimicryWindow(1):mimicryWindow(2));
            [~, p] = ttest2(stimulusData, baselineData);
            significance = p < 0.05 && mimicryResponse > 0;
        catch
            significance = abs(mimicryResponse) > std(displacement) * 0.5; % Heuristic
        end
    else
        significance = abs(mimicryResponse) > std(displacement) * 0.5;
    end
    
    % Store results
    mimicryMetrics.mimicryResponse = mimicryResponse;
    mimicryMetrics.mimicryLatency = mimicryLatency;
    mimicryMetrics.baselineMovement = baselineMovement;
    mimicryMetrics.stimulusMovement = stimulusMovement;
    mimicryMetrics.significance = significance;
    
    disp(['Mimicry analysis: Response=', num2str(mimicryResponse, '%.3f'), ...
          ', Latency=', num2str(mimicryLatency, '%.1f'), 'ms, Significant=', num2str(significance)]);
end
