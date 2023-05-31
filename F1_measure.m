function f1_measure = F1_measure(labels,pred,n_class)
% This function computes an F1 score for every possible pair of classes
% using the test and predicted labels 

labels = double(string(labels));
pred = double(string(pred));
classes = unique(labels);
pairs = nchoosek(classes,2);
f1_measure = struct();
for i=1:nchoosek(n_class,2)
    tp = sum((pred == pairs(i,1))&(labels == pairs(i,1)));
    fp = sum((pred == pairs(i,1))&(labels == pairs(i,2)));
    fn = sum((pred == pairs(i,2))&(labels == pairs(i,1)));
    precision = tp / (tp + fp);
    recall = tp / (tp + fn);
    f1 = (2 * precision * recall) / (precision + recall);
    f1_measure(i).classes = pairs(i,:);
    f1_measure(i).f1 = f1;
end
end