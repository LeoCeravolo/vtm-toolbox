function value = safeGetAnatomicalValue(trialData, regionName, frameIdx)
    % Safely get anatomical region value
    try
        if isfield(trialData, 'AnatomicalMovement') && ...
           isfield(trialData.AnatomicalMovement, regionName) && ...
           ~isempty(trialData.AnatomicalMovement.(regionName))
            
            if length(trialData.AnatomicalMovement.(regionName)) >= frameIdx
                value = trialData.AnatomicalMovement.(regionName)(frameIdx);
                if ~isfinite(value)
                    value = NaN;
                end
            else
                value = NaN;
            end
        else
            value = NaN;
        end
    catch
        value = NaN;
    end
end