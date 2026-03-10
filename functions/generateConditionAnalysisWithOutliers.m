function generateConditionAnalysisWithOutliers(data, participant, outputDir)
% GENERATECONDITIONANALYSISWITHOUTLIERS - Adapted from your original function
% Now works directly with data structure and includes outlier removal
%
% This function provides the same functionality as your original
% generateCorrectedParticipantConditionAnalysis but accesses data directly

try
    disp(['🔬 Generating condition analysis with outlier removal for: ', participant]);

    % === STEP 1: EXTRACT DATA DIRECTLY FROM MAIN STRUCTURE ===
    [conditionDataStructure, conditions] = extractConditionDataFromMainStructure(data, participant);

    if isempty(fieldnames(conditionDataStructure))
        disp(['❌ No condition data found for analysis']);
        return;
    end

    % === STEP 2: GENERATE PLOTS WITH OUTLIER REMOVAL ===
    generateOutlierRobustConditionPlots(conditionDataStructure, conditions, participant, outputDir);

    disp(['✅ Condition analysis with outlier removal completed']);

catch ME
    disp(['❌ Error in condition analysis with outliers: ', ME.message]);
end
end
