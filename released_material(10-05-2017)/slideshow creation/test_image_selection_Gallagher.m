% This script demonstrates the use of the learnt selection probabilities on
% the Gallagher dataset, for finding the most appealing images (highest 
% probability of selection). Please download the dataset from this website
% http://chenlab.ece.cornell.edu/people/Andy/GallagherDataset.html
% and place all the images in the 'Photos_Gallagher' folder. 
% Then you have to select one of the 3 album themes: baby, girl, or boy. These
% are subsets of the whole dataset, where the particular theme hero appears
% in the images. Finally, you have to select the number of images N you would
% like to rank according to their selection probability. The script will 
% depict the top N images with the highest probability of selection, based on
% their visual attributes, and the lowest N images with the lower probability 
% of selection. 
%--------------------------------------------------------------------------
% CITATION
%
% If you use this code for research puproses please cite the following
% publication:
% Vonikakis, V., Subramanian, R., Arnfred, J., & Winkler, S. (2017). A Probabilistic Approach to People-CentricPhoto Selection and Sequencing. IEEE Transactions in Multimedia. Accepted.






clear all;
close all;

load Features_Gallagher;%the precalculated and quantized image features
load P_selection_smoothed %the learned probability distributions (locally normalized before Bayes)
load Filenames_Gallagher;%album filenames from the Gallagher dataset

Din=['Photos_Gallagher' filesep]; %where to get the images from


%--------------------------------------------------------------- Parameters

N=10;%total number of selected images

%---Selecting between 3 different Albums from the Gallagher dataset (please
%uncomment one of the 3 following)

album='baby';
% album='girl';
% album='boy';

%--------------------------------------------------------------------------
%-------------------------------------------------------- Preliminary stuff
%--------------------------------------------------------------------------

%selecting only the images of the selected album out of the whole dataset

if (strcmp(album,'baby'))
    indx=ismember(FILENAMES(:,1),filenames_baby);
    indx=1-indx; indx=logical(indx);
    FEATURES(indx,:)=[];
    FILENAMES(indx,:)=[];
elseif (strcmp(album,'girl'))
    indx=ismember(FILENAMES(:,1),filenames_girl);
    indx=1-indx; indx=logical(indx);
    FEATURES(indx,:)=[];
    FILENAMES(indx,:)=[];
elseif (strcmp(album,'boy'))
    indx=ismember(FILENAMES(:,1),filenames_boy);
    indx=1-indx; indx=logical(indx);
    FEATURES(indx,:)=[];
    FILENAMES(indx,:)=[];
end


%discarding images with NaN facial features (no valid faces detected)
x=isnan(FEATURES(:,1));
FEATURES(x,:)=[];
FILENAMES=FILENAMES(~x,1);%storing the filenames for later
K=size(FEATURES,1);%total available photos to choose from



%multiplying by 100 for numerical stability of the optimization later
P_selected_attrANDtempsegm=P_selected_attrANDtempsegm.*100;




%--------------------------------------------------------------------------
%-----------------------------------------------------------marginalization
%--------------------------------------------------------------------------



Psel_baseline=10/80;%baseline probability, because we found that workers always prefer 10 images irrelevant of album lenght

P_marginalized=sum(P_selected_attrANDtempsegm,2);%sum across time
P_marginalized=squeeze(P_marginalized);
P_marginalized=P_marginalized.*Psel_baseline;



%--------------------------------------------------------------------------
%-----------------------ranking images according to selection probabilities
%--------------------------------------------------------------------------

for i=1:K %within all available images
    
    e=1;%initial probability score for the image
    
    for j=1:size(FEATURES,2)-2 %within all the attributes (skipping bin_time and eye_openness)
        
        bin_attribute=FEATURES(i,j);
        
        %calculating this image's probability score GIVEN its attribute
        e=e*P_marginalized(bin_attribute,j);%the probability score of each image is the product of its attribute probabilities
        
    end
    
    E(i,1)=e;%filling the matrix of probability scores for each image at each position
    
end


%sorting from highest to lowest

[Esort indx]=sort(E,'descend');
FILENAMES_sort=FILENAMES(indx);



%--------------------------------------------------------------------------
%---------------------------------------------depicting top/bottom N images
%--------------------------------------------------------------------------

figure

Ypos=0.6;
positionVector = [0, Ypos+0.25, 0.3, 0.1];
subplot('Position',positionVector,'Visible','off'), text(0,0,['Top ' num2str(N) ' images with the highest selection probability']);

 
Xpos=0;
step=1/N;
for i=1:N
    
    im=imread([Din FILENAMES_sort{i,1}]);
    
    if (size(im,1)>size(im,2))
        positionVector = [Xpos, Ypos-0.01, step, step*2];
    else
        positionVector = [Xpos, Ypos, step, step*1.6];
    end
    
    subplot('Position',positionVector), imshow(im);
    
    Xpos=Xpos+step;
    
end





Ypos=0.2;
positionVector = [0, Ypos+0.25, 1, 0.1];
subplot('Position',positionVector,'Visible','off'), text(0,0,['Bottom ' num2str(N) ' images with the lowest selection probability']);
Xpos=0;
step=1/N;
for i=1:N
    
    im=imread([Din FILENAMES_sort{K-i+1,1}]);
    
    if (size(im,1)>size(im,2))
        positionVector = [Xpos, Ypos-0.01, step, step*2];
    else
        positionVector = [Xpos, Ypos, step, step*1.6];
    end
    
    subplot('Position',positionVector), imshow(im);
    
    Xpos=Xpos+step;
    
end



