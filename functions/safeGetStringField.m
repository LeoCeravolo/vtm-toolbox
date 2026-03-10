function str = safeGetStringField(trialData, fieldName, defaultValue)
    try
        if isfield(trialData, fieldName) && ~isempty(trialData.(fieldName))
            str = char(trialData.(fieldName));
        else
            str = char(defaultValue);
        end
    catch
        str = char(defaultValue);
    end
end
