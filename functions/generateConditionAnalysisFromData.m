function generateConditionAnalysisFromData(data, participant, outputDir)
% GENERATECONDITIONANALYSISFROMDATA - Access data directly from main structure
try
    disp(['🔬 Generating condition analysis from main data structure for: ', participant]);

    % === STEP 1: EXTRACT ALL TRIALS DIRECTLY FROM DATA ===
    [conditionTrials, allTrialData] = extractTrialsFromData(data);

    if isempty(fieldnames(conditionTrials))
        disp(['❌ No trials found in data structure']);
        return;
    end

    % === STEP 2: GENERATE CONDITION PLOTS ===
    generateConditionPlotsFromData(conditionTrials, allTrialData, participant, outputDir);

    % === STEP 3: GENERATE CONDITION REPORT ===
    generateConditionReportFromData(conditionTrials, allTrialData, participant, outputDir);

    disp(['✅ Condition analysis completed using direct data access']);

catch ME
    disp(['❌ Error in direct data access analysis: ', ME.message]);
end
end
