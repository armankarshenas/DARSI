%% Sequence-expression data processing 
% This script reads in CSV file from Rob Philips' group at Caltech and
% reshapes sequences to images and exports them into a new directory along
% with the corresponding expression level
 
%% Specifications 
addpath(genpath("/media/zebrafish/Data2/Arman/PhD/Reg-seq/Matlab/Scripts"))
Path_to_data = "/media/zebrafish/Data2/Arman/Data/LB_dataset";
Path_to_save = "/media/zebrafish/Data2/Arman/Data/LB_dataset/NoBias/0.15";
Path_to_save_imgs = "/media/zebrafish/Data2/Arman/Data/LB_dataset/NoBias/0.15/imgs";

% threshold of activity for labelling (default 20%)
act_thresh = 0.15;
% training and test fraction of the data 
train_f = 0.7;
test_f = 0.15;


%% Main code body
cd(Path_to_data);
seq_file = dir(fullfile(pwd,"*.csv"));
sequences = readtable(seq_file(1).name);
fprintf("Showing a preview of the data ...\n");
head(sequences)
sequences.Properties.VariableNames{5} = 'sequence';
sequences.Properties.VariableNames{4} = 'ct_DNA';
sequences.Properties.VariableNames{2} = 'ct_RNA';
header = string(sequences.gene(:)) + "_"+cell2mat(sequences.barcode(1:height(sequences)));
sequences{:,width(sequences)+1} = header;
sequences.Properties.VariableNames{'Var8'} = 'Header';
sequences(any(ismissing(sequences),2),:) = [];

% Label the dataset
sequences = RNASeqLabel(sequences,act_thresh);

% Partitioning the dataset
[tb_test,tb_train,tb_val] = PartitionDataSet(train_f,test_f,sequences);

cd(Path_to_save)
% Training data
fastawrite("Train_sequences.fa",string(tb_train.Header(:)),string(tb_train.sequence(:)));
writetable(tb_train,"Train_activity.txt");
Train_label = [table2array(tb_train(:,width(tb_train)-1)) table2array(tb_train(:,width(tb_train)))];
save("Train_label.mat",'Train_label');
% Testing data 
fastawrite("Test_sequences.fa",string(tb_test.Header(:)),string(tb_test.sequence(:)));
writetable(tb_test,"Test_activity.txt");
Test_label = [table2array(tb_test(:,width(tb_test)-1)) table2array(tb_test(:,width(tb_train)))];
save("Test_label.mat",'Test_label');
% Validation data
fastawrite("Valid_sequences.fa",string(tb_val.Header(:)),string(tb_val.sequence(:)));
writetable(tb_val,"Valid_activity.txt");
Valid_label = [table2array(tb_val(:,width(tb_val)-1)) table2array(tb_val(:,width(tb_val)))];
save("Valid_label.mat",'Valid_label');


% Generate images for the OneHotEncoder 
OneHotSequence(Path_to_save,Path_to_save_imgs);

