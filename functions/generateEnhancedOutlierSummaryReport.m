function generateEnhancedOutlierSummaryReport(outlierSummary, participant, outputDir, conditions)
% Generate enhanced outlier removal summary report with voice type analysis

try
    reportFile = fullfile(outputDir, [participant, '_EnhancedOutlierRemovalReport.txt']);
    fid = fopen(reportFile, 'w');
    
    fprintf(fid, '=== ENHANCED OUTLIER REMOVAL SUMMARY REPORT ===\n');
    fprintf(fid, 'Participant: %s\n', participant);
    fprintf(fid, 'Generated: %s\n', datestr(now));
    fprintf(fid, 'Method: 3-sigma rule (global statistics)\n');
    fprintf(fid, 'Analysis: Natural vs Synthetic Voice Types\n\n');
    
    metricNames = fieldnames(outlierSummary);
    totalOutliersAllMetrics = 0;
    totalDataAllMetrics = 0;
    
    % Voice type categories for analysis
    voiceTypeCategories = struct();
    voiceTypeCategories.natural = [];
    voiceTypeCategories.synthetic_noise = [];
    voiceTypeCategories.synthetic_spectrum = [];
    voiceTypeCategories.synthetic_other = [];
    
    for metricIdx = 1:length(metricNames)
        metricName = metricNames{metricIdx};
        metricInfo = outlierSummary.(metricName);
        
        fprintf(fid, '=== %s ===\n', metricName);
        
        if isfield(metricInfo, 'globalMean')
            fprintf(fid, 'Global Mean: %.3f\n', metricInfo.globalMean);
            fprintf(fid, 'Global Std: %.3f\n', metricInfo.globalStd);
            fprintf(fid, 'Outlier Bounds: [%.3f, %.3f]\n', metricInfo.bounds(1), metricInfo.bounds(2));
            fprintf(fid, 'Total Original Data: %d\n', metricInfo.totalOriginal);
            fprintf(fid, 'Total Outliers Removed: %d (%.1f%%)\n', metricInfo.totalOutliers, metricInfo.totalOutliers/metricInfo.totalOriginal*100);
            fprintf(fid, 'Total Clean Data: %d\n', metricInfo.totalClean);
            
            totalOutliersAllMetrics = totalOutliersAllMetrics + metricInfo.totalOutliers;
            totalDataAllMetrics = totalDataAllMetrics + metricInfo.totalOriginal;
            
            % Organize by voice type
            fprintf(fid, '\n=== VOICE TYPE BREAKDOWN ===\n');
            
            % Initialize voice type counters
            voiceTypeStats = struct();
            voiceTypeStats.natural = struct('total', 0, 'outliers', 0, 'conditions', {{}});
            voiceTypeStats.synthetic_noise = struct('total', 0, 'outliers', 0, 'conditions', {{}});
            voiceTypeStats.synthetic_spectrum = struct('total', 0, 'outliers', 0, 'conditions', {{}});
            voiceTypeStats.synthetic_other = struct('total', 0, 'outliers', 0, 'conditions', {{}});
            
            % Categorize outlier information by voice type
            for condIdx = 1:length(metricInfo.conditionOutliers)
                condInfo = metricInfo.conditionOutliers{condIdx};
                condition = condInfo.condition;
                
                % Determine voice type
                if startsWith(condition, 'natural_')
                    voiceTypeStats.natural.total = voiceTypeStats.natural.total + condInfo.originalCount;
                    voiceTypeStats.natural.outliers = voiceTypeStats.natural.outliers + condInfo.outlierCount;
                    voiceTypeStats.natural.conditions{end+1} = condition;
                elseif startsWith(condition, 'synthetic_noise_')
                    voiceTypeStats.synthetic_noise.total = voiceTypeStats.synthetic_noise.total + condInfo.originalCount;
                    voiceTypeStats.synthetic_noise.outliers = voiceTypeStats.synthetic_noise.outliers + condInfo.outlierCount;
                    voiceTypeStats.synthetic_noise.conditions{end+1} = condition;
                elseif startsWith(condition, 'synthetic_spectrum_')
                    voiceTypeStats.synthetic_spectrum.total = voiceTypeStats.synthetic_spectrum.total + condInfo.originalCount;
                    voiceTypeStats.synthetic_spectrum.outliers = voiceTypeStats.synthetic_spectrum.outliers + condInfo.outlierCount;
                    voiceTypeStats.synthetic_spectrum.conditions{end+1} = condition;
                else
                    voiceTypeStats.synthetic_other.total = voiceTypeStats.synthetic_other.total + condInfo.originalCount;
                    voiceTypeStats.synthetic_other.outliers = voiceTypeStats.synthetic_other.outliers + condInfo.outlierCount;
                    voiceTypeStats.synthetic_other.conditions{end+1} = condition;
                end
            end
            
            % Report voice type statistics
            voiceTypeNames = {'natural', 'synthetic_noise', 'synthetic_spectrum', 'synthetic_other'};
            voiceTypeDisplayNames = {'Natural Voices', 'Synthetic Noise', 'Synthetic Spectrum', 'Other Synthetic'};
            
            for vtIdx = 1:length(voiceTypeNames)
                vtName = voiceTypeNames{vtIdx};
                vtStats = voiceTypeStats.(vtName);
                
                if vtStats.total > 0
                    outlierRate = vtStats.outliers / vtStats.total * 100;
                    fprintf(fid, '%s:\n', voiceTypeDisplayNames{vtIdx});
                    fprintf(fid, '  Total data points: %d\n', vtStats.total);
                    fprintf(fid, '  Outliers removed: %d (%.1f%%)\n', vtStats.outliers, outlierRate);
                    fprintf(fid, '  Conditions: %s\n', strjoin(vtStats.conditions, ', '));
                    fprintf(fid, '\n');
                end
            end
            
            fprintf(fid, '=== DETAILED CONDITION BREAKDOWN ===\n');
            for condIdx = 1:length(metricInfo.conditionOutliers)
                condInfo = metricInfo.conditionOutliers{condIdx};
                
                % Parse condition name for better display
                condParts = split(condInfo.condition, '_');
                if length(condParts) >= 2
                    voiceType = condParts{1};
                    if length(condParts) >= 3
                        voiceType = [condParts{1}, '_', condParts{2}];
                        emotion = condParts{3};
                    else
                        emotion = condParts{2};
                    end
                    displayName = [strrep(voiceType, '_', ' '), ' - ', emotion];
                else
                    displayName = condInfo.condition;
                end
                
                if condInfo.outlierCount > 0
                    fprintf(fid, '  %s: %d/%d outliers (%.1f%%) - ', displayName, ...
                           condInfo.outlierCount, condInfo.originalCount, ...
                           condInfo.outlierCount/condInfo.originalCount*100);
                    
                    if length(condInfo.outlierValues) <= 5
                        fprintf(fid, 'Values: ');
                        for i = 1:length(condInfo.outlierValues)
                            fprintf(fid, '%.3f ', condInfo.outlierValues(i));
                        end
                        fprintf(fid, '\n');
                    else
                        fprintf(fid, '[%d values]\n', length(condInfo.outlierValues));
                    end
                else
                    fprintf(fid, '  %s: No outliers\n', displayName);
                end
            end
        else
            fprintf(fid, 'No outlier data available\n');
        end
        
        fprintf(fid, '\n');
    end
    
    % Overall summary
    fprintf(fid, '=== OVERALL SUMMARY ===\n');
    fprintf(fid, 'Total Data Points (All Metrics): %d\n', totalDataAllMetrics);
    fprintf(fid, 'Total Outliers Removed: %d\n', totalOutliersAllMetrics);
    if totalDataAllMetrics > 0
        fprintf(fid, 'Overall Outlier Rate: %.2f%%\n', totalOutliersAllMetrics/totalDataAllMetrics*100);
    end
    fprintf(fid, '\n');
    
    % Voice type comparison summary
    fprintf(fid, '=== VOICE TYPE COMPARISON INSIGHTS ===\n');
    fprintf(fid, 'This analysis allows comparison of outlier patterns between:\n');
    fprintf(fid, '- Natural voices: Human speakers with natural emotional prosody\n');
    fprintf(fid, '- Synthetic noise: Emotional envelopes filled with pink noise\n');
    fprintf(fid, '- Synthetic spectrum: Spectral manipulations of emotional speech\n\n');
    
    fprintf(fid, 'Research Questions:\n');
    fprintf(fid, '1. Do synthetic voices produce more outliers (tracking difficulties)?\n');
    fprintf(fid, '2. Which voice type produces most consistent mimicry responses?\n');
    fprintf(fid, '3. Are outlier patterns emotion-specific within voice types?\n\n');
    
    fprintf(fid, '=== OUTLIER DETECTION CRITERIA ===\n');
    fprintf(fid, 'Method: 3-sigma rule\n');
    fprintf(fid, 'Threshold: Mean ± 3 × Standard Deviation\n');
    fprintf(fid, 'Scope: Global (across all voice types and conditions)\n');
    fprintf(fid, 'Justification: Remove extreme values while preserving voice type differences\n');
    
    fclose(fid);
    
    disp(['✓ Enhanced outlier removal report saved: ', reportFile]);
    
catch ME
    disp(['Enhanced outlier summary report error: ', ME.message]);
end
end