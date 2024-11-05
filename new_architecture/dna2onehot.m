function onehot = dna2onehot(sequence)
    baseMap = containers.Map(["A","C","G","T"], 1:4);
    onehot = zeros(4, length(sequence));
    for j = 1:length(sequence)
        onehot(baseMap(sequence(j)), j) = 1;
    end
end