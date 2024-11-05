% Loss function for saliency map computation
function loss = modelLoss(net, dlX, label)
     
    dlYPred = predict(net, dlX);

    % Convert the label to a categorical variable if needed
    label = categorical(label);

    % Calculate cross-entropy loss between predicted and true label
    loss = crossentropy(dlYPred, label);
end