classdef WeightedClassificationLayer < nnet.layer.ClassificationLayer
    properties
        ClassWeights
    end
    methods
        function layer = WeightedClassificationLayer(classWeights, name)
            layer.ClassWeights = classWeights;
            layer.Name = name;
        end
        
        function loss = forwardLoss(layer, Y, T)
            % Apply class weights to each label
            weights = layer.ClassWeights(T+1); % MATLAB indexing
            loss = -sum(weights .* log(Y(T==1))) / numel(T);
        end
    end
end