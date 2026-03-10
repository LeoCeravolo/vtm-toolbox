
function generateVoiceTypeComparisonReport(conditionDataStructure, conditions, participant, outputDir)
% Generate quantitative comparison report between voice types

try
    reportFile = fullfile(outputDir, [participant, '_VoiceTypeComparisonReport.txt']);
    fid = fopen(reportFile, 'w');
    
    fprintf(fid, '=== VOICE TYPE + EMOTION COMPARISON REPORT ===\n');
    fprintf(fid, 'Participant: %s\n', participant);
    fprintf(fid, 'Generated: %s\n', datestr(now));
    fprintf(fid, 'Analysis: Natural vs Synthetic Voice Emotional Mimicry\n\n');
    
    % Define metrics to analyze
    metrics = {'StableMeanDisplacement', 'StableMaxDisplacement', 'ROIFlowMagnitude', ...
               'PeakVelocities', 'MeanVelocities'};
    
    metricNames = {'Mean Displacement', 'Max Displacement', 'Flow Magnitude', ...
                   'Peak Velocities', 'Mean Velocities'};
    
    emotions = {'anger', 'happiness', 'neutral', 'pleasure'};
    voiceTypes = {'natural', 'synthetic_noise', 'synthetic_spectrum'};
    
    % Analyze each metric
    for metricIdx = 1:length(metrics)
        metricField = metrics{metricIdx};
        metricName = metricNames{metricIdx};
        
        fprintf(fid, '=== %s ===\n', metricName);
        
        for emotionIdx = 1:length(emotions)
            emotion = emotions{emotionIdx};
            fprintf(fid, '\n%s Emotion:\n', upper(emotion));
            
            % Compare across voice types for this emotion
            for voiceIdx = 1:length(voiceTypes)
                voiceType = voiceTypes{voiceIdx};
                condName = [voiceType, '_', emotion];
                
                if ismember(condName, conditions) && isfield(conditionDataStructure, condName)
                    condData = conditionDataStructure.(condName);
                    
                    if isfield(condData, metricField) && ~isempty(condData.(metricField))
                        values = condData.(metricField);
                        validValues = values(isfinite(values) & values > 0);
                        
                        if ~isempty(validValues)
                            meanVal = mean(validValues);
                            stdVal = std(validValues);
                            medianVal = median(validValues);
                            
                            fprintf(fid, '  %s: Mean=%.3f±%.3f, Median=%.3f, N=%d\n', ...
                                   strrep(voiceType, '_', ' '), meanVal, stdVal, medianVal, length(validValues));
                        else
                            fprintf(fid, '  %s: No valid data\n', strrep(voiceType, '_', ' '));
                        end
                    else
                        fprintf(fid, '  %s: Field not found\n', strrep(voiceType, '_', ' '));
                    end
                else
                    fprintf(fid, '  %s: Condition not found\n', strrep(voiceType, '_', ' '));
                end
            end
        end
        
        fprintf(fid, '\n');
    end
    
    % Overall summary
    fprintf(fid, '=== OVERALL SUMMARY ===\n');
    fprintf(fid, 'This report allows comparison of mimicry responses between:\n');
    fprintf(fid, '- Natural voices (human speakers)\n');
    fprintf(fid, '- Synthetic noise voices (emotional envelope + pink noise)\n');
    fprintf(fid, '- Synthetic spectrum voices (spectral manipulations)\n\n');
    fprintf(fid, 'Key questions for analysis:\n');
    fprintf(fid, '1. Do synthetic voices elicit weaker mimicry than natural voices?\n');
    fprintf(fid, '2. Which synthetic voice type (noise vs spectrum) is more effective?\n');
    fprintf(fid, '3. Are emotional differences preserved across voice types?\n');
    fprintf(fid, '4. Which metrics best discriminate between conditions?\n\n');
    
    fclose(fid);
    
    disp(['✓ Voice type comparison report saved: ', reportFile]);
    
catch ME
    disp(['Error generating voice type comparison report: ', ME.message]);
end
end