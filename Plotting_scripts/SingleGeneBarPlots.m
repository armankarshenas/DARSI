function [] = SingleGeneBarPlots(ACC,Path_to_save)
%% Plotting bar charts for single gene activity accuracy 
fig1 = figure();
subplot(2,1,1);
hold on;
tb = struct2table(ACC);
acc = (tb.acc);
name = string(tb.gene);
label = tb.datapt;
[sorted_acc,indx] = sort(acc);
[sorted_dtp,indxdtp] = sort(label);
sorted_name = [];
sorted_label =[];
for i=1:length(acc)
    sorted_name = [sorted_name name(indx(i))];
    sorted_label = [sorted_label name(indxdtp(i))];
end
sorted_name = categorical(sorted_name);
sorted_name = reordercats(sorted_name,indx);
b = bar(sorted_name,sorted_acc,'FaceColor','red','FaceAlpha',0.4,'EdgeColor','black');
hold on
grid on
subplot(2,1,2);
sorted_label = categorical(sorted_label);
sorted_label = reordercats(sorted_label,indxdtp);
scatter(sorted_label,sorted_dtp,'*','r');
xlabel("Genes",'FontSize',15,'Interpreter','latex');
ylabel("Number of data points",'FontSize',15,'Interpreter','latex');
grid on;
cd(Path_to_save)
saveas(fig1,"ACCBarChart.fig");
end