function [f1Scores, avgF1Score] = computeF1Score(actualLabels, predictedLabels)
    % computeF1Score Computes the F1 scores for each class and the average F1 score.
    %
    % 
    %
    % Inputs:
    % - actualLabels: A vector containing the true class labels
    % - predictedLabels: A vector containing the predicted class labels
    %
    % Outputs:
    % - f1Scores: A vector containing the F1 scores for each class
    % - avgF1Score: The average F1 score across all classes
    %
    %
    %Written by A. Karshenas -- Nov, 2024
    %----------------------------------------------------
    % Get unique classes
    classes = unique(actualLabels);
    numClasses = numel(classes);
    
    % Initialize arrays to store precision, recall, and F1 scores
    precision = zeros(numClasses, 1);
    recall = zeros(numClasses, 1);
    f1Scores = zeros(numClasses, 1);
    
    % Loop over each class to compute F1 score
    for i = 1:numClasses
        class = classes(i);
        
        % True positives, false positives, and false negatives for this class
        tp = sum((predictedLabels == class) & (actualLabels == class));
        fp = sum((predictedLabels == class) & (actualLabels ~= class));
        fn = sum((predictedLabels ~= class) & (actualLabels == class));
        
        % Compute precision and recall
        if tp + fp > 0
            precision(i) = tp / (tp + fp);
        else
            precision(i) = 0;
        end
        
        if tp + fn > 0
            recall(i) = tp / (tp + fn);
        else
            recall(i) = 0;
        end
        
        % Compute F1 score for this class
        if precision(i) + recall(i) > 0
            f1Scores(i) = 2 * (precision(i) * recall(i)) / (precision(i) + recall(i));
        else
            f1Scores(i) = 0;
        end
    end
    
    % Compute the average F1 score across all classes
    avgF1Score = mean(f1Scores);
end
