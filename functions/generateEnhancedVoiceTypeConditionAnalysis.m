function generateEnhancedVoiceTypeConditionAnalysis(data, participant, outputDir)
% ENHANCED VOICE TYPE CONDITION ANALYSIS - Main function
% Creates condition analysis plots with natural vs synthetic voice differentiation
%
% This provides separate analysis for:
% - Natural voices (Run 1-2): natural_anger, natural_neutral, etc.
% - Synthetic voices (Run 3): synthetic_noise_anger, synthetic_spectrum_anger, etc.

try
    disp(['🎙️ Generating enhanced voice type + condition analysis for: ', participant]);
    disp(['   This will show separate boxes for natural vs synthetic voices']);

    % === STEP 1: EXTRACT DATA WITH VOICE TYPE DIFFERENTIATION ===
    [conditionDataStructure, conditions] = extractConditionDataFromMainStructure_Enhanced(data, participant);

    if isempty(fieldnames(conditionDataStructure))
        disp(['❌ No condition data found for enhanced analysis']);
        return;
    end

    % === STEP 2: DISPLAY CONDITION SUMMARY ===
    displayConditionSummary(conditionDataStructure, conditions);

    % === STEP 3: GENERATE ENHANCED PLOTS ===
    generateOutlierRobustConditionPlots_Enhanced(conditionDataStructure, conditions, participant, outputDir);

    % === STEP 4: GENERATE SUMMARY STATISTICS ===
    generateVoiceTypeComparisonReport(conditionDataStructure, conditions, participant, outputDir);

    disp(['✅ Enhanced voice type condition analysis completed']);
    disp(['📁 Results saved in: ', fullfile(outputDir, 'ConditionAnalysis')]);

catch ME
    disp(['❌ Error in enhanced voice type condition analysis: ', ME.message]);
    disp(['Stack trace: ', ME.stack(1).name, ' at line ', num2str(ME.stack(1).line)]);
end
end
