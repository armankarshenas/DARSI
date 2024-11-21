% Step 1: Load and preprocess data
numSamples = 4045; 
seqLength = 160;
numClasses = 3;  % Set this to the number of expression bins

% One-hot encode the sequences (Assuming A,C,G,T -> 1,2,3,4)
sequences = tb_train.sequence;  % Replace with actual sequences

% Encode sequences into 4x160 one-hot vectors
oneHotSeq = zeros(numSamples, 4, seqLength);
for i = 1:numSamples
    for j = 1:seqLength
        oneHotSeq(i, sequences{i}(j), j) = 1;
    end
end

% Normalize and bin expression values (assume logRatioValues is precomputed)
% Binning to discrete classes
[~, ~, expressionBins] = histcounts(logRatioValues, numClasses);

% Convert labels to categorical for classification
labels = categorical(expressionBins);

% Step 2: Define CNN model
layers = [
    imageInputLayer([4 seqLength 1], 'Normalization', 'none')
    
    convolution2dLayer([4 5], 16, 'Stride', [4 1], 'Padding', 'same')
    reluLayer
    maxPooling2dLayer([1 2], 'Stride', [1 2])
    
    convolution2dLayer([1 5], 32, 'Stride', [1 1], 'Padding', 'same')
    reluLayer
    maxPooling2dLayer([1 2], 'Stride', [1 2])
    
    fullyConnectedLayer(64)
    reluLayer
    dropoutLayer(0.3)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

% Step 3: Train the model
options = trainingOptions('adam', ...
    'MaxEpochs', 20, ...
    'MiniBatchSize', 64, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', false, ...
    'Plots', 'training-progress');

trainedNet = trainNetwork(oneHotSeq, labels, layers, options);

% Step 4: Generate saliency maps for a test sequence
testSeq = oneHotSeq(1, :, :);  % Replace with desired test sequence
dlTestSeq = dlarray(testSeq, 'SSC');

% Use custom function to compute gradients for saliency
gradients = dlfeval(@computeGradients, trainedNet, dlTestSeq);

% Visualize saliency map
saliencyMap = abs(gradients);  % Taking absolute value of gradients
imagesc(squeeze(sum(saliencyMap, 1)));  % Summing over channels
colorbar;
title('Saliency Map of Sequence');
xlabel('Position in Sequence');
ylabel('Importance');

% Helper function to compute gradients
function gradients = computeGradients(net, dlInput)
    % Forward pass
    [~,state] = forward(net, dlInput);
    % Calculate gradients with respect to loss
    gradients = dlgradient(state.Loss, dlInput);
end
