function trialData = validateAndFixTrialDataStructure(trialData, trialName)
% Lightweight validation — fills missing scalar metadata only.
% Does NOT overwrite array fields (displacement, velocity, etc.) so real
% per-frame data is preserved exactly as stored during processing.
if nargin < 2, trialName = 'Unknown'; end

if ~isfield(trialData,'VoiceType')  || isempty(trialData.VoiceType),  trialData.VoiceType  = 'unknown'; end
if ~isfield(trialData,'Condition')  || isempty(trialData.Condition),  trialData.Condition  = 'unknown'; end
if ~isfield(trialData,'RunNumber')  || isempty(trialData.RunNumber),  trialData.RunNumber  = NaN;       end
if ~isfield(trialData,'TrialNumber')|| isempty(trialData.TrialNumber),trialData.TrialNumber= NaN;       end
if ~isfield(trialData,'AnatomicalMovement'), trialData.AnatomicalMovement = struct(); end
end
