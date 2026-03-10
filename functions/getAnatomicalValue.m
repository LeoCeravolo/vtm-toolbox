function value = getAnatomicalValue(trialData, regionName, frameIdx)
    % Get anatomical region value for specific frame
    
    if isfield(trialData, 'AnatomicalMovement') && ...
       isfield(trialData.AnatomicalMovement, regionName) && ...
       ~isempty(trialData.AnatomicalMovement.(regionName))
        
        values = trialData.AnatomicalMovement.(regionName);
        if frameIdx <= length(values)
            value = values(frameIdx);
            if ~isnumeric(value) || ~isfinite(value)
                value = NaN;
            end
        else
            value = NaN;
        end
    else
        value = NaN;
    end
end
