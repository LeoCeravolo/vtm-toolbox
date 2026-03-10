function [conditionDataStructure, conditions] = extractConditionDataFromMainStructure(data, participant)
% EXTRACTCONDITIONDATAFROMMAINSTRUCTURE - Extract and organize data by condition
% This recreates the participantConditionData structure but from main data

conditionDataStructure = struct();
conditions = {};

try
    % Get all runs
    runs = fieldnames(data);
    runs = runs(contains(runs, 'Run'));

    disp(['🔍 Extracting condition data from ', num2str(length(runs)), ' runs']);

    for runIdx = 1:length(runs)
        runName = runs{runIdx};

        % Get all trials in this run
        trials = fieldnames(data.(runName));

        for trialIdx = 1:length(trials)
            ConditionName = trials{trialIdx};
            trialData = data.(runName).(ConditionName);

            % Determine condition type
            conditionType = determineConditionType(ConditionName);

            if ~isempty(conditionType)
                % Initialize condition if it doesn't exist
                if ~isfield(conditionDataStructure, conditionType)
                    conditionDataStructure.(conditionType) = initializeConditionDataStructure();
                    conditions{end+1} = conditionType;
                end

                % Add trial data to condition
                conditionDataStructure.(conditionType) = addTrialToCondition(conditionDataStructure.(conditionType), trialData, ConditionName);
            end
        end
    end

    % Remove duplicates from conditions
    conditions = unique(conditions);

    % Display summary
    disp(['📊 Data extraction summary:']);
    for i = 1:length(conditions)
        condName = conditions{i};
        if isfield(conditionDataStructure, condName)
            numTrials = length(conditionDataStructure.(condName).trials);
            disp(['   ', condName, ': ', num2str(numTrials), ' trials']);
        end
    end

catch ME
    disp(['❌ Error extracting condition data: ', ME.message]);
    conditionDataStructure = struct();
    conditions = {};
end
end
