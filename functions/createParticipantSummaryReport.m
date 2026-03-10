function createParticipantSummaryReport(participant, outputPaths)
% Create a brief summary report of outputs produced for this participant.

try
    summaryFile = fullfile(outputPaths.summaryReports, [participant, '_AnalysisSummary.txt']);
    fid = fopen(summaryFile, 'w');

    fprintf(fid, '=== VOCAL TRACT MIMICRY ANALYSIS SUMMARY ===\n');
    fprintf(fid, 'Participant: %s\n', participant);
    fprintf(fid, 'Analysis Date: %s\n\n', datestr(now));

    fprintf(fid, '=== OUTPUT FOLDERS ===\n');
    fprintf(fid, 'DataExports/       - Frame-level TXT file for R analysis\n');
    fprintf(fid, 'TrialAnalysis/     - Per-trial moving-average plots\n');
    fprintf(fid, 'ConditionAnalysis/ - Data inventory report\n');
    fprintf(fid, 'SummaryReports/    - This summary file\n\n');

    fprintf(fid, '=== KEY OUTPUT FILE ===\n');
    fprintf(fid, 'DataExports/%s_FrameLevel_Enhanced_<timestamp>.txt\n', participant);
    fprintf(fid, '  Tab-delimited, one row per frame per trial.\n');
    fprintf(fid, '  Columns: Participant, Gender, Age, Run, Trial, VoiceType,\n');
    fprintf(fid, '           Condition, Emotion, Frame, Time_Seconds,\n');
    fprintf(fid, '           Displacement, MaxDisplacement, PointCount,\n');
    fprintf(fid, '           MeanVelocity, MaxVelocity, FlowMagnitude,\n');
    fprintf(fid, '           FlowVx, FlowVy, Entropy, TotalPoints,\n');
    fprintf(fid, '           TrackingQuality, PointLossRate,\n');
    fprintf(fid, '           Epiglottis_Movement, Vocal_folds_Movement,\n');
    fprintf(fid, '           Pharynx_Movement, Larynx_Movement,\n');
    fprintf(fid, '           MaxAcceleration, FramesFromStimulus, SecondsFromStimulus,\n');
    fprintf(fid, '           LossTriggeredRefreshes, TotalRefreshes\n\n');

    fprintf(fid, '=== FILE COUNTS ===\n');
    txtFiles  = dir(fullfile(outputPaths.dataExports, '*_FrameLevel_Enhanced_*.txt'));
    trialFiles = dir(fullfile(outputPaths.trialAnalysis, '*.png'));
    fprintf(fid, 'Frame-level TXT files: %d\n', length(txtFiles));
    fprintf(fid, 'Trial plot files:      %d\n', length(trialFiles));

    fclose(fid);
    disp(['Participant summary report created: ', summaryFile]);

catch ME
    if exist('fid','var') && fid ~= -1, fclose(fid); end
    disp(['Summary report error: ', ME.message]);
end
end
