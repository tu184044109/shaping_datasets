% This script demonstrates the use of the learnt selection probabilities on
% the Gallagher dataset, for creating appealing sequences of images (slideshows). 
% Please download the Gallagher dataset from this website
% http://chenlab.ece.cornell.edu/people/Andy/GallagherDataset.html
% and place all the images in the 'Photos_Gallagher' folder. 
% Then you have to select one of the 3 album themes: baby, girl, or boy. These
% are subsets of the whole dataset, where the particular theme hero appears
% in the images. Finally, you have to select the number of images N you would
% like the slideshow to contain. The script will run an ILP method to find
% the optimal selection of images for each position of the slideshow, based
% on the learn selection probabilities and the current pool of images from
% the particular album. The ILP method is implemented in the SLIDESHOW.m script
% which is called from here. The script also depicts a random sequence of 
% images for comparison with the proposed one. Note that the script does
% not include any handling for the near duplicates. As such, depending on 
% the number of images you would like to depict, some of them may look quite
% similar. Post processing methods for near duplicates could be used to filter
% out these cases. 
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
% load P_selection_smoothedb %the learned probability distributions (globally normalized before Bayes)
load Filenames_Gallagher;%album filenames from the Gallagher dataset

Din=['Photos_Gallagher' filesep]; %where to get the images from


%--------------------------------------------------------------- Parameters

N=10;%total images that will be included in the slideshow

%---Selecting between 3 different Albums from the Gallagher dataset (please
%uncomment one of the 3 following)

% album='baby';
album='girl';
% album='boy';


%-------------------------------------------------------- Preliminary stuff


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



%multiplying by 100 for numerical stability of the optimization later
P_selected_attrANDtempsegm=P_selected_attrANDtempsegm.*100;



%--------------------------------------------------------------------------
%-----------------------------------------------creating a random slideshow
%--------------------------------------------------------------------------


figure

Ypos=0.6;
positionVector = [0, Ypos+0.25, 0.3, 0.1];
subplot('Position',positionVector,'Visible','off'), text(0,0,'Random slideshow');

K=size(FEATURES,1);%total available photos to choose from
x=[1:K];


Xpos=0;
step=1/N;
for i=1:N
    
    random_image = randi([1 size(x,2)],1,1);
    im=imread([Din FILENAMES{x(random_image),1}]);
    x(random_image)=[];%deleting the selected image so it will not be selected again
    
    if (size(im,1)>size(im,2))
        positionVector = [Xpos, Ypos-0.01, step, step*2];
    else
        positionVector = [Xpos, Ypos, step, step*1.6];
    end
    
    subplot('Position',positionVector), imshow(im);
    
    Xpos=Xpos+step;
    
end




%--------------------------------------------------------------------------
%----creating a slideshow with the smoothed selection probabilities (Algo2)
%--------------------------------------------------------------------------


slideshow=SLIDESHOW(FEATURES,P_selected_attrANDtempsegm,N);%calling the ILP-based function


% ploting the slideshow (Algo2)

Ypos=0.2;
positionVector = [0, Ypos+0.25, 1, 0.1];
subplot('Position',positionVector,'Visible','off'), text(0,0,'Proposed slideshow');
Xpos=0;
step=1/N;
for i=1:size(slideshow,1)
    
    slideshow{i,3}=FILENAMES{slideshow{i,2},1};
    im=imread([Din FILENAMES{slideshow{i,2},1}]);
    
    if (size(im,1)>size(im,2))
        positionVector = [Xpos, Ypos-0.01, step, step*2];
    else
        positionVector = [Xpos, Ypos, step, step*1.6];
    end
    
    subplot('Position',positionVector), imshow(im);
    
    Xpos=Xpos+step;
    
end








