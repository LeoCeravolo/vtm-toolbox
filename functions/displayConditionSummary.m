function displayConditionSummary(conditionDataStructure, conditions)
% Display detailed summary of extracted conditions

try
    disp(['📊 ENHANCED CONDITION SUMMARY:']);
    disp(['   Total combined conditions found: ', num2str(length(conditions))]);
    disp(' ');
    
    % Group by voice type for organized display
    voiceTypes = {'natural', 'synthetic_noise', 'synthetic_spectrum', 'synthetic_unknown'};
    emotions = {'anger', 'happiness', 'neutral', 'pleasure'};
    
    for vIdx = 1:length(voiceTypes)
        voiceType = voiceTypes{vIdx};
        voiceTypeFound = false;
        
        for eIdx = 1:length(emotions)
            emotion = emotions{eIdx};
            condName = [voiceType, '_', emotion];
            
            if ismember(condName, conditions) && isfield(conditionDataStructure, condName)
                if ~voiceTypeFound
                    disp(['🎙️ ', upper(strrep(voiceType, '_', ' ')), ':']);
                    voiceTypeFound = true;
                end
                
                numTrials = length(conditionDataStructure.(condName).trials);
                
                % Check data quality
                hasValidData = false;
                dataQuality = '';
                
                if isfield(conditionDataStructure.(condName), 'StableMeanDisplacement')
                    validDisp = conditionDataStructure.(condName).StableMeanDisplacement;
                    validDisp = validDisp(isfinite(validDisp) & validDisp > 0);
                    if ~isempty(validDisp)
                        hasValidData = true;
                        dataQuality = sprintf(' (Mean disp: %.2f±%.2f)', mean(validDisp), std(validDisp));
                    end
                end
                
                % FIXED: Use proper MATLAB conditional syntax
                if hasValidData
                    statusIcon = '✓';
                else
                    statusIcon = '⚠';
                end
                
                disp(['     ', statusIcon, ' ', emotion, ': ', num2str(numTrials), ' trials', dataQuality]);
            end
        end
        
        if voiceTypeFound
            disp(' ');
        end
    end
    
    % Check for any unmatched conditions
    unmatchedCount = 0;
    for i = 1:length(conditions)
        matched = false;
        for vIdx = 1:length(voiceTypes)
            for eIdx = 1:length(emotions)
                if strcmp(conditions{i}, [voiceTypes{vIdx}, '_', emotions{eIdx}])
                    matched = true;
                    break;
                end
            end
            if matched, break; end
        end
        if ~matched
            if unmatchedCount == 0
                disp(['🔍 UNMATCHED CONDITIONS:']);
            end
            unmatchedCount = unmatchedCount + 1;
            numTrials = length(conditionDataStructure.(conditions{i}).trials);
            disp(['     ', conditions{i}, ': ', num2str(numTrials), ' trials']);
        end
    end
    
    if unmatchedCount > 0
        disp(' ');
    end
    
catch ME
    disp(['Error displaying condition summary: ', ME.message]);
end
end