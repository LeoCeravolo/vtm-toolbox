
function value = extractScalarMetric(trialData, fieldName)
% Extract scalar value directly
value = NaN;

try
    if isfield(trialData, fieldName) && ~isempty(trialData.(fieldName))
        rawValue = trialData.(fieldName);
        if isnumeric(rawValue) && isscalar(rawValue) && isfinite(rawValue)
            value = rawValue;
        end
    end
catch
    value = NaN;
end
end