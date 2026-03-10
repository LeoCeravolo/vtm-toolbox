function value = getStringFromTrial(trialData, fieldName, defaultValue)
% GETSTRINGFROMTRIAL - Extract string value from trial data
value = defaultValue;

try
    if isfield(trialData, fieldName) && ~isempty(trialData.(fieldName))
        rawValue = trialData.(fieldName);
        if ischar(rawValue) || isstring(rawValue)
            value = char(rawValue);
        end
    end
catch
    value = defaultValue;
end
end
