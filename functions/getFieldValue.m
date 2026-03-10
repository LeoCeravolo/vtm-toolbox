function value = getFieldValue(data, fieldName, frameIdx)
    % Safely extract field value for specific frame
    
    if ischar(fieldName) || isstring(fieldName)
        if ~isfield(data, fieldName) || isempty(data.(fieldName))
            value = NaN;
            return;
        end
        values = data.(fieldName);
    else
        values = fieldName; % Direct array input
    end
    
    if frameIdx <= length(values)
        value = values(frameIdx);
        if ~isnumeric(value) || ~isfinite(value)
            value = NaN;
        end
    else
        value = NaN;
    end
end
