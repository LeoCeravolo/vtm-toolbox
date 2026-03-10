function value = safeGetTrialLevelValue(trialData, fieldName)
    % Safely get trial-level (scalar) values
    try
        if isfield(trialData, fieldName) && ~isempty(trialData.(fieldName))
            value = trialData.(fieldName);
            if isnumeric(value) && length(value) > 1
                value = value(1); % Take first value if array
            end
            if ~isfinite(value)
                value = NaN;
            end
        else
            value = NaN;
        end
    catch
        value = NaN;
    end
end
