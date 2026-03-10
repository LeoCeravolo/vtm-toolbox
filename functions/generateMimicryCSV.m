%% 16. GENERATE MIMICRY CSV OUTPUT
function generateMimicryCSV(groupData, outputDir)
    % Generate CSV files with mimicry metrics for statistical analysis
    
    conditions = groupData.conditions;
    participants = groupData.participants;
    
    % Create comprehensive mimicry data CSV
    csvFile = fullfile(outputDir, 'Comprehensive_Mimicry_Data.csv');
    fid = fopen(csvFile, 'w');
    
    % Write header
    fprintf(fid, 'Participant,Condition,MimicryResponse,MimicryLatency,SpectralMimicryIndex,');
    fprintf(fid, 'TemporalCoherence,RelativeMovementIndex,MimicryEnhancementIndex,');
    fprintf(fid, 'AngerMimicryScore,PleasureMimicryScore,TraditionalDisplacement\n');
    
    % Write data
    for p = 1:length(participants)
        participant = participants{p};
        participantData = groupData.participantData.(participant);
        
        for c = 1:length(conditions)
            condName = conditions{c};
            
            if isfield(participantData, condName)
                data = participantData.(condName);
                
                % Extract metrics with safe defaults
                mimicryResponse = getFieldValue(data, 'MimicryResponse', NaN);
                mimicryLatency = getFieldValue(data, 'MimicryLatency', NaN);
                spectralMimicryIndex = getFieldValue(data, 'SpectralMimicryIndex', NaN);
                temporalCoherence = getFieldValue(data, 'TemporalCoherence', NaN);
                relativeMovementIndex = getFieldValue(data, 'RelativeMovementIndex', NaN);
                mimicryEnhancementIndex = getFieldValue(data, 'MimicryEnhancementIndex', NaN);
                angerMimicryScore = getFieldValue(data, 'AngerMimicryScore', NaN);
                pleasureMimicryScore = getFieldValue(data, 'PleasureMimicryScore', NaN);
                traditionalDisplacement = getFieldValue(data, 'StableMeanDisplacement', NaN);
                
                if ~isempty(traditionalDisplacement) && ~isnan(traditionalDisplacement(1))
                    traditionalDisplacement = mean(traditionalDisplacement);
                else
                    traditionalDisplacement = NaN;
                end
                
                % Write row
                fprintf(fid, '%s,%s,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n', ...
                    participant, condName, mimicryResponse, mimicryLatency, spectralMimicryIndex, ...
                    temporalCoherence, relativeMovementIndex, mimicryEnhancementIndex, ...
                    angerMimicryScore, pleasureMimicryScore, traditionalDisplacement);
            end
        end
    end
    
    fclose(fid);
    disp(['✓ Comprehensive mimicry CSV saved: ', csvFile]);
end
