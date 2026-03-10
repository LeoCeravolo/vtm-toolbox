function generateCSVSummary(groupSummary, conditions, participants, outputDir)
    % Generate CSV files for statistical analysis in other software
    
    % Create summary statistics CSV
    summaryFile = fullfile(outputDir, 'Group_Summary_Statistics.csv');
    fid = fopen(summaryFile, 'w');
    fprintf(fid, 'Condition,Measure,Mean,Std,SE,N,Min,Max\n');
    
    measures = {'StableMeanDisplacement', 'StableMaxDisplacement', 'StablePointCount', 'ROIFlowMagnitude', 'Entropy'};
    measureNames = {'Mean_Displacement', 'Max_Displacement', 'Stable_Point_Count', 'Flow_Magnitude', 'Entropy'};
    
    for c = 1:length(conditions)
        condName = conditions{c};
        for m = 1:length(measures)
            measureName = measures{m};
            measureLabel = measureNames{m};
            
            if isfield(groupSummary.(condName), measureName) && ~isempty(groupSummary.(condName).(measureName))
                data = groupSummary.(condName).(measureName);
                meanVal = mean(data);
                stdVal = std(data);
                seVal = stdVal / sqrt(length(data));
                nVal = length(data);
                minVal = min(data);
                maxVal = max(data);
                
                fprintf(fid, '%s,%s,%.6f,%.6f,%.6f,%d,%.6f,%.6f\n', ...
                    condName, measureLabel, meanVal, stdVal, seVal, nVal, minVal, maxVal);
            end
        end
    end
    fclose(fid);
    
    % Create individual participant data CSV
    participantFile = fullfile(outputDir, 'Individual_Participant_Data.csv');
    fid = fopen(participantFile, 'w');
    fprintf(fid, 'Participant,Condition,Mean_Displacement,Max_Displacement,Stable_Point_Count,Flow_Magnitude,Entropy\n');
    
    for p = 1:length(participants)
        participant = participants{p};
        for c = 1:length(conditions)
            condName = conditions{c};
            
            % Initialize values
            meanDisp = NaN; maxDisp = NaN; pointCount = NaN; flowMag = NaN; entropy = NaN;
            
            % Extract values if they exist
            if isfield(groupSummary.(condName).participantMeans, 'StableMeanDisplacement') && ...
               isfield(groupSummary.(condName).participantMeans.StableMeanDisplacement, participant)
                meanDisp = groupSummary.(condName).participantMeans.StableMeanDisplacement.(participant);
            end
            
            if isfield(groupSummary.(condName).participantMeans, 'StableMaxDisplacement') && ...
               isfield(groupSummary.(condName).participantMeans.StableMaxDisplacement, participant)
                maxDisp = groupSummary.(condName).participantMeans.StableMaxDisplacement.(participant);
            end
            
            if isfield(groupSummary.(condName).participantMeans, 'StablePointCount') && ...
               isfield(groupSummary.(condName).participantMeans.StablePointCount, participant)
                pointCount = groupSummary.(condName).participantMeans.StablePointCount.(participant);
            end
            
            if isfield(groupSummary.(condName).participantMeans, 'ROIFlowMagnitude') && ...
               isfield(groupSummary.(condName).participantMeans.ROIFlowMagnitude, participant)
                flowMag = groupSummary.(condName).participantMeans.ROIFlowMagnitude.(participant);
            end
            
            if isfield(groupSummary.(condName).participantMeans, 'Entropy') && ...
               isfield(groupSummary.(condName).participantMeans.Entropy, participant)
                entropy = groupSummary.(condName).participantMeans.Entropy.(participant);
            end
            
            fprintf(fid, '%s,%s,%.6f,%.6f,%.6f,%.6f,%.6f\n', ...
                participant, condName, meanDisp, maxDisp, pointCount, flowMag, entropy);
        end
    end
    fclose(fid);
    
    disp(['CSV files saved: ', summaryFile, ' and ', participantFile]);
end