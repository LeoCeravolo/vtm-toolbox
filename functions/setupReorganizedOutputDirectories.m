function outputPaths = setupReorganizedOutputDirectories(participant)
% Setup reorganized output directories directly under participant folder

try
    % Main participant directory (one level up from before)
    participantDir = fullfile(pwd, participant);
    if ~exist(participantDir, 'dir')
        mkdir(participantDir);
    end
    
    % Create organized subdirectories directly under participant
    outputPaths = struct();
    
    % Condition Analysis (renamed and moved up)
    outputPaths.conditionAnalysis = fullfile(participantDir, 'ConditionAnalysis');
    if ~exist(outputPaths.conditionAnalysis, 'dir')
        mkdir(outputPaths.conditionAnalysis);
    end
    
    % Trial Analysis (renamed and moved up)
    outputPaths.trialAnalysis = fullfile(participantDir, 'TrialAnalysis');
    if ~exist(outputPaths.trialAnalysis, 'dir')
        mkdir(outputPaths.trialAnalysis);
    end
    
    % Summary Reports (new)
    outputPaths.summaryReports = fullfile(participantDir, 'SummaryReports');
    if ~exist(outputPaths.summaryReports, 'dir')
        mkdir(outputPaths.summaryReports);
    end
    
    % Data Exports (new)
    outputPaths.dataExports = fullfile(participantDir, 'DataExports');
    if ~exist(outputPaths.dataExports, 'dir')
        mkdir(outputPaths.dataExports);
    end
    
    % Quality Control (new)
%     outputPaths.qualityControl = fullfile(participantDir, 'QualityControl');
%     if ~exist(outputPaths.qualityControl, 'dir')
%         mkdir(outputPaths.qualityControl);
%     end
    
    disp(['✓ Reorganized output directories created for: ', participant]);
    
catch ME
    disp(['Output directory setup error: ', ME.message]);
    % Fallback to simple structure
    outputPaths = struct();
    outputPaths.conditionAnalysis = fullfile(pwd, participant);
    outputPaths.trialAnalysis = fullfile(pwd, participant);
    outputPaths.summaryReports = fullfile(pwd, participant);
    outputPaths.dataExports = fullfile(pwd, participant);
%     outputPaths.qualityControl = fullfile(pwd, participant);
end
end
