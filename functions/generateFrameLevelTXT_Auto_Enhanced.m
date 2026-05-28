function generateFrameLevelTXT_Auto_Enhanced(data, participant, outputDir, gender, age)
    % Enhanced frame-level TXT export with voice type and demographics
    % Demographics are passed directly from VTM_main (extracted from logfile)
    %
    % INPUTS:
    %   data      - data struct from VTM_main
    %   participant - participant folder name string
    %   outputDir   - output directory path
    %   gender      - 'female' or 'male' (optional, default 'Unknown')
    %   age         - numeric age (optional, default NaN)

    % Silent fallback if demographics not provided
    if nargin < 4, gender = 'Unknown'; end
    if nargin < 5, age = NaN; end

    if ~exist(outputDir, 'dir'), mkdir(outputDir); end

    % Initialize data collection
    allFrameData = [];
    runs = fieldnames(data);

    for runIdx = 1:length(runs)
        runName = runs{runIdx};
        if ~isstruct(data.(runName))
            continue;
        end

        % Extract run number for voice type determination
        runNumber = str2double(regexp(runName, '\d+', 'match', 'once'));
        if isempty(runNumber), runNumber = 1; end

        trials = fieldnames(data.(runName));

        for trialIdx = 1:length(trials)
            trialName = trials{trialIdx};
            trialData = data.(runName).(trialName);

            % Get voice type and condition
            if isfield(trialData, 'VoiceType')
                voiceType = trialData.VoiceType;
            else
                voiceType = determineVoiceType(runNumber, trialName);
            end

            if isfield(trialData, 'Condition')
                condition = trialData.Condition;
            else
                condition = extractConditionFromTrialName_Enhanced(trialName, runNumber);
            end

            % Get frame-level data
            frameData = extractFrameLevelData_Enhanced(trialData, participant, runName, trialName, ...
                condition, gender, age, voiceType, runNumber);

            if ~isempty(frameData)
                allFrameData = [allFrameData; frameData];
                fprintf('✓ Extracted %d frames from %s - %s (%s)\n', ...
                    size(frameData,1), runName, trialName, voiceType);
            end
        end
    end

    if ~isempty(allFrameData)
        % Create output filename with timestamp
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        filename  = fullfile(outputDir, sprintf('%s_FrameLevel_Enhanced_%s.txt', participant, timestamp));

        % Write header and data
        [headers, stringColumns] = getFrameLevelHeaders_Enhanced();

        fid = fopen(filename, 'w');

        % Write header line (tab-delimited)
        fprintf(fid, '%s', headers{1});
        for i = 2:length(headers)
            fprintf(fid, '\t%s', headers{i});
        end
        fprintf(fid, '\n');

        % Write data rows (tab-delimited)
        for row = 1:size(allFrameData, 1)
            for col = 1:size(allFrameData, 2)
                if col == 1
                    if ismember(col, stringColumns)
                        fprintf(fid, '%s', allFrameData{row, col});
                    else
                        fprintf(fid, '%.6f', allFrameData{row, col});
                    end
                else
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
        fprintf('📊 Total frames: %d\n', size(allFrameData, 1));
        fprintf('👤 Demographics: %s, age %.0f\n', gender, age);
        fprintf('🎙️ Voice types: Natural (Run 1-2), Synthetic (Run 3)\n');
    else
        fprintf('⚠️ No frame data found for %s\n', participant);
    end
end