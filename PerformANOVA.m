function [measure_dist] = PerformANOVA(tb_gene,OH_gene,Path_to_save,name)
    % Performing one-way ANOVA
    [~,~,stats] = anova1(tb_gene.ct_RNA,OH_gene.RNA_label);
    name = split(name,"_");
    name_1 = name{1} + "_anova1.png";
    cd(Path_to_save)
    saveas(gca,name_1);
    close all
    % Performing multi comparison
    [result,m,~,gnames] = multcompare(stats);
    name_3 = name{1}+"_multcomp.png";
    saveas(gca,name_3);
    close all
    tbl = array2table(result,"VariableNames",["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
    tbl.("Group A") = gnames(tbl.("Group A"));
    tbl.("Group B") = gnames(tbl.("Group B"));
    name_2 = name{1} +"_ANOVA.txt";
    writetable(tbl,name_2);
    measure_dist = mean(tbl.("P-value"));
        save(name{1}+"_ANOVA.mat",'m','tbl','stats','measure_dist');

end