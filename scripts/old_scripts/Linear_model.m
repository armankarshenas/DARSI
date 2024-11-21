% Linear_model trains a fully connected network on the reg-seq data and
% generates prediction for the expression bin 

% Written by A. Karshenas -- Feb 22, 2024
%----------------------------------------------------
%% Specifications 

addpath(genpath("/mnt/3dda8c88-9203-43bd-b240-4a31fecd10c3/Arman/PhD/Reg-seq/Matlab"))
Path_to_data = "/mnt/3dda8c88-9203-43bd-b240-4a31fecd10c3/Arman/PhD/DARSI/Data/LB_dataset/Linear_model/data";
Path_to_save = "/mnt/3dda8c88-9203-43bd-b240-4a31fecd10c3/Arman/PhD/DARSI/Data/LB_dataset/Linear_model/Model/";


%% Main code
cd(Path_to_data)
Genes = dir(pwd);

% Here I will have to implement some code that gets the size and number of
% classes from the imds and use those in network arch 

% Set the network architechture
layers = [
    featureInputLayer(160,'Normalization', 'zscore')
    fullyConnectedLayer(160,"Name","fc_1")
    batchNormalizationLayer("Name","batchnorm_4")
    reluLayer("Name","relu_4")
    dropoutLayer(0.4,"Name","dropout_1")
    fullyConnectedLayer(3,"Name","fc_2")
    batchNormalizationLayer("Name","batchnorm_5")
    reluLayer("Name","relu_5")
    dropoutLayer(0.4,"Name","dropout_2")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];
ACC = struct();
for i=3:length(Genes)

    cd(Genes(i).folder+"/"+Genes(i).name)
    data_train = readtable("Train.txt");
    data_train = convertvars(data_train,'Var161','categorical');
    data_test = readtable("Test.txt");
    data_test = convertvars(data_test,'Var161','categorical');
    data_valid = readtable("Valid.txt");
    data_valid = convertvars(data_valid,'Var161','categorical');


% Specifying training options 

opts = trainingOptions("sgdm",...
    "ExecutionEnvironment","auto",...
    "MaxEpochs",1000,...
    "MiniBatchSize",32,...
    "InitialLearnRate",0.001,...
    "Shuffle","every-epoch",...
    'LearnRateDropFactor',0.2,'LearnRateDropPeriod',5,'LearnRateSchedule','piecewise','ValidationPatience',30,'OutputNetwork','best-validation-loss',...
    "Plots","none",...
    "ValidationData",data_valid,'ValidationFrequency',2);

% Training the network  
cd(Path_to_save)
if exist(Genes(i).name) == 7
    cd(Genes(i).name)
else
    mkdir(Genes(i).name)
    cd(Genes(i).name)
end

diary training_log.txt
[net, traininfo] = trainNetwork(data_train,layers,opts);
diary off

% Saving the model
name = Genes(i).name +"_trained_network.mat";
save(name,'net','traininfo');

% Evaluate the model 

Y = classify(net,X_test);
confusionchart(categorical(table2array(y_test)),Y);
ACC(i-2).gene = Genes(i).name;
ACC(i-2).acc = nnz(double(Y)==table2array(y_test))/length(Y);
ACC(i-2).datapt = length(Y)*100/15;
saveas(gca,'ConfusionMatrix.png');
close all
end
cd(Path_to_save)
save("SingelGeneACC.mat",'ACC');
SingleGeneBarPlots(ACC,pwd);
saveas(gca,'BarChart.fig');
close all;