function [meanVal, stdVal, countVal] = extractMetricStatistics(condData, metricName)
% Extract mean, std, and count for a specific metric

meanVal = NaN;
stdVal = NaN;
countVal = 0;

try
    if isfield(condData, metricName) && ~isempty(condData.(metricName))
        data = condData.(metricName);
        
        % Handle different data types
        if isnumeric(data)
            validData = data(isfinite(data));
            if ~isempty(validData)
                meanVal = mean(validData);
                if length(validData) > 1
                    stdVal = std(validData);
                end
                countVal = length(validData);
            end
        elseif iscell(data)
            % Handle cell arrays (like velocity metrics)
            allValues = [];
            for i = 1:length(data)
                if isnumeric(data{i}) && ~isempty(data{i})
                    cellData = data{i};
                    validCellData = cellData(isfinite(cellData));
                    allValues = [allValues; validCellData(:)];
                end
            end
            
            if ~isempty(allValues)
                meanVal = mean(allValues);
                if length(allValues) > 1
                    stdVal = std(allValues);
                end
                countVal = length(allValues);
            end
        end
    end
    
catch ME
    % Keep default NaN/0 values
end
end
