function value = getSafeAnatomicalValue(trialData, regionName)
% Safely extract anatomical movement values

try
    if isfield(trialData, 'AnatomicalMovement') && ...
       isfield(trialData.AnatomicalMovement, regionName) && ...
       ~isempty(trialData.AnatomicalMovement.(regionName))
        
        data = trialData.AnatomicalMovement.(regionName);
        
        if isnumeric(data)
            validData = data(isfinite(data));
            if ~isempty(validData)
                value = mean(validData);
            else
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
