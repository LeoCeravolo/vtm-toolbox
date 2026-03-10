function exportConditionSummaryCSV(participantConditionData, participant, conditions, outputDir)
% Updated CSV export function with new directory structure

try
    % Create CSV files in the data exports directory
    csvFilename = fullfile(outputDir, [participant, '_ConditionSummary.csv']);
    statsFilename = fullfile(outputDir, [participant, '_ConditionStatistics.csv']);
    
    % Prepare and write CSV data (your existing code)
    [csvData, csvHeaders] = prepareConditionCSVData(participantConditionData, participant, conditions);
    
    if ~isempty(csvData)
        writeCombinedCSV(csvFilename, csvHeaders, csvData);
        disp(['✅ Condition summary CSV: ', csvFilename]);
    end
    
    % Generate statistics CSV
    generateConditionStatisticsCSV(participantConditionData, participant, conditions, outputDir);
    
    % Optional: Generate trial-level CSV
    % generateTrialLevelCSV(participantConditionData, participant, conditions, outputDir);
    
catch ME
    disp(['CSV export error: ', ME.message]);
end
end
