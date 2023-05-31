function [tb_test,tb_train,tb_valid] = PartitionDataSet(frac_train,frac_test,dataset)
% Shuffling the dataset before partitioning 
index = randperm(size(dataset,1));
dataset = dataset(index,:);


train_idx = floor(size(dataset,1)*frac_train);
test_idx = floor(size(dataset,1)*frac_test);
tb_train = dataset(1:train_idx,:);
tb_test = dataset(train_idx+1:train_idx+test_idx,:);
tb_valid = dataset(train_idx+test_idx+1:end,:);
end