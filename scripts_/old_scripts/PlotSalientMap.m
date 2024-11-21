function [] = PlotSalientMap(Image,cmap,seq,Path_to_save,name)
    seq = split(string(seq),"");
    seq = seq(2:end-1);
    cd(Path_to_save);
    name = name +".fig";
    figure()
    heatmap(Image,'Colormap',cmap,'XDisplayLabels',(seq),'YDisplayLabels',["A","T","C","G"]);
    saveas(gcf,name);
    close
end
