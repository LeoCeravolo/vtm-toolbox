%% 6. CALCULATE BAND POWER
function bandPower = calculateBandPower(psd, freqs, band)
    % Calculate power in a specific frequency band
    
    bandIndices = freqs >= band(1) & freqs <= band(2);
    if any(bandIndices)
        bandPower = trapz(freqs(bandIndices), psd(bandIndices));
    else
        bandPower = 0;
    end
end
