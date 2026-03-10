function [conditionTrials, allTrialData] = extractTrialsFromData(data)
% EXTRACTTRIALSFROMDATA - Extract and organize trials by condition from main data
conditionTrials = struct();
allTrialData = struct();

try
    % Get all runs
    runs = fieldnames(data);
    runs = runs(contains(runs, 'Run'));

    disp(['🔍 Found ', num2str(length(runs)), ' runs in data structure']);

    for runIdx = 1:length(runs)
        runName = runs{runIdx};

        % Get all conditions in this run
        conditions = fieldnames(data.(runName));

        disp(['  📂 Run ', runName, ': ', num2str(length(conditions)), ' conditions']);

        for condIdx = 1:length(conditions)
            ConditionName = conditions{condIdx};
            conditionData = data.(runName).(ConditionName);

            % Determine condition type (emotion)
            conditionType = determineConditionType(ConditionName);

            if ~isempty(conditionType)
                % Initialize condition arrays if needed
                if ~isfield(conditionTrials, conditionType)
                    conditionTrials.(conditionType) = {};
                    allTrialData.(conditionType) = struct();
                    allTrialData.(conditionType).trials = {};
                    allTrialData.(conditionType).runNames = {};
                    allTrialData.(conditionType).conditionNames = {};
                    allTrialData.(conditionType).data = {};
                end

                % Add trial to condition
                conditionTrials.(conditionType){end+1} = ConditionName;
                allTrialData.(conditionType).trials{end+1} = ConditionName;
                allTrialData.(conditionType).runNames{end+1} = runName;
                allTrialData.(conditionType).conditionNames{end+1} = ConditionName;
                allTrialData.(conditionType).data{end+1} = conditionData;

                disp(['    ✅ Added: ', ConditionName, ' → ', conditionType]);
            else
                disp(['    ⚠ Could not determine condition type for: ', ConditionName]);
            end
        end
    end

    % Summary
    conditionTypes = fieldnames(conditionTrials);
    disp(['📊 Data extraction summary:']);
    for i = 1:length(conditionTypes)
        condType = conditionTypes{i};
        numTrials = length(conditionTrials.(condType));
        disp(['   ', condType, ': ', num2str(numTrials), ' trials']);
    end

catch ME
    disp(['❌ Error extracting trials from data: ', ME.message]);
    conditionTrials = struct();
    allTrialData = struct();
end
end
