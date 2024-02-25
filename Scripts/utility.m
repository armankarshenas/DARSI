Path_to_overhead_dir = "/mnt/3dda8c88-9203-43bd-b240-4a31fecd10c3/Arman/PhD/DARSI/Data/LB_dataset/NoBias/0.15/Model/Single_genes";
Path_to_save = "/mnt/3dda8c88-9203-43bd-b240-4a31fecd10c3/Arman/PhD/DARSI/Confusion_matrices";

cd(Path_to_overhead_dir)

genes = dir(pwd);

for i=3:length(genes)
    cd(Path_to_overhead_dir)
    if genes(i).isdir ==1
        cd(genes(i).name);
        I = imread("ConfusionMatrix.png");
        name_to_write = genes(i).name + ".png";
        cd(Path_to_save)
        imwrite(I,name_to_write)
    end

end