function value = getSafeMimicryMetric(trialData, fieldName)
% Safely extract mimicry metrics that might have special handling

value = NaN;

try
    % First try direct field access
    if isfield(trialData, fieldName) && ~isempty(trialData.(fieldName))
        data = trialData.(fieldName);
        
        % Handle different data types for mimicry metrics
        if isnumeric(data)
            validData = data(isfinite(data));
            if ~isempty(validData)
                if length(validData) == 1
                    value = validData;
                else
                    value = mean(validData);
                end
            end
        elseif ischar(data) || isstring(data)
            % Try to convert string to number
            numValue = str2double(data);
            if isfinite(numValue)
                value = numValue;
            end
        elseif iscell(data) && ~isempty(data)
            % Handle cell arrays
            if isnumeric(data{1})
                numData = cell2mat(data);
                validData = numData(isfinite(numData));
                if ~isempty(validData)
                    value = mean(validData);
                end
            end
        end
        return;
    end
    
    % Try alternative field names for specific metrics
    alternativeNames = {};
    switch fieldName
        case 'MimicryLatency'
            alternativeNames = {'Latency', 'MimicryOnset', 'ResponseLatency'};
        case 'EmotionMimicryIndex'
            alternativeNames = {'EmotionIndex', 'MimicryIndex', 'EmotionalMimicry'};
    end
    
    for i = 1:length(alternativeNames)
        if isfield(trialData, alternativeNames{i}) && ~isempty(trialData.(alternativeNames{i}))
            value = getSafeTrialValue(trialData, alternativeNames{i});
            return;
        end
    end
    
catch ME
    disp(['Warning in getSafeMimicryMetric for ', fieldName, ': ', ME.message]);
    value = NaN;
end
end
