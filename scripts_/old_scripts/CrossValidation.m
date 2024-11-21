function [] = CrossValidation(ACC,Path_to_save)
tb = struct2table(ACC);
fig = figure();
subplot(3,1,1);
kernel_sz = 3:1:20;
best_acc = zeros(1,length(ACC));
mean_acc = zeros(1,length(ACC));
names = string(tb.gene);

for i=1:length(ACC)
    plot(kernel_sz,ACC(i).acc,'DisplayName',ACC(i).gene);
    hold on;
    best_acc(i) = max(ACC(i).acc);
    mean_acc(i) = mean(ACC(i).acc);

end
xlabel("Motif Size (bp)",'FontSize',14,'Interpreter','latex');
ylabel("Classification accuracy",'FontSize',14,'Interpreter','latex');
grid on;
[sorted_best_acc,indxbst] = sort(best_acc);
[sorted_mean_acc,indxmean] = sort(mean_acc);
sorted_name_best = [];
sorted_name_mean = [];
for i=1:length(ACC)
    sorted_name_best = [sorted_name_best names(indxbst(i))];
    sorted_name_mean = [sorted_name_mean names(indxmean(i))];
end

sorted_name_best = categorical(sorted_name_best);
sorted_name_mean = categorical(sorted_name_mean);

sorted_name_best = reordercats(sorted_name_best,indxbst);
sorted_name_mean = reordercats(sorted_name_mean,indxmean);

subplot(3,1,2)
scatter(sorted_name_best,sorted_best_acc);
xlabel("Genes",'FontSize',14,'Interpreter','latex');
ylabel("Best classification accuracy",'FontSize',14,'Interpreter','latex');
grid on;
mean_best = mean(best_acc);
hold on
yline(mean_best)

subplot(3,1,3);
scatter(sorted_name_mean,sorted_mean_acc);
xlabel("Genes",'FontSize',14,'Interpreter','latex');
ylabel("Mean classification accuracy",'FontSize',14,'Interpreter','latex');
grid on;
mean_mean = mean(mean_acc);
hold on
yline(mean_mean);

cd(Path_to_save)
saveas(gca,"CrossValidation.fig")
end