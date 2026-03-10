function value = getSafeTrialString(trialData, fieldName)
% Safely extract string values from trial data structure

try
    if isfield(trialData, fieldName) && ~isempty(trialData.(fieldName))
        data = trialData.(fieldName);
        
        if ischar(data) || isstring(data)
            value = char(data);
        elseif iscell(data) && ~isempty(data)
            value = char(data{1});
        else
            value = char(string(data));
        end
        
        % Remove any problematic characters for CSV
        value = strrep(value, ',', ';');
        value = strrep(value, newline, ' ');
    else
        value = 'NA';
    end
    
catch
    value = 'NA';
end
end
