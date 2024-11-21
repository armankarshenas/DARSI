function saliencyMapsGenerator(Path_to_data, Path_to_model)
    % SaliencyMapsGenerator generates saliency maps for models and inputs
    % 
    % Inputs:
    %   Path_to_data - The path to the folder containing the data
    %   Path_to_model - The path to the folder containing the trained models
    % 
    % Written by A. Karshenas -- Nov, 2024
    %----------------------------------------------------
    
    % Add all scripts from the current repository (including subdirectories)
    currentScriptDir = fileparts(mfilename('fullpath'));
    addpath(genpath(currentScriptDir));
    
    Path_to_model = Path_to_model +"/model";
    % Main code
    cd(Path_to_model);
    Genes = dir(pwd);
    
    for i = 5:length(Genes)
        waitbar(i/length(Genes));
        cd(fullfile(Path_to_model, Genes(i).name));
        
        % Load trained network
        net = load(fullfile(Path_to_model, Genes(i).name, strcat(Genes(i).name, "_trained_network.mat")));
        net = net.net;
        
        % Create image datastore
        imds = imageDatastore(fullfile(Path_to_data, "Test", Genes(i).name), 'IncludeSubfolders', true);
        [YPred, scores] = classify(net, imds);

        % Plot scores histogram
        edges = 0:0.1:1;
        h1 = histcounts(scores(:, 1), edges);
        h2 = histcounts(scores(:, 2), edges);
        h3 = histcounts(scores(:, 3), edges);

        fig1 = figure();
        bar1 = bar(edges(1:end-1), [h1; h2; h3], 'grouped');
        set(bar1(3), 'DisplayName', '-1');
        set(bar1(2), 'DisplayName', '0');
        set(bar1(1), 'DisplayName', '1');
        legend();
        grid on;
        saveas(fig1, "ScoresHistogram.fig");
        close;

        % Gradient visualization
        cd(Path_to_data);
        load("Test_sequences.mat");
        Seq = fastaread("Test_sequences.fa");
        Seq = struct2table(Seq);
        OneHot = struct2table(OneHot);
        tb = OneHot(contains(string(OneHot.index), Genes(i).name), :);
        Seq = Seq(contains(string(Seq.Header), Genes(i).name), :);
        clear OneHot;

        gradMap = struct();
        inputsz = net.Layers(1).InputSize;
        gradcamMap = [];
        counter = 1;
        
        for j = 1:height(tb)
            I = cell2mat(tb{j, 1});
            try
                gradMap(counter).Map = gradCAM(net, I, YPred(j), 'ReductionLayer', 'softmax', 'FeatureLayer', 'maxpool_2', 'ExecutionEnvironment', 'cpu');
                gradMap(counter).RNALabel = tb.RNA_label(j);
                gradMap(counter).Index = string(tb.index(j));
                gradcamMap(:, :, counter) = I;
                counter = counter + 1;
            catch
                fprintf("gradCAM failed on image %d \n", j);
            end
        end

        gradMapctr = struct2table(gradMap);
        I = [];
        
        % High expression
        RNA_3 = gradMapctr((gradMapctr.RNALabel) == 3, :);
        for k = 1:height(RNA_3)
            I(:, :, k) = cell2mat(RNA_3.Map(k));
        end
        SalientMaps(1).Name = "High Expression";
        SalientMaps(1).Map = mean(I, 3);
        SalientMaps(1).data = I;

        % Low expression
        I = [];
        RNA_2 = gradMapctr((gradMapctr.RNALabel) == 2, :);
        for k = 1:height(RNA_2)
            I(:, :, k) = cell2mat(RNA_2.Map(k));
        end
        SalientMaps(2).Name = "Low Expression";
        SalientMaps(2).Map = mean(I, 3);
        SalientMaps(2).data = I;

        % Zero expression
        I = [];
        RNA_1 = gradMapctr((gradMapctr.RNALabel) == 1, :);
        for k = 1:height(RNA_1)
            I(:, :, k) = cell2mat(RNA_1.Map(k));
        end
        SalientMaps(3).Name = "No Expression";
        SalientMaps(3).Map = mean(I, 3);
        SalientMaps(3).data = I;

        % Finding the most common sequence from the sequences used
        commonseq = CommonSequence(Seq);
        xlabel_name = cellstr(commonseq(:));
        ylabel_name = cellstr(["A", "T", "C", "G"]);
        
        % Generate and save saliency maps
        cd(fullfile(Path_to_model, Genes(i).name));
        figure();
        
        subplot(3, 1, 1);
        imagesc(SalientMaps(1).Map);
        colormap("jet");
        colorbar;
        title("Saliency Map for Sequences with High Expression");
        xticks(1:1:160);  
        xticklabels(xlabel_name); 
        xtickangle(0);
        yticklabels(ylabel_name);
        hold on;
        
        subplot(3, 1, 2);
        imagesc(SalientMaps(2).Map);
        colormap("jet");
        colorbar;
        title("Saliency Map for Sequences with Low Expression");
        xticks(1:1:160);  
        xticklabels(xlabel_name); 
        xtickangle(0);
        yticklabels(ylabel_name);
        hold on;
        
        subplot(3, 1, 3);
        imagesc(SalientMaps(3).Map);
        colormap("jet");
        colorbar;
        title("Saliency Map for Sequences with Zero Expression");
        xticks(1:1:160);  
        xticklabels(xlabel_name); 
        xtickangle(0);
        yticklabels(ylabel_name);
        hold on;
        
        saveas(gcf, "SaliencyMap.fig");
        saveas(gcf, "SaliencyMap.eps", "epsc");
        saveas(gcf, "SaliencyMap.png");
        close;
        
        save("SalientMapData.mat", 'gradMap', 'SalientMaps');

        % Final saliency map
        Final_saliency_map = cat(3, SalientMaps(1).Map, SalientMaps(2).Map, SalientMaps(3).Map);
        Final_saliency_map = mean(Final_saliency_map, 3);
        
        figure();
        imagesc(Final_saliency_map);
        colormap("jet");
        colorbar;
        title("Saliency Map for Sequences with Zero Expression");
        xticks(1:1:160);  
        yticks(1:1:4);
        xticklabels(xlabel_name); 
        xtickangle(0);
        yticklabels(ylabel_name);
        saveas(gcf, "FinalSaliencyMap.fig");
        saveas(gcf, "FinalSaliencyMap.eps", "epsc");
        saveas(gcf, "FinalSaliencyMap.png");
        close;

        save("FinalSaliencyMap.mat", 'Final_saliency_map');
    end
end
