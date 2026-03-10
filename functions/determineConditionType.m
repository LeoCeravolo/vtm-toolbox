%% COMPLETE HELPER FUNCTIONS FOR VOCAL TRACT ANALYSIS
%% 2. DETERMINE CONDITION TYPE FUNCTION
function conditionType = determineConditionType(conditionName)
% Extract condition type from condition name
% Returns: 'neutral', 'pleasure', 'happiness', 'anger', or ''

conditionName = lower(conditionName);

if contains(conditionName, 'neutral')
    conditionType = 'neutral';
elseif contains(conditionName, 'pleasure')
    conditionType = 'pleasure';
elseif contains(conditionName, 'happiness') || contains(conditionName, 'happy')
    conditionType = 'happiness';
elseif contains(conditionName, 'anger') || contains(conditionName, 'angry')
    conditionType = 'anger';
else
%     % Try to extract from filename patterns
%     if contains(conditionName, '1_') || contains(conditionName, '_1')
%         conditionType = 'neutral';
%     elseif contains(conditionName, '2_') || contains(conditionName, '_2')
%         conditionType = 'pleasure';
%     elseif contains(conditionName, '3_') || contains(conditionName, '_3')
%         conditionType = 'happiness';
%     elseif contains(conditionName, '4_') || contains(conditionName, '_4')
%         conditionType = 'anger';
%     else
%         conditionType = '';
%         disp(['Warning: Could not determine condition type for: ', conditionName]);
%     end
end
end
