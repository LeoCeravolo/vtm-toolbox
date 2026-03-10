%% 9. EMOTION-SPECIFIC MIMICRY METRICS
function participantData = calculateEmotionSpecificMimicry(participantData, conditions, config)
    % Calculate emotion-specific mimicry indices
    
    % Reference condition (neutral)
    neutralCondition = 'neutral';
    
    if ~isfield(participantData, neutralCondition) || isempty(participantData.(neutralCondition).StableMeanDisplacement)
        disp('Warning: No neutral condition data for emotion-specific mimicry calculation');
        % Use first available condition as reference
        availableConditions = fieldnames(participantData);
        if ~isempty(availableConditions)
            neutralCondition = availableConditions{1};
        else
            return;
        end
    end
    
    % Get neutral baseline metrics
    neutralMovement = mean(participantData.(neutralCondition).StableMeanDisplacement);
    if isfield(participantData.(neutralCondition), 'MimicryResponse')
        neutralMimicryResponse = mean(participantData.(neutralCondition).MimicryResponse);
    else
        neutralMimicryResponse = 0;
    end
    
    for i = 1:length(conditions)
        condName = conditions{i};
        
        if ~strcmp(condName, neutralCondition) && isfield(participantData, condName)
            % Calculate emotion-specific mimicry indices
            
            % 1. Relative Movement Index = (Emotion - Neutral) / Neutral
            if ~isempty(participantData.(condName).StableMeanDisplacement) && neutralMovement > 0
                emotionMovement = mean(participantData.(condName).StableMeanDisplacement);
                participantData.(condName).RelativeMovementIndex = ...
                    (emotionMovement - neutralMovement) / neutralMovement;
            else
                participantData.(condName).RelativeMovementIndex = 0;
            end
            
            % 2. Mimicry Enhancement Index (for conditions expected to show mimicry)
            if isfield(participantData.(condName), 'MimicryResponse') && ~isempty(participantData.(condName).MimicryResponse)
                emotionMimicryResponse = mean(participantData.(condName).MimicryResponse);
                if abs(neutralMimicryResponse) > 1e-6 % Avoid division by near-zero
                    participantData.(condName).MimicryEnhancementIndex = ...
                        (emotionMimicryResponse - neutralMimicryResponse) / abs(neutralMimicryResponse);
                else
                    participantData.(condName).MimicryEnhancementIndex = emotionMimicryResponse;
                end
            else
                participantData.(condName).MimicryEnhancementIndex = 0;
            end
            
            % 3. Condition-specific metrics for anger and pleasure
            if contains(lower(condName), 'anger')
                % Anger: expect increased movement intensity and faster responses
                if isfield(participantData.(condName), 'MimicryLatency') && ~isempty(participantData.(condName).MimicryLatency)
                    avgLatency = mean(participantData.(condName).MimicryLatency(~isnan(participantData.(condName).MimicryLatency)));
                    participantData.(condName).AngerMimicryScore = calculateAngerMimicryScore(participantData.(condName), avgLatency);
                else
                    participantData.(condName).AngerMimicryScore = 0;
                end
                
            elseif contains(lower(condName), 'pleasure')
                % Pleasure: expect sustained, rhythmic movements
                if isfield(participantData.(condName), 'TemporalCoherence') && ~isempty(participantData.(condName).TemporalCoherence)
                    avgCoherence = mean(participantData.(condName).TemporalCoherence);
                    participantData.(condName).PleasureMimicryScore = calculatePleasureMimicryScore(participantData.(condName), avgCoherence);
                else
                    participantData.(condName).PleasureMimicryScore = 0;
                end
            end
            
            % 4. Spectral Emotion Index (based on frequency characteristics)
            if isfield(participantData.(condName), 'SpectralMimicryIndex') && ~isempty(participantData.(condName).SpectralMimicryIndex)
                spectralIdx = mean(participantData.(condName).SpectralMimicryIndex);
                participantData.(condName).SpectralEmotionIndex = spectralIdx;
            else
                participantData.(condName).SpectralEmotionIndex = 0;
            end
            
            disp(['Calculated emotion-specific metrics for ', condName, ...
                  ': RelMovIdx=', num2str(participantData.(condName).RelativeMovementIndex, '%.3f'), ...
                  ', MimEnhIdx=', num2str(participantData.(condName).MimicryEnhancementIndex, '%.3f')]);
        end
    end
end
