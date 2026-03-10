

function generateFunctionalInterpretationReport(participantConditionData, participant, conditions, outputDir)
    % Generate a report interpreting vocal tract movements in functional terms
    
    try
        reportFile = fullfile(outputDir, ['FunctionalInterpretation_', participant, '.txt']);
        fid = fopen(reportFile, 'w');
        
        fprintf(fid, 'VOCAL TRACT FUNCTIONAL ANALYSIS REPORT\n');
        fprintf(fid, '=====================================\n');
        fprintf(fid, 'Participant: %s\n', participant);
        fprintf(fid, 'Generated: %s\n\n', datestr(now));
        
        for condIdx = 1:length(conditions)
            condName = conditions{condIdx};
            if isfield(participantConditionData, condName)
                fprintf(fid, 'CONDITION: %s\n', upper(condName));
                fprintf(fid, '-------------------\n');
                
                condData = participantConditionData.(condName);
                
                % Analyze each anatomical region
                if isfield(condData, 'AnatomicalMovement')
                    anatData = condData.AnatomicalMovement;
                    
                    if isfield(anatData, 'vocal_folds') && ~isempty(anatData.vocal_folds)
                        validData = anatData.vocal_folds(isfinite(anatData.vocal_folds) & anatData.vocal_folds > 0);
                        if ~isempty(validData)
                            fprintf(fid, 'Vocal Fold Activity: Mean=%.3f, Max=%.3f (phonation-related movement)\n', mean(validData), max(validData));
                        end
                    end
                    
                    if isfield(anatData, 'larynx') && ~isempty(anatData.larynx)
                        validData = anatData.larynx(isfinite(anatData.larynx) & anatData.larynx > 0);
                        if ~isempty(validData)
                            fprintf(fid, 'Laryngeal Activity: Mean=%.3f, Max=%.3f (overall laryngeal function)\n', mean(validData), max(validData));
                        end
                    end
                    
                    if isfield(anatData, 'pharynx') && ~isempty(anatData.pharynx)
                        validData = anatData.pharynx(isfinite(anatData.pharynx) & anatData.pharynx > 0);
                        if ~isempty(validData)
                            fprintf(fid, 'Pharyngeal Activity: Mean=%.3f, Max=%.3f (articulation and resonance)\n', mean(validData), max(validData));
                        end
                    end
                    
                    if isfield(anatData, 'epiglottis') && ~isempty(anatData.epiglottis)
                        validData = anatData.epiglottis(isfinite(anatData.epiglottis) & anatData.epiglottis > 0);
                        if ~isempty(validData)
                            fprintf(fid, 'Epiglottal Activity: Mean=%.3f, Max=%.3f (airway protection/articulation)\n', mean(validData), max(validData));
                        end
                    end
                end
                
                fprintf(fid, '\n');
            end
        end
        
        fprintf(fid, 'INTERPRETATION NOTES:\n');
        fprintf(fid, '- Higher values indicate more movement/activity in that region\n');
        fprintf(fid, '- Vocal fold activity relates to phonation and voice production\n');
        fprintf(fid, '- Laryngeal activity reflects overall laryngeal function\n');
        fprintf(fid, '- Pharyngeal activity relates to articulation and vocal tract shaping\n');
        fprintf(fid, '- Epiglottal activity may indicate articulatory adjustments\n');
        
        fclose(fid);
        disp(['✓ Functional interpretation report saved: ', reportFile]);
        
    catch ME
        disp(['Functional interpretation report error: ', ME.message]);
        if exist('fid', 'var') && fid > 0
            fclose(fid);
        end
    end
end