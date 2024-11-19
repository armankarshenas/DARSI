function map = gradientAttribution(net,img,YPred,softmaxName,method)

lgraph = layerGraph(net);
lgraph = removeLayers(lgraph,lgraph.Layers(end).Name);
dlnet = dlnetwork(lgraph);

% To use automatic differentiation, convert the image to a dlarray.
dlImg = dlarray(single(img),"SSC");

if method == "autodiff"
% Use dlfeval and the gradientMap function to compute the derivative. The gradientMap
% function passes the image forward through the network to obtain the class scores
% and contains a call to dlgradient to evaluate the gradients of the scores with respect
% to the image.
dydI = dlfeval(@gradientMap,dlnet,dlImg,softmaxName,YPred);
end

if method == "guided-backprop"

% Use the custom layer CustomBackpropReluLayer (attached as a supporting file)  
% with a nonstandard backward pass, and use it with automatic differentiation.
customRelu = CustomBackpropReluLayer();

% Set the BackpropMode property of each CustomBackpropReluLayer to "guided-backprop".
customRelu.BackpropMode = "guided-backprop";

% Use the supporting function replaceLayersOfType to replace all instances of reluLayer in the network with
% instances of CustomBackpropReluLayer. 
lgraphGB = replaceLayersOfType(lgraph, ...
    'nnet.cnn.layer.ReLULayer',customRelu);

% Convert the layer graph containing the CustomBackpropReluLayers into a dlnetwork.
dlnetGB = dlnetwork(lgraphGB);
dydI = dlfeval(@gradientMap,dlnetGB,dlImg,softmaxName,YPred);
end

% Sum the absolute values of each pixel along the channel dimension, then rescale
% between 0 and 1.
map = sum(abs(extractdata(dydI)),3);
map = rescale(map);
end