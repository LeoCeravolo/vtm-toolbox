
function [cleanData, outlierInfo] = removeOutliersMAD(data, conditionName)
% Alternative outlier removal using Median Absolute Deviation (MAD) method

cleanData = [];
outlierInfo = struct();

try
    if isempty(data)
        return;
    end
    
    validData = data(isfinite(data) & data > 0);
    
    if length(validData) < 3
        cleanData = validData;
        outlierInfo.method = 'MAD_insufficient_data';
        return;
    end
    
    % Calculate MAD bounds
    medianVal = median(validData);
    MAD = median(abs(validData - medianVal));
    
    % Modified Z-score threshold (typically 3.5 for MAD)
    threshold = 3.5;
    
    % Calculate modified Z-scores
    modifiedZScores = 0.6745 * (validData - medianVal) / MAD;
    
    % Remove outliers
    outlierMask = abs(modifiedZScores) > threshold;
    cleanData = validData(~outlierMask);
    outliers = validData(outlierMask);
    
    % Store outlier information
    outlierInfo.method = 'MAD';
    outlierInfo.condition = conditionName;
    outlierInfo.median = medianVal;
    outlierInfo.MAD = MAD;
    outlierInfo.threshold = threshold;
    outlierInfo.originalCount = length(validData);
    outlierInfo.outlierCount = length(outliers);
    outlierInfo.cleanCount = length(cleanData);
    outlierInfo.outlierValues = outliers;
    
catch ME
    disp(['MAD outlier removal error: ', ME.message]);
    cleanData = data;
end
end