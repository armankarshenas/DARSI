% SaliencyMaps generates saliency maps for models and inputs

% Written by A. Karshenas -- Feb 22, 2024
%----------------------------------------------------

clear
clc
close all
%% Specifications
addpath(genpath("/media/zebrafish/Data2/Arman/PhD/Reg-seq/Matlab"));
Path_to_data = "/media/zebrafish/Data2/Arman/Data/LB_dataset/0.10/imgs";
Path_to_model = "/media/zebrafish/Data2/Arman/Data/LB_dataset/0.10/Model/Single_genes";

%% Main code
cd(Path_to_model)
Genes = dir(pwd);
for i=5:length(Genes)
    waitbar(i/length(Genes));
    cd(Path_to_model+"/"+Genes(i).name);
    net = load(Genes(i).name+"_trained_network.mat");
    net = net.net;
    imds = imageDatastore(Path_to_data+"/Test/"+Genes(i).name,'IncludeSubfolders',true);
    [YPred,scores] = classify(net,imds);
    edges = 0:0.1:1;
    h1 = histcounts(scores(:,1),edges);
    h2 = histcounts(scores(:,2),edges);
    h3 = histcounts(scores(:,3),edges);
    fig1 = figure();
    bar1 = bar(edges(1:end-1),[h1;h2;h3],'grouped');
    set(bar1(3),'DisplayName','-1');
    set(bar1(2),'DisplayName','0');
    set(bar1(1),'DisplayName','1');
    legend();
    grid on;
    saveas(fig1,"ScoresHistogram.fig");
    close

    % Activation visualisation - does not work well
    %{
act = activations(net,imds,"fc_1");
sz = size(act);
act = reshape(act,[sz(1) sz(2) 1 sz(3)]);
    %}

    % Gradient visualization
    cd(Path_to_data)
    cd ..
    load("Test_sequences.mat")
    Seq = fastaread("Test_sequences.fa");
    Seq = struct2table(Seq);
    OneHot = struct2table(OneHot);
    tb = OneHot(contains(string(OneHot.index),Genes(i).name),:);
    Seq = Seq(contains(string(Seq.Header),Genes(i).name),:);
    gradMap = struct();
    inputsz = net.Layers(1).InputSize;
    gradcamMap = [];
    counter=1;
    for j=1:height(tb)

        I = cell2mat(tb{j,1});
        try
            gradMap(counter).Map = gradCAM(net,I,YPred(j),'ReductionLayer','softmax','FeatureLayer','maxpool_2','ExecutionEnvironment','gpu');
            gradMap(counter).RNALabel = tb.RNA_label(j);
            gradMap(counter).DNALabel = tb.DNA_label(j);
            gradMap(counter).Index = string(tb.index(j));
            gradcamMap(:,:,counter) = I;
            counter = counter+1;
        catch
            fprintf("gradCAM failed on image %d \n",j);
        end
    end
    gradMapctr = struct2table(gradMap);
    I = [];
    RNA_1 = gradMapctr((gradMapctr.RNALabel) == 1,:);
    for k=1:height(RNA_1)
        I(:,:,k) = cell2mat(RNA_1.Map(k));
    end
    SalientMaps = struct();
    SalientMaps(1).Name = "Increased Expression";
    SalientMaps(1).Map = mean(I,3);
    SalientMaps(1).data = I;

    I = [];
    RNA_0 = gradMapctr((gradMapctr.RNALabel) == 0,:);
    for k=1:height(RNA_0)
        I(:,:,k) = cell2mat(RNA_0.Map(k));
    end
    SalientMaps(2).Name = "WT Expression";
    SalientMaps(2).Map = mean(I,3);
    SalientMaps(2).data = I;

    I=[];
    RNA_n1 = gradMapctr((gradMapctr.RNALabel) == -1,:);
    for k=1:height(RNA_n1)
        I(:,:,k) = cell2mat(RNA_n1.Map(k));
    end
    SalientMaps(3).Name = "Decreased Expression";
    SalientMaps(3).Map = mean(I,3);
    SalientMaps(3).data = I;

    SalientMaps(4).Name = "All Expression Data";
    SalientMaps(4).Map = mean(cat(3,SalientMaps(1).Map,SalientMaps(2).Map,SalientMaps(3).Map),3);
    SalientMaps(4).data = gradcamMap;

    % Finding the most common sequence from the sequences used
    commonseq = CommonSequence(Seq);

    PlotSalientMap(SalientMaps(1).Map,hot,commonseq,Genes(i).folder+"/"+Genes(i).name,SalientMaps(1).Name);
    PlotSalientMap(SalientMaps(2).Map,hot,commonseq,Genes(i).folder+"/"+Genes(i).name,SalientMaps(2).Name);
    PlotSalientMap(SalientMaps(3).Map,hot,commonseq,Genes(i).folder+"/"+Genes(i).name,SalientMaps(3).Name);
    PlotSalientMap(SalientMaps(4).Map,hot,commonseq,Genes(i).folder+"/"+Genes(i).name,SalientMaps(4).Name);
    figure();
    plot(max(SalientMaps(1).Map),'LineWidth',2,'Color','r','DisplayName',SalientMaps(1).Name);
    hold on;
    plot(max(SalientMaps(2).Map),'LineWidth',2,'Color','b','DisplayName',SalientMaps(2).Name);
    hold on;
    plot(max(SalientMaps(3).Map),'LineWidth',2,'Color','k','DisplayName',SalientMaps(3).Name);
    hold on;
    plot(max(SalientMaps(4).Map),'LineWidth',2,'Color','m','DisplayName',SalientMaps(4).Name);
    hold on;
    saveas(gcf,"PredictedBindingSites.fig");
    close
    save("SalientMapData.mat",'gradMap','SalientMaps');
end
