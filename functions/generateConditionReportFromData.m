function generateConditionReportFromData(conditionTrials, allTrialData, participant, outputDir)
% GENERATECONDITIONREPORTFROMDATA - Generate text report using direct data access
try
    reportFile = fullfile(outputDir, ['DirectConditionReport_', participant, '.txt']);
    fid = fopen(reportFile, 'w');

    if fid == -1
        error('Could not create report file');
    end

    fprintf(fid, '=== CONDITION ANALYSIS (DIRECT DATA ACCESS) ===\n');
    fprintf(fid, 'Participant: %s\n', participant);
    fprintf(fid, 'Generated: %s\n\n', datestr(now));

    conditions = fieldnames(allTrialData);

    for condIdx = 1:length(conditions)
        conditionType = conditions{condIdx};
        conditionInfo = allTrialData.(conditionType);

        fprintf(fid, '--- CONDITION: %s ---\n', upper(conditionType));
        fprintf(fid, 'Number of trials: %d\n', length(conditionInfo.trials));

        % Analyze key metrics
        metrics = {'StableMeanDisplacement', 'ROIFlowMagnitude', 'MeanVelocity'};
        metricNames = {'Traditional Displacement', 'ML Displacement', 'ML Confidence'};

        for metricIdx = 1:length(metrics)
            metricName = metrics{metricIdx};
            metricTitle = metricNames{metricIdx};

            % Extract values from all trials
            values = [];
            for trialIdx = 1:length(conditionInfo.data)
                trialData = conditionInfo.data{trialIdx};
                value = extractMetricFromTrial(trialData, metricName);
                if isfinite(value)
                    values(end+1) = value;
                end
            end

            if ~isempty(values)
                fprintf(fid, '%s: %.3f ± %.3f (n=%d)\n', metricTitle, mean(values), std(values), length(values));
            else
                fprintf(fid, '%s: No valid data\n', metricTitle);
            end
        end

        fprintf(fid, '\n');
    end

    fclose(fid);
    disp(['✅ Condition report saved: ', reportFile]);

catch ME
    if exist('fid', 'var') && fid ~= -1
        fclose(fid);
    end
    disp(['❌ Error generating condition report: ', ME.message]);
end
end
