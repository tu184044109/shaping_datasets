function [ slideshow_indexes ] = SLIDESHOW( FEATURES, P_sel_attrANDtempsegm, N)

% SLIDESHOW:
% Create a sequence of photos, based on pre-learnt image selection 
% probabilities and image features, using Integer Linear Programming (ILP).
% The code uses Matlab's "intlinprog" solver, which is part of the Optimization toolbox. 
%   
% INPUTS:
% --------
% FEATURES: matrix with precaluclated and quantized image features. Rows 
%           correspond to different images. Columns correspond to different 
%           image attributes. Features should be quantized to integers.
% P_sel_attrANDtempsegm: Conditional probability of an image being selected, 
%           given its attributes and the temporal segment of a sequence. 
%           1st dimension corresponds to total number of attribute quantizations
%           2nd dimension corresponds to total number of temporal segments
%           3rd dimension corresponds to total number of image attributes
% N: total number of selected images, out of the total existing ones 
%    (the total rows of FEATURES matrix)
%    
% OUTPUTS
% -------
% slideshow: the indexes (corresponding to rows in the FEATURES matrix) 
%            of the N selected images for the slideshow, starting from 1st
%            to last.
%
%--------------------------------------------------------------------------
% CITATION
%
% If you use this code for research puproses please cite the following
% publication:
% Vonikakis, V., Subramanian, R., Arnfred, J., & Winkler, S. (2017). A Probabilistic Approach to People-CentricPhoto Selection and Sequencing. IEEE Transactions in Multimedia. DOI: 10.1109/TMM.2017.2699859








K=size(FEATURES,1);%total available photos to choose from
total_temporal_bins=size(P_sel_attrANDtempsegm,2);



%-----------------------------filling the probability matrix for each image

E=zeros(N,size(FEATURES,1));%matrix with the probability scores

for t=1:N %within all slideshow images
    
    %quantization function assigning images to one of the slideshow's temporal segments
    bin_time=(floor(((t-1)*total_temporal_bins)/N))+1;%temporal bin that the current image belongs to (bin_time)
    
    for i=1:K %within all available images
        
        e=1;%initial probability score for the image
        
        for j=1:size(FEATURES,2)-2 %within all the attributes (skipping bin_time and eye_openness)
            
            bin_attribute=FEATURES(i,j);
            
            %calculating this image's probability score GIVEN its bin_time and bin_attribute
            e=e*P_sel_attrANDtempsegm(bin_attribute,bin_time,j);%the probability score of each image is the product of its probabilities
            
        end
        
        E(t,i)=e;%filling the matrix of probability scores for each image at each position
        
    end
    
end



%------------------------------------------Integer Linear Programming - ILP

%objective function
c=reshape(E,[1,numel(E)]);%vectorizing E

%1st constraint: total number of selected images should be N
A=[ones(1,size(c,2));-ones(1,size(c,2))];
b=[N;-N];


%2nd constraint: strictly 1 image per position
for i=1:N
    
    a=zeros(size(E,1),size(E,2));
    a(i,:)=1;
    a=reshape(a,[1,numel(a)]);
    
    A=[A;a;-a]; b=[b;1;-1];
    
end


%3rd constraint: up to 1 selection for each image
index=zeros(size(E,1),size(E,2));
for j=1:K
    
    a=zeros(size(E,1),size(E,2));
    a(:,j)=1;
    a=reshape(a,[1,numel(a)]);
    
    A=[A;a]; b=[b;1];%an image should be used 1 bin_time at the most
    
    index(:,j)=j;
    
end

index=reshape(index,[numel(index),1]);

%range and type of variables for ILP (we need binary)
lb=zeros(1,size(A,2));%lower bound=0
ub=ones(1,size(A,2));%upper bound=1
intcon=[1:size(A,2)];%force all integers

X=intlinprog(-c,intcon,A,b,[],[],lb,ub);%ILP optimization


%-----------------------------------------------reading optimization result

q=index.*X;
q=reshape(q,size(E,1),size(E,2));

[s(:,1),s(:,2)] = find(q);
s=sortrows(s,1);
slideshow_indexes=num2cell(s);



end

