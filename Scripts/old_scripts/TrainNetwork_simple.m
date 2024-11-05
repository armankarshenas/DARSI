% DeepLearningSingleGene 1: loads the dataset, 2: sets the network architechure, 3:
% train the network, 4: evaluate the model, and 5: plots any neccessary
% figures

% Written by A. Karshenas -- Feb 25, 2024
%----------------------------------------------------

%% Specifications 

addpath(genpath("~/Desktop/DARSI/Scripts"))
Path_to_data = "~/Desktop/DARSI/imgs";
Path_to_save = "~/Desktop/DARSI/new_run_plots/model";



%% Main code
cd(Path_to_data)
cd("Train")
Genes = dir(pwd);
cd ..

% Here I will have to implement some code that gets the size and number of
% classes from the imds and use those in network arch 

% Set the network architechture

ACC = struct();
for i=3:length(Genes)
% Load the dataset
imds_train = imageDatastore(Path_to_data + "/Train"+"/"+Genes(i).name,'IncludeSubfolders',true,'LabelSource','foldernames');
imds_test = imageDatastore(Path_to_data + "/Test"+"/"+Genes(i).name,'IncludeSubfolders',true,'LabelSource','foldernames');
imds_valid = imageDatastore(Path_to_data+"/Valid"+"/"+Genes(i).name,'IncludeSubfolders',true,'LabelSource','foldernames');


% Calculate class weights
label_counts = countcats(categorical(imds_train.Labels));
total_labels = sum(label_counts);
class_weights = total_labels ./ (length(label_counts) * label_counts);

layers = [
    imageInputLayer([4 160 1]) % Input layer for 4x160 images
    
    convolution2dLayer([2,5],8,'Padding','same') % First convolutional layer
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2) % Max pooling
    
    convolution2dLayer([2,5],16,'Padding','same') % Second convolutional layer
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(64) % Fully connected layer
    reluLayer
    dropoutLayer(0.5)
    
    fullyConnectedLayer(3) % Output layer (number of classes)
    softmaxLayer];

% Specifying training options 
options = trainingOptions('adam','InitialLearnRate', 1e-3, ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 64, ...
    'ValidationData', imds_valid, ...
    'ValidationFrequency', 20, ...
    'Plots', 'training-progress', ...,
    'Metrics','accuracy',...
    'Verbose', false, ...
    'ValidationPatience',30,'OutputNetwork','best-validation-loss');

Loss_fn = @(Y,T) crossentropy(Y,T, ...
    NormalizationFactor="all-elements", ...
    Weights=class_weights, ...
    WeightsFormat="C")*3;


% Training the network  
cd(Path_to_save)
if exist(Genes(i).name) == 7
    cd(Genes(i).name)
else
    mkdir(Genes(i).name)
    cd(Genes(i).name)
end

diary training_log.txt
[net, traininfo] = trainNetwork(imds_test,layers,Loss_fn,options);
diary off

% Saving the model
name = Genes(i).name +"_trained_network.mat";
save(name,'net','traininfo');

% Evaluate the model 

Y = classify(net,imds_test);
confusionchart(imds_test.Labels,Y);
F1 = F1_measure(imds_test.Labels,Y,3);
save('F1.mat','F1');
ACC(i-2).gene = Genes(i).name;
ACC(i-2).acc = nnz(Y==imds_test.Labels)/length(Y);
ACC(i-2).datapt = length(Y)*100/15;
saveas(gca,'ConfusionMatrix.png');
close all
end
cd(Path_to_save)
save("SingelGeneACC.mat",'ACC');
SingleGeneBarPlots(ACC,pwd);
saveas(gca,'BarChart.fig');
close all;

