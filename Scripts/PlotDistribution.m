function [] = PlotDistribution(tb_gene,OH_gene,Path_to_save,name)
    a1 = OH_gene.RNA_label == 1;
    a0 = OH_gene.RNA_label == 0;
    an = OH_gene.RNA_label == -1;
    figure1 = figure;
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    histogram(tb_gene.ct_RNA(a1),'BinWidth',10,'FaceAlpha',0.3,'FaceColor','b','Parent',axes1,'DisplayName',"1");
    hold on;
    histogram(tb_gene.ct_RNA(a0),'BinWidth',10,'FaceAlpha',0.3,'FaceColor','m','Parent',axes1,'DisplayName',"0");
    hold on; 
    histogram(tb_gene.ct_RNA(an),'BinWidth',10,'FaceAlpha',0.3,'FaceColor','r','Parent',axes1,'DisplayName',"-1");
    box(axes1,'on');
    grid(axes1,'on');
    xlabel("ct RNA",'FontSize',15,'Interpreter','latex')
    hold(axes1,'off');
    set(axes1,'LineWidth',2);
    legend(axes1,'show');
    cd(Path_to_save);
    name = split(name,"_");
    name = name{1}+"_distribution.png";
    saveas(gca,name)
    close all;
end