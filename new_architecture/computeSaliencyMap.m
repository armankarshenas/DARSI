function saliencyMap = computeSaliencyMap(net, image, label)
    dlX = dlarray(image, 'SSC');
    gradients = dlfeval(@(dlX) dlgradient(@(dlX) modelLoss(net, dlX, label), dlX), dlX);
    saliencyMap = abs(extractdata(gradients));
end