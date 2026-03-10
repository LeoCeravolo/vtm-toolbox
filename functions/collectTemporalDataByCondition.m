function conditionData = collectTemporalDataByCondition(data)
    % Collect and organize temporal data by condition
    
    conditionData = struct();
    conditions = {'neutral', 'pleasure', 'happiness', 'anger'};
    
    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        conditionData.(condName) = struct();
        conditionData.(condName).timeSeriesData = {};
        conditionData.(condName).durationMetrics = struct([]); % FIXED: Initialize as empty struct array
        conditionData.(condName).patterns = {};
        conditionData.(condName).trialNames = {};
    end
    
    % Extract data from all runs and trials
    runs = fieldnames(data);
    
    for runIdx = 1:length(runs)
        runName = runs{runIdx};
        if ~isstruct(data.(runName)), continue; end
        
        trials = fieldnames(data.(runName));
        
        for trialIdx = 1:length(trials)
            trialName = trials{trialIdx};
            trialData = data.(runName).(trialName);
            
            if ~isstruct(trialData), continue; end
            
            % Determine condition
            condType = determineConditionFromTrial(trialName);
            if isempty(condType) || ~isfield(conditionData, condType), continue; end
            
            % Collect time series data
            if isfield(trialData, 'AllDisplacements') && ~isempty(trialData.AllDisplacements)
                timeSeriesData = extractTimeSeriesFromTrial(trialData);
                if ~isempty(timeSeriesData)
                    conditionData.(condType).timeSeriesData{end+1} = timeSeriesData;
                    conditionData.(condType).trialNames{end+1} = trialName;
                end
            end
            
            % Collect duration metrics
            if isfield(trialData, 'ComprehensiveTemporalAmplitudeIndex')
                metrics = struct();
                metrics.CTAI = getFieldOrNaN(trialData, 'ComprehensiveTemporalAmplitudeIndex');
                metrics.MPI = getFieldOrNaN(trialData, 'MovementPersistenceIndex');
                metrics.TDI = getFieldOrNaN(trialData, 'TemporalDensityIndex');
                metrics.OSI = getFieldOrNaN(trialData, 'OscillationSustainIndex');
                
                % FIXED: Safe assignment to struct array
                if isempty(conditionData.(condType).durationMetrics)
                    conditionData.(condType).durationMetrics = metrics;
                else
                    conditionData.(condType).durationMetrics(end+1) = metrics;
                end
            end
            
            % Collect pattern information
            if isfield(trialData, 'MovementPattern')
                conditionData.(condType).patterns{end+1} = trialData.MovementPattern;
            end
        end
    end
end
