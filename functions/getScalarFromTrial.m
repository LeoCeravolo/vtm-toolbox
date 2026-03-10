function value = getScalarFromTrial(trialData, fieldName, defaultValue)
% GETSCALARFROMTRIAL - Extract scalar value from trial data
value = defaultValue;

try
    if isfield(trialData, fieldName) && ~isempty(trialData.(fieldName))
        rawValue = trialData.(fieldName);

        if isnumeric(rawValue)
            if isscalar(rawValue) && isfinite(rawValue)
                value = rawValue;
            elseif ~isscalar(rawValue)
                % Array - get a representative value
                validValues = rawValue(isfinite(rawValue));
                if ~isempty(validValues)
                    if contains(fieldName, 'Mean')
                        value = mean(validValues);
                    elseif contains(fieldName, 'Max')
                        value = max(validValues);
                    else
                        value = mean(validValues);
                    end
                end
            end
        end
    end
catch
    value = defaultValue;
end
end
