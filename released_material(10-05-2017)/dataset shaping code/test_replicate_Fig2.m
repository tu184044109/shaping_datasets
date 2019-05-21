% Script that replicates Fig.2 from the paper 
% "A Probabilistic Approach to People-Centric Photo Selection and Sequencing"
% The script demonstrates different ways of selecting 20 out of 100 random
% 2D datapoints. For the purpose of exact replication, these 100 random
% datapoints are loaded from a saved data file. However, you may comment
% the loading of the data and substitute it with new random datapoints.
%--------------------------------------------------------------------------
% CITATION
%
% If you use this code for research puproses please cite the following
% publication:
% Vonikakis, V., Subramanian, R., Arnfred, J., & Winkler, S. (2017). A Probabilistic Approach to People-CentricPhoto Selection and Sequencing. IEEE Transactions in Multimedia. Accepted.




clear all;
close all;


%--------------------------------------------------------------- parameters

N=20; %subset of selected data (try to have integers per bin)
H=10; %quantization bins
lamda=0.5; %balance between the 2 objectives: distribution vs correlation

%------------------------------------------ defining objective distribution

%Here we define a Uniform target distribution
distribution_objective=ones(H,1);
distribution_objective=distribution_objective./sum(distribution_objective);

%--------------------------------------------------------------- input data

%loading existing random points for replicating exactly paper's results
load DATA_random_2D;
% A=rand(100,2);%trying new random points (uncomment to try it)

M=size(A,2);%total number of dimensions
K=size(A,1);%total number of data points

%------------------------------------------ quantizing attributes into bins

A_quantized=A;
A_quantized=A_quantized.*H;
A_quantized=floor(A_quantized);
A_quantized=A_quantized+1;
A_quantized(A_quantized==H+1)=H;

%-------------------------- different ways of selecting N out of 100 points

figure

j=-3;
jj=10;

for i=1:6 %(6 different case)

    %positive correlation
    if (i==1)
        xx=[85 99 100 11 48 56 45 20 92 68 96 30 52 86 75 77 47 87 33 5];
        xx=xx';
        x=zeros(100,1);
        x(xx)=1;
        x=logical(x);
        xtitle='positive correlation';
        
    elseif (i==2)%negative correlation
        xx=[69 67 4 76 13 41 3 26 78 8 68 58 30 52 57 35 6 24 89 51];
        xx=xx';
        x=zeros(100,1);
        x(xx)=1;
        x=logical(x);
        xtitle='negative correlation';
        
    elseif (i==3)
        x  = SHAPE(A,A_quantized,N,H,distribution_objective,0);
        xtitle='uniform distribution without correlation minimization';
        
    elseif (i==4)%vertical correlation
        xx=[49 21 85 99 100 80 11 48 84 44 66 72 23 76 16 50 79 67 4 69];
        xx=xx';
        x=zeros(100,1);
        x(xx)=1;
        x=logical(x);
        xtitle='vertical correlation';
        
    elseif (i==5)%horizontal correlation
        xx=[99 85 49 18 21 97 73 40 93 90 82 70 95 22 35 2 94 89 51 14];
        xx=xx';
        x=zeros(100,1);
        x(xx)=1;
        x=logical(x);
        xtitle='horizontal correlation';
        
    else
        x  = SHAPE(A,A_quantized,N,H,distribution_objective,0.5);
        xtitle='PROPOSED: uniform distribution & correlation minimization';
    end
    
    
    %---------------------------------- calculating the resulting distributions
    
    A_reduced=A(x,:);
    
    [Rp,Pp]=corr(A_reduced,'type','Pearson');%calculating resulting correlations
    
    %--------------------------------------------------- depicting scatter data

    
  
    %calculations for ploting in the subimages
    j=j+3;
    if (j>6)
        jj=jj+27;
        j=0;
    end
    k=j+jj;
    
    
    %side distributions
    subplot(6,9,[k-9,k-8]), bar(hist(A_reduced(:,1),((1:H)-0.5)./H));
    set(gca,'xtick',[],'ytick',[]);
    axis tight;
    subplot(6,9,[k+2,k+11]), barh(hist(A_reduced(:,2),((1:H)-0.5)./H));
    set(gca,'xtick',[],'ytick',[]);
    axis tight;
    
    %main scatter plots
    
    %all the data
    ax=A(:,1);
    ay=A(:,2);
    subplot(6,9,[k,k+1,k+9,k+10]), scatter(ax,ay,80,'k','LineWidth',1);
    hold on;
    
    %selected data
    ax=A_reduced(:,1);
    ay=A_reduced(:,2);
    subplot(6,9,[k,k+1,k+9,k+10]), scatter(ax,ay,100,'filled','k','LineWidth',1);
    grid on;
    hold on;
    title({xtitle;['Pearson: rho=' num2str(Rp(1,2)) '(p=' num2str(Pp(1,2)) ')']});

    %LS line
    h=lsline;
    set(h(1),'LineWidth',1,'Color','k')
    set(h(2),'Visible','off')
    
    set(gca,'XLim',[0 1],'YLim',[0 1],'XTick',[0:0.1:1],'YTick',[0:0.1:1]);
    
    hold off;
    
end
