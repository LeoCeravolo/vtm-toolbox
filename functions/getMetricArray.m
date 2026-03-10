function metricArray = getMetricArray(condData, metricName, expectedLength)
% Get metric array padded to expected length with NaN

metricArray = NaN(expectedLength, 1);

try
    if isfield(condData, metricName) && ~isempty(condData.(metricName))
        data = condData.(metricName);
        if isnumeric(data)
            actualLength = min(length(data), expectedLength);
            metricArray(1:actualLength) = data(1:actualLength);
        end
    end
    
catch ME
    % Keep NaN array
end
end
