function [meanVal, stdVal, countVal] = extractAnatomicalStatistics(condData, metricName)
% Extract statistics for anatomical movement metrics

meanVal = NaN;
stdVal = NaN;
countVal = 0;

try
    % Parse anatomical metric name (e.g., 'AnatomicalMovement_tongue')
    parts = split(metricName, '_');
    if length(parts) == 2 && strcmp(parts{1}, 'AnatomicalMovement')
        regionName = parts{2};
        
        if isfield(condData, 'AnatomicalMovement') && ...
           isstruct(condData.AnatomicalMovement) && ...
           isfield(condData.AnatomicalMovement, regionName)
            
            data = condData.AnatomicalMovement.(regionName);
            if isnumeric(data) && ~isempty(data)
                validData = data(isfinite(data) & data > 0);
                if ~isempty(validData)
                    meanVal = mean(validData);
                    if length(validData) > 1
                        stdVal = std(validData);
                    end
                    countVal = length(validData);
                end
            end
        end
    end
    
catch ME
    % Keep default NaN/0 values
end
end
