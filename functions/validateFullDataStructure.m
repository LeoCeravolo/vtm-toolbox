function data = validateFullDataStructure(data, participant)
% Retained for compatibility — no longer called by VTM_main.
% Frame-level data is exported directly after processing without re-validation.
if nargin < 2, participant = 'Unknown'; end
disp(['Data structure ready for: ', participant]);
end
