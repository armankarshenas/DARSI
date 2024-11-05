function [balancedData, balancedLabels] = balanceData(data, labels)
    % Implementation of resampling logic here (e.g., oversample minority classes)
    % Output: balancedData and balancedLabels
    uniqueLabels = unique(labels);
    labelCounts = arrayfun(@(x) sum(labels == x), uniqueLabels);
    
    % Determine the maximum count (majority class)
    maxCount = max(labelCounts);
    
    % Initialize lists to store balanced data and labels
    balancedData = [];
    balancedLabels = [];
    
    % Iterate over each class
    for i = 1:length(uniqueLabels)
        label = uniqueLabels(i);
        
        % Extract all samples for the current class
        classData = data(:,:,labels == label);
        classLabels = labels(labels == label);
        
        % Calculate how many times to duplicate the current class samples
        numDuplicates = ceil(maxCount / size(classData, 3));
        
        % Duplicate and randomly select samples to match the max count
        oversampledData = repmat(classData, [1, 1, numDuplicates]);
        oversampledLabels = repmat(classLabels, numDuplicates, 1);
        
        % Trim the oversampled data to have exactly maxCount samples
        oversampledData = oversampledData(:,:,1:maxCount);
        oversampledLabels = oversampledLabels(1:maxCount);
        
        % Append to the balanced dataset
        balancedData = cat(3, balancedData, oversampledData);
        balancedLabels = [balancedLabels; oversampledLabels];
    end
end
