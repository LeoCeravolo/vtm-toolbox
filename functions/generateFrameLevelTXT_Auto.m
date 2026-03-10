
function generateFrameLevelTXT_Auto(data, participant, outputDir)
    % Generate frame-by-frame TXT with automatic demographic extraction
    
    % Automatically extract demographics
    [gender, age] = extractDemographics(participant);
    
    if ~exist(outputDir, 'dir'), mkdir(outputDir); end
    
    % Initialize data collection
    allFrameData = [];
    
    runs = fieldnames(data);
    
    for runIdx = 1:length(runs)
        runName = runs{runIdx};
        
        if ~isstruct(data.(runName))
            continue; % Skip non-struct fields
        end
        
        trials = fieldnames(data.(runName));
        
        for trialIdx = 1:length(trials)
            trialName = trials{trialIdx};
            trialData = data.(runName).(trialName);
            
            % Extract condition from trial name
            condition = extractConditionFromTrialName(trialName);
            
            % Get frame-level data with gender and age
frameData = extractFrameLevelData(trialData, participant, runName, trialName, condition, gender, age, trialIdx);
            
            if ~isempty(frameData)
                allFrameData = [allFrameData; frameData];
                fprintf('✓ Extracted %d frames from %s - %s\n', size(frameData,1), runName, trialName);
            end
        end
    end
    
    if ~isempty(allFrameData)
        % Create output filename
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        filename = fullfile(outputDir, sprintf('%s_FrameLevel_%s.txt', participant, timestamp));
        
        % Write header and data to TXT file
        [headers, stringColumns] = getFrameLevelHeaders();
        
        % Open file for writing
        fid = fopen(filename, 'w');
        
        % Write header line (tab-delimited)
        fprintf(fid, '%s', headers{1});
        for i = 2:length(headers)
            fprintf(fid, '\t%s', headers{i});
        end
        fprintf(fid, '\n');
        
        % Write data (tab-delimited with proper formatting for strings)
        for row = 1:size(allFrameData, 1)
            for col = 1:size(allFrameData, 2)
                if col == 1
                    % First column - no tab prefix
                    if ismember(col, stringColumns)
                        fprintf(fid, '%s', allFrameData{row, col});
                    else
                        fprintf(fid, '%.6f', allFrameData{row, col});
                    end
                else
                    % All other columns - tab prefix
                    if ismember(col, stringColumns)
                        fprintf(fid, '\t%s', allFrameData{row, col});
                    else
                        fprintf(fid, '\t%.6f', allFrameData{row, col});
                    end
                end
            end
            fprintf(fid, '\n');
        end
        
        fclose(fid);
        
        fprintf('✅ Frame-level TXT exported: %s\n', filename);
        fprintf('📊 Total frames exported: %d\n', size(allFrameData, 1));
        fprintf('👤 Demographics: %s, age %.0f\n', gender, age);
    else
        fprintf('⚠️ No frame data found for %s\n', participant);
    end
end