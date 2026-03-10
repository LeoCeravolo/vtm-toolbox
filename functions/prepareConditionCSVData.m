function [csvData, csvHeaders] = prepareConditionCSVData(participantConditionData, participant, conditions)
% Prepare condition data for CSV export

csvData = {};
csvHeaders = {};

try
    % Define all possible metrics to export
    standardMetrics = {
        'StableMeanDisplacement', 'StableMaxDisplacement', 'StablePointCount', 'PointCount',
        'ROIFlowMagnitude', 'Entropy', 'PeakVelocities', 'MeanVelocities', 'VelocityVariances',
        'MaxAccelerations', 'MimicryResponse', 'MimicryLatency', 'BaselineMovement', 
        'StimulusMovement', 'SpectralMimicryIndex', 'FrequencyProfile', 'EmotionMimicryIndex',
        'TemporalCoherence'
    };
    
    mlMetrics = {
        
    };
    
    anatomicalMetrics = {
        'AnatomicalMovement_tongue', 'AnatomicalMovement_lip', 
        'AnatomicalMovement_pharynx', 'AnatomicalMovement_larynx'
    };
    
    % Create headers
    csvHeaders = {'Participant', 'Condition', 'TrialCount'};
    
    % Add standard metric headers
    for i = 1:length(standardMetrics)
        csvHeaders{end+1} = [standardMetrics{i}, '_Mean'];
        csvHeaders{end+1} = [standardMetrics{i}, '_Std'];
        csvHeaders{end+1} = [standardMetrics{i}, '_Count'];
    end
    
    % Add ML metric headers
    for i = 1:length(mlMetrics)
        csvHeaders{end+1} = [mlMetrics{i}, '_Mean'];
        csvHeaders{end+1} = [mlMetrics{i}, '_Std'];
        csvHeaders{end+1} = [mlMetrics{i}, '_Count'];
    end
    
    % Add anatomical metric headers
    for i = 1:length(anatomicalMetrics)
        csvHeaders{end+1} = [anatomicalMetrics{i}, '_Mean'];
        csvHeaders{end+1} = [anatomicalMetrics{i}, '_Std'];
        csvHeaders{end+1} = [anatomicalMetrics{i}, '_Count'];
    end
    
    % Process each condition
    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        
        if isfield(participantConditionData, condName)
            condData = participantConditionData.(condName);
            
            % Initialize row data
            rowData = {participant, condName};
            
            % Add trial count
            if isfield(condData, 'trials') && iscell(condData.trials)
                rowData{end+1} = length(condData.trials);
            else
                rowData{end+1} = 0;
            end
            
            % Process standard metrics
            for metricIdx = 1:length(standardMetrics)
                metricName = standardMetrics{metricIdx};
                [meanVal, stdVal, countVal] = extractMetricStatistics(condData, metricName);
                rowData{end+1} = meanVal;
                rowData{end+1} = stdVal;
                rowData{end+1} = countVal;
            end
            
            % Process ML metrics
            for metricIdx = 1:length(mlMetrics)
                metricName = mlMetrics{metricIdx};
                [meanVal, stdVal, countVal] = extractMetricStatistics(condData, metricName);
                rowData{end+1} = meanVal;
                rowData{end+1} = stdVal;
                rowData{end+1} = countVal;
            end
            
            % Process anatomical metrics
            for metricIdx = 1:length(anatomicalMetrics)
                metricName = anatomicalMetrics{metricIdx};
                [meanVal, stdVal, countVal] = extractAnatomicalStatistics(condData, metricName);
                rowData{end+1} = meanVal;
                rowData{end+1} = stdVal;
                rowData{end+1} = countVal;
            end
            
            csvData{end+1} = rowData;
        end
    end
    
    disp(['📊 Prepared CSV data for ', num2str(length(csvData)), ' conditions with ', num2str(length(csvHeaders)), ' metrics']);
    
catch ME
    disp(['CSV data preparation error: ', ME.message]);
    csvData = {};
    csvHeaders = {};
end
end
