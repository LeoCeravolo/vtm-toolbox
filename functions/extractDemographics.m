function [gender, age] = extractDemographics(participant)
    % Automatically extract gender and age from participant logfile
    
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
        
        % Extract gender from first column (assuming it's consistent)
            genderCell = logData{2, 1}; % Skip header row
            if genderCell==1
                gender = 'female';
            else
                gender = 'male';
            end
            age = logData{2, 2}; % Skip header row

        
        fprintf('✓ Demographics extracted for %s: Gender=%s, Age=%.0f\n', participant, gender, age);
        
    catch ME
        fprintf('⚠️ Error reading demographic file for %s: %s\n', participant, ME.message);
        gender = 'Unknown';
        age = NaN;
    end
end
