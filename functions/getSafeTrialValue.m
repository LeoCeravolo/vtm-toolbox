function value = getSafeTrialValue(trialData, fieldName)
% Safely extract numeric values from trial data structure

try
    if isfield(trialData, fieldName) && ~isempty(trialData.(fieldName))
        data = trialData.(fieldName);
        
        % Handle different data types
        if isnumeric(data)
            if length(data) == 1
                value = data;
            elseif length(data) > 1
                % For arrays, take the mean of finite values
                validData = data(isfinite(data));
                if ~isempty(validData)
                    value = mean(validData);
                else
                    value = NaN;
                end
            else
                value = NaN;
            end
        elseif ischar(data) || isstring(data)
            % Handle string/char data that might be numeric
            try
                numValue = str2double(data);
                if isfinite(numValue)
                    value = numValue;
                else
                    value = NaN;
                end
            catch
                value = NaN;
            end
        elseif iscell(data)
            % Handle cell arrays
            try
                if ~isempty(data) && isnumeric(data{1})
                    numData = cell2mat(data);
                    validData = numData(isfinite(numData));
                    if ~isempty(validData)
                        value = mean(validData);
                    else
                        value = NaN;
                    end
                else
                    value = NaN;
                end
            catch
                value = NaN;
            end
        else
            % Non-numeric data, try to convert
            try
                value = double(data);
                if ~isfinite(value)
                    value = NaN;
                end
            catch
                value = NaN;
            end
        end
    else
        value = NaN;
    end
    
    % Ensure we return a finite number or NaN (not Inf)
    if ~isfinite(value)
        value = NaN;
    end
    
catch ME
    % Debug output for problematic fields
    if nargin >= 2
        disp(['Warning: Error extracting ', fieldName, ': ', ME.message]);
    end
    value = NaN;
end
end
