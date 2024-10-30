
% SequenceDataProcessing
% This script reads in CSV file from Rob Philips' group at Caltech and
% reshapes sequences to images and exports them into a new directory along
% with the corresponding expression level

% Written by A. Karshenas -- Feb 22, 2024
%---------------------------------------------------- 
clc
clear all 

%% Specifications 
addpath(genpath("~/Desktop/DARSI/Scripts"))
Path_to_data = "~/Desktop/DARSI/";
Path_to_save = "~/Desktop/DARSI/";
Path_to_save_histograms = "~/Desktop/DARSI/new_run_plots/histograms";
Path_to_save_imgs = "~/Desktop/DARSI/imgs";

max_iteration_for_binnning = 1e4;
% training and test fraction of the data 
train_f = 0.7;
test_f = 0.15;


%% Main code body
cd(Path_to_data);

% load the dataset and clean up the columns 
sequences = readtable("new_data_LB.txt");
fprintf("Showing a preview of the data ...\n");
head(sequences)
sequences.Properties.VariableNames{'seq'} = 'sequence';
sequences.sequence = cellfun(@(x) x(1:end-20), sequences.sequence, 'UniformOutput', false);
sequences.barcode = cellfun(@(x) x(end-19:end), sequences.sequence, 'UniformOutput', false);

% Filter out only operons with over 1000 variants & generate a summary
% table 
summaryTable = groupsummary(sequences, 'gene', 'IncludeEmptyGroups', true);
writetable(summaryTable,"summaryTable.txt");
genesAboveThreshold = summaryTable.gene(summaryTable.GroupCount > 1000);
sequences = sequences(ismember(sequences.gene, genesAboveThreshold), :);
header = string(sequences.gene(:)) + "_"+cell2mat(sequences.barcode(1:height(sequences)));
sequences{:,width(sequences)+1} = header;
sequences.Properties.VariableNames{'Var7'} = 'Header';
sequences(any(ismissing(sequences),2),:) = [];

% Label the dataset
    [bin_count,sequences] = RNA_DNASeqLabel(sequences,max_iteration_for_binnning,Path_to_save_histograms);
writetable(bin_count,'bin_count.txt')
% Partitioning the dataset
[tb_test,tb_train,tb_val] = PartitionDataSet(train_f,test_f,sequences);

cd(Path_to_save)
% Training data
fastawrite("Train_sequences.fa",string(tb_train.Header(:)),string(tb_train.sequence(:)));
writetable(tb_train,"Train_activity.txt");
Train_label = table2array(tb_train(:,width(tb_train)));
save("Train_label.mat",'Train_label');
% Testing data 
fastawrite("Test_sequences.fa",string(tb_test.Header(:)),string(tb_test.sequence(:)));
writetable(tb_test,"Test_activity.txt");
Test_label = table2array(tb_test(:,width(tb_train)));
save("Test_label.mat",'Test_label');
% Validation data
fastawrite("Valid_sequences.fa",string(tb_val.Header(:)),string(tb_val.sequence(:)));
writetable(tb_val,"Valid_activity.txt");
Valid_label = table2array(tb_val(:,width(tb_val)));
save("Valid_label.mat",'Valid_label');


% Generate images for the OneHotEncoder 
OneHotSequence(Path_to_save,Path_to_save_imgs);

