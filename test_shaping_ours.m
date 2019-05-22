% This script replicates the balancing results for the GALLAGHER dataset 
% depicted in the paper 
% V. Vonikakis, R. Subramanian, S. Winkler. (2016). "Shaping Datasets: 
% Optimal Data Selection for Specific Target Distributions". 
% Proc. ICIP2016, Phoenix, USA, Sept. 25-28.
% 
% 6 different image attributes are used: timestamp, colorfulness, sharpness, 
% exposure, contrast and in/out. The original data are quantized before the 
% MILP optimization. A subset of N different images is selected out of the 
% total K images of the dataset.
%
% The original images of the Gallagher dataset can be found in:
% http://chenlab.ece.cornell.edu/people/Andy/GallagherDataset.html



clear;
close all;
opengl('save','software') % use software renderer to avoid crash
% set(0,'defaulttextinterpreter','latex')
% 19:height, 20:width, 21:pixels, 22:ratio

% selected colns of several features
% need to modify
sel = [2, 4, 6, 8, 10, 12, 21, 22]; 

T = readtable('fl_ia_vm_ugc_output_stats.csv');  % input distribution
T_ugc = readtable('yt_ugc_output_stats.csv');  % target distribution

DATA = table2cell(T);
DATA = DATA(:,sel);  % selected only features in `sel'



DATA = [T.Properties.VariableNames(sel); DATA]; % mapping to their defined data structure
% load GALLAGHER;%load data


%--------------------------------------------------------------loading data

A=cell2mat(DATA(2:end,:));%keeping only the raw data
nans = sum(isnan(A),2) > 0; % remove nan~ in A
A = A(~nans,:);

T(nans, :) = [];  % remove nans  in T
% idx = A(:,7)>1080 | A(:,8)>1920;
% A = A(idx,:);
% A = (A-min(A))./(max(A)-min(A));

legend_plot=T.Properties.VariableNames(sel);% keeping the labels for displaying later

special_chars = '[]{}()=''.().....,;:%%{%}!@_^'; % add escape character
for n = 1:length(legend_plot)
    out_str = '';
    for l = legend_plot{n}
        if (~isempty(find(special_chars == l)))
            out_str = [out_str, '\', l];
        else
            out_str = [out_str, l];
        end
    end
    legend_plot{n} = out_str;
end



N=2000; %total number of selected observations to be included in the subset
H=16; %number of quantization bins in each dimension (attribute)
M=size(A,2);%total number of dimensions
K=size(A,1);%total number of available observations
xbins = 1:H;

%------------------------------------------ defining objective distribution

%please uncomment the target distribution you would like the final subset
%to have.
yt_ugc = table2cell(T_ugc);
yt_ugc = yt_ugc(:,sel);

% idx = find([yt_ugc{:,7}]>1080 | [yt_ugc{:,8}]>1920);
% yt_ugc = cell2mat(yt_ugc(idx,:));
yt_ugc = cell2mat(yt_ugc);

% exclude rows containing nan
nans = sum(isnan(yt_ugc),2) > 0; 
yt_ugc = yt_ugc(~nans,:);

% Jointly normalization 
maxvec = max([max(A);max(yt_ugc)]);
minvec = min([min(A);min(yt_ugc)]);
A = (A-minvec)./(maxvec-minvec);
yt_ugc = (yt_ugc-minvec)./(maxvec-minvec);
distribution_objective = zeros(H,M);
edges = linspace(0,1,H+1);
for m=1:M
distribution_objective(:,m) = histcounts(yt_ugc(:,m), edges, 'Normalization', 'probability')';
end

%uniform distribution
% distribution_objective=ones(H,1); 
 
%triangular distribution
% distribution_objective=[2 ; 4 ; 6; 8; 10; 8; 6;4;2]; 

%linearly-descending distribution
% distribution_objective=[10 ; 9 ; 8; 7; 6; 5; 4;3;2]; 
 

%normalizing distribution

% distribution_objective = distribution_objective .* ones(size(distribution_objective)).*10e-5;
%distribution_objective=distribution_objective./sum(distribution_objective, 'omitnan');



%------------------------------------------ quantizing attributes into bins

A_quantized=A;
A_quantized=A_quantized.*H;
A_quantized=floor(A_quantized);
A_quantized=A_quantized+1;
A_quantized(A_quantized==H+1)=H;


%------------------------------------- displaying the initial distributions


% distribution_original=(hist(A_quantized(:,1:M),xbins))';
distribution_original = zeros(H,M);
for m=1:M
distribution_original(:,m) = histcounts(A(:,m), edges)';
end
distribution_original = distribution_original';

% set draw ylimit
ymax=max(distribution_original');

f1 = figure('Name', 'Sampling results 1', 'Position', [0 0 1600 1400]); % set figure
f2 = figure('Name', 'Sampling results 2', 'Position', [0 0 1600 1400]); % set figure

for i=1:M
    if i <= floor(M/2) % split display
        figure(f1)
        subplot(2,M/2,i) % split display
    else
        figure(f2)
        subplot(2,M/2,i-M/2)
    end
    bar(distribution_original(i,:),'FaceColor','w','EdgeColor','k', 'LineWidth', 1.5)
    
    title(['Orig. Hist. of ' legend_plot{i}], 'FontSize', 16, 'Interpreter', 'latex');
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','w','EdgeColor','k', 'LineWidth', 1.5)
    ylim([0 ymax(i)]);%same scale on Y axis
    hold on;
    %drawing the distribution objective on the original distributions to
    %show whether there is availability of data on each bin
    for n=1:H  %across all quantization bins
        % here modified 
        q=ceil(distribution_objective(n,i)*N);%required number of data in this bin
        line([n-0.5 n+0.5],[q q],'Color','r', 'LineWidth', 3);%new setlevel
    end
    leg1 = legend('combined_8k', 'yt_ugc');
    set(leg1, 'Interpreter', 'latex');
    set(leg1, 'FontSize', 14);
    hold off;
    
end


%------------------------------------------------ Running MILP optimization


%getting the indexes of the observations that will be used in the subset
x  = SHAPE_DATASET(A_quantized,N,H,distribution_objective); 


%--------------------------------------- Displaying the final distributions

%getting the final subset based on the indexes provided by the optimizaiton
A_reduced=A_quantized(x,:);

%getting the list of selected images out of the original data
DATA_reduced=DATA([false ;x],:);
DATA_reduced=[DATA(1,:) ; DATA_reduced];

%estimating the distribution of the subset
distribution_final=(hist(A_reduced(:,1:M),xbins))';
%ymax=max(distribution_final');


%disaplying the new distributions of the subset
for i=1:M
    if i <= floor(M/2) % split display
        figure(f1)
        subplot(2,M/2,i+M/2) % split display
    else
        figure(f2)
        subplot(2,M/2,i)
    end
    bar(distribution_final(i,:), 'FaceColor','w','EdgeColor','k', 'LineWidth', 1.5)
    title(['Subset Hist. of ' legend_plot{i}], 'FontSize', 16, 'Interpreter', 'latex');
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','w','EdgeColor','k', 'LineWidth', 1.5)
    ylim([0 ymax(i)]);%same scale on Y axis
    hold on;
    
    %drawing the distribution objective on the original distributions to
    %show whether there is availability of data on each bin
    for n=1:H  %across all quantization bins
        q=ceil(distribution_objective(n,i)*N);%required number of data in this bin
        line([n-0.5 n+0.5],[q q],'Color','r', 'LineWidth', 3);%new setlevel
    end

    leg2 = legend('sampled_2k', 'yt_ugc');
    set(leg2, 'Interpreter', 'latex');
    set(leg2, 'FontSize', 14);
    
    hold off;
    
end

% print output
set(f1,'Units','Inches');
pos = get(f1, 'Position');
set(f1,'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3),pos(4)]);
print(f1,'results1.pdf','-dpdf','-r0'); 

set(f2,'Units','Inches');
pos = get(f2, 'Position');
set(f2,'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3),pos(4)]);
print(f2,'results2.pdf','-dpdf','-r0');   

