function value = getFieldOrNaN(structData, fieldName)
    if isfield(structData, fieldName) && ~isempty(structData.(fieldName))
        if isnumeric(structData.(fieldName))
            value = structData.(fieldName);
            if isnan(value)
                value = NaN;
            end
        else
            value = NaN;
        end
    else
        value = NaN;
    end
end
