function frames = calculateFramesFromStimulus(frameIdx, stimulusOnset)
    try
        if isfinite(stimulusOnset) && stimulusOnset > 0
            frames = frameIdx - stimulusOnset;
        else
            frames = NaN;
        end
    catch
        frames = NaN;
    end
end
