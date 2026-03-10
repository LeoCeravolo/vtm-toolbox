function [cleanData, outlierInfo] = removeOutliersIQR(data, conditionName)
% Alternative outlier removal using Interquartile Range (IQR) method

cleanData = [];
outlierInfo = struct();

try
    if isempty(data)
        return;
    end
    
    validData = data(isfinite(data) & data > 0);
    
    if length(validData) < 4 % Need at least 4 points for IQR
        cleanData = validData;
        outlierInfo.method = 'IQR_insufficient_data';
        return;
    end
    
    % Calculate IQR bounds
    Q1 = prctile(validData, 25);
    Q3 = prctile(validData, 75);
    IQR = Q3 - Q1;
    
    % Standard IQR outlier detection: Q1 - 1.5*IQR, Q3 + 1.5*IQR
    lowerBound = Q1 - 1.5 * IQR;
    upperBound = Q3 + 1.5 * IQR;
    
    % Remove outliers
    outlierMask = (validData < lowerBound) | (validData > upperBound);
    cleanData = validData(~outlierMask);
    outliers = validData(outlierMask);
    
    % Store outlier information
    outlierInfo.method = 'IQR';
    outlierInfo.condition = conditionName;
    outlierInfo.Q1 = Q1;
    outlierInfo.Q3 = Q3;
    outlierInfo.IQR = IQR;
    outlierInfo.bounds = [lowerBound, upperBound];
    outlierInfo.originalCount = length(validData);
    outlierInfo.outlierCount = length(outliers);
    outlierInfo.cleanCount = length(cleanData);
    outlierInfo.outlierValues = outliers;
    
catch ME
    disp(['IQR outlier removal error: ', ME.message]);
    cleanData = data;
end
end
