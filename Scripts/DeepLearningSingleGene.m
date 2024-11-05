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
    classificationLayer];
ACC = struct();
for i=3:length(Genes)

% Load the dataset
imds_train = imageDatastore(Path_to_data + "/Train"+"/"+Genes(i).name,'IncludeSubfolders',true,'LabelSource','foldernames');
imds_test = imageDatastore(Path_to_data + "/Test"+"/"+Genes(i).name,'IncludeSubfolders',true,'LabelSource','foldernames');
imds_valid = imageDatastore(Path_to_data+"/Valid"+"/"+Genes(i).name,'IncludeSubfolders',true,'LabelSource','foldernames');

X_train = zeros(4,160,1,length(imds_train.Labels));
Y_train = imds_train.Labels;
for j=1:length(Y_train)
    X_train(:,:,:,i) = readimage(imds_train,j);
end
X_test = zeros(4,160,1,length(imds_test.Labels));
Y_test = imds_test.Labels;
for j=1:length(Y_test)
    X_test(:,:,:,i) = readimage(imds_test,j);
end
X_valid = zeros(4,160,1,length(imds_valid.Labels));
Y_valid = imds_valid.Labels;
for j=1:length(Y_valid)
    X_valid(:,:,:,j) = readimage(imds_valid,j);
end

% Calculate class weights
label_counts = countcats(categorical(imds_train.Labels));
total_labels = sum(label_counts);
class_weights = total_labels ./ (length(label_counts) * label_counts);
% Specifying training options 

%{
opts = trainingOptions("adam",...
    "ExecutionEnvironment","GPU",...
    "InitialLearnRate",0.01,...
    "Shuffle","every-epoch",...
    'LearnRateDropFactor',0.2,'LearnRateDropPeriod',5,'LearnRateSchedule','piecewise','ValidationPatience',30,'OutputNetwork','best-validation-loss',...
    "Plots","none",...
    "ValidationData",imds_valid,'ValidationFrequency',20);
    %}
options = trainingOptions('adam', ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 50, ...
    'MiniBatchSize', 64, ...
    'ValidationData', imds_valid, ...
    'ValidationFrequency', 20, ...
    'Plots', 'training-progress',...
    'OutputNetwork','best-validation-loss'); 

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
[net, traininfo] = trainNetwork(imds_train,layers,options);
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

