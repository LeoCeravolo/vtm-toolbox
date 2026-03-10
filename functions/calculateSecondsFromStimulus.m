function seconds = calculateSecondsFromStimulus(frameIdx, stimulusOnset)
    try
        if isfinite(stimulusOnset) && stimulusOnset > 0
            seconds = (frameIdx - stimulusOnset) / 25;
        else
            seconds = NaN;
        end
    catch
        seconds = NaN;
    end
end