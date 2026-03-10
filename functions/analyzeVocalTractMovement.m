function analyzeVocalTractMovement(data, run, conditionName, anatomicalROIs, frameCount)
    % Analyze movement in visible vocal tract regions with functional interpretation
    
    if ~isfield(data.(run).(conditionName), 'stableDisplacements') || isempty(data.(run).(conditionName).stableDisplacements)
        return;
    end
    
    stableDisplacements = data.(run).(conditionName).stableDisplacements;
    commonCurrPoints = data.(run).(conditionName).commonCurrPoints; % Assuming this exists
    
    % Analyze each visible anatomical region
    regionNames = fieldnames(anatomicalROIs);
    for regionIdx = 1:length(regionNames)
        regionName = regionNames{regionIdx};
        regionROI = anatomicalROIs.(regionName);
        regionIndices = findPointsInROI(commonCurrPoints, regionROI);
        
        % Ensure field exists
        if ~isfield(data.(run).(conditionName).AnatomicalMovement, regionName)
            data.(run).(conditionName).AnatomicalMovement.(regionName) = [];
        end
        
        if ~isempty(regionIndices)
            regionDisplacements = stableDisplacements(regionIndices);
            if ~isempty(regionDisplacements)
                regionMovement = mean(regionDisplacements);
                
                % Store movement data
                data.(run).(conditionName).AnatomicalMovement.(regionName)(frameCount) = regionMovement;
                
                % Add functional interpretation
                data.(run).(conditionName) = addFunctionalInterpretation(data.(run).(conditionName), regionName, regionMovement, frameCount);
            else
                data.(run).(conditionName).AnatomicalMovement.(regionName)(frameCount) = NaN;
            end
        else
            data.(run).(conditionName).AnatomicalMovement.(regionName)(frameCount) = NaN;
        end
    end
end
