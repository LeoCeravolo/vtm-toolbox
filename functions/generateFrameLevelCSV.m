function generateFrameLevelCSV(data, participant, outputDir)
    % Generate frame-by-frame CSV for detailed R analysis
    
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
            
            % Get frame-level data
            frameData = extractFrameLevelData(trialData, participant, runName, trialName, condition);
            
            if ~isempty(frameData)
                allFrameData = [allFrameData; frameData];
                fprintf('✓ Extracted %d frames from %s - %s\n', size(frameData,1), runName, trialName);
            end
        end
    end
    
    if ~isempty(allFrameData)
        % Create output filename
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        filename = fullfile(outputDir, sprintf('%s_FrameLevel_%s.csv', participant, timestamp));
        
        % Write to CSV
        writematrix(allFrameData, filename);
        
        % Create header file
        headerFilename = fullfile(outputDir, sprintf('%s_FrameLevel_Headers_%s.txt', participant, timestamp));
        headers = getFrameLevelHeaders();
        writecell(headers', headerFilename);
        
        fprintf('✅ Frame-level CSV exported: %s\n', filename);
        fprintf('📋 Headers saved: %s\n', headerFilename);
        fprintf('📊 Total frames exported: %d\n', size(allFrameData, 1));
    else
        fprintf('⚠️ No frame data found for %s\n', participant);
    end
end
