function generateOutlierSummaryReport(outlierSummary, participant, outputDir)
% Generate detailed outlier removal summary report

try
    reportFile = fullfile(outputDir, [participant, '_OutlierRemovalReport.txt']);
    fid = fopen(reportFile, 'w');
    
    fprintf(fid, '=== OUTLIER REMOVAL SUMMARY REPORT ===\n');
    fprintf(fid, 'Participant: %s\n', participant);
    fprintf(fid, 'Generated: %s\n', datestr(now));
    fprintf(fid, 'Method: 3-sigma rule (global statistics)\n\n');
    
    metricNames = fieldnames(outlierSummary);
    totalOutliersAllMetrics = 0;
    totalDataAllMetrics = 0;
    
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
            
            fprintf(fid, '\nCondition-wise breakdown:\n');
            for condIdx = 1:length(metricInfo.conditionOutliers)
                condInfo = metricInfo.conditionOutliers{condIdx};
                if condInfo.outlierCount > 0
                    fprintf(fid, '  %s: %d/%d outliers (%.1f%%) - ', condInfo.condition, ...
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
                    fprintf(fid, '  %s: No outliers\n', condInfo.condition);
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
    
    fprintf(fid, '=== OUTLIER DETECTION CRITERIA ===\n');
    fprintf(fid, 'Method: 3-sigma rule\n');
    fprintf(fid, 'Threshold: Mean ± 3 × Standard Deviation\n');
    fprintf(fid, 'Scope: Global (across all conditions)\n');
    fprintf(fid, 'Justification: Remove extreme values that may skew condition comparisons\n');
    
    fclose(fid);
    
    disp(['✓ Outlier removal report saved: ', reportFile]);
    
catch ME
    disp(['Outlier summary report error: ', ME.message]);
end
end
