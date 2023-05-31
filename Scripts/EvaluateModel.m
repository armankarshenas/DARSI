function [] = EvaluateModel(net,Path_to_data)
    imds_test = imageDatastore(Path_to_data,'IncludeSubfolders',true,'LabelSource','foldernames');
    Y = Classify(net,imds_test.Labels);
    acc = nnz(Y==imds_test.Labels)/length(Y);
    
end