function value = extractMetricFromTrial(trialData, metricName)
% EXTRACTMETRICFROMTRIAL - Extract single metric value from trial data
value = NaN;

try
    if isfield(trialData, metricName) && ~isempty(trialData.(metricName))
        rawValue = trialData.(metricName);

        if isnumeric(rawValue)
            if isscalar(rawValue)
                % Single value
                if isfinite(rawValue)
                    value = rawValue;
                end
            else
                % Array - extract meaningful value
                validValues = rawValue(isfinite(rawValue) & rawValue > 0);
                if ~isempty(validValues)
                    switch metricName
                        case {'StableMeanDisplacement', 'ROIFlowMagnitude'}
                            value = mean(validValues);
                        case {'StableMaxDisplacement', 'MaxVelocity'}
                            value = max(validValues);
                        case {'MeanVelocity'}
                            value = mean(validValues);
                        otherwise
                            value = mean(validValues);
                    end
                end
            end
        end
    end

catch ME
    disp(['⚠ Error extracting ', metricName, ': ', ME.message]);
end
end
