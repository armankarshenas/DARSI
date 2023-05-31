function lgraph = replaceLayersOfType(lgraph,layerType,newLayer)

% Replace layers in the layerGraph lgraph of the type specified by
% layerType with copies of the layer newLayer.

for i=1:length(lgraph.Layers)
    if isa(lgraph.Layers(i),layerType)
        % Match names between the old and new layers.
        layerName = lgraph.Layers(i).Name;
        newLayer.Name = layerName;
        
        lgraph = replaceLayer(lgraph,layerName,newLayer);
    end
end
end