function trainGeneSpecificCNN(Path_to_data, Path_to_save)
% trainGeneSpecificCNN Processes data for multiple genes, trains a CNN for
% expression prediction, and saves results for each gene.
%
% Inputs:
% - Path_to_data: String, path to the directory containing data files
% - Path_to_save: String, path to the directory where results will be saved
%
%
% Written by A. Karshenas -- Nov, 2024
%--------------------------------------------------------------------------

    % Add all scripts from the current repository (including subdirectories)
    currentScriptDir = fileparts(mfilename('fullpath'));
    addpath(genpath(currentScriptDir));

    % Load training, testing, and validation datasets
    cd(Path_to_data)
    tb_train = readtable('Train_activity.txt');
    tb_test = readtable('Test_activity.txt');
    tb_valid = readtable('Valid_activity.txt');

    % Combine datasets into a single table
    TB = vertcat(tb_train, tb_test, tb_valid);

    % Get unique gene names in the dataset
    Genes = unique(TB.gene);

    % Initialize arrays for storing metrics
    acc = zeros(1, length(Genes));
    original_num_data = zeros(1, length(Genes));
    f_1 = zeros(1, length(Genes));
    f_2 = zeros(1, length(Genes));
    f_3 = zeros(1, length(Genes));

    % Loop through each gene to process data and train models
    for i = 1:length(Genes)
        waitbar(i / length(Genes), [], sprintf('Processing Gene %d of %d', i, length(Genes)));

        % Filter data for the current gene
        TB_gene = TB(string(TB.gene) == Genes{i}, :);

        % Extract sequences and labels for the current gene
        sequences = TB_gene.sequence;
        labels = TB_gene.label_RNA_DNA;

        % Prepare one-hot encoded DNA sequences
        numSequences = length(sequences);
        inputData = zeros(4, 160, 1, numSequences);
        for j = 1:numSequences
            inputData(:, :, :, j) = dna2onehot(sequences{j});
        end

        % Balance data across classes
        [balancedData, balancedLabels] = balanceData(inputData, labels);

        % Split the balanced data into training, validation, and test sets
        [trainData, trainLabels, valData, valLabels, testData, testLabels] = splitData(balancedData, balancedLabels);

        % Reshape data for CNN input
        trainData = reshape(trainData, [4, 160, 1, size(trainData, 4)]);
        trainLabels = categorical(trainLabels);
        valData = reshape(valData, [4, 160, 1, size(valData, 4)]);
        valLabels = categorical(valLabels);
        testData = reshape(testData, [4, 160, 1, size(testData, 4)]);
        testLabels = categorical(testLabels);

        % Define the CNN architecture
        layers = [
            imageInputLayer([4 160 1])
            convolution2dLayer([4 5], 32, 'Stride', [1 1], 'Padding', 'same')
            batchNormalizationLayer
            reluLayer
            maxPooling2dLayer([1 2], 'Stride', 2)
            convolution2dLayer([1 5], 64, 'Stride', [1 1], 'Padding', 'same')
            batchNormalizationLayer
            reluLayer
            maxPooling2dLayer([1 2], 'Stride', 2)
            fullyConnectedLayer(3)
            softmaxLayer
            classificationLayer
        ];

        % Training options for the CNN
        options = trainingOptions('adam', ...
            'MaxEpochs', 20, ...
            'MiniBatchSize', 32, ...
            'Shuffle', 'every-epoch', ...
            'Plots', 'training-progress', ...
            'Verbose', false, ...
            'ValidationData', {valData, valLabels}, ...
            'ValidationFrequency', 20, ...
            'OutputNetwork', 'best-validation');

        % Train the CNN on the training data
        net = trainNetwork(trainData, trainLabels, layers, options);

        % Classify the test data
        YPred = classify(net, testData);

        % Create a directory to save results for the current gene
        cd(Path_to_save)
        mkdir(Genes{i})
        cd(Genes{i})

        % Plot and save a confusion matrix
        confusionchart(testLabels, YPred, 'ColumnSummary', 'column-normalized', 'RowSummary', 'row-normalized');
        saveas(gcf, Genes{i} + "_confusion_matrix.eps", "epsc");
        saveas(gcf, Genes{i} + "_confusion_matrix.png");
        close

        % Calculate accuracy and display it
        accuracy = sum(YPred == testLabels) / numel(testLabels);
        disp(['Test Accuracy for ', Genes{i}, ': ', num2str(accuracy * 100), '%']);

        % Compute F1 scores
        [f1Scores, averageF1] = computeF1Score(testLabels, YPred);

        % Store metrics
        acc(i) = accuracy;
        original_num_data(i) = size(inputData, 4);
        f_1(i) = f1Scores(1);
        f_2(i) = f1Scores(2);
        f_3(i) = f1Scores(3);
    end

    % Save metrics for all genes
    cd(Path_to_save)
    save("TrainingMetrics.mat", 'acc', 'original_num_data', 'f_1', 'f_2', 'f_3');
end
