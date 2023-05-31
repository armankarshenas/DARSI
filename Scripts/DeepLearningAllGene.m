%% Info
% This script 1: loads the dataset, 2: sets the network architechure, 3:
% train the network, 4: evaluate the model, and 5: plots any neccessary
% figures

%% Specifications 

addpath(genpath("/media/zebrafish/Data2/Arman/PhD/Reg-seq/Matlab/Scripts"))
Path_to_data = "/media/zebrafish/Data2/Arman/Data/LB_dataset/imgs";
Path_to_save = "/media/zebrafish/Data2/Arman/Data/LB_dataset/Model/";


%% Main code
cd(Path_to_data)
% Load the dataset
imds_train = imageDatastore(Path_to_data + "/Train",'IncludeSubfolders',true,'LabelSource','foldernames');
imds_test = imageDatastore(Path_to_data + "/Test",'IncludeSubfolders',true,'LabelSource','foldernames');
imds_valid = imageDatastore(Path_to_data+"/Valid",'IncludeSubfolders',true,'LabelSource','foldernames');

% Here I will have to implement some code that gets the size and number of
% classes from the imds and use those in network arch 

% Set the network architechture
layers = [
    imageInputLayer([4 160 1],"Name","SequenceInput")
    convolution2dLayer([7 7],256,"Name","conv_1","Padding","same")
    convolution2dLayer([3 3],60,"Name","conv_2","Padding","same")
    batchNormalizationLayer("Name","batchnorm_1")
    reluLayer("Name","relu_1")
    maxPooling2dLayer([2 2],"Name","maxpool_1","Padding","same")
    convolution2dLayer([5 5],60,"Name","conv_4","Padding","same")
    batchNormalizationLayer("Name","batchnorm_3")
    reluLayer("Name","relu_3")
    maxPooling2dLayer([2 2],"Name","maxpool_3","Padding","same")
    convolution2dLayer([3 3],120,"Name","conv_3","Padding","same")
    batchNormalizationLayer("Name","batchnorm_2")
    reluLayer("Name","relu_2")
    maxPooling2dLayer([2 2],"Name","maxpool_2","Padding","same")
    fullyConnectedLayer(256,"Name","fc_1")
    batchNormalizationLayer("Name","batchnorm_4")
    reluLayer("Name","relu_4")
    dropoutLayer(0.4,"Name","dropout_1")
    fullyConnectedLayer(3,"Name","fc_2")
    batchNormalizationLayer("Name","batchnorm_5")
    reluLayer("Name","relu_5")
    dropoutLayer(0.4,"Name","dropout_2")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];
plot(layerGraph(layers));


% Specifying training options 
opts = trainingOptions("sgdm",...
    "ExecutionEnvironment","auto",...
    "InitialLearnRate",0.01,...
    "Shuffle","every-epoch",...
    'LearnRateDropFactor',0.1,'LearnRateDropPeriod',5,'LearnRateSchedule','piecewise','ValidationPatience',5,'OutputNetwork','best-validation-loss',...
    "Plots","training-progress",...
    "ValidationData",imds_valid,'ValidationFrequency',100);

% Training the network  
diary training_log.txt 
[net, traininfo] = trainNetwork(imds_test,layers,opts);
diary off

% Saving the model
cd(Path_to_save)
name = "Lb_dataset_v1_allgene.mat";
save(name,'net');

% Evaluate the model 

Y = classify(net,imds_test);
confusionchart(imds_test.Labels,Y);
saveas(gca,'ConfusionMatrix.png');




