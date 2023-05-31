%% Info
% This script 1: loads the dataset, 2: sets the network architechure, 3:
% train the network, 4: evaluate the model for cross validation

%% Specifications 

addpath(genpath("/media/zebrafish/Data2/Arman/PhD/Reg-seq/Matlab/Scripts"))
Path_to_data = "/media/zebrafish/Data2/Arman/Data/LB_dataset/0.10/imgs";
Path_to_save = "/media/zebrafish/Data2/Arman/Data/LB_dataset/0.10/Model/CrossVal3";

kernel_sz = 3:1:20;

%% Main code
cd(Path_to_data)
cd("Train")
Genes = dir(pwd);
cd ..
ACC = struct();
for ker=1:length(kernel_sz)
% Set the network architechture
layers = [
    imageInputLayer([4 160 1],"Name","SequenceInput")
    convolution2dLayer([kernel_sz(ker) kernel_sz(ker)],256,"Name","conv_1","Padding","same")
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
for i=3:length(Genes)

% Load the dataset
imds_train = imageDatastore(Path_to_data + "/Train"+"/"+Genes(i).name,'IncludeSubfolders',true,'LabelSource','foldernames');
imds_test = imageDatastore(Path_to_data + "/Test"+"/"+Genes(i).name,'IncludeSubfolders',true,'LabelSource','foldernames');
imds_valid = imageDatastore(Path_to_data+"/Valid"+"/"+Genes(i).name,'IncludeSubfolders',true,'LabelSource','foldernames');

% Specifying training options 
opts = trainingOptions("sgdm",...
    "ExecutionEnvironment","auto",...
    "InitialLearnRate",0.01,...
    "Shuffle","every-epoch",...
    'LearnRateDropFactor',0.2,'LearnRateDropPeriod',5,'LearnRateSchedule','piecewise','ValidationPatience',30,'OutputNetwork','best-validation-loss',...
    "Plots","none",...
    "ValidationData",imds_valid,'ValidationFrequency',20);

% Training the network  
cd(Path_to_save)
if exist(string(ker)) == 7
    cd(string(ker))
else
    mkdir(string(ker))
    cd(string(ker))
end

if exist(Genes(i).name) == 7
    cd(Genes(i).name)
else
    mkdir(Genes(i).name)
    cd(Genes(i).name)
end

diary training_log.txt
[net, traininfo] = trainNetwork(imds_test,layers,opts);
diary off

% Saving the model
name = Genes(i).name +"_trained_network.mat";
save(name,'net','traininfo');

% Evaluate the model 

Y = classify(net,imds_test);

ACC(i-2).gene = Genes(i).name;
ACC(i-2).acc(ker) = nnz(Y==imds_test.Labels)/length(Y);
ACC(i-2).datapt = length(Y)*100/15;

end
end
cd(Path_to_save)
save("CrossVal.mat",'ACC');