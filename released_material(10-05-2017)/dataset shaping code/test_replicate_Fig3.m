% Script that replicates Fig.3 from the paper 
% "A Probabilistic Approach to People-Centric Photo Selection and Sequencing"
% The script demonstrates different ways of selecting 1K out of 11K random
% 6D datapoints. For the purpose of exact replication, these 11K random
% datapoints are loaded from a saved data file. However, you may comment
% the loading of the data and substitute it with new random datapoints.
% The script currently enforces a Uniform target distribution. However, you 
% may uncomment the other options, which include Gaussian or Weibull, or
% you may create your own target distribution.
%--------------------------------------------------------------------------
% CITATION
%
% If you use this code for research puproses please cite the following
% publication:
% Vonikakis, V., Subramanian, R., Arnfred, J., & Winkler, S. (2017). A Probabilistic Approach to People-CentricPhoto Selection and Sequencing. IEEE Transactions in Multimedia. Accepted.





clear all;
close all;



%-----------------------------------------------------------main parameters

K=11000; %total data points
N=1000; %subset of selected data
H=10; %quantization levels (integer)
lamda=0.5; %balance between correlation vs distribution objectives

%-------------------------------------------defining objective distribution
%uncomment one of the following 3 target distributions or create your own

%--uniform distribution
distribution_objective=ones(H,1);
distribution_objective=distribution_objective./sum(distribution_objective);

%--gaussian distribution
% pd = makedist('Normal','mu',H/2,'sigma',1);
% x=((1:H)-0.5);
% distribution_objective = pdf(pd,x);
% distribution_objective=distribution_objective';


%--weibull distribution
% pd = makedist('Weibull','a',5,'b',2);
% x=((1:H)-0.5);
% distribution_objective = pdf(pd,x);
% distribution_objective=distribution_objective';


%--------------------------------------------------------------- input data


%load precomputed data 
load DATA_random_6D;


% ...or uncoment the following section in order to generate new data with
% different distributions


%--generating random points with different distributions for each dimension
% A=[];
% pd = makedist('Normal','mu',0,'sigma',1);
% q = random(pd,K,1);
% q=q-min(q);
% q=q./max(q);
% A(:,1)=q;
% 
% pd = makedist('GeneralizedPareto','k',-0.5,'sigma',1,'theta',0);
% q = random(pd,K,1);
% q=q-min(q);
% q=q./max(q);
% A(:,2)=q;
% 
% pd = makedist('Triangular');
% q = random(pd,K,1);
% q=q-min(q);
% q=q./max(q);
% A(:,3)=q;
% 
% pd = makedist('Uniform');
% q = random(pd,K,1);
% q=q-min(q);
% q=q./max(q);
% A(:,4)=q;
% 
% pd = makedist('Nakagami');
% q = random(pd,K,1);
% q=q-min(q);
% q=q./max(q);
% A(:,5)=q;






M=size(A,2);

%------------------------------------------------ quantizing data into bins

A_quantized=A;
A_quantized=A_quantized.*H;
A_quantized=floor(A_quantized);
A_quantized=A_quantized+1;
A_quantized(A_quantized==H+1)=H;

%------------------------------------- displaying the initial distributions

figure, [S,AX,BigAx,HISTs,HAx]=plotmatrix(A,'r.');
set(S,'Color','b','MarkerSize',1);
set(HISTs,'FaceColor','b');
% set(AX,'XLim',[0 1],'YLim',[0 1]);
title(BigAx,'Original Dataset')
xlabel('Dataset dimensions');
ylabel('Dataset dimensions');

for i=1:M-1
    for j=i+1:M
        axes(AX(i,j));
        h=lsline;
        set(h,'LineWidth',1,'Color','k')
        [Rp,Pp]=corr([A(:,i) A(:,j)],'type','Pearson');
        text(0.01,0.99,[num2str(round_simple(Rp(1,2),2)) ' (' num2str(round_simple(Pp(1,2),2)) ')'],'FontSize',10,'FontWeight','bold');
        
        axes(AX(j,i));
        h=lsline;
        set(h,'LineWidth',1,'Color','k')
        [Rp,Pp]=corr([A(:,j) A(:,i)],'type','Pearson');
        text(0.01,0.99,[num2str(round_simple(Rp(1,2),2)) ' (' num2str(round_simple(Pp(1,2),2)) ')'],'FontSize',10,'FontWeight','bold');
    end
end

%saving in high quality PDF
% print -painters -dpdf -r300 original.pdf


%------------------------------------------------ Running MILP optimization

x  = SHAPE(A,A_quantized,N,H,distribution_objective,lamda);

A_reduced=A(x,:);

%------------------------------------ depicting the resulting distributions

figure, [S,AX,BigAx,HISTs,HAx]=plotmatrix(A_reduced,'r.');
set(S,'Color','r','MarkerSize',1);
set(HISTs,'FaceColor','r');
% set(AX,'XLim',[0 1],'YLim',[0 1]);
title(BigAx,'Reduced Dataset')
xlabel('Dataset dimensions');
ylabel('Dataset dimensions');

for i=1:M-1
    for j=i+1:M
        axes(AX(i,j));
        h=lsline;
        set(h,'LineWidth',1,'Color','k')
        [Rp,Pp]=corr([A_reduced(:,i) A_reduced(:,j)],'type','Pearson');
        text(0.01,0.99,[num2str(round_simple(Rp(1,2),2)) ' (' num2str(round_simple(Pp(1,2),2)) ')'],'FontSize',10,'FontWeight','bold');
        
        axes(AX(j,i));
        h=lsline;
        set(h,'LineWidth',1,'Color','k')
        [Rp,Pp]=corr([A_reduced(:,j) A_reduced(:,i)],'type','Pearson');
        text(0.01,0.99,[num2str(round_simple(Rp(1,2),2)) ' (' num2str(round_simple(Pp(1,2),2)) ')'],'FontSize',10,'FontWeight','bold');
    end
end

%saving in high quality PDF
% print -painters -dpdf -r300 weibull.pdf
