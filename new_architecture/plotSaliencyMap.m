function plotSaliencyMap(saliencyMap, sequence)
    figure;
    imagesc(saliencyMap);
    colorbar;
    title(['Saliency Map for Sequence: ', sequence]);
    xlabel('Position');
    ylabel('Base (A, C, G, T)');
end