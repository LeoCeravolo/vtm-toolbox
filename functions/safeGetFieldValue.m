function value = safeGetFieldValue(trialData, fieldName, index)
    % Safely get field value with bounds checking
    try
        if isfield(trialData, fieldName) && ~isempty(trialData.(fieldName))
            if length(trialData.(fieldName)) >= index
                value = trialData.(fieldName)(index);
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