function generateConditionStatisticsCSV(participantConditionData, participant, conditions, outputDir)
% Generate additional summary statistics CSV

try
    % Create statistics summary filename
    statsFilename = fullfile(outputDir, [participant, '_ConditionStatistics.csv']);
    
    fid = fopen(statsFilename, 'w');
    
    % Write headers for statistics summary
    fprintf(fid, 'Metric,Condition,Mean,Std,Min,Max,Median,Count,Valid_Percentage\n');
    
    % Define metrics to analyze
    metricsToAnalyze = {
        'StableMeanDisplacement', 'StableMaxDisplacement', 'ROIFlowMagnitude', 'Entropy',
        'PeakVelocities', 'MeanVelocities',
    };
    
    for metricIdx = 1:length(metricsToAnalyze)
        metricName = metricsToAnalyze{metricIdx};
        
        for condIdx = 1:length(conditions)
            condName = conditions{condIdx};
            
            if isfield(participantConditionData, condName)
                condData = participantConditionData.(condName);
                
                % Get trial count for percentage calculation
                totalTrials = 0;
                if isfield(condData, 'trials') && iscell(condData.trials)
                    totalTrials = length(condData.trials);
                end
                
                if isfield(condData, metricName) && ~isempty(condData.(metricName))
                    data = condData.(metricName);
                    
                    if isnumeric(data)
                        validData = data(isfinite(data));
                        
                        if ~isempty(validData)
                            % Calculate statistics
                            meanVal = mean(validData);
                            stdVal = std(validData);
                            minVal = min(validData);
                            maxVal = max(validData);
                            medianVal = median(validData);
                            countVal = length(validData);
                            
                            % Calculate valid percentage
                            validPercentage = 0;
                            if totalTrials > 0
                                validPercentage = countVal / totalTrials * 100;
                            end
                            
                            % Write row
                            fprintf(fid, '%s,%s,%.6f,%.6f,%.6f,%.6f,%.6f,%d,%.1f\n', ...
                                   metricName, condName, meanVal, stdVal, minVal, maxVal, ...
                                   medianVal, countVal, validPercentage);
                        else
                            % No valid data
                            fprintf(fid, '%s,%s,NaN,NaN,NaN,NaN,NaN,0,0.0\n', metricName, condName);
                        end
                    end
                else
                    % Metric not available for this condition
                    fprintf(fid, '%s,%s,NaN,NaN,NaN,NaN,NaN,0,0.0\n', metricName, condName);
                end
            end
        end
    end
    
    fclose(fid);
    
    disp(['✅ Condition statistics CSV exported: ', statsFilename]);
    
catch ME
    disp(['Statistics CSV export error: ', ME.message]);
    if exist('fid', 'var') && fid ~= -1
        fclose(fid);
    end
end
end
