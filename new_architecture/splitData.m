function [trainData, trainLabels, valData, valLabels, testData, testLabels] = splitData(data, labels)
    % Set the random seed for reproducibility
    rng(1);
    
    % Determine the number of samples
    numSamples = size(data, 3);
    
    % Shuffle indices
    indices = randperm(numSamples);
    
    % Define split sizes
    numTrain = round(0.75 * numSamples);
    numVal = round(0.15 * numSamples);
    
    % Select indices for each subset
    trainIdx = indices(1:numTrain);
    valIdx = indices(numTrain+1:numTrain+numVal);
    testIdx = indices(numTrain+numVal+1:end);
    
    % Split the data and labels
    trainData = data(:, :, trainIdx);
    trainLabels = labels(trainIdx);
    
    valData = data(:, :, valIdx);
    valLabels = labels(valIdx);
    
    testData = data(:, :, testIdx);
    testLabels = labels(testIdx);
end
