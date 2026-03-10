%% 5. FREQUENCY DOMAIN ANALYSIS
function spectralMetrics = performFrequencyAnalysis(data, run, conditionName, config)
    % Perform frequency domain analysis for mimicry detection
    
    spectralMetrics = struct();
    
    % Get displacement data
    if isfield(data.(run).(conditionName), 'StableMeanDisplacement')
        displacement = data.(run).(conditionName).StableMeanDisplacement;
        displacement = displacement(~isnan(displacement));
    else
        spectralMetrics = initializeEmptySpectralMetrics();
        return;
    end
    
    if length(displacement) < 20 % Need minimum length for spectral analysis
        spectralMetrics = initializeEmptySpectralMetrics();
        return;
    end
    
    % Remove DC component and detrend
    displacement = detrend(displacement);
    
    % Compute power spectral density
    try
        [psd, freqs] = pwelch(displacement, [], [], [], config.frameRate);
    catch
        spectralMetrics = initializeEmptySpectralMetrics();
        return;
    end
    
    % Define frequency bands
    lowBand = config.frequencyBands(1, :);      % 0.5-2 Hz (slow movements)
    speechBand = config.frequencyBands(2, :);    % 2-8 Hz (speech-like)
    highBand = config.frequencyBands(3, :);      % 8-15 Hz (fast movements)
    
    % Calculate power in different bands
    totalPower = trapz(freqs, psd);
    
    lowPower = calculateBandPower(psd, freqs, lowBand);
    speechPower = calculateBandPower(psd, freqs, speechBand);
    highPower = calculateBandPower(psd, freqs, highBand);
    
    % Mimicry-specific metrics
    spectralMimicryIndex = speechPower / totalPower; % Higher for speech-like movements
    
    % Temporal coherence (autocorrelation-based)
    temporalCoherence = calculateTemporalCoherence(displacement, config);
    
    % Store results
    spectralMetrics.spectralMimicryIndex = spectralMimicryIndex;
    spectralMetrics.frequencyProfile = psd;
    spectralMetrics.frequencies = freqs;
    spectralMetrics.speechBandPower = speechPower;
    spectralMetrics.lowBandPower = lowPower;
    spectralMetrics.highBandPower = highPower;
    spectralMetrics.totalPower = totalPower;
    spectralMetrics.temporalCoherence = temporalCoherence;
    
    disp(['Spectral analysis: MimicryIndex=', num2str(spectralMimicryIndex, '%.3f'), ...
          ', SpeechPower=', num2str(speechPower, '%.3f'), ', Coherence=', num2str(temporalCoherence, '%.3f')]);
end
