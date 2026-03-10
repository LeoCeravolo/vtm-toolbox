function predictions = classifyMimicry(mlModel, testData)
% Classify test data using trained model

try
    predictions = predict(mlModel, testData);
catch ME
    % Return default predictions if classification fails
    predictions = repmat({'unknown'}, size(testData, 1), 1);
end

end
