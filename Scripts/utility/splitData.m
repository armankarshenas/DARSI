function [trainData, trainLabels, valData, valLabels, testData, testLabels] = splitData(data, labels)
    % splitData Splits the data and labels into training, validation, and test sets.
    %
    %
    % This function takes in a dataset and its corresponding labels, shuffles the data, 
    % and splits it into three subsets: training (70%), validation (15%), and test (15%).
    %
    % Inputs:
    % - data: A 4x160xN array representing the data, where N is the number of samples.
    % - labels: A vector of length N containing the labels for each sample.
    %
    % Outputs:
    % - trainData: The training subset of the data (4x160xN_train).
    % - trainLabels: The training subset of the labels (N_train).
    % - valData: The validation subset of the data (4x160xN_val).
    % - valLabels: The validation subset of the labels (N_val).
    % - testData: The test subset of the data (4x160xN_test).
    % - testLabels: The test subset of the labels (N_test).
    %
    % % Written by A. Karshenas -- Nov, 2024
    %----------------------------------------------------
    % Set the random seed for reproducibility
    rng(1);
    
    % Determine the number of samples
    numSamples = size(data, 3);
    
    % Shuffle indices
    indices = randperm(numSamples);
    
    % Define split sizes
    numTrain = round(0.70 * numSamples);
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
