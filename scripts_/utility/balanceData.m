function [balancedData, balancedLabels] = balanceData(data, labels)
    % balanceData Resamples data to balance the class distribution by oversampling the minority classes.
    %
    % Inputs:
    % - data: Input data, typically with dimensions [features x length x num_samples]
    % - labels: A vector of class labels corresponding to each sample
    %
    % Outputs:
    % - balancedData: Data after resampling to balance the class distribution
    % - balancedLabels: Corresponding labels after resampling
    %
    %
    % Written by A. Karshenas -- Nov, 2024
    %----------------------------------------------------
    % Find the unique class labels
    uniqueLabels = unique(labels);
    
    % Count the number of samples for each class
    labelCounts = arrayfun(@(x) sum(labels == x), uniqueLabels);
    
    % Find the maximum count across all classes (majority class size)
    maxCount = max(labelCounts);
    
    % Initialize empty arrays for the balanced data and labels
    balancedData = [];
    balancedLabels = [];

    % Loop through each class label to balance its data
    for i = 1:length(uniqueLabels)
        label = uniqueLabels(i);
        
        % Extract data and labels corresponding to the current class
        classData = data(:,:,labels == label);
        classLabels = labels(labels == label);
        
        % Calculate how many times to duplicate the current class data
        numDuplicates = ceil(maxCount / size(classData, 3));
        
        % Oversample the class data by repeating and then trimming
        oversampledData = repmat(classData, [1, 1, numDuplicates]);
        oversampledLabels = repmat(classLabels, numDuplicates, 1);
        
        % Trim the oversampled data to exactly match the maximum count
        oversampledData = oversampledData(:,:,1:maxCount);
        oversampledLabels = oversampledLabels(1:maxCount);
        
        % Append the current class's balanced data and labels to the final dataset
        balancedData = cat(3, balancedData, oversampledData);
        balancedLabels = [balancedLabels; oversampledLabels];
    end
end
