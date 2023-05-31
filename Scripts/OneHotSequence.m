function [] = OneHotSequence(Path_to_data,Path_to_save)
% This function generates matrices for each sequence as a one-hot encoder
%% Main code 
cd(Path_to_data)
TXT_files = dir(fullfile(pwd,"*.txt"));
FST_files = dir(fullfile(pwd,"*.fa"));
for i=1:length(FST_files)
    fprintf("Processing %s ... \n",FST_files(i).name);
    OneHot = struct();
    fst = fastaread(FST_files(i).folder + "/"+ FST_files(i).name);
    tb = readtable(TXT_files(i).folder+"/"+TXT_files(i).name);
    path_name = split(FST_files(i).name,"_");
    path_name = path_name{1};
    cd(Path_to_save);
    mkdir(path_name);
    path_name = Path_to_save + "/" + path_name;
    cd(path_name);
    for j=1:height(tb)
        seq_read = OneHotEncoder(fst(j).Sequence);
        WriteImageToTIFF(seq_read,path_name,string(tb.gene{j}),tb.label_RNA(j),string(tb.Header{j}));
        OneHot(j).data = seq_read;
        OneHot(j).index = fst(j).Header;
        OneHot(j).RNA_label = tb.label_RNA(j);
        OneHot(j).DNA_label = tb.label_DNA(j);
        waitbar(j/height(tb))
    end
    cd(Path_to_data)
    name = split(FST_files(i).name,".fa");
    name = name{1};
    name = name + ".mat";
    save(name,'OneHot');
end
end
