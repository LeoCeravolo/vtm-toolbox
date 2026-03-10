function conditionData = addFunctionalInterpretation(conditionData, regionName, movement, frameCount)
    % Add functional interpretation for different vocal tract regions
    
    % Initialize functional metrics if they don't exist
    if ~isfield(conditionData, 'FunctionalMetrics')
        conditionData.FunctionalMetrics = struct();
    end
    
    switch regionName
        case 'vocal_folds'
            % Vocal fold movement - related to phonation
            if ~isfield(conditionData.FunctionalMetrics, 'phonationActivity')
                conditionData.FunctionalMetrics.phonationActivity = [];
            end
            conditionData.FunctionalMetrics.phonationActivity(frameCount) = movement;
            
        case 'larynx'
            % Laryngeal movement - overall laryngeal function
            if ~isfield(conditionData.FunctionalMetrics, 'laryngealActivity')
                conditionData.FunctionalMetrics.laryngealActivity = [];
            end
            conditionData.FunctionalMetrics.laryngealActivity(frameCount) = movement;
            
        case 'pharynx'
            % Pharyngeal movement - articulation and resonance
            if ~isfield(conditionData.FunctionalMetrics, 'pharyngealActivity')
                conditionData.FunctionalMetrics.pharyngealActivity = [];
            end
            conditionData.FunctionalMetrics.pharyngealActivity(frameCount) = movement;
            
        case 'epiglottis'
            % Epiglottal movement - airway protection and articulation
            if ~isfield(conditionData.FunctionalMetrics, 'epiglottalActivity')
                conditionData.FunctionalMetrics.epiglottalActivity = [];
            end
            conditionData.FunctionalMetrics.epiglottalActivity(frameCount) = movement;
    end
end
