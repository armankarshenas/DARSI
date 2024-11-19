function [] = EvaluateModel(net,Path_to_data)
% EvaluateModel classifies sequences using a pre-trained network 
% and computes the accuracy. 

% Written by A. Karshenas -- Feb 25, 2024
%----------------------------------------------------
    imds_test = imageDatastore(Path_to_data,'IncludeSubfolders',true,'LabelSource','foldernames');
    Y = Classify(net,imds_test.Labels);
    acc = nnz(Y==imds_test.Labels)/length(Y);
    
end
