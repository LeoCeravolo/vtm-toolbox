function generateEnhancedGroupLevelAnalysis(groupData, mimicryConfig)
    % Generate comprehensive group-level analysis
    
    try
        outputDir = 'GroupLevelAnalysis';
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        
        % Extract group-level data
        participants = groupData.participants;
        conditions = groupData.conditions;
        
        if length(participants) < 2
            disp('Insufficient participants for group analysis');
            return;
        end
        
        % Initialize group summary data
        groupSummary = struct();
        for condIdx = 1:length(conditions)
            condName = conditions{condIdx};
            groupSummary.(condName) = struct();
            groupSummary.(condName).PeakVelocities = [];
            groupSummary.(condName).MeanVelocities = [];
            groupSummary.(condName).StableMeanDisplacement = [];
            groupSummary.(condName).MimicryResponse = [];
            groupSummary.(condName).ParticipantIDs = {};
        end
        
        % Collect data across participants
        for pIdx = 1:length(participants)
            participant = participants{pIdx};
            if isfield(groupData.participantData, participant)
                pData = groupData.participantData.(participant);
                
                for condIdx = 1:length(conditions)
                    condName = conditions{condIdx};
                    if isfield(pData, condName)
                        condData = pData.(condName);
                        
                        % Aggregate peak velocities
                        if isfield(condData, 'PeakVelocities') && ~isempty(condData.PeakVelocities)
                            validPeakVel = condData.PeakVelocities(isfinite(condData.PeakVelocities));
                            if ~isempty(validPeakVel)
                                groupSummary.(condName).PeakVelocities = [groupSummary.(condName).PeakVelocities; validPeakVel(:)];
                                groupSummary.(condName).ParticipantIDs = [groupSummary.(condName).ParticipantIDs; repmat({participant}, length(validPeakVel), 1)];
                            end
                        end
                        
                        % Aggregate other metrics similarly...
                        if isfield(condData, 'StableMeanDisplacement') && ~isempty(condData.StableMeanDisplacement)
                            validDisp = condData.StableMeanDisplacement(isfinite(condData.StableMeanDisplacement));
                            if ~isempty(validDisp)
                                groupSummary.(condName).StableMeanDisplacement = [groupSummary.(condName).StableMeanDisplacement; validDisp(:)];
                            end
                        end
                        
                        if isfield(condData, 'MimicryResponse') && ~isempty(condData.MimicryResponse)
                            validMimicry = condData.MimicryResponse(isfinite(condData.MimicryResponse));
                            if ~isempty(validMimicry)
                                groupSummary.(condName).MimicryResponse = [groupSummary.(condName).MimicryResponse; validMimicry(:)];
                            end
                        end
                    end
                end
            end
        end
        
        % Generate group-level plots
        generateGroupComparisonPlots(groupSummary, conditions, outputDir);
        
        % Save group summary data
        groupSummaryFile = fullfile(outputDir, 'GroupSummaryData.mat');
        save(groupSummaryFile, 'groupSummary', 'participants', 'conditions', 'mimicryConfig');
        
        disp(['✓ Enhanced group-level analysis completed in: ', outputDir]);
        
    catch ME
        disp(['Enhanced group-level analysis error: ', ME.message]);
    end
end
