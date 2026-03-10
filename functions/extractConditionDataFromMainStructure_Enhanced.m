function [conditionDataStructure, conditions] = extractConditionDataFromMainStructure_Enhanced(data, participant)
% ENHANCED VERSION - Extract and organize data by VOICE TYPE + EMOTION condition
% Creates separate conditions for natural vs synthetic voices with emotions

conditionDataStructure = struct();
conditions = {};

try
    % Get all runs
    runs = fieldnames(data);
    runs = runs(contains(runs, 'Run'));

    disp(['🔍 Enhanced extraction: Processing ', num2str(length(runs)), ' runs with voice type differentiation']);

    for runIdx = 1:length(runs)
        runName = runs{runIdx};
        
        % Extract run number for voice type determination
        runNumber = str2double(regexp(runName, '\d+', 'match', 'once'));
        if isempty(runNumber), runNumber = 1; end

        % Get all trials in this run
        trials = fieldnames(data.(runName));

        for trialIdx = 1:length(trials)
            ConditionName = trials{trialIdx};
            trialData = data.(runName).(ConditionName);

            % Determine emotion condition (your existing logic)
            emotionCondition = determineConditionType(ConditionName);
            
            % Determine voice type (using your existing function)
            if isfield(trialData, 'VoiceType') && ~isempty(trialData.VoiceType)
                voiceType = trialData.VoiceType;
            else
                voiceType = determineVoiceType(runNumber, ConditionName);
            end

            % Create COMBINED condition: voiceType_emotion
            if ~isempty(emotionCondition) && ~isempty(voiceType)
                combinedCondition = [voiceType, '_', emotionCondition];
                
                % Initialize condition if it doesn't exist
                if ~isfield(conditionDataStructure, combinedCondition)
                    conditionDataStructure.(combinedCondition) = initializeConditionDataStructure();
                    conditions{end+1} = combinedCondition;
                end

                % Add trial data to condition
                conditionDataStructure.(combinedCondition) = addTrialToCondition(conditionDataStructure.(combinedCondition), trialData, ConditionName);
                
                % Debug output
                if mod(trialIdx, 10) == 1  % Every 10th trial
                    disp(['  -> ', ConditionName, ' -> ', combinedCondition]);
                end
            else
                disp(['⚠ Skipping trial with incomplete condition info: ', ConditionName, ' (emotion:', emotionCondition, ', voice:', voiceType, ')']);
            end
        end
    end

    % Sort conditions for logical grouping: voice type first, then emotion
    conditions = unique(conditions);
    conditions = sortConditionsLogically(conditions);

    % Display enhanced summary
    disp(['📊 Enhanced data extraction summary:']);
    
    % Group by voice type for summary
    voiceTypes = {};
    for i = 1:length(conditions)
        parts = split(conditions{i}, '_');
        if length(parts) >= 2
            voiceType = parts{1};
            if ~ismember(voiceType, voiceTypes)
                voiceTypes{end+1} = voiceType;
            end
        end
    end
    
    for vIdx = 1:length(voiceTypes)
        voiceType = voiceTypes{vIdx};
        disp(['🎙️ ', upper(voiceType), ' VOICES:']);
        
        for i = 1:length(conditions)
            if startsWith(conditions{i}, voiceType)
                condName = conditions{i};
                if isfield(conditionDataStructure, condName)
                    numTrials = length(conditionDataStructure.(condName).trials);
                    emotion = strrep(condName, [voiceType, '_'], '');
                    disp(['     ', emotion, ': ', num2str(numTrials), ' trials']);
                end
            end
        end
        disp(' ');
    end

catch ME
    disp(['❌ Error in enhanced condition data extraction: ', ME.message]);
    conditionDataStructure = struct();
    conditions = {};
end
end
