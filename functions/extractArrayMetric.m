function value = extractArrayMetric(trialData, fieldName, func)
% Extract value from array using specified function (mean, max, etc.)
value = NaN;

try
    if isfield(trialData, fieldName) && ~isempty(trialData.(fieldName))
        rawData = trialData.(fieldName);
        if isnumeric(rawData)
            validData = rawData(isfinite(rawData) & rawData > 0);
            if ~isempty(validData)
                value = func(validData);
            end
        end
    end
catch
    value = NaN;
end
end
