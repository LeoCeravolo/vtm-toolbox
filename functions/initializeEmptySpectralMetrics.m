%% 7. INITIALIZE EMPTY SPECTRAL METRICS
function spectralMetrics = initializeEmptySpectralMetrics()
    % Initialize empty spectral metrics structure
    
    spectralMetrics.spectralMimicryIndex = NaN;
    spectralMetrics.frequencyProfile = [];
    spectralMetrics.frequencies = [];
    spectralMetrics.speechBandPower = NaN;
    spectralMetrics.lowBandPower = NaN;
    spectralMetrics.highBandPower = NaN;
    spectralMetrics.totalPower = NaN;
    spectralMetrics.temporalCoherence = NaN;
end
