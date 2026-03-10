function [alignmentMetrics] = calculateStimulusResponseAlignment(mlClassification, stimulusOnset, frameRate)
% Calculate how well classifications align with expected stimulus-response pattern

alignmentMetrics = struct();

% Define temporal windows
preStimWindow = max(1, stimulusOnset - round(0.2 * frameRate)) : stimulusOnset-1;
stimWindow = stimulusOnset : min(length(mlClassification), stimulusOnset + round(0.5 * frameRate));
postStimWindow = min(length(mlClassification), stimulusOnset + round(0.5 * frameRate) + 1) : ...
                 min(length(mlClassification), stimulusOnset + round(2.0 * frameRate));

% Calculate mimicry rates in each window
if ~isempty(preStimWindow)
    alignmentMetrics.preStimMimicryRate = sum(mlClassification(preStimWindow)) / length(preStimWindow) * 100;
else
    alignmentMetrics.preStimMimicryRate = 0;
end

if ~isempty(stimWindow)
    alignmentMetrics.stimMimicryRate = sum(mlClassification(stimWindow)) / length(stimWindow) * 100;
else
    alignmentMetrics.stimMimicryRate = 0;
end

if ~isempty(postStimWindow)
    alignmentMetrics.postStimMimicryRate = sum(mlClassification(postStimWindow)) / length(postStimWindow) * 100;
else
    alignmentMetrics.postStimMimicryRate = 0;
end

% Expected pattern: low pre-stim, high stim, medium post-stim
expectedPattern = [5, 25, 10]; % Expected percentages
actualPattern = [alignmentMetrics.preStimMimicryRate, alignmentMetrics.stimMimicryRate, alignmentMetrics.postStimMimicryRate];

% Calculate alignment score based on pattern matching
patternDifference = abs(actualPattern - expectedPattern);
alignmentScore = max(0, 100 - mean(patternDifference) * 2);
alignmentMetrics.alignmentScore = alignmentScore;
end
