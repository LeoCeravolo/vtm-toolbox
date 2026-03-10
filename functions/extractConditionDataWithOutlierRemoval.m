function [conditionData, conditionLabels, outlierInfo] = extractConditionDataWithOutlierRemoval(participantConditionData, conditions, metricName)
% Extract condition data and remove outliers using 3-sigma rule

conditionData = {};
conditionLabels = {};
outlierInfo = struct();
outlierInfo.totalOutliers = 0;
outlierInfo.conditionOutliers = {};

% First pass: collect all data to establish global statistics
allData = [];
allConditionLabels = [];

for condIdx = 1:length(conditions)
    condName = conditions{condIdx};
    if isfield(participantConditionData, condName) && ...
       isfield(participantConditionData.(condName), metricName) && ...
       ~isempty(participantConditionData.(condName).(metricName))
        
        data = participantConditionData.(condName).(metricName);
        validData = data(isfinite(data) & data > 0);
        
        if ~isempty(validData)
            allData = [allData; validData(:)];
            allConditionLabels = [allConditionLabels; repmat({condName}, length(validData), 1)];
        end
    end
end

if isempty(allData)
    disp(['⚠ No valid data found for metric: ', metricName]);
    return;
end

% Calculate global statistics for outlier detection
globalMean = mean(allData);
globalStd = std(allData);
outlierThreshold = 3; % 3-sigma rule

% Define outlier bounds
lowerBound = globalMean - outlierThreshold * globalStd;
upperBound = globalMean + outlierThreshold * globalStd;

disp(['=== OUTLIER DETECTION FOR ', metricName, ' ===']);
disp(['Global mean: ', num2str(globalMean, '%.3f')]);
disp(['Global std: ', num2str(globalStd, '%.3f')]);
disp(['Outlier bounds: [', num2str(lowerBound, '%.3f'), ', ', num2str(upperBound, '%.3f'), ']']);

% Second pass: remove outliers from each condition
for condIdx = 1:length(conditions)
    condName = conditions{condIdx};
    if isfield(participantConditionData, condName) && ...
       isfield(participantConditionData.(condName), metricName) && ...
       ~isempty(participantConditionData.(condName).(metricName))
        
        data = participantConditionData.(condName).(metricName);
        validData = data(isfinite(data) & data > 0);
        
        if ~isempty(validData)
            % Identify outliers
            outlierMask = (validData < lowerBound) | (validData > upperBound);
            outliers = validData(outlierMask);
            cleanData = validData(~outlierMask);
            
            % Store outlier information
            outlierInfo.conditionOutliers{end+1} = struct('condition', condName, ...
                                                         'originalCount', length(validData), ...
                                                         'outlierCount', length(outliers), ...
                                                         'cleanCount', length(cleanData), ...
                                                         'outlierValues', outliers);
            outlierInfo.totalOutliers = outlierInfo.totalOutliers + length(outliers);
            
            % Log outlier removal
            if length(outliers) > 0
                outlierPercentage = length(outliers) / length(validData) * 100;
                disp(['  ', condName, ': Removed ', num2str(length(outliers)), '/', num2str(length(validData)), ...
                      ' outliers (', num2str(outlierPercentage, '%.1f'), '%)']);
                if length(outliers) <= 5 % Show outlier values if not too many
                    disp(['    Outlier values: ', num2str(outliers', '%.3f ')]);
                end
            else
                disp(['  ', condName, ': No outliers detected']);
            end
            
            % Use clean data for analysis
            if ~isempty(cleanData)
                conditionData{end+1} = cleanData;
                conditionLabels{end+1} = condName;
            else
                disp(['  ⚠ ', condName, ': All data removed as outliers!']);
            end
        end
    end
end

% Final summary
totalOriginal = sum(cellfun(@(x) x.originalCount, outlierInfo.conditionOutliers));
totalClean = sum(cellfun(@length, conditionData));
totalOutliersRemoved = outlierInfo.totalOutliers;

disp(['📊 OUTLIER SUMMARY: ', num2str(totalOutliersRemoved), '/', num2str(totalOriginal), ...
      ' outliers removed (', num2str(totalOutliersRemoved/totalOriginal*100, '%.1f'), '%)']);
disp(['📊 CLEAN DATA: ', num2str(totalClean), ' values retained for analysis']);
disp(['===============================================']);

outlierInfo.metric = metricName;
outlierInfo.globalMean = globalMean;
outlierInfo.globalStd = globalStd;
outlierInfo.outlierThreshold = outlierThreshold;
outlierInfo.bounds = [lowerBound, upperBound];
outlierInfo.totalOriginal = totalOriginal;
outlierInfo.totalClean = totalClean;
end
