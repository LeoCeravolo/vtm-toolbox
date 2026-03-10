function [gender, age] = extractDemographics_Enhanced(participant)
    % Enhanced demographics extraction with better error handling
    
    % Construct the logfile path
    participantDir = fullfile('E:\Dropbox\LeuchterGrandjean_lc_sg', participant, 'logfiles');
    
    % Look for the Resultfile with pattern matching
    logPattern = fullfile(participantDir, 'Resultfile_VocalCords_Perception*.txt');
    logFiles = dir(logPattern);
    
    if isempty(logFiles)
        fprintf('⚠️ No demographic logfile found for %s, using defaults\n', participant);
        gender = 'Unknown';
        age = NaN;
        return;
    end
    
    % Use the first matching file
    logFilePath = fullfile(participantDir, logFiles(1).name);
    
    try
        % Read the file
        logData = readcell(logFilePath);
        
        % Extract gender from first column (your custom logic)
        if size(logData, 1) >= 2 && size(logData, 2) >= 1
            genderCell = logData{2, 1}; % Skip header row
            if isnumeric(genderCell) && genderCell == 1
                gender = 'female';
            elseif isnumeric(genderCell) && genderCell == 0
                gender = 'male';
            else
                gender = 'Unknown';
            end
        else
            gender = 'Unknown';
        end
        
        % Extract age from second column
        if size(logData, 1) >= 2 && size(logData, 2) >= 2
            age = logData{2, 2}; % Skip header row
            if ~isnumeric(age)
                age = str2double(age);
            end
            if isnan(age)
                age = NaN;
            end
        else
            age = NaN;
        end
        
        fprintf('✓ Demographics extracted for %s: Gender=%s, Age=%.0f\n', participant, gender, age);
        
    catch ME
        fprintf('⚠️ Error reading demographic file for %s: %s\n', participant, ME.message);
        gender = 'Unknown';
        age = NaN;
    end
end
