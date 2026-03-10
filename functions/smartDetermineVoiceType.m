function voiceType = smartDetermineVoiceType(runNumber, trialName, trialData)
% SMART VOICE TYPE DETERMINATION for your specific trial naming patterns
% Handles: pleasure_pinknoized__42, natural voices, etc.

voiceType = '';

try
    % Convert to lowercase for consistent matching
    trialName = lower(trialName);
    
    % === METHOD 1: Check if VoiceType field exists in trial data ===
    if nargin >= 3 && isstruct(trialData) && isfield(trialData, 'VoiceType') && ~isempty(trialData.VoiceType)
        voiceType = trialData.VoiceType;
        return;
    end
    
    % === METHOD 2: Pattern matching from trial names ===
    % Based on your example: "pleasure_pinknoized__42"
    
    if contains(trialName, 'pinknoized') || contains(trialName, 'pink_noise') || contains(trialName, 'pinknoise')
        voiceType = 'synthetic_noise';
        disp(['🎙️ Detected pink noise synthetic: ', trialName]);
    elseif contains(trialName, 'shuffled') || contains(trialName, 'shuffle')
        voiceType = 'synthetic_spectrum';
        disp(['🎙️ Detected spectrum shuffled synthetic: ', trialName]);
    elseif contains(trialName, 'spectrum') || contains(trialName, 'spectral') || contains(trialName, 'spec_')
        voiceType = 'synthetic_spectrum';
        disp(['🎙️ Detected spectrum synthetic: ', trialName]);
    elseif contains(trialName, 'vocoded') || contains(trialName, 'vocode')
        voiceType = 'synthetic_vocoded';
        disp(['🎙️ Detected vocoded synthetic: ', trialName]);
    elseif contains(trialName, 'robotic') || contains(trialName, 'robot')
        voiceType = 'synthetic_robotic';
        disp(['🎙️ Detected robotic synthetic: ', trialName]);
    elseif contains(trialName, 'synthetic') || contains(trialName, 'synth')
        voiceType = 'synthetic_unknown';
        disp(['🎙️ Detected generic synthetic: ', trialName]);
    elseif contains(trialName, 'natural') || contains(trialName, 'human')
        voiceType = 'natural';
        disp(['🎙️ Detected natural voice: ', trialName]);
    else
        % === METHOD 3: Run-based determination ===
        if runNumber <= 2
            voiceType = 'natural';
            % Only log if this is the first few trials to avoid spam
            if mod(str2double(regexp(trialName, '\d+', 'match', 'once')), 10) == 1
                disp(['🎙️ Run-based natural voice: ', trialName, ' (Run ', num2str(runNumber), ')']);
            end
        elseif runNumber == 3
            % Run 3 contains synthetic voices, but we couldn't determine the type
            voiceType = 'synthetic_unknown';
            disp(['🎙️ Run 3 synthetic (unknown type): ', trialName]);
        else
            voiceType = 'unknown';
            disp(['⚠ Unknown voice type: ', trialName, ' (Run ', num2str(runNumber), ')']);
        end
    end
    
    % === METHOD 4: Additional pattern checks for edge cases ===
    if isempty(voiceType) || strcmp(voiceType, 'unknown')
        % Check for other synthetic voice indicators
        syntheticKeywords = {'artificial', 'generated', 'modified', 'processed', 'filtered'};
        for i = 1:length(syntheticKeywords)
            if contains(trialName, syntheticKeywords{i})
                voiceType = 'synthetic_unknown';
                disp(['🎙️ Keyword-based synthetic: ', trialName]);
                break;
            end
        end
        
        % Final fallback: use run number
        if isempty(voiceType) || strcmp(voiceType, 'unknown')
            if runNumber <= 2
                voiceType = 'natural';
            else
                voiceType = 'synthetic_unknown';
            end
        end
    end
    
catch ME
    % Emergency fallback: use run number
    if runNumber <= 2
        voiceType = 'natural';
    else
        voiceType = 'synthetic_unknown';
    end
    disp(['⚠ Voice type detection error for ', trialName, ': ', ME.message]);
end

% Ensure we always return a valid voice type
if isempty(voiceType)
    voiceType = 'unknown';
end
end