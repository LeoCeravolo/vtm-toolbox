%% 8. CALCULATE TEMPORAL COHERENCE
function coherence = calculateTemporalCoherence(displacement, config)
    % Calculate temporal coherence for rhythmic pattern detection
    
    if length(displacement) < 15
        coherence = 0;
        return;
    end
    
    try
        % Calculate autocorrelation
        [acorr, lags] = xcorr(displacement, 'normalized');
        
        % Look for peaks at speech rhythm intervals (2-8 Hz range)
        speechRhythmLags = round(config.frameRate ./ [2:8]); % Convert Hz to frame lags
        
        % Find maximum correlation at speech-relevant lags
        validLags = lags > 0 & lags <= max(speechRhythmLags);
        if any(validLags)
            relevantCorr = acorr(validLags);
            speechLagCorr = [];
            
            for lag = speechRhythmLags
                if lag <= length(relevantCorr)
                    speechLagCorr(end+1) = relevantCorr(lag);
                end
            end
            
            if ~isempty(speechLagCorr)
                coherence = max(speechLagCorr);
            else
                coherence = max(relevantCorr);
            end
        else
            coherence = 0;
        end
        
        % Ensure coherence is between 0 and 1
        coherence = max(0, min(1, coherence));
        
    catch
        coherence = 0;
    end
end
