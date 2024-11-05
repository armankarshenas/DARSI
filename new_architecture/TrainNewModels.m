% Add all folders in "Scripts" directory to the path
addpath(genpath("~/Desktop/DARSI/Scripts"))

% Define paths for data and where to save results
Path_to_data = "~/Desktop/DARSI/";
Path_to_save = "~/Desktop/DARSI/new_model/";

% Reading in the training, testing, and validation data tables
cd(Path_to_data)
tb_train = readtable('Train_activity.txt');
tb_test = readtable('Test_activity.txt');
tb_valid = readtable('Valid_activity.txt');

% Concatenate all data tables to create a single dataset
TB = vertcat(tb_train, tb_test, tb_valid);

% Get a unique list of gene names in the dataset
Genes = unique(TB.gene);

% Loop over each unique gene to process data and train a model
for i = 1:length(Genes)
    waitbar(i/length(Genes));
    % Filter data for the current gene
    TB = TB(string(TB.gene) == Genes{i}, :);

    % Extract sequences and labels for the gene
    sequences = TB.sequence;
    labels = TB.label_RNA_DNA;

    % Initialize an array for one-hot encoded DNA sequences
    numSequences = length(sequences);
    inputData = zeros(4, 160, 1, numSequences);

    % Convert each DNA sequence to a one-hot encoded format
    for j = 1:numSequences
        sequence = sequences{j};
        inputData(:,:,:,j) = dna2onehot(sequence);
    end

    % Balance the data across classes using a custom function
    [balancedData, balancedLabels] = balanceData(inputData, labels);

    % Split the balanced data into training, validation, and test sets
    [trainData, trainLabels, valData, valLabels, testData, testLabels] = splitData(balancedData, balancedLabels);

    % Reshape data to match input dimensions of the CNN
    trainData = reshape(trainData, [4, 160, 1, length(trainData)]);
    trainLabels = categorical(trainLabels);
    valData = reshape(valData, [4, 160, 1, length(valData)]);
    valLabels = categorical(valLabels);
    testData = reshape(testData, [4, 160, 1, length(testData)]);
    testLabels = categorical(testLabels);

    % Define the CNN architecture
    layers = [
        imageInputLayer([4 160 1]) % Input layer for one-hot encoded DNA
        convolution2dLayer([4 5], 32, 'Stride', [1 1], 'Padding', 'same')
        batchNormalizationLayer
        reluLayer
        maxPooling2dLayer([1 2], 'Stride', 2)

        convolution2dLayer([1 5], 64, 'Stride', [1 1], 'Padding', 'same')
        batchNormalizationLayer
        reluLayer
        maxPooling2dLayer([1 2], 'Stride', 2)

        fullyConnectedLayer(3) % 3 classes for the binned expression levels
        softmaxLayer
        classificationLayer
        ];

    % Specify training options for the CNN
    options = trainingOptions('adam', ...
        'MaxEpochs', 20, ...
        'MiniBatchSize', 32, ...
        'Shuffle', 'every-epoch', ...
        'Plots', 'training-progress', ...
        'Verbose', false, ...
        'ValidationData', {valData, valLabels}, ...
        'ValidationFrequency', 20, ...
        'OutputNetwork', 'best-validation');

    % Train the CNN model on the training data
    net = trainNetwork(trainData, trainLabels, layers, options);

    % Classify the test data using the trained model
    YPred = classify(net, testData);

    % Create a folder for saving results for the current gene
    cd(Path_to_save)
    mkdir(Genes{i})
    cd(Genes{i})

    % Plot and save a confusion matrix for the test predictions
    confusionchart(testLabels, YPred, 'ColumnSummary', 'column-normalized', 'RowSummary', 'row-normalized');
    name = Genes{i} + "_confusion_matrix";
    saveas(gca, name + ".eps", "epsc");
    saveas(gca, name + ".png");
    close

    % Calculate and display test accuracy
    accuracy = sum(YPred == testLabels) / numel(testLabels);
    disp(['Test Accuracy: ', num2str(accuracy * 100), '%']);

    % Compute F1 scores for each class using a custom function
    [f1Scores, averagef1] = computeF1Score(testLabels, YPred);

    % Store metrics for later analysis
    acc(i) = accuracy;
    original_num_data(i) = length(inputData);
    f_1(i) = f1Scores(1);
    f_2(i) = f1Scores(2);
    f_3(i) = f1Scores(3);
end

% Save the training metrics in a .mat file
cd(Path_to_save)
save("TrainingMetrics.mat", 'acc', "original_num_data", "f_3", "f_2", "f_1");
