function value = getSafeVelocityMetric(trialData, fieldName)
% Safely extract velocity metrics that might be in VelocityMetrics structure or direct fields

value = NaN;

try
    % First try direct field access
    if isfield(trialData, fieldName) && ~isempty(trialData.(fieldName))
        value = getSafeTrialValue(trialData, fieldName);
        return;
    end
    
    % Try VelocityMetrics structure
    if isfield(trialData, 'VelocityMetrics') && ~isempty(trialData.VelocityMetrics)
        if isfield(trialData.VelocityMetrics, fieldName) && ~isempty(trialData.VelocityMetrics.(fieldName))
            data = trialData.VelocityMetrics.(fieldName);
            if isnumeric(data)
                validData = data(isfinite(data));
                if ~isempty(validData)
                    if length(validData) == 1
                        value = validData;
                    else
                        value = mean(validData);
                    end
                end
            end
            return;
        end
    end
    
    % Try common alternative field names
    alternativeNames = {};
    switch fieldName
        case 'PeakVelocities'
            alternativeNames = {'PeakVelocity', 'MaxVelocity', 'VelocityPeak'};
        case 'MeanVelocities'
            alternativeNames = {'MeanVelocity', 'AvgVelocity', 'VelocityMean'};
        case 'VelocityVariances'
            alternativeNames = {'VelocityVariance', 'VelVariance', 'VelocityStd'};
    end
    
    for i = 1:length(alternativeNames)
        if isfield(trialData, alternativeNames{i}) && ~isempty(trialData.(alternativeNames{i}))
            value = getSafeTrialValue(trialData, alternativeNames{i});
            return;
        end
    end
    
catch ME
    disp(['Warning in getSafeVelocityMetric for ', fieldName, ': ', ME.message]);
    value = NaN;
end
end
