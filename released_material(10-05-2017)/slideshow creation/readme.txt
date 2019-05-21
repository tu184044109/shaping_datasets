Supplementary material for the paper "A Probabilistic Approach to People-Centric Photo Selection and Sequencing"
----------------------------------------------------------------------------------------------------------------

This folder demonstrates the proposed Integer Linear Program (ILP) for slideshow creation and image appeal estimation, using the learnt selection probabilities 
from our crowdsourcing study, as well as Matlab's "intlinprog" solver.


CONTENTS
--------
- Script "test_slideshow_Gallagher.m" demonstrates the results of the proposed image sequencing method 
  on 3 different sub-albums from the Gallagher dataset: 'baby', 'girl' and 'boy'. 
- Script "test_image_selection_Gallagher.m" demonstrates ranking images from these 3 albums according to the 
  predicted probability of selection (image appeal), based on the learnt selection probabilities from our crowdsourcing study. 
- Function "SLIDESHOW.m" creates a sequence of photos, based on pre-learnt image selection 
  probabilities and image features, using Integer Linear Programming (ILP).
- Datafile "Features_Gallagher.mat" contains the pre-learnt image features (13 visual attributes) for the Gallagher dataset.
- Datafile "Filenames_Gallagher.mat" contains the filenames of the 3 different sub-albums from the Gallagher dataset: 'baby', 'girl' and 'boy'.  
- Datafile "P_selection_smoothed.mat" contains the leart selection probabilities from our crowdsourcing study, for 13 visual attributes.
- Datafile "P_selection_smoothedb.mat" contains a slightly different version of the leart selection probabilities (normalized in a different way). 


DEPENDENCIES
------------
- Function "SLIDESHOW.m" requires Matlab's "intlinprog" solver, which is part of the Optimization toolbox. 
- The provided code requires images from the Gallagher dataset. For obvious copyright reasons we cannot release these images.
  You may download them from this link: http://chenlab.ece.cornell.edu/people/Andy/GallagherDataset.html
  Once downloaded, please place ALL the image files inside directory "Photos_Gallagher". After that, you should be able to run all the provided code.


CITATION
--------
If you use this code for research puproses please cite the following publication:
Vonikakis, V., Subramanian, R., Arnfred, J., & Winkler, S. (2017). A Probabilistic Approach to People-CentricPhoto Selection and Sequencing. IEEE Transactions in Multimedia. DOI: 10.1109/TMM.2017.2699859


CONTACT
-------
For anyquestions/suggestions, please contact me at: bbonik@gmail.com





You may run the script 

You may run the script 

