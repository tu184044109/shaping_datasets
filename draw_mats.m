close all;
clear;

sampled_all = load('sampled_data.mat');
sampled_all = sampled_all.DATA_reduced;
sampled_gt = load('sampled_data_ge_2e6.mat');
sampled_gt = sampled_gt.DATA_reduced;

sampled_le = load('sampled_data_lt_2e6.mat');
sampled_le = sampled_le.DATA_reduced;

yt_ugc = load('yt_ugc.mat');
yt_ugc = yt_ugc.yt_ugc;

features = sampled_all(1,:);

sampled_split = [cell2mat(sampled_gt(2:end,:));cell2mat(sampled_le(2:end,:))];
sampled_all = cell2mat(sampled_all(2:end,:));

maxvec = max([max(sampled_split);max(sampled_split)]);
minvec = min([min(sampled_split);min(sampled_split)]);
sampled_split = (sampled_split-minvec)./(maxvec-minvec);
sampled_all = (sampled_all-minvec)./(maxvec-minvec);

nbins = 128;
for i = 1:length(features)
    f1 = figure;
    edges = linspace(0,1, nbins);
    hold on;
    [H, edges] = histcounts(sampled_split(:,i),edges,'Normalization','probability');
    t = edges(2:end) - (edge(2)-edge(1))/2;
    plot(t,H, '-', 'LineWidth', 2, 'Color', 'r');
    hold on;
    
    edges = linspace(0,1, nbins);
    [H, edges] = histcounts(sampled_all(:,i),edges,'Normalization','probability');
    t = edges(2:end) - (edge(2)-edge(1))/2;
    plot(t,H, '-', 'LineWidth', 2, 'Color', 'b');
    hold on;
    
    edges = linspace(0,1, nbins);
    [H, edges] = histcounts(yt_ugc(:,i),edges,'Normalization','probability');
    t = edges(2:end) - (edge(2)-edge(1))/2;
    plot(t,H, '-', 'LineWidth', 2, 'Color', 'k');
    
    title(['Histrogram of ',features{i}], 'Interpreter', 'latex');
    xlabel('Value', 'Interpreter', 'latex');
    ylabel('Probability', 'Interpreter', 'latex');
    leg = legend('Split_sample', 'All_sample', 'yt_ugc');
    set(leg, 'Interpreter', 'latex');
    grid on; box on; 
    

    
end