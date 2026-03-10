function generateDataInventoryReport(data, participant, outputDir)
% Generate a data inventory report listing all runs, trials, and data availability.
try
    reportFile = fullfile(outputDir, ['DataInventory_', participant, '.txt']);
    fid = fopen(reportFile, 'w');
    if fid == -1, error('Could not create inventory file'); end

    fprintf(fid, '=== DATA STRUCTURE INVENTORY ===\n');
    fprintf(fid, 'Participant: %s\n', participant);
    fprintf(fid, 'Generated: %s\n\n', datestr(now));

    runs = fieldnames(data);
    runs = runs(contains(runs, 'Run'));
    fprintf(fid, 'RUNS FOUND: %d\n', length(runs));

    totalTrials       = 0;
    trialsWithData    = 0;

    for runIdx = 1:length(runs)
        runName    = runs{runIdx};
        conditions = fieldnames(data.(runName));

        fprintf(fid, '\n--- %s ---\n', runName);
        fprintf(fid, 'Trials: %d\n', length(conditions));

        for condIdx = 1:length(conditions)
            ConditionName = conditions{condIdx};
            trialData     = data.(runName).(ConditionName);
            totalTrials   = totalTrials + 1;

            hasData = isfield(trialData, 'StableMeanDisplacement') && ...
                      ~isempty(trialData.StableMeanDisplacement);

            if hasData, trialsWithData = trialsWithData + 1; end

            conditionType = determineConditionType(ConditionName);
            fprintf(fid, '  %s [%s]: displacement_data=%s\n', ...
                ConditionName, conditionType, char(string(hasData)));
        end
    end

    fprintf(fid, '\n=== OVERALL SUMMARY ===\n');
    fprintf(fid, 'Total trials: %d\n', totalTrials);
    fprintf(fid, 'Trials with displacement data: %d (%.1f%%)\n', ...
        trialsWithData, 100 * trialsWithData / max(totalTrials, 1));

    fclose(fid);
    disp(['Data inventory saved: ', reportFile]);

catch ME
    if exist('fid', 'var') && fid ~= -1, fclose(fid); end
    disp(['Error generating data inventory: ', ME.message]);
end
end
