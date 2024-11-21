% SaliencyMaps generates saliency maps for models and inputs

% Written by A. Karshenas -- Feb 22, 2024
%----------------------------------------------------

clear
clc
close all
%% Specifications
addpath(genpath("~/Desktop/DARSI/Scripts"));
Path_to_data = "~/Desktop/DARSI/imgs";
Path_to_model = "~/Desktop/DARSI/new_run_plots/model";
%% Main code
cd(Path_to_model)
Genes = dir(pwd);
for i=7:length(Genes)
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
    clear OneHot
    gradMap = struct();
    inputsz = net.Layers(1).InputSize;
    gradcamMap = [];
    counter=1;
    for j=1:height(tb)

        I = cell2mat(tb{j,1});
        try
            gradMap(counter).Map = gradCAM(net,I,YPred(j),'ReductionLayer','softmax','FeatureLayer','maxpool_2','ExecutionEnvironment','cpu');
            gradMap(counter).RNALabel = tb.RNA_label(j);
            gradMap(counter).Index = string(tb.index(j));
            gradcamMap(:,:,counter) = I;
            counter = counter+1;
        catch
            fprintf("gradCAM failed on image %d \n",j);
        end
    end
    gradMapctr = struct2table(gradMap);
    I = [];
    RNA_3 = gradMapctr((gradMapctr.RNALabel) == 3,:);
    for k=1:height(RNA_3)
        I(:,:,k) = cell2mat(RNA_3.Map(k));
    end
    SalientMaps = struct();
    SalientMaps(1).Name = "High Expression";
    SalientMaps(1).Map = mean(I,3);
    SalientMaps(1).data = I;

    I = [];
    RNA_2 = gradMapctr((gradMapctr.RNALabel) == 2,:);
    for k=1:height(RNA_2)
        I(:,:,k) = cell2mat(RNA_2.Map(k));
    end
    SalientMaps(2).Name = "Low Expression";
    SalientMaps(2).Map = mean(I,3);
    SalientMaps(2).data = I;

    I=[];
    RNA_1 = gradMapctr((gradMapctr.RNALabel) == 1,:);
    for k=1:height(RNA_1)
        I(:,:,k) = cell2mat(RNA_1.Map(k));
    end
    SalientMaps(3).Name = "No Expression";
    SalientMaps(3).Map = mean(I,3);
    SalientMaps(3).data = I;


    % Finding the most common sequence from the sequences used
    commonseq = CommonSequence(Seq);
    xlabel_name = cellstr(commonseq(:));
    ylabel_name = cellstr(["A","T","C","G"]);
    
    cd(Path_to_model+"/"+Genes(i).name);
    
    figure();
    subplot(3,1,1)
    imagesc(SalientMaps(1).Map)
    colormap("jet")
    colorbar;
    title("Saliency Map for Sequences with High Expression")
    xticks(1:1:160);  
    xticklabels(xlabel_name); 
    xtickangle(0);
    yticklabels(ylabel_name)
    hold on;
    subplot(3,1,2)
    imagesc(SalientMaps(2).Map);
    colormap("jet")
    colorbar;
    title("Saliency Map for Sequences with Low Expression")
    xticks(1:1:160);  
    xticklabels(xlabel_name); 
    xtickangle(0);
    yticklabels(ylabel_name)
    hold on;
    
    subplot(3,1,3)
    imagesc(SalientMaps(3).Map);
    colormap("jet")
    colorbar;
    title("Saliency Map for Sequences with Zero Expression")
    xticks(1:1:160);  
    xticklabels(xlabel_name); 
    xtickangle(0);
    yticklabels(ylabel_name)
    hold on;
    
    saveas(gcf,"SaliencyMap.fig");
    saveas(gcf,"SaliencyMap.eps","epsc")
    saveas(gcf,"SaliencyMap.png")
    close

    save("SalientMapData.mat",'gradMap','SalientMaps');

    Final_saliency_map = cat(3, SalientMaps(1).Map, SalientMaps(2).Map, SalientMaps(3).Map);
    Final_saliency_map = mean(Final_saliency_map,3);
    figure()
    imagesc(Final_saliency_map)
    colormap("jet")
    colorbar;
    title("Saliency Map for Sequences with Zero Expression")
    xticks(1:1:160);  
    yticks(1:1:4)
    xticklabels(xlabel_name); 
    xtickangle(0);
    yticklabels(ylabel_name)
    saveas(gcf,"FinalSaliencyMap.fig")
    saveas(gcf,"FinalSaliencyMap.eps","epsc")
    saveas(gcf,"FinalSaliencyMap.png")
    close 
    
    save("FinalSaliencyMap.mat",'Final_saliency_map')
end
