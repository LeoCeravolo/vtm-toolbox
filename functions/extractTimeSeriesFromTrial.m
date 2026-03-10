function timeSeriesData = extractTimeSeriesFromTrial(trialData)
    timeSeriesData = struct();
    
    if isfield(trialData, 'AllDisplacements') && ~isempty(trialData.AllDisplacements)
        % Concatenate all frame displacements
        allDisplacements = [];
        for frameIdx = 1:length(trialData.AllDisplacements)
            if ~isempty(trialData.AllDisplacements{frameIdx})
                frameDisp = trialData.AllDisplacements{frameIdx};
                allDisplacements = [allDisplacements; mean(frameDisp)]; % Take mean per frame
            else
                allDisplacements = [allDisplacements; NaN];
            end
        end
        
        timeSeriesData.displacements = allDisplacements;
        
        % Extract episodes if available
        if ~isempty(allDisplacements)
            threshold = prctile(allDisplacements(~isnan(allDisplacements)), 70);
            movementFrames = allDisplacements > threshold;
            timeSeriesData.episodes = findConsecutiveEpisodes(movementFrames);
        end
    end
end
